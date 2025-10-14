import 'package:flutter/material.dart';

import 'package:aelion/services/course_api_service.dart';
import 'package:aelion/widgets/skeleton.dart';

typedef QuizLoader = Future<List<QuizQuestionDto>> Function({
  required String topic,
  required int numQuestions,
  required String language,
});

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.topic, this.quizLoader});

  static const routeName = '/quiz';

  final String topic;
  final QuizLoader? quizLoader;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final PageController controller = PageController();
  List<QuizQuestionDto>? _questions;
  List<int?> _answers = const [];
  int index = 0;
  int? _selectedIndex;
  bool _loading = true;
  String? _error;
  bool _didInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialLoad) {
      _didInitialLoad = true;
      _loadQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final localeLanguage = Localizations.localeOf(context).languageCode;
      final loader = widget.quizLoader ?? CourseApiService.generateQuiz;
      final questions = await loader(
        topic: widget.topic,
        numQuestions: 10,
        language: localeLanguage,
      );

      if (!mounted) return;
      setState(() {
        _questions = questions;
        _answers = List<int?>.filled(questions.length, null);
        _selectedIndex = null;
        index = 0;
        _loading = false;
      });

      if (controller.hasClients) {
        controller.jumpToPage(0);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _answers = const [];
        _error = 'Failed to load quiz: ${error.toString()}';
        _loading = false;
      });
    }
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
        .where((i) {
      final correctIndex = questions[i].correctIndex;
      if (correctIndex < 0) {
        return false;
      }
      return _answers[i] == correctIndex;
    }).length;

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
    if (_loading) {
      return const _QuizSkeleton();
    }

    final questions = _questions;
    if (_error != null || questions == null || questions.isEmpty) {
      return _QuizError(
        topic: widget.topic,
        message: _error ?? 'Unable to load quiz questions.',
        onRetry: _loadQuestions,
      );
    }

    final total = questions.length;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Mini quiz - ${widget.topic}')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: total == 0 ? 0 : (index + 1) / total,
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
                final options = question.options;
                final int? selectedForPage =
                    i == index ? _selectedIndex : _answers[i];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.question,
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Mini quiz - $topic')),
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
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
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
