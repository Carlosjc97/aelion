import 'package:aelion/services/api_config.dart';

class Env {
  static String get env => AppConfig.env;

  static String get baseUrl => AppConfig.apiBaseUrl;

  static bool get hasCvStudioKey {
    final key = AppConfig.cvStudioApiKey ?? '';
    return key.isNotEmpty && key != 'changeme';
  }
}
