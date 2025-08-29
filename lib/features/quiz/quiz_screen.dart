import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  static const routeName = '/quiz';
  final String topic;
  const QuizScreen({super.key, required this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final controller = PageController();
  int index = 0;

  // índice de pregunta -> respuesta seleccionada
  final Map<int, int?> answers = {};

  // 10 preguntas dummy
  late final List<Map<String, dynamic>> questions = List.generate(
    10,
    (i) => {
      'q': 'Pregunta ${i + 1}: ¿…sobre ${i.isEven ? 'concepto' : 'práctica'}?',
      'opts': <String>['A', 'B', 'C', 'D'],
      'correct': i % 4,
    },
  );

  void _next() async {
    if (index < questions.length - 1) {
      await controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }

    int score = 0;
    for (var i = 0; i < questions.length; i++) {
      final selected = answers[i];
      final correct = questions[i]['correct'] as int;
      if (selected != null && selected == correct) score++;
    }

    String level;
    if (score <= 3) {
      level = 'beginner';
    } else if (score <= 7) {
      level = 'intermediate';
    } else {
      level = 'advanced';
    }

    if (!mounted) return;
    Navigator.pop(context, {
      'quizPassed': true,
      'score': score,
      'level': level,
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Mini test – ${widget.topic}')),
      body: Column(
        children: [
          LinearProgressIndicator(value: (index + 1) / total),
          Expanded(
            child: PageView.builder(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => index = i),
              itemCount: total,
              itemBuilder: (context, i) {
                final q = questions[i];
                final List<String> opts = (q['opts'] as List).cast<String>();
                final value = answers[i];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q['q'] as String, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),

                      // ✅ Nuevo patrón con RadioGroup (sin deprecations)
                      RadioGroup<int>(
                        value: value,
                        onChanged: (v) => setState(() => answers[i] = v),
                        child: Column(
                          children: [
                            for (var optIndex = 0; optIndex < opts.length; optIndex++)
                              RadioListTile<int>(
                                value: optIndex,
                                // groupValue/onChanged se manejan por RadioGroup
                                title: Text(opts[optIndex]),
                              ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      FilledButton(
                        onPressed: value == null ? null : _next,
                        child: Text(i == total - 1 ? 'Terminar' : 'Siguiente'),
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
