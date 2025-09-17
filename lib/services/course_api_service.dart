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

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, val) => MapEntry('$key', val));
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  static bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (['true', '1', 'yes', 'y'].contains(normalized)) return true;
      if (['false', '0', 'no', 'n'].contains(normalized)) return false;
    }
    return fallback;
  }

  static Map<String, dynamic> _shapeOutline(Map<String, dynamic> raw) {
    final outline = <String, dynamic>{
      'topic': raw['topic']?.toString() ?? 'Curso',
      'level': raw['level']?.toString() ?? 'beginner',
    };

    final modules = _asMapList(raw['modules']).asMap().entries.map((entry) {
      final moduleIndex = entry.key;
      final module = Map<String, dynamic>.from(entry.value);
      final lessons = _asMapList(module['lessons']).asMap().entries.map((
        lessonEntry,
      ) {
        final lessonIndex = lessonEntry.key;
        final lesson = Map<String, dynamic>.from(lessonEntry.value);
        final unlocked = moduleIndex == 0 && lessonIndex == 0;
        final shaped = {
          ...lesson,
          'id':
              lesson['id']?.toString() ??
              'lesson-${moduleIndex + 1}-${lessonIndex + 1}',
          'title':
              lesson['title']?.toString() ??
              'Leccion ${moduleIndex + 1}.${lessonIndex + 1}',
          'description':
              lesson['description']?.toString() ??
              lesson['content']?.toString(),
          'locked': _asBool(lesson['locked'], fallback: !unlocked),
          'status': _coerceStatus(lesson['status']),
          'premium': lesson.containsKey('premium')
              ? _asBool(lesson['premium'], fallback: false)
              : null,
        };
        shaped.removeWhere((key, value) => value == null);
        return shaped;
      }).toList();

      if (lessons.isEmpty) {
        lessons.add({
          'id': 'lesson-${moduleIndex + 1}-1',
          'title': 'Leccion ${moduleIndex + 1}.1',
          'locked': moduleIndex == 0 ? false : true,
          'status': 'todo',
        });
      }

      final isFirstModule = moduleIndex == 0;
      final locked = _asBool(module['locked'], fallback: !isFirstModule);
      if (lessons.isNotEmpty && moduleIndex > 0) {
        lessons[0] = {...lessons[0], 'locked': locked};
      } else if (lessons.isNotEmpty && isFirstModule) {
        lessons[0] = {...lessons[0], 'locked': false};
      }

      return {
        ...module,
        'id': module['id']?.toString() ?? 'module-${moduleIndex + 1}',
        'title': module['title']?.toString() ?? 'Modulo ${moduleIndex + 1}',
        'locked': locked,
        'lessons': lessons,
      };
    }).toList();

    final modulesOrFallback = modules.isEmpty
        ? [
            {
              'id': 'module-1',
              'title': 'Modulo 1',
              'locked': false,
              'lessons': [
                {
                  'id': 'lesson-1-1',
                  'title': 'Leccion 1.1',
                  'locked': false,
                  'status': 'todo',
                },
              ],
            },
          ]
        : modules;

    outline['modules'] = modulesOrFallback;

    final requestedHours = _parseHours(raw['estimated_hours']);
    outline['estimated_hours'] =
        requestedHours ?? _fallbackEstimatedHours(modulesOrFallback);

    return outline;
  }

  static int? _parseHours(dynamic value) {
    final number = double.tryParse(value?.toString() ?? '');
    if (number == null || number <= 0) {
      return null;
    }
    return number.round();
  }

  static int _fallbackEstimatedHours(List<dynamic> modules) {
    final totalLessons = modules.fold<int>(0, (sum, module) {
      final lessons = module is Map<String, dynamic>
          ? module['lessons']
          : module is Map
          ? module['lessons']
          : null;
      if (lessons is List) {
        return sum + lessons.length;
      }
      return sum;
    });

    if (totalLessons == 0) {
      return 6;
    }

    return (totalLessons * 1.5).ceil();
  }

  static String _coerceStatus(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    const allowed = {'todo', 'in_progress', 'done'};
    return allowed.contains(raw) ? raw! : 'todo';
  }

  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
  }) async {
    final trimmedTopic = topic.trim();
    if (trimmedTopic.isEmpty) {
      throw ArgumentError('topic requerido');
    }

    final response = await http.post(
      _uri('/outline'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'topic': trimmedTopic}),
    );

    if (response.statusCode != 200) {
      final detail = response.body.isNotEmpty ? response.body : 'sin detalle';
      throw Exception('outline_error (${response.statusCode}): $detail');
    }

    final decoded = jsonDecode(response.body);
    final map = _asMap(decoded);
    return _shapeOutline(map);
  }
}
