import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CourseApiService {
  /// Base del proxy. Usa API_BASE_URL del .env (ej: http://192.168.100.21:8787)
  static String get _base {
    final raw = dotenv.env['API_BASE_URL']?.trim();
    if (raw == null || raw.isEmpty) return 'http://localhost:8787';
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static Uri _uri(String path) => Uri.parse('$_base$path');

  /// Obtiene preguntas tipo test desde el proxy (/quiz).
  /// Formato esperado: { questions: [ { q,a,b,c,d,correct }, ... ] }
  static Future<List<Map<String, dynamic>>> fetchQuiz({
    required String topic,
  }) async {
    try {
      final res = await http.post(
        _uri('/quiz'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'topic': topic}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final arr = data['questions'];
        if (arr is List) {
          return arr
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (_) {
      // ignora y cae al fallback
    }

    // Fallback local si falla la API
    return [
      {
        'q': '¿Qué es $topic?',
        'a': 'Un lenguaje',
        'b': 'Un framework',
        'c': 'Una base de datos',
        'd': 'Un IDE',
        'correct': 'b',
      },
      {
        'q': '¿Qué archivo define dependencias en Flutter?',
        'a': 'pubspec.yaml',
        'b': 'package.json',
        'c': 'build.gradle',
        'd': 'pom.xml',
        'correct': 'a',
      },
      {
        'q': '¿Qué comando crea un proyecto nuevo?',
        'a': 'flutter create',
        'b': 'flutter run',
        'c': 'flutter build',
        'd': 'dart run',
        'correct': 'a',
      },
    ];
  }

  /// Genera un outline 3x3 (3 módulos × 3 lecciones),
  /// usando las preguntas como títulos de lección y con bloqueo/desbloqueo.
  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
  }) async {
    // 1) Trae preguntas (o usa fallback)
    List<Map<String, dynamic>> questions = await fetchQuiz(topic: topic);

    // 2) Asegura 9 lecciones
    while (questions.length < 9) {
      questions.add({
        'q': 'Concepto de $topic',
        'a': 'A',
        'b': 'B',
        'c': 'C',
        'd': 'D',
        'correct': 'a',
      });
    }

    // 3) Construye módulos/lessons
    final modules = <Map<String, dynamic>>[];
    for (var m = 0; m < 3; m++) {
      final lessons = <Map<String, dynamic>>[];
      for (var i = 0; i < 3; i++) {
        final idx = m * 3 + i;
        lessons.add({
          'id': 'm${m + 1}l${i + 1}',
          'title': 'Lección ${idx + 1}: ${(questions[idx]['q'] ?? 'Tema')}'
              .toString(),
          'locked': !(m == 0 && i == 0), // solo la primera desbloqueada
          'status': 'todo',
        });
      }
      modules.add({
        'id': 'm${m + 1}',
        'title': 'Módulo ${m + 1}',
        'locked': m > 0, // módulo 1 desbloqueado, el resto bloqueados
        'lessons': lessons,
      });
    }

    // 4) Outline final
    return {
      'topic': topic,
      'level': 'beginner',
      'estimated_hours': 2,
      'modules': modules,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}
