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

  void _select(int qIndex, int optIndex) {
    setState(() => answers[qIndex] = optIndex);
  }

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
                final selected = answers[i];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q['q'] as String, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),

                      // Opciones SIN RadioListTile (evita deprecations)
                      for (var optIndex = 0; optIndex < opts.length; optIndex++)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            onTap: () => _select(i, optIndex),
                            leading: Icon(
                              selected == optIndex
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                            ),
                            title: Text(opts[optIndex]),
                          ),
                        ),

                      const Spacer(),
                      FilledButton(
                        onPressed: selected == null ? null : _next,
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
