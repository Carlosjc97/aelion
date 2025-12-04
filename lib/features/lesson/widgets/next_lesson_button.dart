import 'package:flutter/material.dart';

import 'package:edaptia/features/lesson/lesson_router.dart';
import 'package:edaptia/features/lesson/models/lesson_view_config.dart';

class NextLessonButton extends StatelessWidget {
  const NextLessonButton({
    super.key,
    required this.config,
  });

  final LessonViewConfig config;

  @override
  Widget build(BuildContext context) {
    final hasNext = config.hasNextLesson;
    final nextLesson = config.nextLesson;
    return FilledButton.icon(
      onPressed: () {
        if (hasNext && nextLesson != null) {
          // Pop current lesson first, then navigate to next
          Navigator.of(context).pop();
          LessonRouter.navigateToLesson(
            context: context,
            lesson: nextLesson,
            moduleTitle: config.moduleTitle,
            moduleNumber: config.moduleNumber,
            lessonIndex: config.lessonIndex + 1,
            courseId: config.courseId,
            allModuleLessons: config.allModuleLessons,
          );
        } else {
          // Last lesson of module - return to adaptive journey
          Navigator.of(context).pop();
        }
      },
      icon: Icon(hasNext ? Icons.arrow_forward : Icons.check_circle),
      label: Text(hasNext ? 'Siguiente lección' : 'Volver al recorrido'),
    );
  }
}
