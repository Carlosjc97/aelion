import 'package:flutter/foundation.dart' show kReleaseMode;

class ApiConfig {
  static const String _fixedHost =
      'https://us-east4-aelion-c90d2.cloudfunctions.net';

  // Assessment API (Cloud Run)
  static const String _assessmentApiHost =
      'https://assessment-api-110324120650.us-central1.run.app';

  // En debug puedes permitir override por env; en release, SIEMPRE fijo y https.
  static String get apiBaseUrl {
    if (kReleaseMode) return _fixedHost;
    final env =
        const String.fromEnvironment('API_BASE_URL', defaultValue: _fixedHost);
    final lower = env.toLowerCase();
    if (!lower.startsWith('https://') || lower.contains('localhost')) {
      return _fixedHost;
    }
    return env;
  }

  static String get assessmentApiUrl => _assessmentApiHost;

  static String outline() => '$apiBaseUrl/outline';
  static String quiz() => '$apiBaseUrl/quiz';
  static String placementQuizStart() => '$apiBaseUrl/placementQuizStart';
  static String placementQuizGrade() => '$apiBaseUrl/placementQuizGrade';
  static String trackSearch() => '$apiBaseUrl/trackSearch';
  static String trending(String lang) => '$apiBaseUrl/trending?lang=$lang';

  // Assessment API endpoints (IRT adaptive testing)
  static String assessmentStart() => '$assessmentApiUrl/assessment/start';
  static String assessmentAnswer() => '$assessmentApiUrl/assessment/answer';
  static String assessmentFinish() => '$assessmentApiUrl/assessment/finish';
  static String assessmentHealth() => '$assessmentApiUrl/health';
}
