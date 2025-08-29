import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart'; // usa AppConfig

class CourseApiService {
  /// Genera el outline de un curso para [topic].
  /// Si no hay config o la request falla, retorna un fallback seguro.
  static Future<Map<String, dynamic>> generateOutline({required String topic}) async {
    if (!AppConfig.isConfigured) {
      return _fallbackOutline(topic);
    }

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/generate-outline');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if ((AppConfig.cvStudioApiKey ?? '').isNotEmpty)
          'Authorization': 'Bearer ${AppConfig.cvStudioApiKey}',
      };

      final body = jsonEncode(<String, dynamic>{
        'topic': topic,
        'lang': 'es',
        'level': 'beginner',
      });

      final res = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // ignoramos en MVP y caemos al fallback
    }

    return _fallbackOutline(topic);
  }

  /// Genera el contenido de una lección (si tu backend lo soporta).
  /// Si no hay config o falla, retorna un fallback simple.
  static Future<Map<String, dynamic>> generateLesson({
    required String topic,
    required String lessonId,
  }) async {
    if (!AppConfig.isConfigured) {
      return _fallbackLesson(topic: topic, lessonId: lessonId);
    }

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/generate-lesson');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if ((AppConfig.cvStudioApiKey ?? '').isNotEmpty)
          'Authorization': 'Bearer ${AppConfig.cvStudioApiKey}',
      };

      final body = jsonEncode(<String, dynamic>{
        'topic': topic,
        'lessonId': lessonId,
        'lang': 'es',
      });

      final res = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // ignoramos en MVP y caemos al fallback
    }

    return _fallbackLesson(topic: topic, lessonId: lessonId);
  }

  // ===== Fallbacks seguros (nunca pantalla blanca) =====

  static Map<String, dynamic> _fallbackOutline(String topic) {
    return <String, dynamic>{
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

  static Map<String, dynamic> _fallbackLesson({
    required String topic,
    required String lessonId,
  }) {
    return <String, dynamic>{
      "lessonId": lessonId,
      "title": "Lección de $topic",
      "content":
          "Contenido de ejemplo para $lessonId en el tema $topic.\n\n(Esto es un fallback local.)",
    };
  }
}
