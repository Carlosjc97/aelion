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
  ProgressService._();
  static final ProgressService i = ProgressService._();

  static const _kXp = 'xp';
  static const _kBadges = 'badges';
  static const _kStreakStart = 'streakStart';
  static const _kStreakCount = 'streakCount';
  static String _kCourse(String topic) => 'courseProgress:$topic';

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

  /// Curva simple: nivel crece cada 100 xp (ajÃºstalo cuando quieras)
  int get level => (xp / 100).floor() + 1;
  int xpToNextLevel() => level * 100 - xp;

  // ---------- Badges ----------
  List<String> get badges {
    final raw = _prefs?.getStringList(_kBadges) ?? const [];
    return raw;
  }

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
    if (diff == 0) return; // ya contabilizada hoy
    if (diff == 1) {
      await _prefs?.setString(_kStreakStart, today.toIso8601String());
      await _prefs?.setInt(_kStreakCount, streakCount + 1);
    } else {
      // racha cortada
      await _prefs?.setString(_kStreakStart, today.toIso8601String());
      await _prefs?.setInt(_kStreakCount, 1);
    }
  }

  // ---------- Avance por curso/tema ----------
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
}
