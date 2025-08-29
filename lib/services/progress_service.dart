import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de progreso local usando SharedPreferences.
///
/// Estructura de curso esperada (igual a la usada en ModuleOutlineView):
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

  /// Lee el JSON de progreso del curso [courseId].
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

  /// Guarda el JSON de progreso del curso [courseId].
  Future<void> save(String courseId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(courseId), jsonEncode(data));
  }

  /// Marca la lección como completada y desbloquea la siguiente.
  ///
  /// - Desbloquea la siguiente lección del mismo módulo.
  /// - Si no hay más lecciones, desbloquea la primera del siguiente módulo.
  /// Devuelve el curso actualizado (o null si algo falla).
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

    final lessons =
        (modules[mIndex]['lessons'] as List).cast<Map<String, dynamic>>();
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
        final nextLessons =
            (nextModule['lessons'] as List).cast<Map<String, dynamic>>();
        if (nextLessons.isNotEmpty) nextLessons.first['locked'] = false;
      }
    }

    await save(courseId, data);
    return data;
  }

  // ---------------------------------------------------------------------------
  // Checklist por lección (persistencia simple por IDs de curso/módulo/lección)
  // ---------------------------------------------------------------------------

  /// Carga un checklist de práctica para una lección.
  /// Si no existe, devuelve una lista del tamaño [length] rellenada con `false`.
  Future<List<bool>> loadLessonChecklist({
    required String courseId,
    required String moduleId,
    required String lessonId,
    required int length,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chk_${courseId}_${moduleId}_${lessonId}';
    final raw = prefs.getStringList(key);
    if (raw == null || raw.length != length) {
      return List<bool>.filled(length, false);
    }
    return raw.map((e) => e == '1').toList();
  }

  /// Guarda el checklist de práctica para una lección.
  Future<void> saveLessonChecklist({
    required String courseId,
    required String moduleId,
    required String lessonId,
    required List<bool> checks,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chk_${courseId}_${moduleId}_${lessonId}';
    await prefs.setStringList(
      key,
      checks.map((e) => (e ? '1' : '0')).toList(),
    );
  }
}
