import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralised configuration loaded from dotenv files with safe fallbacks.
class AppConfig {
  static const String _prodBaseUrl =
      'https://aelion-110324120650.us-east4.run.app';

  static String get env =>
      dotenv.env['AELION_ENV'] ?? (kReleaseMode ? 'production' : 'development');

  /// Base URL used for backend communication.
  static String get apiBaseUrl => _resolveApiBaseUrl();

  /// Public base URL (kept for backwards compatibility).
  static String get baseUrl => apiBaseUrl;

  static String? get cvStudioApiKey => dotenv.env['CV_STUDIO_API_KEY'];

  static bool get premiumEnabled {
    final raw = (dotenv.env['AELION_PREMIUM_ENABLED'] ?? 'false')
        .trim()
        .toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes' || raw == 'on';
  }

  static String _resolveApiBaseUrl() {
    final envCandidates = <String?>[
      dotenv.env['API_BASE_URL'],
      dotenv.env['BASE_URL'],
    ].map(_sanitizeBaseUrl).whereType<String>();

    for (final candidate in envCandidates) {
      if (kReleaseMode && _isLocalhost(candidate)) {
        continue;
      }
      return candidate;
    }

    if (!kReleaseMode) {
      final emulator = _emulatorBaseUrl();
      if (emulator != null) {
        return emulator;
      }
      return 'http://localhost:8787';
    }

    return _prodBaseUrl;
  }

  static String? _sanitizeBaseUrl(String? raw) {
    if (raw == null) {
      return null;
    }
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final withoutTrailingSlash =
        trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
    return withoutTrailingSlash;
  }

  static bool _isLocalhost(String value) {
    final lower = value.toLowerCase();
    return lower.contains('localhost') || lower.contains('127.0.0.1');
  }

  static String? _emulatorBaseUrl() {
    final useEmulator =
        (dotenv.env['USE_FUNCTIONS_EMULATOR'] ?? '').toLowerCase() == 'true';
    if (!useEmulator) {
      return null;
    }
    final project = dotenv.env['FIREBASE_PROJECT_ID']?.trim();
    if (project == null || project.isEmpty) {
      return null;
    }
    final host = dotenv.env['FUNCTIONS_EMULATOR_HOST']?.trim();
    final port = dotenv.env['FUNCTIONS_EMULATOR_PORT']?.trim();
    final resolvedHost = (host == null || host.isEmpty) ? 'localhost' : host;
    final resolvedPort = (port == null || port.isEmpty) ? '5001' : port;
    return 'http://$resolvedHost:$resolvedPort/$project/us-east4';
  }
}