import 'package:flutter/material.dart';

import 'package:edaptia/features/adaptive_journey/widgets/adaptive_loading_indicator.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:edaptia/services/course/quiz_service.dart' as quiz_service;

class ModuleGateQuizArgs {
  const ModuleGateQuizArgs({
    required this.moduleNumber,
    required this.topic,
    required this.language,
    this.moduleTitle,
    this.lessonTitles = const <String>[],
  });

  final int moduleNumber;
  final String topic;
  final String language;
  final String? moduleTitle;
  final List<String> lessonTitles;
}

class ModuleGateQuizScreen extends StatefulWidget {
  const ModuleGateQuizScreen({
    super.key,
    required this.moduleNumber,
    required this.topic,
    required this.language,
    this.moduleTitle,
    this.lessonTitles = const <String>[],
  });

  static const routeName = '/module-gate-quiz';

  final int moduleNumber;
  final String topic;
  final String language;
  final String? moduleTitle;
  final List<String> lessonTitles;

  @override
  State<ModuleGateQuizScreen> createState() => _ModuleGateQuizScreenState();
}

enum _GateQuizStage { loading, questions, result, error }

class _ModuleGateQuizScreenState extends State<ModuleGateQuizScreen> {
  _GateQuizStage _stage = _GateQuizStage.loading;
  PlacementQuizStartResponse? _session;
  List<int?> _answers = const [];
  int _currentIndex = 0;
  bool _submitting = false;
  String? _error;
  ModuleQuizGradeResponse? _grade;
  GatePracticeState? _practice;

