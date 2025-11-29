import 'package:edaptia/services/course/models.dart';

import 'lesson_types.dart';

class LessonScreenArgs {
  const LessonScreenArgs({required this.config});

  final LessonViewConfig config;
}

class LessonViewConfig {
  const LessonViewConfig({
    required this.courseId,
    required this.moduleTitle,
    required this.moduleNumber,
    required this.lessonIndex,
    required this.lessonTitle,
    required this.hook,
    required this.theory,
    required this.exampleGlobal,
    required this.takeaway,
    required this.lessonType,
    this.motivation,
    this.microQuiz = const <AdaptiveMcq>[],
    this.practice,
    this.hint,
  });

  final String courseId;
  final String moduleTitle;
  final int moduleNumber;
  final int lessonIndex;
  final String lessonTitle;
  final String hook;
  final String theory;
  final String exampleGlobal;
  final String? motivation;
  final String takeaway;
  final LessonType lessonType;
  final List<AdaptiveMcq> microQuiz;
  final AdaptiveLessonPractice? practice;
  final String? hint;

  bool get hasMicroQuiz => microQuiz.isNotEmpty;
  bool get hasPractice => practice != null;

  factory LessonViewConfig.fromAdaptiveLesson(
    AdaptiveLesson lesson, {
    required String moduleTitle,
    required int moduleNumber,
    required int lessonIndex,
    required String courseId,
  }) {
    return LessonViewConfig(
      courseId: courseId,
      moduleTitle: moduleTitle,
      moduleNumber: moduleNumber,
      lessonIndex: lessonIndex,
      lessonTitle: lesson.title,
      hook: lesson.hook,
      theory: lesson.theory,
      exampleGlobal: lesson.exampleGlobal,
      motivation: lesson.motivation,
      takeaway: lesson.takeaway,
      lessonType: lessonTypeFromRaw(lesson.lessonType),
      microQuiz: lesson.microQuiz,
      practice: lesson.practice,
      hint: lesson.hint,
    );
  }
}
