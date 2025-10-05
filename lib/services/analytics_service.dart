import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logCourseStarted(String topic) =>
      _analytics.logEvent(name: 'course_started', parameters: {'topic': topic});

  Future<void> logQuestionAnswered(
          {required String topic, required bool correct}) =>
      _analytics.logEvent(
          name: 'question_answered',
          parameters: {'topic': topic, 'correct': correct});

  Future<void> logCourseCompleted(String topic) => _analytics
      .logEvent(name: 'course_completed', parameters: {'topic': topic});

  Future<void> logCourseAbandoned(String topic) => _analytics
      .logEvent(name: 'course_abandoned', parameters: {'topic': topic});
}
