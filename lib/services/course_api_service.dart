import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class CourseApiService {
  // Genera SOLO el outline (módulos/lecciones). Si no hay backend, devuelve MOCK.
  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
    String level = 'beginner',
  }) async {
    if (!ApiConfig.isConfigured) {
      return {
        "topic": topic,
        "level": level,
        "estimated_hours": 4,
        "modules": [
          {
            "id": "m1",
            "title": "Fundamentos de $topic",
            "locked": false,
            "lessons": [
              {"id": "m1l1", "title": "¿Qué es $topic?", "locked": false, "status": "todo"},
              {"id": "m1l2", "title": "Instalación y setup", "locked": true, "status": "todo"},
            ]
          },
          {
            "id": "m2",
            "title": "Primeros pasos con $topic",
            "locked": true,
            "lessons": [
              {"id": "m2l1", "title": "Tu primer ejemplo", "locked": true, "status": "todo"},
              {"id": "m2l2", "title": "Buenas prácticas", "locked": true, "status": "todo"},
            ]
          }
        ]
      };
    }

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/generate-outline'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'topic': topic, 'level': level}),
    );
    if (res.statusCode != 200) {
      throw Exception('Outline failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // Preparado para cuando conectes backend real (por ahora no lo usamos en UI).
  static Future<Map<String, dynamic>> generateLesson({
    required String topic,
    required String moduleId,
    required String lessonId,
    required String lessonTitle,
  }) async {
    if (!ApiConfig.isConfigured) {
      return {
        "title": lessonTitle,
        "summary": "Resumen rápido de $lessonTitle.",
        "sections": [
          {"heading": "Concepto", "content_md": "Explicación breve de **$lessonTitle**."},
          {"heading": "Ejemplo", "content_md": "Código o caso de uso simple."}
        ],
        "resources": []
      };
    }
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/generate-lesson'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic': topic,
        'moduleId': moduleId,
        'lessonId': lessonId,
        'lessonTitle': lessonTitle,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Lesson failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
