import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/typography.dart';

import '../models/lesson_view_config.dart';
import '../widgets/lesson_header_widget.dart';
import '../widgets/lesson_takeaway_card.dart';

class WelcomeLessonScreen extends StatelessWidget {
  const WelcomeLessonScreen({super.key, required this.config});

  static const routeName = '/lesson/welcome';

  final LessonViewConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(config.lessonTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LessonHeaderWidget(
              moduleTitle: config.moduleTitle, hook: config.hook),
          const SizedBox(height: 16),
          Text('Teoría clave', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          MarkdownBody(
            data: config.theory,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              p: EdaptiaTypography.body,
            ),
          ),
          const SizedBox(height: 16),
          Text('Ejemplo práctico', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          Text(
            config.exampleGlobal,
            style: EdaptiaTypography.body.copyWith(
              color: EdaptiaColors.textSecondary,
            ),
          ),
          if (config.motivation?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            Text('Motivación', style: EdaptiaTypography.title3),
            const SizedBox(height: 8),
            Text(
              config.motivation!,
              style: EdaptiaTypography.body.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 24),
          LessonTakeawayCard(takeaway: config.takeaway),
        ],
      ),
    );
  }
}
