import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Servicio de curso – usa AppConfig. No depende de `isConfigured`.
class CourseApiService {
  static bool get _configured =>
      (AppConfig.baseUrl).trim().isNotEmpty &&
      AppConfig.baseUrl.startsWith('http');

  /// Genera outline de curso desde el backend; si falla, usa fallback.
  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
  }) async {
    if (_configured) {
      try {
        final resp = await http.post(
          Uri.parse('${AppConfig.baseUrl}/generate-outline'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'topic': topic}),
        );
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          if (data['modules'] is List) return data;
        }
      } catch (_) {
        // cae al fallback
      }
    }

    // Fallback mínimo
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
            {"id": "m1l2", "title": "Ejemplo práctico", "locked": true, "status": "todo", "premium": true},
          ]
        }
      ]
    };
  }

  /// Genera una lección (bilingüe eventualmente). Fallback si no hay backend.
  static Future<Map<String, dynamic>> generateLesson({
    required String moduleId,
    required String lessonId,
  }) async {
    if (_configured) {
      try {
        final resp = await http.post(
          Uri.parse('${AppConfig.baseUrl}/generate-lesson'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'moduleId': moduleId, 'lessonId': lessonId}),
        );
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          return data;
        }
      } catch (_) {
        // cae al fallback
      }
    }

    return {
      "lessonId": lessonId,
      "title": "Lección $lessonId",
      "content": "Contenido generado de ejemplo para $lessonId.",
      "lang": "es",
    };
  }
}
