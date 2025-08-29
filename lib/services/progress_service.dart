import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda y actualiza el progreso de un curso en local (SharedPreferences)
/// Estructura esperada:
/// {
///   "topic": "...",
///   "modules": [
///     {
///       "id": "m1",
///       "title": "...",
///       "locked": false,
///       "lessons": [
///         {"id":"m1l1","title":"...","locked":false,"status":"todo"},
///         ...
///       ]
///     },
///     ...
///   ]
/// }
class ProgressService {
  static const _prefix = 'course_progress_';

  String _key(String courseId) => '$_prefix$courseId';

  Future<Map<String, dynamic>?> load(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(courseId));
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(String courseId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(courseId), jsonEncode(data));
  }

  /// Marca la lección como completada y desbloquea la siguiente
  Future<Map<String, dynamic>?> markLessonCompleted({
    required String courseId,
    required String moduleId,
    required String lessonId,
  }) async {
    final data = await load(courseId);
    if (data == null) return null;

    final modules = (data['modules'] as List).cast<Map<String, dynamic>>();
    final mIndex = modules.indexWhere((m) => m['id'] == moduleId);
    if (mIndex < 0) return data;

    final lessons = (modules[mIndex]['lessons'] as List).cast<Map<String, dynamic>>();
    final lIndex = lessons.indexWhere((l) => l['id'] == lessonId);
    if (lIndex < 0) return data;

    // Marcar completada
    lessons[lIndex]['status'] = 'done';

    // Desbloquear la siguiente dentro del mismo módulo
    if (lIndex + 1 < lessons.length) {
      lessons[lIndex + 1]['locked'] = false;
    } else {
      // Siguiente módulo: desbloquear módulo y su primera lección
      if (mIndex + 1 < modules.length) {
        final nextModule = modules[mIndex + 1];
        nextModule['locked'] = false;
        final nextLessons = (nextModule['lessons'] as List).cast<Map<String, dynamic>>();
        if (nextLessons.isNotEmpty) nextLessons.first['locked'] = false;
      }
    }

    await save(courseId, data);
    return data;
  }
}
