import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Usa API_BASE_URL si existe; si no, usa BASE_URL; si no, vacío.
  static String get baseUrl {
    final a = dotenv.maybeGet('API_BASE_URL')?.trim();
    if (a != null && a.isNotEmpty) return a;
    final b = dotenv.maybeGet('BASE_URL')?.trim();
    if (b != null && b.isNotEmpty) return b;
    return '';
  }

  static bool get isConfigured => baseUrl.isNotEmpty;
}
