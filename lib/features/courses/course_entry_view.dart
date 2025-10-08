import 'package:flutter/material.dart';

import 'package:aelion/core/app_colors.dart';
import 'package:aelion/features/quiz/quiz_screen.dart';
import 'package:aelion/widgets/skeleton.dart';

class CourseEntryView extends StatefulWidget {
  const CourseEntryView({super.key});

  static const routeName = '/course-entry';

  @override
  State<CourseEntryView> createState() => _CourseEntryViewState();
}

class _CourseEntryViewState extends State<CourseEntryView> {
  final TextEditingController _controller = TextEditingController();
  bool _generating = false;

  final List<String> _chips = const [
    'Intro to Flutter',
    'SQL for beginners',
    'Data science 101',
    'Logic fundamentals',
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
      final result = await Navigator.push<Map<String, Object?>>(
        context,
        MaterialPageRoute<Map<String, Object?>>(
          builder: (_) => QuizScreen(topic: trimmed),
        ),
      );

      if (!mounted || result == null) return;

      final score = result['score'] as int? ?? 0;
      final level = result['level'] as String? ?? 'unknown';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz completed: $score/10 • level: $level')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Text('Take a course', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Search a topic and launch a 10-question quiz to calibrate the outline.',
          style: theme.textTheme.bodyLarge,
        ),
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
                decoration: const InputDecoration(
                  hintText:
                      'Example: Flutter fundamentals, linear algebra, SQL... ',
                  prefixIcon: Icon(Icons.search),
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
                      : const Text('Generate quiz'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We keep quizzes short (10 questions) before generating the tailored outline.',
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
          children: _chips.map((chip) {
            return ActionChip(
              label: Text(chip),
              onPressed: () => _goToQuiz(chip),
              backgroundColor: colorScheme.surfaceContainerHighest,
            );
          }).toList(),
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
