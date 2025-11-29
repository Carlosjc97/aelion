import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/components/edaptia_card.dart';
import 'package:edaptia/core/design_system/typography.dart';
import 'package:edaptia/features/assessment/assessment_results_screen.dart';
import 'package:edaptia/features/lesson/lesson_router.dart';
import 'package:edaptia/features/paywall/paywall_helper.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/providers/streak_provider.dart';
import 'package:edaptia/services/adaptive_module_cache.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:edaptia/services/course/models.dart';
import 'package:edaptia/services/entitlements_service.dart';
import 'package:edaptia/services/local_quiz_cache.dart';
import 'package:edaptia/services/quiz_attempt_storage.dart';
import 'package:edaptia/services/topic_band_cache.dart';
import 'package:edaptia/widgets/skeleton.dart';

typedef PlacementQuizLoader = Future<PlacementQuizStartResponse> Function({
  required String topic,
  required String language,
});

typedef PlacementQuizGrader = Future<PlacementQuizGradeResponse> Function({
  required String quizId,
  required List<PlacementQuizAnswer> answers,
});

class QuizScreenArgs {
  const QuizScreenArgs({
    required this.topic,
    required this.language,
    this.autoOpenOutline = true,
    this.outlineGenerator,
  });

  final String topic;
  final String language;
  final bool autoOpenOutline;
  final OutlineFetcher? outlineGenerator;
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.topic,
    required this.language,
    this.autoOpenOutline = true,
    this.startLoader,
    this.grader,
    this.outlineGenerator,
    this.firebaseAuth,
  });

  static const routeName = '/quiz/start';

  final String topic;
  final String language;
  final bool autoOpenOutline;
  final PlacementQuizLoader? startLoader;
  final PlacementQuizGrader? grader;
  final OutlineFetcher? outlineGenerator;
  final FirebaseAuth? firebaseAuth;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

enum _QuizStage { intro, loading, questions, result, error }

class _QuizScreenState extends State<QuizScreen> {
  final PageController _controller = PageController();

