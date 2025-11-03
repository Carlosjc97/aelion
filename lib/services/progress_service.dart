// lib/services/progress_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';

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

class StreakUpdate {
  const StreakUpdate({
    required this.incremented,
    required this.streakLength,
  });

  final bool incremented;
  final int streakLength;

  int get day => streakLength;
}

class ProgressService {
  ProgressService._internal();
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;

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

  int get xp => _prefs?.getInt(_kXp) ?? 0;

  Future<int> addXp(int delta) async {
    final next = xp + delta;
    await _prefs?.setInt(_kXp, next);
    return next;
  }

  int get level => (xp / 100).floor() + 1;
  int xpToNextLevel() => level * 100 - xp;

  List<String> get badges => _prefs?.getStringList(_kBadges) ?? const [];

  Future<void> awardBadge(String id) async {
    final b = badges.toSet();
    if (b.add(id)) {
      await _prefs?.setStringList(_kBadges, b.toList());
    }
  }

  bool hasBadge(String id) => badges.contains(id);

  DateTime? _parseDate(String? iso) =>
      iso == null ? null : DateTime.tryParse(iso);

  int get streakCount => _prefs?.getInt(_kStreakCount) ?? 0;

  Future<StreakUpdate> tickDailyStreak() async {
    final today = DateTime.now();
    final startIso = _prefs?.getString(_kStreakStart);
    final start = _parseDate(startIso);
    if (start == null) {
      await _prefs?.setString(_kStreakStart, today.toIso8601String());
      await _prefs?.setInt(_kStreakCount, 1);
      return const StreakUpdate(incremented: true, streakLength: 1);
    }
    final sameDay = DateTime(start.year, start.month, start.day);
    final nowDay = DateTime(today.year, today.month, today.day);
    final diff = nowDay.difference(sameDay).inDays;
    final current = streakCount;
    if (diff == 0) {
      return StreakUpdate(incremented: false, streakLength: current);
    }
    if (diff == 1) {
      await _prefs?.setString(_kStreakStart, today.toIso8601String());
      final next = current + 1;
      await _prefs?.setInt(_kStreakCount, next);
      return StreakUpdate(incremented: true, streakLength: next);
    }
    await _prefs?.setString(_kStreakStart, today.toIso8601String());
    await _prefs?.setInt(_kStreakCount, 1);
    return const StreakUpdate(incremented: true, streakLength: 1);
  }

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

  Future<Map<String, dynamic>?> load(String courseId) async {
    final raw = _prefs?.getString(_kOutline(courseId));
    if (raw == null) return null;
    final map = jsonDecode(raw);
    if (map is Map<String, dynamic>) return map;
    if (map is Map) return Map<String, dynamic>.from(map);
    return null;
  }

  Future<void> save(String courseId, Map<String, dynamic> outline) async {
    await _prefs?.setString(_kOutline(courseId), jsonEncode(outline));
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  bool _areLessonsComplete(List<Map<String, dynamic>> lessons) {
    return lessons.every((lesson) {
      final status = lesson['status']?.toString().toLowerCase();
      return status == 'done';
    });
  }

  Future<Map<String, dynamic>?> markLessonCompleted({
    required String courseId,
    required String moduleId,
    required String lessonId,
  }) async {
    final outline = await load(courseId);
    if (outline == null) return null;

    final modules = _asMapList(outline['modules']);
    if (modules.isEmpty) return outline;

    final mIndex = modules.indexWhere(
      (module) => module['id']?.toString() == moduleId,
    );
    if (mIndex < 0) return outline;

    final module = modules[mIndex];
    final lessons = _asMapList(module['lessons']);
    if (lessons.isEmpty) return outline;

    final lessonCount = lessons.length;
    final wasModuleComplete = _areLessonsComplete(lessons);

    final lIndex = lessons.indexWhere(
      (lesson) => lesson['id']?.toString() == lessonId,
    );
    if (lIndex < 0) return outline;

    lessons[lIndex]['status'] = 'done';
    lessons[lIndex]['locked'] = false;

    if (lIndex + 1 < lessons.length) {
      lessons[lIndex + 1]['locked'] = false;
    } else if (mIndex + 1 < modules.length) {
      final nextModule = Map<String, dynamic>.from(modules[mIndex + 1]);
      final nextLessons = _asMapList(nextModule['lessons']);
      if (nextLessons.isNotEmpty) {
        nextLessons[0]['locked'] = false;
        nextModule['lessons'] = nextLessons;
      }
      nextModule['locked'] = false;
      modules[mIndex + 1] = nextModule;
    } else {
      outline['completed'] = true;
    }

    module['lessons'] = lessons;
    modules[mIndex] = module;
    outline['modules'] = modules;

    final isModuleComplete = _areLessonsComplete(lessons);
    if (!wasModuleComplete && isModuleComplete) {
      final moduleBand =
          module['band']?.toString() ?? outline['band']?.toString();
      unawaited(
        AnalyticsService().trackModuleCompleted(
          moduleId: moduleId,
          topic: courseId,
          band: moduleBand,
          lessonCount: lessonCount,
        ),
      );
    }

    await save(courseId, outline);
    return outline;
  }
}

