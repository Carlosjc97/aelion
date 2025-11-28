import 'package:flutter/material.dart';

import 'package:edaptia/services/course/models.dart';

import 'models/lesson_types.dart';
import 'models/lesson_view_config.dart';
import 'screens/activity_screen.dart';
import 'screens/applied_project_screen.dart';
import 'screens/diagnostic_quiz_screen.dart';
import 'screens/guided_practice_screen.dart';
import 'screens/mini_game_screen.dart';
import 'screens/reflection_screen.dart';
import 'screens/theory_refresh_screen.dart';
import 'screens/welcome_lesson_screen.dart';

class LessonRouter {
  const LessonRouter._();

  static Future<void> navigateToLesson({
    required BuildContext context,
    required AdaptiveLesson lesson,
    required String moduleTitle,
    required String courseId,
  }) async {
    final config = LessonViewConfig.fromAdaptiveLesson(
      lesson,
      moduleTitle: moduleTitle,
      courseId: courseId,
    );
    final routeName = _getRouteForLessonType(config.lessonType);
    await Navigator.pushNamed(
      context,
      routeName,
      arguments: LessonScreenArgs(config: config),
    );
  }

  static String _getRouteForLessonType(LessonType type) {
    switch (type) {
      case LessonType.diagnosticQuiz:
        return DiagnosticQuizScreen.routeName;
      case LessonType.miniGame:
        return MiniGameScreen.routeName;
      case LessonType.guidedPractice:
        return GuidedPracticeScreen.routeName;
      case LessonType.activity:
        return ActivityScreen.routeName;
      case LessonType.appliedProject:
        return AppliedProjectScreen.routeName;
      case LessonType.reflection:
        return ReflectionScreen.routeName;
      case LessonType.theoryRefresh:
        return TheoryRefreshScreen.routeName;
      case LessonType.welcomeSummary:
        return WelcomeLessonScreen.routeName;
    }
  }
}
