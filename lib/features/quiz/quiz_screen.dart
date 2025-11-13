import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:edaptia/features/assessment/assessment_results_screen.dart';
import 'package:edaptia/features/modules/adaptive/adaptive_journey_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:edaptia/services/course/models.dart';
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
  // Functionality moved to adaptive flow in adaptive_journey_screen.dart

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
    case PlacementBand.beginner:
      return l10n.quizBandBeginner;
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
