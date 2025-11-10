import 'package:flutter/foundation.dart' show kReleaseMode;

class ApiConfig {
  // ALL functions now in us-central1
  static const String _fixedHost =
      'https://us-central1-aelion-c90d2.cloudfunctions.net';

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

  static String outline() => '$apiBaseUrl/outline';
  static String outlineGenerative() => '$apiBaseUrl/outlineGenerative';
  static String outlineTweak() => '$apiBaseUrl/outlineTweak';
  static String quiz() => '$apiBaseUrl/quiz';
  static String placementQuizStart() => '$apiBaseUrl/placementQuizStart';
  static String placementQuizStartLive() =>
      '$apiBaseUrl/placementQuizStartLive';
  static String placementQuizGrade() => '$apiBaseUrl/placementQuizGrade';
  static String fetchNextModule() => '$apiBaseUrl/fetchNextModule';
  static String moduleQuizStart() => '$apiBaseUrl/moduleQuizStart';
  static String moduleQuizGrade() => '$apiBaseUrl/moduleQuizGrade';
  static String validateChallenge() => '$apiBaseUrl/validateChallenge';
  static String trackSearch() => '$apiBaseUrl/trackSearch';
  static String trending(String lang) => '$apiBaseUrl/trending?lang=$lang';
  static String openaiUsageMetrics() => '$apiBaseUrl/openaiUsageMetrics';
}
