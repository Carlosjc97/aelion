import 'package:flutter/material.dart';

import 'package:edaptia/l10n/app_localizations.dart';

class LessonDetailArgs {
  const LessonDetailArgs({
    required this.courseId,
    required this.moduleTitle,
    required this.lessonTitle,
    this.content,
  });

  final String courseId;
  final String moduleTitle;
  final String lessonTitle;
  final String? content;
}

class LessonDetailPage extends StatelessWidget {
  const LessonDetailPage({super.key, required this.args});

  static const routeName = '/lesson/detail';

  final LessonDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final rawContent = args.content?.trim();
    final bodyText = (rawContent != null && rawContent.isNotEmpty)
        ? rawContent
        : l10n.lessonContentComingSoon;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.lessonTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              args.moduleTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              bodyText,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

