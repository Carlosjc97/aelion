import 'package:flutter/material.dart';

import 'package:edaptia/features/lesson/lesson_router.dart';
import 'package:edaptia/features/lesson/models/lesson_view_config.dart';
import 'package:edaptia/features/quiz/module_gate_quiz_screen.dart';

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
          // Last lesson of module - navigate to module quiz
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(
            ModuleGateQuizScreen.routeName,
            arguments: ModuleGateQuizArgs(
              moduleNumber: config.moduleNumber,
              topic: config.courseId,
              language: 'es',
              moduleTitle: config.moduleTitle,
              lessonTitles: config.allModuleLessons
                  .map((l) => '${l.title}: ${l.hook}')
                  .toList(),
            ),
          );
        }
      },
      icon: Icon(hasNext ? Icons.arrow_forward : Icons.quiz),
      label: Text(hasNext ? 'Siguiente lección' : 'Quiz del módulo'),
    );
  }
}
