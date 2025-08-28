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
  final answers = <int, int?>{};
  final questions = List.generate(
    10,
    (i) => {
      'q': 'Pregunta ${i + 1}: ¿…sobre ${i.isEven ? 'concepto' : 'práctica'}?',
      'opts': ['A', 'B', 'C', 'D'],
      'correct': 1,
    },
  );

  void _next() {
    if (index < questions.length - 1) {
      controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      Navigator.pop(context); // vuelve al Outline
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias! Ajustaremos tu curso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
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
                final value = answers[i];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q['q'] as String, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      for (var optIndex = 0; optIndex < 4; optIndex++)
                        RadioListTile<int>(
                          value: optIndex,
                          groupValue: value,
                          title: Text('${q['opts']![optIndex]}'),
                          onChanged: (v) => setState(() => answers[i] = v),
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
