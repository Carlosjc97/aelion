import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CourseApiService {
  static String get _base =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8787';

  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'topic': topic}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final questions = (data['questions'] as List?) ?? const [];

        // Construye 3 módulos x 3 lecciones (si no hay 9 preguntas, rellena)
        final totalLessons = 9;
        final q = List<Map<String, dynamic>>.from(
          questions.cast<Map?>().whereType<Map>(),
        );

        while (q.length < totalLessons) {
          q.add({
            'q': 'Tema: $topic',
            'a': 'A',
            'b': 'B',
            'c': 'C',
            'd': 'D',
            'correct': 'a',
          });
        }

        final modules = <Map<String, dynamic>>[];
        for (var m = 0; m < 3; m++) {
          final lessons = <Map<String, dynamic>>[];
          for (var i = 0; i < 3; i++) {
            final idx = m * 3 + i;
            lessons.add({
              'id': 'm${m + 1}l${i + 1}',
              'title': 'Lección ${idx + 1}',
              'locked': !(m == 0 && i == 0),
              'status': 'todo',
            });
          }
          modules.add({
            'id': 'm${m + 1}',
            'title': 'Módulo ${m + 1}',
            'locked': m > 0,
            'lessons': lessons,
          });
        }

        return {
          'topic': topic,
          'level': 'beginner',
          'estimated_hours': 2,
          'modules': modules,
        };
      }
    } catch (_) {
      // continúa a fallback
    }

    // Fallback local si falla
    return _fallbackOutline(topic);
  }

  static Map<String, dynamic> _fallbackOutline(String topic) => {
    'topic': topic,
    'level': 'beginner',
    'estimated_hours': 1,
    'modules': [
      {
        'id': 'm1',
        'title': 'Introducción',
        'locked': false,
        'lessons': [
          {
            'id': 'm1l1',
            'title': 'Bienvenida',
            'locked': false,
            'status': 'todo',
          },
          {
            'id': 'm1l2',
            'title': 'Conceptos clave',
            'locked': true,
            'status': 'todo',
          },
        ],
      },
      {
        'id': 'm2',
        'title': 'Práctica',
        'locked': true,
        'lessons': [
          {
            'id': 'm2l1',
            'title': 'Ejercicios guiados',
            'locked': true,
            'status': 'todo',
          },
        ],
      },
    ],
  };
}
