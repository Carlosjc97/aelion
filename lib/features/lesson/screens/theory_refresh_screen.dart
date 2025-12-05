import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/typography.dart';
import 'package:edaptia/services/course_api_service.dart';

import '../models/lesson_view_config.dart';
import '../widgets/lesson_header_widget.dart';
import '../widgets/lesson_takeaway_card.dart';
import '../widgets/next_lesson_button.dart';

class TheoryRefreshScreen extends StatefulWidget {
  const TheoryRefreshScreen({super.key, required this.config});

  static const routeName = '/lesson/theory-refresh';

  final LessonViewConfig config;

  @override
  State<TheoryRefreshScreen> createState() => _TheoryRefreshScreenState();
}

class _TheoryRefreshScreenState extends State<TheoryRefreshScreen> {
  @override
  void initState() {
    super.initState();
    CourseApiService.markLessonVisited(
      topic: widget.config.courseId,
      moduleNumber: widget.config.moduleNumber,
      lessonIndex: widget.config.lessonIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.config.lessonTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LessonHeaderWidget(
              moduleTitle: widget.config.moduleTitle,
              hook: widget.config.hook),
          const SizedBox(height: 16),
          Text('Repaso esencial', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          MarkdownBody(
            data: widget.config.theory,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(theme),
          ),
          const SizedBox(height: 16),
          Text('Aplicación', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          Text(
            widget.config.exampleGlobal,
            style: EdaptiaTypography.body.copyWith(
              color: EdaptiaColors.textSecondary,
            ),
          ),
          if (widget.config.motivation?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            Text('Recuerda', style: EdaptiaTypography.title3),
            const SizedBox(height: 8),
            Text(widget.config.motivation!, style: EdaptiaTypography.body),
          ],
          const SizedBox(height: 24),
          LessonTakeawayCard(takeaway: widget.config.takeaway),
          const SizedBox(height: 12),
          NextLessonButton(config: widget.config),
        ],
      ),
    );
  }
}
