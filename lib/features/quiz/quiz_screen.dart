import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  static const routeName = '/quiz';
  final String topic;
  const QuizScreen({super.key, required this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final PageController controller = PageController();
  int index = 0;
  int? _selectedIndex;
  late final List<Map<String, dynamic>> _questions;
  late final List<int?> _answers;

  @override
  void initState() {
    super.initState();
    _questions = List.generate(
      10,
      (i) => {
        'q':
            'Pregunta ${i + 1} sobre ${widget.topic}: ${i.isEven ? 'concepto' : 'practica'}. Cual es la opcion correcta?',
        'opts': <String>['A', 'B', 'C', 'D'],
        'correct': i % 4,
      },
    );
    _answers = List<int?>.filled(_questions.length, null);
    _selectedIndex = _answers.first;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onOptionSelected(int questionIndex, int? value) {
    setState(() {
      _answers[questionIndex] = value;
      if (questionIndex == index) {
        _selectedIndex = value;
      }
    });
  }

  Future<void> _next() async {
    final total = _questions.length;
    final bool isLast = index >= total - 1;

    if (!isLast) {
      await controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }

    final int score = List.generate(total, (i) => i)
        .where((i) => _answers[i] != null)
        .where((i) => _answers[i] == _questions[i]['correct'])
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
          title: const Text('Resultados del quiz'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aciertos: $score/$total'),
              const SizedBox(height: 8),
              Text('Nivel asignado: $level'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      index = page;
      _selectedIndex = _answers[page];
    });
  }

  @override
  Widget build(BuildContext context) {
    final int total = _questions.length;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Mini test - ${widget.topic}')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (index + 1) / total,
            color: cs.primary,
            backgroundColor: cs.surfaceContainerHighest,
          ),
          Expanded(
            child: PageView.builder(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _onPageChanged,
              itemCount: total,
              itemBuilder: (context, i) {
                final question = _questions[i];
                final List<String> options = (question['opts'] as List).cast<String>();
                final int? selectedForPage = i == index ? _selectedIndex : _answers[i];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['q'] as String,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      RadioGroup<int>(
                        groupValue: selectedForPage,
                        onChanged: (value) => _onOptionSelected(i, value),
                        child: Column(
                          children: [
                            for (var optIndex = 0; optIndex < options.length; optIndex++)
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
                          child: Text(i == total - 1 ? 'Terminar' : 'Siguiente'),
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
