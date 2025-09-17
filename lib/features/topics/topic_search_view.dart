import 'package:flutter/material.dart';
import 'package:learning_ia/features/quiz/quiz_screen.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

class TopicSearchArgs {
  final String originLabel;
  final String placeholder;
  const TopicSearchArgs({required this.originLabel, required this.placeholder});
}

class TopicSearchView extends StatefulWidget {
  static const routeName = '/topic-search';
  const TopicSearchView({super.key});

  @override
  State<TopicSearchView> createState() => _TopicSearchViewState();
}

class _TopicSearchViewState extends State<TopicSearchView> {
  final controller = TextEditingController();
  bool busy = false;

  Future<void> _startQuiz() async {
    final topic = controller.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un tema para continuar')),
      );
      return;
    }
    if (busy) return;

    setState(() => busy = true);
    try {
      final result = await Navigator.pushNamed(
        context,
        QuizScreen.routeName,
        arguments: topic,
      );

      if (!mounted) return;
      if (result is Map && result['quizPassed'] == true) {
        await Navigator.pushNamed(
          context,
          ModuleOutlineView.routeName,
          arguments: topic,
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as TopicSearchArgs?;
    final title = args?.originLabel ?? 'Busca un tema';
    final hint = args?.placeholder ?? '¿Qué quieres aprender?';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _startQuiz(),
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: busy ? null : _startQuiz,
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Hacer mini test'),
            ),
          ],
        ),
      ),
    );
  }
}
