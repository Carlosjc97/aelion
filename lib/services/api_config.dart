import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart'; // Usa AppConfig (no ApiConfig)

class CourseApiService {
  /// Genera el outline de un curso para [topic].
  /// Intenta llamar al backend (`/courses/outline`). Si falla, devuelve un mock seguro.
  static Future<Map<String, dynamic>> generateOutline({required String topic}) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/courses/outline');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if ((AppConfig.cvStudioApiKey ?? '').isNotEmpty)
          'Authorization': 'Bearer ${AppConfig.cvStudioApiKey}',
      };

      final body = jsonEncode({
        'topic': topic,
        'lang': 'es', // MVP por defecto
        'level': 'beginner',
      });

      final res = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data;
      }
    } catch (_) {
      // Ignoramos en MVP; caemos al fallback
    }

    // Fallback seguro (nunca pantalla blanca)
    return {
      "topic": topic,
      "level": "beginner",
      "estimated_hours": 2,
      "modules": [
        {
          "id": "m1",
          "title": "Introducción",
          "locked": false,
          "lessons": [
            {"id": "m1l1", "title": "Definición", "locked": false, "status": "todo"},
            {
              "id": "m1l2",
              "title": "Ejemplo práctico",
              "locked": true,
              "status": "todo",
              "premium": true
            },
          ]
        }
      ]
    };
  }

  /// Sincroniza progreso (best-effort); silencioso si falla en este MVP.
  static Future<void> syncProgress(String courseId, Map<String, dynamic> progressData) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/courses/$courseId/progress');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if ((AppConfig.cvStudioApiKey ?? '').isNotEmpty)
          'Authorization': 'Bearer ${AppConfig.cvStudioApiKey}',
      };

      await http
          .post(uri, headers: headers, body: jsonEncode(progressData))
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Ignorar en MVP
    }
  }
}
