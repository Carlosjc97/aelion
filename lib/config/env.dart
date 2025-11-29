import 'package:edaptia/services/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Unified environment configuration
class Env {
  Env._();

  static final DotEnv _env = dotenv;

  // Environment & Base URL
  static String get env =>
      _env.env['AELION_ENV'] ?? (kReleaseMode ? 'production' : 'development');

  static String get baseUrl => ApiConfig.apiBaseUrl;

  // PostHog Analytics
  static String get posthogKey =>
      _read('POSTHOG_KEY', fallback: kReleaseMode ? '' : 'ph_dev_placeholder');

  static String get posthogHost => _read(
        'POSTHOG_HOST',
        fallback: 'https://us.i.posthog.com',
      );

  // CV Studio Integration
  static bool get hasCvStudioKey {
    final key = _env.env['CV_STUDIO_API_KEY'] ?? '';
    return key.isNotEmpty && key != 'changeme';
  }

  // Helper
  static String _read(String key, {String fallback = ''}) {
    final value = _env.env[key];
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }
}
