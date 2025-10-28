import 'package:aelion/services/api_config.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get env =>
      dotenv.env['AELION_ENV'] ?? (kReleaseMode ? 'production' : 'development');

  static String get baseUrl => ApiConfig.apiBaseUrl;

  static bool get hasCvStudioKey {
    final key = dotenv.env['CV_STUDIO_API_KEY'] ?? '';
    return key.isNotEmpty && key != 'changeme';
  }
}