  bool get _useGenerative =>
      widget.moduleTitle != null && widget.moduleTitle!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    if (_useGenerative) {
      await _loadGenerativeQuiz();
      return;
    }
    await _loadBankQuiz();
  }

  Future<void> _loadGenerativeQuiz() async {
    setState(() {
      _stage = _GateQuizStage.loading;
      _error = null;
      _grade = null;
      _answers = const [];
      _currentIndex = 0;
    });

    try {
      // Use the new generative endpoint that generates based on lesson content
      final session = await quiz_service.QuizService.startModuleQuizGenerate(
        moduleNumber: widget.moduleNumber,
        topic: widget.topic,
        moduleTitle: widget.moduleTitle!,
        lessonTitles: widget.lessonTitles,
        language: widget.language,
      );

      if (!mounted) return;
      setState(() {
        _session = session;
        _practice = session.practice;
        _answers = List<int?>.filled(session.questions.length, null);
        _currentIndex = 0;
        _stage = _GateQuizStage.questions;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _stage = _GateQuizStage.error;
      });
    }
  }

  Future<void> _loadBankQuiz() async {
    setState(() {
      _stage = _GateQuizStage.loading;
      _error = null;
      _grade = null;
      _answers = const [];
      _currentIndex = 0;
    });

    try {
      final session = await CourseApiService.startModuleGateQuiz(
        moduleNumber: widget.moduleNumber,
        topic: widget.topic,
        language: widget.language,
      );

      if (!mounted) return;
      setState(() {
        _session = session;
        _practice = session.practice;
        _answers = List<int?>.filled(session.questions.length, null);
        _currentIndex = 0;
        _stage = _GateQuizStage.questions;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _stage = _GateQuizStage.error;
      });
    }
  }

  void _selectAnswer(int choice) {
    if (_stage != _GateQuizStage.questions) return;
    setState(() {
      _answers[_currentIndex] = choice;
    });
  }

  Future<void> _nextOrSubmit() async {
    if (_stage != _GateQuizStage.questions || _submitting) return;
    if (_answers[_currentIndex] == null) return;

    final session = _session;
    if (session == null) return;

    if (_currentIndex < session.questions.length - 1) {
      setState(() => _currentIndex += 1);
      return;
    }
    await _submitQuiz();
  }

  Future<void> _submitQuiz() async {
    final session = _session;
    if (session == null) return;

    setState(() {
      _submitting = true;
    });

    try {
      final answers = <PlacementQuizAnswer>[];
      for (var i = 0; i < session.questions.length; i++) {
        final choice = _answers[i];
        if (choice == null) continue;
        answers.add(
          PlacementQuizAnswer(
            id: session.questions[i].id,
            choiceIndex: choice,
          ),
        );
      }

      final grade = await CourseApiService.gradeModuleQuiz(
        quizId: session.quizId,
        answers: answers,
      );

      if (!mounted) return;
      setState(() {
        _grade = grade;
        final previous = _practice;
        _practice = GatePracticeState(
          enabled: grade.practiceUnlocked || (previous?.enabled ?? false),
          hints: previous?.hints ?? const <String>[],
          attempts: grade.attempts,
          maxAttempts: previous?.maxAttempts ?? 3,
        );
        _stage = _GateQuizStage.result;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _stage = _GateQuizStage.error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.moduleTitle?.isNotEmpty == true
        ? 'Quiz ${widget.moduleTitle}'
        : 'Quiz módulo ${widget.moduleNumber}';

    switch (_stage) {
      case _GateQuizStage.loading:
        return _GateQuizScaffold(
          title: title,
          body: const _GateQuizSkeleton(),
        );
      case _GateQuizStage.questions:
        return _GateQuizScaffold(
          title: title,
          body: _buildQuestionView(l10n),
        );
      case _GateQuizStage.result:
        final grade = _grade;
        if (grade == null) {
          return _GateQuizScaffold(
            title: title,
            body: _GateQuizError(
              message: l10n.quizUnknownError,
              onRetry: _loadQuiz,
            ),
          );
        }
        return _GateQuizScaffold(
          title: title,
          body: _buildResultView(l10n, grade),
        );
      case _GateQuizStage.error:
        return _GateQuizScaffold(
          title: title,
          body: _GateQuizError(
            message: _error ?? l10n.quizUnknownError,
            onRetry: _loadQuiz,
          ),
        );
    }
  }

  Widget _buildQuestionView(AppLocalizations l10n) {
    final session = _session;
    if (session == null) {
      return _GateQuizError(
        message: l10n.quizUnknownError,
        onRetry: _loadQuiz,
      );
    }

    final questions = session.questions;
    final currentQuestion = questions[_currentIndex];
    final selected = _answers[_currentIndex];
    final isLast = _currentIndex == questions.length - 1;
    final practice = _practice ?? session.practice;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GateQuizHeader(
            moduleNumber: widget.moduleNumber,
            currentIndex: _currentIndex,
            total: questions.length,
          ),
          if (practice != null) ...[
            const SizedBox(height: 12),
            _GatePracticeBanner(
              practice: practice,
              l10n: l10n,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            currentQuestion.text,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...currentQuestion.choices.asMap().entries.map(
                (entry) => _GateChoiceTile(
                  key: Key('gate-module-q$_currentIndex-option-${entry.key}'),
                  label: entry.value,
                  selected: selected == entry.key,
                  onTap: () => _selectAnswer(entry.key),
                ),
              ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: selected == null || _submitting ? null : _nextOrSubmit,
              child: _submitting && isLast
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isLast ? l10n.quizSubmit : l10n.quizNext),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(
    AppLocalizations l10n,
    ModuleQuizGradeResponse grade,
  ) {
    final passed = grade.passed;
    final icon = passed ? Icons.check_circle : Icons.error_outline;
    final color = passed ? Colors.green : Colors.orange;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        passed ? l10n.gateQuizPassed : l10n.gateQuizFailed,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l10n.quizScorePercentage(grade.scorePct)),
                if (grade.incorrectTags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    passed
                        ? 'Excelente trabajo. Revisa estas areas para seguir mejorando:'
                        : 'Repasa estas lecciones del modulo:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...grade.incorrectTags.map((tag) {
                    final isLesson = tag.contains('Lección') || tag.contains('Module');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLesson ? Icons.school : Icons.lightbulb_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tag,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                if (!passed && _practice != null) ...[
                  const SizedBox(height: 16),
                  _GatePracticeBanner(
                    practice: _practice!,
                    l10n: l10n,
                  ),
                ],
                const SizedBox(height: 24),
                if (!passed) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _loadQuiz,
                      child: Text(l10n.gateQuizRetry),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(passed),
                    child: Text(passed ? l10n.quizContinue : l10n.quizDone),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GateChoiceTile extends StatelessWidget {
  const _GateChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _GatePracticeBanner extends StatelessWidget {
  const _GatePracticeBanner({
    required this.practice,
    required this.l10n,
  });

  final GatePracticeState practice;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final attemptsUsed = practice.attempts.clamp(0, practice.maxAttempts);
    final attemptsLabel = l10n.gatePracticeAttempts(
      attemptsUsed,
      practice.maxAttempts,
    );
    final unlocked = practice.enabled;
    final hints = practice.hints;

    return Card(
      color: unlocked
          ? theme.colorScheme.secondaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  unlocked ? Icons.lightbulb : Icons.timelapse,
                  color: unlocked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    unlocked
                        ? l10n.gatePracticeUnlocked
                        : l10n.gatePracticeLocked,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              attemptsLabel,
              style: theme.textTheme.bodySmall,
            ),
            if (unlocked && hints.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.gatePracticeHintsTitle,
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              ...hints.map(
                (hint) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(hint)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GateQuizScaffold extends StatelessWidget {
  const _GateQuizScaffold({
    required this.title,
    required this.body,
  });

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }
}

class _GateQuizHeader extends StatelessWidget {
  const _GateQuizHeader({
    required this.moduleNumber,
    required this.currentIndex,
    required this.total,
  });

  final int moduleNumber;
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total <= 0 ? 0.0 : (currentIndex + 1) / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completa el quiz para desbloquear el módulo ${moduleNumber + 1}.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress),
      ],
    );
  }
}

class _GateQuizSkeleton extends StatelessWidget {
  const _GateQuizSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AdaptiveLoadingIndicator(
          message: 'Estamos generando esto en vivo',
          subtitle: 'Por eso puede tardar unos segundos...',
        ),
      ),
    );
  }
}

class _GateQuizError extends StatelessWidget {
  const _GateQuizError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

