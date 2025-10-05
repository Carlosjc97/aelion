import 'package:flutter/material.dart';

import 'package:aelion/features/modules/module_outline_view.dart';
import 'package:aelion/features/quiz/quiz_screen.dart';
import 'package:aelion/widgets/skeleton.dart';

class TopicSearchArgs {
  const TopicSearchArgs({required this.originLabel, required this.placeholder});

  final String originLabel;
  final String placeholder;
}

class TopicSearchView extends StatefulWidget {
  const TopicSearchView({super.key});

  static const routeName = '/topic-search';

  @override
  State<TopicSearchView> createState() => _TopicSearchViewState();
}

class _TopicSearchViewState extends State<TopicSearchView> {
  final TextEditingController controller = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _startQuiz() async {
    final topic = controller.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Type a topic to continue')));
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
    final title = args?.originLabel ?? 'Search a topic';
    final hint = args?.placeholder ?? 'What do you want to learn?';

    final body = Padding(
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
            label: const Text('Take mini quiz'),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          body,
          if (busy) const _TopicLoadingOverlay(),
        ],
      ),
    );
  }
}

class _TopicLoadingOverlay extends StatelessWidget {
  const _TopicLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.85),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Skeleton(height: 56, width: 260),
              SizedBox(height: 12),
              Skeleton(height: 48, width: 200),
            ],
          ),
        ),
      ),
    );
  }
}