  _QuizStage _stage = _QuizStage.intro;
  PlacementQuizStartResponse? _session;
  PlacementQuizGradeResponse? _grade;
  List<int?> _answers = const [];
  int _currentIndex = 0;
  bool _submitting = false;
  String? _error;
  // ignore: unused_field
  List<String> _detectedGaps = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _beginQuiz() async {
    setState(() {
      _stage = _QuizStage.loading;
      _error = null;
      _grade = null;
      _answers = const [];
      _currentIndex = 0;
    });

    final userId = _currentUserId;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final loader = widget.startLoader ?? CourseApiService.startPlacementQuiz;
      final language = widget.language.trim().toLowerCase();
      final quizLang = language == 'es' ? 'es' : 'en';
      final session = await loader(
        topic: widget.topic,
        language: quizLang,
      );

      await QuizAttemptStorage.instance.recordStart(
        userId:
            (widget.firebaseAuth ?? FirebaseAuth.instance).currentUser?.uid ??
                'anonymous',
        topic: widget.topic,
        language: quizLang,
      );

      await LocalQuizCache.instance.saveSession(
        userId: userId,
        session: CachedQuizSession(
          quizId: session.quizId,
          topic: widget.topic,
          language: quizLang,
          expiresAt: session.expiresAt,
          questions: session.questions,
          answers: _answers,
        ),
      );

      if (!mounted) return;

      setState(() {
        _session = session;
        _answers = List<int?>.filled(session.questions.length, null);
        _currentIndex = 0;
        _stage = _QuizStage.questions;
      });

      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
    } catch (error) {
      final language = widget.language.trim().toLowerCase();
      final cached = await LocalQuizCache.instance.restoreSession(
        userId: userId,
        topic: widget.topic,
        language: language,
      );
      if (cached != null && !cached.isExpired) {
        if (!mounted) return;
        _loadCachedSession(cached);
        final message = language == 'es'
            ? 'Reanudamos tu quiz sin conexion'
            : 'Resumed cached quiz offline';
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(message)),
          );
        return;
      }
      if (!mounted) return;
      setState(() {
        _session = null;
        _stage = _QuizStage.error;
        _error = error.toString();
      });
    }
  }

  String get _currentUserId {
    return (widget.firebaseAuth ?? FirebaseAuth.instance).currentUser?.uid ??
        'anonymous';
  }

  void _onOptionSelected(int questionIndex, int? value) {
    if (_stage != _QuizStage.questions || value == null) return;
    setState(() {
      _answers[questionIndex] = value;
    });
    unawaited(_persistCachedAnswers());
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  bool get _isLastQuestion {
    final session = _session;
    if (session == null || session.questions.isEmpty) {
      return false;
    }
    return _currentIndex >= session.questions.length - 1;
  }

  Future<void> _nextOrSubmit() async {
    if (_stage != _QuizStage.questions || _submitting) {
      return;
    }
    final session = _session;
    if (session == null) {
      return;
    }

    final selected = _answers[_currentIndex];
    if (selected == null) {
      final messenger = ScaffoldMessenger.of(context);
      final l10n = AppLocalizations.of(context)!;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.quizAnswerAllPrompt)),
        );
      return;
    }

    if (_isLastQuestion) {
      await _submitQuiz(session);
    } else {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _submitQuiz(PlacementQuizStartResponse session) async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final grader = widget.grader ?? CourseApiService.gradePlacementQuiz;
      final answers = <PlacementQuizAnswer>[];
      for (var i = 0; i < session.questions.length; i++) {
        final selectedIndex = _answers[i];
        if (selectedIndex == null) continue;
        answers.add(
          PlacementQuizAnswer(
            id: session.questions[i].id,
            choiceIndex: selectedIndex,
          ),
        );
      }

      final grade = await grader(
        quizId: session.quizId,
        answers: answers,
      );
      await LocalQuizCache.instance.clear(
        userId: _currentUserId,
        topic: widget.topic,
        language: widget.language,
      );

      if (!mounted) return;
      setState(() {
        _grade = grade;
        _stage = _QuizStage.result;
        _submitting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _finalizePlan() async {
    if (!widget.autoOpenOutline) {
      _returnResult(apply: true);
      return;
    }

    final grade = _grade;
    if (grade == null || _submitting) {
      return;
    }

    setState(() => _submitting = true);

    try {
      final auth = widget.firebaseAuth ?? FirebaseAuth.instance;
      final userId = auth.currentUser?.uid ?? 'anonymous';
      final topic = widget.topic.trim();
      final language = widget.language.trim().toLowerCase();

      await TopicBandCache.instance.setBand(
        userId: userId,
        topic: topic,
        language: language,
        band: grade.band,
      );

      if (!mounted) return;

      setState(() => _submitting = false);

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AdaptiveJourneyScreen(
            topic: topic,
            target: topic,
            initialBand: grade.band,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _returnResult({required bool apply}) {
    final grade = _grade;
    if (grade == null) {
      Navigator.of(context).maybePop();
      return;
    }
    Navigator.of(context).pop({
      'band': CourseApiService.placementBandToString(grade.band),
      'scorePct': grade.scorePct,
      'suggestedDepth': grade.suggestedDepth,
      'recommendRegenerate': grade.recommendRegenerate,
      'apply': apply,
    });
  }

  void _loadCachedSession(CachedQuizSession cached) {
    final restored = PlacementQuizStartResponse(
      quizId: cached.quizId,
      expiresAt: cached.expiresAt,
      maxMinutes: 15,
      questions: cached.questions,
      numQuestions: cached.questions.length,
    );

    final restoredAnswers = cached.answers.length == restored.questions.length
        ? List<int?>.from(cached.answers)
        : List<int?>.filled(restored.questions.length, null);

    setState(() {
      _session = restored;
      _answers = restoredAnswers;
      _stage = _QuizStage.questions;
      _currentIndex = 0;
    });

    if (_controller.hasClients) {
      _controller.jumpToPage(0);
    }
  }

  Future<void> _persistCachedAnswers() async {
    final session = _session;
    if (session == null) return;
    await LocalQuizCache.instance.saveAnswers(
      userId: _currentUserId,
      topic: widget.topic,
      language: widget.language,
      answers: _answers,
    );
  }

  // Removed _maybeTweakOutline and _mergeTweakIntoOutline
  // Functionality moved to AdaptiveJourneyScreen (adaptive_flow_screen.dart)

  Future<bool> _handleWillPop() async {
    if (_submitting) {
      return false;
    }
    if (_stage != _QuizStage.questions) {
      return true;
    }

    final l10n = AppLocalizations.of(context)!;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.quizExitTitle),
        content: Text(l10n.quizExitMessage),
        actions: [
          TextButton(
            key: const Key('quiz-exit-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.quizExitCancel),
          ),
          TextButton(
            key: const Key('quiz-exit-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.quizExitConfirm),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  Widget _buildIntro(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizTitle),
        leading: IconButton(
          key: const Key('quiz-exit'),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quizHeaderTitle(widget.topic),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.quizIntroDescription,
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            FilledButton(
              key: const Key('quiz-start'),
              onPressed: _beginQuiz,
              child: Text(l10n.startQuiz),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestions(AppLocalizations l10n) {
    final session = _session;
    if (session == null) {
      return _buildError(l10n);
    }
    final questions = session.questions;
    final total = questions.length;
    final isLast = _isLastQuestion;
    final buttonLabel = isLast ? l10n.submit : l10n.next;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizTitle),
        leading: IconButton(
          key: const Key('quiz-exit'),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          _QuizProgressHeader(
            topic: widget.topic,
            currentIndex: _currentIndex,
            total: total,
            maxMinutes: session.maxMinutes,
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _onPageChanged,
              itemCount: total,
              itemBuilder: (context, index) {
                final question = questions[index];
                final selected = _answers[index];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.text,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: question.choices.length,
                          itemBuilder: (context, choiceIndex) {
                            final choice = question.choices[choiceIndex];
                            return RadioListTile<int>(
                              value: choiceIndex,
                              // ignore: deprecated_member_use
                              groupValue: selected,
                              // ignore: deprecated_member_use
                              onChanged: (value) =>
                                  _onOptionSelected(index, value),
                              title: Text(choice),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton(
                            key: const Key('quiz-exit-button'),
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: Text(l10n.quizExitConfirm),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 180,
                            child: FilledButton(
                              key: ValueKey(
                                  isLast ? 'quiz-submit' : 'quiz-next'),
                              onPressed: selected == null || _submitting
                                  ? null
                                  : _nextOrSubmit,
                              child: _submitting && isLast
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                    )
                                  : Text(buttonLabel),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(AppLocalizations l10n) {
    final grade = _grade;
    if (grade == null) {
      return _buildIntro(l10n);
    }
    if (!widget.autoOpenOutline) {
      return _buildLegacyResult(l10n, grade);
    }

    return AssessmentResultsScreen(
      theta: _resolveTheta(grade),
      responseCorrectness: _buildResponseCorrectness(grade),
      bandLabel: _bandLabel(l10n, grade.band),
      scorePct: grade.scorePct,
      isGeneratingPlan: _submitting,
      onStartPlan: _finalizePlan,
      onClose: () => Navigator.of(context).maybePop(),
      topic: widget.topic,
      onGapsResolved: (gaps) => _detectedGaps = List<String>.from(gaps),
    );
  }

  Widget _buildLegacyResult(
    AppLocalizations l10n,
    PlacementQuizGrade grade,
  ) {
    final bandLabel = _bandLabel(l10n, grade.band);
    final scoreText = l10n.quizScorePercentage(grade.scorePct);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizTitle),
        leading: IconButton(
          key: const Key('quiz-exit'),
          icon: const Icon(Icons.close),
          onPressed: _submitting ? null : () => _returnResult(apply: false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quizResultTitle(bandLabel),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Chip(label: Text(l10n.quizLevelChip(bandLabel))),
                Chip(label: Text(scoreText)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.quizKeepCurrentPlan(bandLabel),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('quiz-apply-results'),
                onPressed:
                    _submitting ? null : () => _returnResult(apply: true),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.quizApplyResults),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              key: const Key('quiz-result-done'),
              onPressed: _submitting ? null : () => _returnResult(apply: false),
              child: Text(l10n.quizDone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return _QuizError(
      topic: widget.topic,
      message: _error ?? l10n.quizUnknownError,
      onRetry: _beginQuiz,
    );
  }

  double _resolveTheta(PlacementQuizGrade grade) {
    final theta = grade.theta;
    if (theta != null) {
      return theta.clamp(-3.0, 3.0);
    }
    final fraction = grade.scoreFraction;
    final mapped = (fraction * 4) - 2;
    return mapped.clamp(-3.0, 3.0);
  }

  List<bool> _buildResponseCorrectness(PlacementQuizGrade grade) {
    final provided = grade.responseCorrectness;
    if (provided.isNotEmpty) {
      return provided;
    }
    final total = _session?.questions.length ?? 10;
    final correct = ((grade.scorePct / 100) * total).round().clamp(0, total);
    return List<bool>.generate(
      total,
      (index) => index < correct,
      growable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    late final Widget child;
    switch (_stage) {
      case _QuizStage.intro:
        child = _buildIntro(l10n);
        break;
      case _QuizStage.loading:
        child = _QuizSkeleton(title: l10n.quizTitle);
        break;
      case _QuizStage.questions:
        child = _buildQuestions(l10n);
        break;
      case _QuizStage.result:
        child = _buildResult(l10n);
        break;
      case _QuizStage.error:
        child = _buildError(l10n);
        break;
    }

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: child,
    );
  }
}

String _bandLabel(AppLocalizations l10n, PlacementBand band) {
  switch (band) {
    case PlacementBand.basic:
      return l10n.quizBandBasic;
    case PlacementBand.intermediate:
      return l10n.quizBandIntermediate;
    case PlacementBand.advanced:
      return l10n.quizBandAdvanced;
  }
}

// Removed _extractOutlineList - functionality moved to adaptive flow

class _QuizProgressHeader extends StatelessWidget {
  const _QuizProgressHeader({
    required this.topic,
    required this.currentIndex,
    required this.total,
    required this.maxMinutes,
  });

  final String topic;
  final int currentIndex;
  final int total;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progressValue =
        total <= 0 ? 0.0 : (currentIndex + 1) / total.clamp(1, total);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quizHeaderTitle(topic),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progressValue),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.quizQuestionCounter(currentIndex + 1, total),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                l10n.quizTimeHint(maxMinutes),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuizError extends StatelessWidget {
  const _QuizError({
    required this.topic,
    required this.message,
    required this.onRetry,
  });

  final String topic;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizSkeleton extends StatelessWidget {
  const _QuizSkeleton({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: null,
            color: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Skeleton(height: 24, width: 220),
                  SizedBox(height: 16),
                  Skeleton(height: 18, width: double.infinity),
                  SizedBox(height: 8),
                  Skeleton(height: 18, width: double.infinity),
                  SizedBox(height: 8),
                  Skeleton(height: 18, width: double.infinity),
                  Spacer(),
                  Skeleton(height: 48, width: double.infinity),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class AdaptiveJourneyScreen extends StatefulWidget {
  const AdaptiveJourneyScreen({
    super.key,
    required this.topic,
    required this.target,
    required this.initialBand,
  });

  final String topic;
  final String target;
  final PlacementBand initialBand;

  static const routeName = '/adaptiveJourney';

  @override
  State<AdaptiveJourneyScreen> createState() => _AdaptiveJourneyScreenState();
}

class _AdaptiveJourneyScreenState extends State<AdaptiveJourneyScreen> {
  bool _loadingPlan = true;
  bool _loadingCheckpoint = false;
  bool _submittingCheckpoint = false;
  bool _loadingBooster = false;
  String? _error;

  AdaptivePlanDraft? _plan;
  AdaptiveLearnerState? _learnerState;
  AdaptiveModuleOut? _module;
  AdaptiveCheckpointQuiz? _checkpoint;
  AdaptiveEvaluationResponse? _evaluationResponse;
  AdaptiveBooster? _booster;

  final Map<String, String> _checkpointAnswers = <String, String>{};
  final Map<int, _ModuleTileState> _timeline = <int, _ModuleTileState>{};

  int _activeModuleNumber = 1;
  bool _hasPremium = false;

  // Expansion state for timeline modules
  final Set<int> _expandedModules = <int>{};
  final Map<int, AdaptiveModuleOut> _cachedModules = <int, AdaptiveModuleOut>{};

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EntitlementsService _entitlements = EntitlementsService();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _stateSub;

  static const int _maxTimelineModules = 12;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loadingPlan = true;
      _error = null;
      _module = null;
      _checkpoint = null;
      _evaluationResponse = null;
      _booster = null;
      _checkpointAnswers.clear();
      _timeline.clear();
    });

    await _stateSub?.cancel();

    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _loadingPlan = false;
        _error = 'AUTH_REQUIRED';
      });
      return;
    }

    try {
      await _entitlements.ensureLoaded();

      // ✅ CACHE FIRST: Load cached modules immediately
      await _loadCachedModules();

      // If we have cached M1, show it immediately and skip API calls
      if (_cachedModules.containsKey(1)) {
        final cachedM1 = _cachedModules[1]!;
        final seeds = <int, _ModuleTileState>{};

        // Create timeline for all modules (not just cached ones)
        // This ensures M2, M3, etc. are visible even if only M1 is cached
        const defaultModuleCount = 6; // Default number of modules to show
        for (int i = 1; i <= defaultModuleCount; i++) {
          final cachedModule = _cachedModules[i];
          final suggestion = _suggestionFor(i);

          seeds[i] = _ModuleTileState(
            number: i,
            title: cachedModule?.title ?? suggestion?.title ?? 'Módulo $i',
            skills: cachedModule?.skillsTargeted ?? suggestion?.skills ?? const <String>[],
            unlocked: i == 1,
            completed: false,
            requiresPremium: i > 1,
          );
        }

        setState(() {
          _timeline
            ..clear()
            ..addAll(seeds);
          _activeModuleNumber = 1;
          _module = cachedM1;
          _hasPremium = _entitlements.isPremium;
          _loadingPlan = false;
        });

        await _startStateListener(user.uid);

        debugPrint('[QuizScreen] Loaded M1 from cache, showing ${seeds.length} modules total');
        return; // ✅ Exit early - we have cached content
      }

      // No cache - must fetch from API
      // FASE 1: Obtener conteo rÃ¡pido (5-10 segundos)
      final countResponse = await CourseApiService.fetchModuleCount(
        topic: widget.topic,
        band: widget.initialBand,
        target: widget.target,
        timeout: const Duration(seconds: 30),
      );

      // Crear skeleton UI inmediatamente con mÃ³dulos vacÃ­os
      final seeds = <int, _ModuleTileState>{};
      for (int i = 1; i <= countResponse.moduleCount && i <= _maxTimelineModules; i++) {
        seeds[i] = _ModuleTileState(
          number: i,
          title: 'Módulo $i',  // Placeholder, se llenará después con el contenido real
          skills: const <String>[],
          unlocked: i == 1,
          completed: false,
          requiresPremium: i > 1,
        );
      }

      setState(() {
        _timeline
          ..clear()
          ..addAll(seeds);
        _activeModuleNumber = 1;
        _hasPremium = _entitlements.isPremium;
        _loadingPlan = false;  // âœ… UI visible inmediatamente
      });

      await _startStateListener(user.uid);

      // FASE 2: Generar M1 (60-90s, pero usuario ya ve skeleton)
      await _generateModule(1);
    } catch (error) {
      setState(() {
        _error = error.toString();
        _loadingPlan = false;
      });
    }
  }

  Future<void> _startStateListener(String userId) async {
    await _stateSub?.cancel();
    _stateSub = _firestore
        .collection('users')
        .doc(userId)
        .collection('adaptiveState')
        .doc('summary')
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return;
      }
      final state = AdaptiveLearnerState.fromJson(
        Map<String, dynamic>.from(data),
      );
      if (!mounted) return;
      setState(() {
        _learnerState = state;
        _syncTimelineWithHistory(state.history);
      });
    });
  }

  void _syncTimelineWithHistory(AdaptiveLearnerHistory history) {
    for (final entry in _timeline.values) {
      entry.unlocked = entry.number == 1;
      entry.completed = false;
    }

    for (final moduleNumber in history.passedModules) {
      _ensureTile(moduleNumber);
      final tile = _timeline[moduleNumber]!;
      tile.completed = true;
      tile.unlocked = true;
    }

    for (final moduleNumber in history.failedModules) {
      _ensureTile(moduleNumber);
      final tile = _timeline[moduleNumber]!;
      tile.unlocked = true;
      tile.completed = false;
    }

    if (history.passedModules.isNotEmpty) {
      final nextNumber = history.passedModules.reduce(math.max) + 1;
      _ensureTile(nextNumber);
      _timeline[nextNumber]!.unlocked = true;
    }
  }

  void _ensureTile(int moduleNumber) {
    final suggestion = _suggestionFor(moduleNumber);
    _timeline.putIfAbsent(
      moduleNumber,
      () => _ModuleTileState(
        number: moduleNumber,
        title: suggestion?.title ?? 'M$moduleNumber',
        skills: suggestion?.skills ?? const <String>[],
        unlocked: moduleNumber == 1,
        completed: false,
        requiresPremium: moduleNumber > 1,
      ),
    );
  }

  Future<void> _generateModule(int moduleNumber) async {
    setState(() {
      _module = null;
      _checkpoint = null;
      _evaluationResponse = null;
      _booster = null;
      _checkpointAnswers.clear();
      _error = null;
      _activeModuleNumber = moduleNumber;
    });

    try {
      var focus = List<String>.from(
          _timeline[moduleNumber]?.skills ?? const <String>[]);
      if (focus.isEmpty) {
        focus = _topDeficits();
      }
      final response = await CourseApiService.generateAdaptiveModule(
        topic: widget.topic,
        moduleNumber: moduleNumber,
        focusSkills: focus,
      );

      if (!mounted) return;

      // Cache the generated module
      _cachedModules[moduleNumber] = response.module;
      unawaited(AdaptiveModuleCache.instance.saveModule(
        topic: widget.topic,
        language: 'es',
        band: widget.initialBand.name,
        module: response.module,
      ));

      setState(() {
        _module = response.module;
        _learnerState = response.learnerState;
        _timeline[moduleNumber]?.unlocked = true;
        _timeline[moduleNumber]?.completed = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    }
  }

  /// Load all cached modules from persistent storage
  Future<void> _loadCachedModules() async {
    try {
      for (int moduleNumber = 1; moduleNumber <= _maxTimelineModules; moduleNumber++) {
        final cached = await AdaptiveModuleCache.instance.loadModule(
          topic: widget.topic,
          language: 'es',
          band: widget.initialBand.name,
          moduleNumber: moduleNumber,
        );
        if (cached != null) {
          _cachedModules[moduleNumber] = cached;
        }
      }
    } catch (e) {
      // Fail silently - cache is optional
      debugPrint('[QuizScreen] Error loading cached modules: $e');
    }
  }

  Future<void> _generateCheckpoint() async {
    final module = _module;
    if (module == null || _loadingCheckpoint) {
      return;
    }

    setState(() {
      _loadingCheckpoint = true;
      _checkpoint = null;
      _evaluationResponse = null;
      _booster = null;
      _checkpointAnswers.clear();
      _error = null;
    });

    try {
      final response = await CourseApiService.generateAdaptiveCheckpoint(
        topic: widget.topic,
        moduleNumber: module.moduleNumber,
        skillsTargeted: module.skillsTargeted,
      );

      if (!mounted) return;

      setState(() {
        _checkpoint = response.quiz;
        _learnerState = response.learnerState;
        for (final item in response.quiz.items) {
          _checkpointAnswers[item.id] = '';
        }
        _loadingCheckpoint = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loadingCheckpoint = false;
      });
    }
  }

  Future<void> _submitCheckpoint(AppLocalizations l10n) async {
    final module = _module;
    final checkpoint = _checkpoint;
    if (module == null || checkpoint == null || _submittingCheckpoint) {
      return;
    }

    final unanswered = _checkpointAnswers.values.any((value) => value.isEmpty);
    if (unanswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adaptiveFlowCheckpointMissingSelection)),
      );
      return;
    }

    setState(() {
      _submittingCheckpoint = true;
      _error = null;
    });

    try {
      final answers = _checkpointAnswers.entries
          .map((entry) =>
              <String, String>{'id': entry.key, 'choice': entry.value})
          .toList(growable: false);

      final response = await CourseApiService.evaluateAdaptiveCheckpoint(
        moduleNumber: module.moduleNumber,
        answers: answers,
        skillsTargeted: module.skillsTargeted,
      );

      if (!mounted) return;

      setState(() {
        _evaluationResponse = response;
        _learnerState = response.learnerState;
        _submittingCheckpoint = false;
      });

      if (response.action == 'advance') {
        _markCompleted(module.moduleNumber);
        _ensureTile(module.moduleNumber + 1);
        _timeline[module.moduleNumber + 1]!.unlocked = true;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _submittingCheckpoint = false;
      });
    }
  }

  Future<void> _requestBooster() async {
    final evaluation = _evaluationResponse;
    if (evaluation == null ||
        evaluation.result.weakSkills.isEmpty ||
        _loadingBooster) {
      return;
    }

    setState(() {
      _loadingBooster = true;
      _error = null;
    });

    try {
      final response = await CourseApiService.requestAdaptiveBooster(
        topic: widget.topic,
        weakSkills: evaluation.result.weakSkills,
      );

      if (!mounted) return;

      setState(() {
        _booster = response.booster;
        _learnerState = response.learnerState;
        _loadingBooster = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loadingBooster = false;
      });
    }
  }

  List<String> _topDeficits() {
    final mastery = _learnerState?.skillMastery;
    if (mastery == null || mastery.isEmpty) {
      return const <String>[];
    }
    final entries = mastery.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return entries.take(3).map((entry) => entry.key).toList(growable: false);
  }

  AdaptivePlanModuleSuggestion? _suggestionFor(int moduleNumber) {
    return _plan?.suggestedModules.firstWhere(
      (module) => module.moduleNumber == moduleNumber,
      orElse: () => AdaptivePlanModuleSuggestion(
        moduleNumber: moduleNumber,
        title: 'M$moduleNumber',
        skills: const <String>[],
        objective: '',
      ),
    );
  }

  void _markCompleted(int moduleNumber) {
    final tile = _timeline[moduleNumber];
    if (tile == null) return;
    tile.completed = true;
    unawaited(_recordDailyCheckIn('adaptive_module_$moduleNumber'));
  }

  Future<void> _handleModuleTileTap(int moduleNumber) async {
    final l10n = AppLocalizations.of(context)!;
    final tile = _timeline[moduleNumber];
    if (tile == null) return;

    // If module already has cached data, just toggle expansion
    if (_cachedModules.containsKey(moduleNumber)) {
      setState(() {
        if (_expandedModules.contains(moduleNumber)) {
          _expandedModules.remove(moduleNumber);
        } else {
          _expandedModules.add(moduleNumber);
        }
      });
      return;
    }

    // Otherwise, check permissions and generate module
    if (!tile.unlocked) {
      final previous = moduleNumber - 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adaptiveFlowLockedModule('$previous'))),
      );
      return;
    }

    if (tile.requiresPremium && moduleNumber > 1 && !_hasPremium) {
      final granted = await PaywallHelper.checkAndShowPaywall(
        context,
        trigger: 'adaptive_module_$moduleNumber',
        onTrialStarted: _reloadEntitlements,
      );
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.adaptiveFlowLockedPremium)),
          );
        }
        return;
      }
      await _reloadEntitlements();
      if (!_hasPremium) {
        return;
      }
    }

    // Generate module and auto-expand it
    await _generateModule(moduleNumber);
    if (mounted && _cachedModules.containsKey(moduleNumber)) {
      setState(() {
        _expandedModules.add(moduleNumber);
      });
    }
  }

  Future<void> _reloadEntitlements() async {
    try {
      await _entitlements.ensureLoaded(forceRefresh: true);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _hasPremium = _entitlements.isPremium;
    });
  }

  List<_ModuleTileState> get _timelineTiles {
    final tiles = _timeline.values.toList()
      ..sort((a, b) => a.number.compareTo(b.number));
    return tiles.take(_maxTimelineModules).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loadingPlan) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adaptiveFlowTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error == 'AUTH_REQUIRED') {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adaptiveFlowTitle)),
        body: Center(child: Text('Sign in required to continue.')),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adaptiveFlowTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.adaptiveFlowError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _bootstrap,
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adaptiveFlowTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLearnerStateCard(l10n),
          const SizedBox(height: 16),
          _buildPlanCard(l10n),
          const SizedBox(height: 16),
          _buildTimeline(l10n),
          const SizedBox(height: 16),
          _buildCheckpointCard(l10n),
          const SizedBox(height: 16),
          _buildBoosterCard(l10n),
        ],
      ),
    );
  }

  Widget _buildLearnerStateCard(AppLocalizations l10n) {
    final mastery = _learnerState?.skillMastery ?? const <String, double>{};
    final chips = mastery.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final headline =
        EdaptiaTypography.title2.copyWith(color: Colors.white);
    final subtitle =
        EdaptiaTypography.body.copyWith(color: Colors.white70);
    final chipStyle = EdaptiaTypography.caption
        .copyWith(color: Colors.white, fontWeight: FontWeight.w600);

    return EdaptiaCard(
      gradient: EdaptiaColors.hookGradient,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adaptiveFlowLearnerState, style: headline),
          const SizedBox(height: 8),
          Text(' · ', style: subtitle),
          const SizedBox(height: 4),
          Text(
            'Band: ',
            style: subtitle,
          ),
          const SizedBox(height: 12),
          if (chips.isEmpty)
            Text(l10n.adaptiveFlowEmptySkills, style: subtitle)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.take(12).map((entry) {
                final pct = (entry.value * 100).clamp(0, 100).round();
                return Chip(
                  backgroundColor: Colors.white24,
                  labelStyle: chipStyle,
                  label: Text('${entry.key} $pct%'),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(AppLocalizations l10n) {
    final plan = _plan;
    if (plan == null) {
      return const SizedBox.shrink();
    }
    return EdaptiaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adaptiveFlowPlanSection,
            style: EdaptiaTypography.title3
                .copyWith(color: EdaptiaColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            plan.notes,
            style: EdaptiaTypography.body
                .copyWith(color: EdaptiaColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(AppLocalizations l10n) {
    final tiles = _timelineTiles;
    return EdaptiaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: tiles.map((tile) {
          final isActive = tile.number == _activeModuleNumber;
          final background = tile.completed
              ? EdaptiaColors.successGradient
              : isActive
                  ? EdaptiaColors.hookGradient
                  : null;
          final baseColor = tile.completed
              ? EdaptiaColors.success
              : isActive
                  ? EdaptiaColors.primary
                  : EdaptiaColors.border;
          final foreground =
              (tile.completed || isActive) ? Colors.white : EdaptiaColors.textPrimary;

          IconData icon;
          if (tile.completed) {
            icon = Icons.check_circle;
          } else if (!tile.unlocked) {
            icon = Icons.lock_outline;
          } else if (tile.requiresPremium && !_hasPremium) {
            icon = Icons.lock;
          } else {
            icon = Icons.play_circle;
          }

          final isExpanded = _expandedModules.contains(tile.number);
          final cachedModule = _cachedModules[tile.number];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: background == null ? EdaptiaColors.cardLight : null,
                  gradient: background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: baseColor.withValues(alpha: baseColor.a * 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _handleModuleTileTap(tile.number),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(icon, color: foreground, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'M${tile.number}',
                                        style: EdaptiaTypography.title3.copyWith(color: foreground),
                                      ),
                                      if (isActive) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Activo',
                                            style: EdaptiaTypography.caption.copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (cachedModule != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      cachedModule.title,
                                      style: EdaptiaTypography.body.copyWith(color: foreground),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      tile.title,
                                      style: EdaptiaTypography.body.copyWith(color: foreground),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    tile.skills.isEmpty
                                        ? l10n.adaptiveFlowEmptySkills
                                        : tile.skills.take(2).join(', '),
                                    style: EdaptiaTypography.caption.copyWith(
                                      color: foreground.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: foreground,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      const Divider(height: 1, color: Colors.white24),
                      if (cachedModule != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: cachedModule.lessons.asMap().entries.map((entry) {
                              final index = entry.key;
                              final lesson = entry.value;
                              return _LessonCard(
                                index: index,
                                lesson: lesson,
                                moduleTitle: cachedModule.title,
                                courseId: widget.topic,
                              );
                            }).toList(),
                          ),
                        ),
                      ] else ...[
                        // Show loading indicator while module is being generated
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                          child: Center(
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Generando módulo ${tile.number}...',
                                  style: EdaptiaTypography.body.copyWith(
                                    color: foreground.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildCheckpointCard(AppLocalizations l10n) {
    final checkpoint = _checkpoint;
    final evaluation = _evaluationResponse;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.adaptiveFlowCheckpointSection,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _loadingCheckpoint ? null : _generateCheckpoint,
                  icon: _loadingCheckpoint
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.quiz),
                  label: Text(l10n.adaptiveFlowGenerateCheckpoint),
                ),
              ],
            ),
            if (checkpoint != null) ...[
              const SizedBox(height: 12),
              ...checkpoint.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.stem),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _checkpointAnswers[item.id]?.isEmpty ?? true
                            ? null
                            : _checkpointAnswers[item.id],
                        decoration: InputDecoration(
                          labelText: item.skillTag,
                          border: const OutlineInputBorder(),
                        ),
                        items: item.options.entries
                            .map(
                              (entry) => DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text('${entry.key}. ${entry.value}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _checkpointAnswers[item.id] = value ?? '';
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              FilledButton(
                onPressed: _submittingCheckpoint
                    ? null
                    : () => _submitCheckpoint(l10n),
                child: _submittingCheckpoint
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.adaptiveFlowSubmitAnswers),
              ),
            ],
            if (evaluation != null) ...[
              const SizedBox(height: 16),
              Text(l10n.adaptiveFlowScoreLabel(evaluation.result.score)),
              const SizedBox(height: 8),
              Text(
                evaluation.action == 'advance'
                    ? l10n.adaptiveFlowActionAdvance
                    : evaluation.action == 'booster'
                        ? l10n.adaptiveFlowActionBooster
                        : l10n.adaptiveFlowActionReplan,
              ),
              if (evaluation.result.weakSkills.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.adaptiveFlowWeakSkills(
                    evaluation.result.weakSkills.join(', '))),
              ],
              if (evaluation.action == 'advance') ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      _handleModuleTileTap(_activeModuleNumber + 1),
                  child: Text(l10n.adaptiveFlowGenerateModule),
                ),
              ],
              if (evaluation.action == 'booster') ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loadingBooster ? null : _requestBooster,
                  icon: _loadingBooster
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.flash_on),
                  label: Text(l10n.adaptiveFlowBoosterCta),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBoosterCard(AppLocalizations l10n) {
    final booster = _booster;
    if (booster == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.adaptiveFlowBoosterSection,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(booster.boosterFor.join(', ')),
            const SizedBox(height: 12),
            ...booster.lessons.asMap().entries.map(
                  (entry) =>
                      _LessonCard(
                        index: entry.key + 1,
                        lesson: entry.value,
                        moduleTitle: 'Booster: ${booster.boosterFor.join(', ')}',
                        courseId: widget.topic,
                      ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordDailyCheckIn(String source) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final snapshot = await container
          .read(streakProvider.notifier)
          .checkIn(userId, silent: true);
      if (snapshot?.incremented == true) {
        unawaited(
          AnalyticsService().track(
            'return_day',
            properties: <String, Object?>{
              'day': snapshot!.streakDays,
              'source': source,
              'streak_len': snapshot.streakDays,
            },
            targets: const {AnalyticsService.targetPosthog},
          ),
        );
      }
    } catch (error) {
      debugPrint('[AdaptiveJourneyScreen] streak auto check-in failed: $error');
    }
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.index,
    required this.lesson,
    required this.moduleTitle,
    required this.courseId,
  });

  final int index;
  final AdaptiveLesson lesson;
  final String moduleTitle;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          LessonRouter.navigateToLesson(
            context: context,
            lesson: lesson,
            moduleTitle: moduleTitle,
            courseId: courseId,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('L$index • ${lesson.title}',
                        style: theme.textTheme.titleSmall),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(lesson.lessonType.replaceAll('_', ' ')),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                lesson.hook,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.arrow_forward, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to open lesson',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleTileState {
  _ModuleTileState({
    required this.number,
    required this.title,
    required this.skills,
    required this.unlocked,
    required this.completed,
    required this.requiresPremium,
  });

  final int number;
  final String title;
  final List<String> skills;
  bool unlocked;
  bool completed;
  bool requiresPremium;
}





