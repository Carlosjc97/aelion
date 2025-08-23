import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get env => dotenv.env['AELION_ENV'] ?? 'desconocido';
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static bool get hasCvStudioKey {
    final key = dotenv.env['CV_STUDIO_API_KEY'] ?? '';
    return key.isNotEmpty && key != 'changeme';
  }
}
