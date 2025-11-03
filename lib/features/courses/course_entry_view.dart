import 'package:flutter/material.dart';

import 'package:edaptia/core/app_colors.dart';
import 'package:edaptia/features/quiz/quiz_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/widgets/skeleton.dart';

class CourseEntryView extends StatefulWidget {
  const CourseEntryView({super.key});

  static const routeName = '/course-entry';

  @override
  State<CourseEntryView> createState() => _CourseEntryViewState();
}

class _CourseEntryViewState extends State<CourseEntryView> {
  final TextEditingController _controller = TextEditingController();
  bool _generating = false;

  List<String> _chipLabels(AppLocalizations l10n) => [
        l10n.courseEntryExampleFlutter,
        l10n.courseEntryExampleSql,
        l10n.courseEntryExampleDataScience,
        l10n.courseEntryExampleLogic,
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToQuiz(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty || _generating) return;

    setState(() => _generating = true);
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      await Navigator.of(context).pushNamed(
        QuizScreen.routeName,
        arguments: QuizScreenArgs(
          topic: trimmed,
          language: languageCode,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _generating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Text(l10n.courseEntryTitle, style: theme.textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(l10n.courseEntrySubtitle, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.neutral),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: _goToQuiz,
                decoration: InputDecoration(
                  hintText: l10n.courseEntryHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _generating ? null : () => _goToQuiz(_controller.text),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                  ),
                  child: _generating
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.courseEntryStart),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.courseEntryFooter,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _chipLabels(l10n)
              .map(
                (chip) => ActionChip(
                  label: Text(chip),
                  onPressed: () => _goToQuiz(chip),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              )
              .toList(),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            body,
            if (_generating) const _CourseLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _CourseLoadingOverlay extends StatelessWidget {
  const _CourseLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.9)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Skeleton(height: 24, width: 240),
              SizedBox(height: 12),
              Skeleton(height: 56, width: 200),
              SizedBox(height: 12),
              Skeleton(height: 16, width: 180),
            ],
          ),
        ),
      ),
    );
  }
}


