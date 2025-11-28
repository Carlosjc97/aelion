enum LessonType {
  welcomeSummary('welcome_summary'),
  diagnosticQuiz('diagnostic_quiz'),
  guidedPractice('guided_practice'),
  activity('activity'),
  miniGame('mini_game'),
  theoryRefresh('theory_refresh'),
  appliedProject('applied_project'),
  reflection('reflection');

  const LessonType(this.value);
  final String value;
}

LessonType lessonTypeFromRaw(String? raw) {
  final key = raw?.trim().toLowerCase();
  if (key == null || key.isEmpty) {
    return LessonType.welcomeSummary;
  }
  for (final type in LessonType.values) {
    if (type.value == key) {
      return type;
    }
  }
  return LessonType.welcomeSummary;
}

extension LessonTypeX on LessonType {
  String get analyticsLabel {
    switch (this) {
      case LessonType.welcomeSummary:
        return 'welcome_summary';
      case LessonType.diagnosticQuiz:
        return 'diagnostic_quiz';
      case LessonType.guidedPractice:
        return 'guided_practice';
      case LessonType.activity:
        return 'activity';
      case LessonType.miniGame:
        return 'mini_game';
      case LessonType.theoryRefresh:
        return 'theory_refresh';
      case LessonType.appliedProject:
        return 'applied_project';
      case LessonType.reflection:
        return 'reflection';
    }
  }

  bool get usesMicroQuiz =>
      this == LessonType.diagnosticQuiz || this == LessonType.miniGame;

  bool get usesPractice =>
      this == LessonType.guidedPractice ||
      this == LessonType.activity ||
      this == LessonType.appliedProject;
}
