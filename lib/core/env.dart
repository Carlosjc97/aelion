import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  /// Devuelve el entorno configurado o 'desconocido' si no hay configuraciÃ³n.
  static String get env => dotenv.isInitialized
      ? dotenv.env['AELION_ENV'] ?? 'desconocido'
      : 'desconocido';

  /// Devuelve la URL base (BASE_URL) o una cadena vacÃ­a si no estÃ¡ configurada.
  static String get baseUrl =>
      dotenv.isInitialized ? dotenv.env['BASE_URL'] ?? '' : '';

  /// Indica si hay una clave CV_STUDIO_API_KEY configurada y que no sea 'changeme'.
  static bool get hasCvStudioKey {
    if (!dotenv.isInitialized) return false;
    final key = dotenv.env['CV_STUDIO_API_KEY'] ?? '';
    return key.isNotEmpty && key != 'changeme';
  }
}
