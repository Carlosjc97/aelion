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

  // Tipado explícito para evitar Object
  late final List<Map<String, dynamic>> questions = List.generate(
    10,
    (i) => {
      'q': 'Pregunta ${i + 1}: ¿…sobre ${i.isEven ? 'concepto' : 'práctica'}?',
      'opts': <String>['A', 'B', 'C', 'D'],
      'correct': 1,
    },
  );

  void _next() {
    if (index < questions.length - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias! Ajustaremos tu curso.')),
      );
    }
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
                      for (var optIndex = 0; optIndex < opts.length; optIndex++)
                        RadioListTile<int>(
                          value: optIndex,
                          groupValue: value, // deprecation: aviso, no bloquea
                          title: Text(opts[optIndex]),
                          onChanged: (v) => setState(() => answers[i] = v), // idem
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
