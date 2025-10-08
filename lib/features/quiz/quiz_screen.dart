import 'package:flutter/material.dart';

import 'package:aelion/widgets/skeleton.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.topic});

  static const routeName = '/quiz';

  final String topic;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final PageController controller = PageController();
  List<Map<String, Object>>? _questions;
  late List<int?> _answers;
  int index = 0;
  int? _selectedIndex;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _loading = true);
    final generated = List<Map<String, Object>>.generate(10, (i) {
      final detail = i.isEven ? 'concepts' : 'practice';
      return {
        'question':
            'Question ${i + 1} about ${widget.topic}: focus on $detail. Pick the best option.',
        'options': <String>['Option A', 'Option B', 'Option C', 'Option D'],
        'correct': i % 4,
      };
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    setState(() {
      _questions = generated;
      _answers = List<int?>.filled(generated.length, null);
      _selectedIndex = _answers.first;
      index = 0;
      _loading = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onOptionSelected(int questionIndex, int? value) {
    if (_answers[questionIndex] == value) return;
    setState(() {
      _answers[questionIndex] = value;
      if (questionIndex == index) {
        _selectedIndex = value;
      }
    });
  }

  Future<void> _next() async {
    final questions = _questions;
    if (questions == null) return;
    final total = questions.length;
    final bool isLast = index >= total - 1;

    if (!isLast) {
      await controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }

    final int score = List<int>.generate(total, (i) => i)
        .where((i) => _answers[i] != null)
        .where((i) => _answers[i] == questions[i]['correct'])
        .length;

    final String level;
    if (score <= 3) {
      level = 'beginner';
    } else if (score <= 7) {
      level = 'intermediate';
    } else {
      level = 'advanced';
    }

    await _showResultsDialog(score, total, level);
  }

  Future<void> _showResultsDialog(int score, int total, String level) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiz results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Correct answers: $score / $total'),
              const SizedBox(height: 8),
              Text('Suggested level: $level'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    Navigator.of(context).pop({
      'score': score,
      'level': level,
      'quizPassed': score >= total / 2,
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      index = page;
      _selectedIndex = _answers[page];
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = _questions;
    final total = questions?.length ?? 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading || questions == null) {
      return const _QuizSkeleton();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Mini quiz - ${widget.topic}')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (index + 1) / total,
            color: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
          Expanded(
            child: PageView.builder(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _onPageChanged,
              itemCount: total,
              itemBuilder: (context, i) {
                final question = questions[i];
                final List<String> options =
                    (question['options'] as List).cast<String>();
                final int? selectedForPage =
                    i == index ? _selectedIndex : _answers[i];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['question'] as String,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      RadioGroup<int>(
                        groupValue: selectedForPage,
                        onChanged: (value) => _onOptionSelected(i, value),
                        child: Column(
                          children: [
                            for (var optIndex = 0;
                                optIndex < options.length;
                                optIndex++)
                              RadioListTile<int>(
                                value: optIndex,
                                title: Text(options[optIndex]),
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: selectedForPage == null ? null : _next,
                          child: Text(
                            i == total - 1 ? 'Finish' : 'Next',
                          ),
                        ),
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
}

class _QuizSkeleton extends StatelessWidget {
  const _QuizSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mini quiz')),
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
