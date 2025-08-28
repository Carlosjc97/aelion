import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static String _key(String courseId) => 'progress_$courseId';

  Future<Map<String, dynamic>?> getProgress(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(courseId));
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveProgress(String courseId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(courseId), jsonEncode(data));
  }

  Future<Map<String, dynamic>> markLessonDone({
    required String courseId,
    required Map<String, dynamic> courseData,
    required String moduleId,
    required String lessonId,
  }) async {
    final modules = (courseData['modules'] as List).cast<Map<String, dynamic>>();
    final mi = modules.indexWhere((m) => m['id'] == moduleId);
    if (mi == -1) return courseData;

    final lessons = (modules[mi]['lessons'] as List).cast<Map<String, dynamic>>();
    final li = lessons.indexWhere((l) => l['id'] == lessonId);
    if (li == -1) return courseData;

    lessons[li]['status'] = 'done';

    // Desbloquea siguiente lección o siguiente módulo
    if (li + 1 < lessons.length) {
      lessons[li + 1]['locked'] = false;
    } else {
      final allDone = lessons.every((l) => l['status'] == 'done');
      if (allDone && mi + 1 < modules.length) {
        modules[mi + 1]['locked'] = false;
        final next = (modules[mi + 1]['lessons'] as List).cast<Map<String, dynamic>>();
        if (next.isNotEmpty) next[0]['locked'] = false;
      }
    }

    await saveProgress(courseId, courseData);
    return courseData;
  }
}
