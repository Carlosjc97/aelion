import 'package:flutter/material.dart';

import 'package:edaptia/features/quiz/quiz_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/widgets/skeleton.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final topic = controller.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.topicSearchMissingTopic)),
      );
      return;
    }
    if (busy) return;

    setState(() => busy = true);
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      await Navigator.pushNamed(
        context,
        QuizScreen.routeName,
        arguments: QuizScreenArgs(
          topic: topic,
          language: languageCode,
        ),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final args = ModalRoute.of(context)?.settings.arguments as TopicSearchArgs?;
    final title = args?.originLabel ?? l10n.topicSearchTitleFallback;
    final hint = args?.placeholder ?? l10n.topicSearchHintFallback;

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
            label: Text(l10n.topicSearchStartButton),
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

