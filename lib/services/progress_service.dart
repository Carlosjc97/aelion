// lib/services/progress_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CourseProgress {
  final String topic;
  final Set<int> unlockedSteps;
  final int lastStep;
  final bool completed;

  CourseProgress({
    required this.topic,
    required this.unlockedSteps,
    required this.lastStep,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'unlockedSteps': unlockedSteps.toList(),
    'lastStep': lastStep,
    'completed': completed,
  };

  factory CourseProgress.fromJson(Map<String, dynamic> json) => CourseProgress(
    topic: json['topic'] as String,
    unlockedSteps: Set<int>.from(
      (json['unlockedSteps'] as List).map((e) => e as int),
    ),
    lastStep: json['lastStep'] as int,
    completed: json['completed'] as bool,
  );
}

class ProgressService {
  // -------- Singleton consistente (SIN .i) --------
  ProgressService._internal();
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;

  // -------- Claves --------
  static const _kXp = 'xp';
  static const _kBadges = 'badges';
  static const _kStreakStart = 'streakStart';
  static const _kStreakCount = 'streakCount';
  static String _kCourse(String topic) => 'courseProgress:$topic';
  static String _kOutline(String courseId) => 'outline:$courseId';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ---------- XP / Nivel ----------
  int get xp => _prefs?.getInt(_kXp) ?? 0;

  Future<int> addXp(int delta) async {
    final next = xp + delta;
    await _prefs?.setInt(_kXp, next);
    return next;
  }

  int get level => (xp / 100).floor() + 1;
  int xpToNextLevel() => level * 100 - xp;

  // ---------- Badges ----------
  List<String> get badges => _prefs?.getStringList(_kBadges) ?? const [];

  Future<void> awardBadge(String id) async {
    final b = badges.toSet();
    if (b.add(id)) {
      await _prefs?.setStringList(_kBadges, b.toList());
    }
  }

  bool hasBadge(String id) => badges.contains(id);

  // ---------- Racha diaria ----------
  DateTime? _parseDate(String? iso) =>
      iso == null ? null : DateTime.tryParse(iso);

  int get streakCount => _prefs?.getInt(_kStreakCount) ?? 0;

  Future<void> tickDailyStreak() async {
    final today = DateTime.now();
    final startIso = _prefs?.getString(_kStreakStart);
    final start = _parseDate(startIso);
    if (start == null) {
      await _prefs?.setString(_kStreakStart, today.toIso8601String());
      await _prefs?.setInt(_kStreakCount, 1);
      return;
    }
    final sameDay = DateTime(start.year, start.month, start.day);
    final nowDay = DateTime(today.year, today.month, today.day);
    final diff = nowDay.difference(sameDay).inDays;
    if (diff == 0) return; // ya contado hoy
    if (diff == 1) {
      await _prefs?.setString(_kStreakStart, today.toIso8601String());
      await _prefs?.setInt(_kStreakCount, streakCount + 1);
    } else {
      await _prefs?.setString(_kStreakStart, today.toIso8601String());
      await _prefs?.setInt(_kStreakCount, 1);
    }
  }

  // ---------- Avance por curso (compatibilidad) ----------
  Future<CourseProgress> getCourseProgress(String topic) async {
    final raw = _prefs?.getString(_kCourse(topic));
    if (raw == null) {
      return CourseProgress(
        topic: topic,
        unlockedSteps: {0},
        lastStep: 0,
        completed: false,
      );
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return CourseProgress.fromJson(map);
  }

  Future<void> _saveCourseProgress(CourseProgress p) async {
    await _prefs?.setString(_kCourse(p.topic), jsonEncode(p.toJson()));
  }

  Future<CourseProgress> unlockStep(
    String topic,
    int step, {
    bool markCompleted = false,
  }) async {
    final current = await getCourseProgress(topic);
    final next = CourseProgress(
      topic: topic,
      unlockedSteps: {...current.unlockedSteps, step},
      lastStep: step > current.lastStep ? step : current.lastStep,
      completed: markCompleted ? true : current.completed,
    );
    await _saveCourseProgress(next);
    return next;
  }

  Future<CourseProgress> markCompleted(String topic) async {
    final current = await getCourseProgress(topic);
    final next = CourseProgress(
      topic: topic,
      unlockedSteps: current.unlockedSteps,
      lastStep: current.lastStep,
      completed: true,
    );
    await _saveCourseProgress(next);
    return next;
  }

  // ---------- NUEVO: Outline ----------
  Future<Map<String, dynamic>?> load(String courseId) async {
    final raw = _prefs?.getString(_kOutline(courseId));
    if (raw == null) return null;
    final map = jsonDecode(raw);
    if (map is Map<String, dynamic>) return map;
    return Map<String, dynamic>.from(map as Map);
  }

  Future<void> save(String courseId, Map<String, dynamic> outline) async {
    await _prefs?.setString(_kOutline(courseId), jsonEncode(outline));
  }

  Future<Map<String, dynamic>?> markLessonCompleted({
    required String courseId,
    required String moduleId,
    required String lessonId,
  }) async {
    final outline = await load(courseId);
    if (outline == null) return null;

    final rawModules = outline['modules'];
    if (rawModules is! List) return outline;

    final modules = rawModules
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final mIndex = modules.indexWhere((m) => (m['id'] as String?) == moduleId);
    if (mIndex < 0) return outline;

    final m = modules[mIndex];
    final rawLessons = m['lessons'];
    if (rawLessons is! List) return outline;

    final lessons = rawLessons
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final lIndex = lessons.indexWhere((l) => (l['id'] as String?) == lessonId);
    if (lIndex < 0) return outline;

    // Completar
    lessons[lIndex]['status'] = 'done';

    // Desbloquear siguiente
    if (lIndex + 1 < lessons.length) {
      lessons[lIndex + 1]['locked'] = false;
    } else {
      // Siguiente módulo
      if (mIndex + 1 < modules.length) {
        modules[mIndex + 1]['locked'] = false;
        final nextLessons = modules[mIndex + 1]['lessons'];
        if (nextLessons is List && nextLessons.isNotEmpty) {
          final first = Map<String, dynamic>.from(nextLessons.first as Map);
          first['locked'] = false;
          final nextCopy = nextLessons
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          nextCopy[0] = first;
          modules[mIndex + 1]['lessons'] = nextCopy;
        }
      } else {
        outline['completed'] = true;
      }
    }

    m['lessons'] = lessons;
    modules[mIndex] = m;
    outline['modules'] = modules;

    await save(courseId, outline);
    return outline;
  }
}
