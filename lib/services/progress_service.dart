import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _kCompletedLessonsKey = 'aelion.completed_lessons';
  static const _kCourseProgressPrefix = 'aelion.course.'; // + courseId

  /// Guarda el outline de un curso (mock/simple).
  Future<void> saveProgress(String courseId, Map<String, dynamic> outline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kCourseProgressPrefix$courseId', jsonEncode(outline));
  }

  /// Carga el outline guardado (si existe). Retorna null si no hay.
  Future<Map<String, dynamic>?> loadProgress(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_kCourseProgressPrefix$courseId');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) return map;
    } catch (_) {}
    return null;
  }

  /// Marca una lección como completada (persistencia local).
  Future<void> markLessonCompleted(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_kCompletedLessonsKey) ?? <String>[];
    if (!current.contains(lessonId)) {
      current.add(lessonId);
      await prefs.setStringList(_kCompletedLessonsKey, current);
    }
  }

  /// Consulta si una lección ya fue completada.
  Future<bool> isLessonCompleted(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_kCompletedLessonsKey) ?? <String>[];
    return current.contains(lessonId);
  }

  /// (Opcional) Limpia progreso local (útil para debugging).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCompletedLessonsKey);
    // Nota: si quieres limpiar outlines guardados, itera por keys y elimina las que empiecen con el prefijo.
  }
}
