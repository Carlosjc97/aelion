import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ConfiguraciÃ³n centralizada leÃ­da desde .env / env.public
class AppConfig {
  static String get env => dotenv.env['AELION_ENV'] ?? 'development';

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  static String? get cvStudioApiKey => dotenv.env['CV_STUDIO_API_KEY'];

  /// Flag premium controlado por .env
  ///
  /// Acepta: true/false, 1/0, yes/no, on/off (case-insensitive)
  static bool get premiumEnabled {
    final raw =
        (dotenv.env['AELION_PREMIUM_ENABLED'] ?? 'false').trim().toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes' || raw == 'on';
  }
}
