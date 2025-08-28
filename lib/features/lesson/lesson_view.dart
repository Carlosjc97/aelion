import 'package:flutter/material.dart';

class LessonView extends StatelessWidget {
  static const routeName = '/lesson';

  final String? lessonId;
  final String title;
  final String content;

  const LessonView({
    super.key,
    this.lessonId,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (lessonId != null)
              Text('ID: $lessonId', style: text.titleMedium),
            const SizedBox(height: 12),
            Text(content, style: text.bodyLarge),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Marcar como completada'),
            ),
          ],
        ),
      ),
    );
  }
}
