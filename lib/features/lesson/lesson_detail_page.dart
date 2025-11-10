import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/course_api_service.dart';

class LessonDetailArgs {
  const LessonDetailArgs({
    required this.courseId,
    required this.moduleTitle,
    required this.lessonTitle,
    this.content,
    this.lesson,
  });

  final String courseId;
  final String moduleTitle;
  final String lessonTitle;
  final String? content;
  final Map<String, dynamic>? lesson;
}

class LessonDetailPage extends StatefulWidget {
  const LessonDetailPage({super.key, required this.args});

  static const routeName = '/lesson/detail';

  final LessonDetailArgs args;

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  final TextEditingController _answerController = TextEditingController();
  ChallengeValidationResult? _validation;
  bool _validating = false;
  String? _validationError;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final args = widget.args;
    final rawContent = args.content?.trim();
    final bodyText = (rawContent != null && rawContent.isNotEmpty)
        ? rawContent
        : l10n.lessonContentComingSoon;
    final lesson = widget.args.lesson ?? const <String, dynamic>{};
    final isSpanish = l10n.localeName.startsWith('es');
    final challengeTitle =
        isSpanish ? 'Reto interactivo' : 'Interactive challenge';
    final challengePlaceholder = isSpanish
        ? 'Escribe tu respuesta...'
        : 'Write your answer...';
    final validateLabel = isSpanish ? 'Validar respuesta' : 'Validate answer';
    final hook = lesson['hook']?.toString();
    final takeaway = lesson['takeaway']?.toString();
    final reto = lesson['reto'] as Map<String, dynamic>? ?? lesson['challenge'] as Map<String, dynamic>?;
    final challengeDesc =
        reto?['desc']?.toString() ?? reto?['description']?.toString();
    final expectedOutput =
        reto?['expected']?.toString() ?? reto?['expectedOutput']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(args.lessonTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              args.moduleTitle,
              style: theme.textTheme.titleMedium,
            ),
            if (hook != null && hook.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                hook,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            MarkdownBody(
              data: bodyText,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(theme),
            ),
            if (takeaway != null && takeaway.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    takeaway,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
            if (challengeDesc != null && challengeDesc.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                challengeTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                challengeDesc,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _answerController,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: challengePlaceholder,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _validating
                    ? null
                    : () => _validateChallenge(
                          challengeDesc,
                          expectedOutput ?? '',
                        ),
                icon: _validating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.emoji_events_outlined),
                label: Text(validateLabel),
              ),
              if (_validationError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _validationError!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ],
              if (_validation != null) ...[
                const SizedBox(height: 12),
                _ChallengeResult(
                  result: _validation!,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _validateChallenge(
    String description,
    String expected,
  ) async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      final errorMessage = Localizations.localeOf(context).languageCode == 'es'
          ? 'Comparte tu respuesta antes de validar.'
          : 'Add your answer before validating.';
      setState(() => _validationError = errorMessage);
      return;
    }

    setState(() {
      _validationError = null;
      _validating = true;
    });

    try {
      final result = await CourseApiService.validateChallenge(
        topic: widget.args.courseId,
        challengeDescription: description,
        expected: expected,
        answer: answer,
        language: Localizations.localeOf(context).languageCode,
      );
      if (!mounted) return;
      setState(() {
        _validation = result;
        _validating = false;
      });
      await AnalyticsService().track(
        'challenge_validated',
        properties: <String, Object?>{
          'score': result.score,
          'passed': result.passed,
          'lesson': widget.args.lessonTitle,
        },
      );
      if (!mounted) return;
      if (result.passed) {
        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                Localizations.localeOf(context).languageCode == 'es'
                    ? '¡Ganaste una insignia!'
                    : 'Badge unlocked!',
              ),
            ),
          );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _validationError = error.toString();
        _validating = false;
      });
    }
  }
}

class _ChallengeResult extends StatelessWidget {
  const _ChallengeResult({required this.result});

  final ChallengeValidationResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = result.passed ? Colors.green : theme.colorScheme.error;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.passed ? Icons.emoji_events : Icons.info_outline,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  '${result.score} / 100',
                  style: theme.textTheme.titleMedium?.copyWith(color: color),
                ),
                if (result.badgeId != null) ...[
                  const SizedBox(width: 12),
                  Chip(
                    label: Text(
                      result.badgeId!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              result.feedback,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

