import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class QuizAttemptStorage {
  QuizAttemptStorage._();

  static final QuizAttemptStorage instance = QuizAttemptStorage._();

  static const _storageKey = 'quizAttempts.v1';

  Future<void> recordStart({
    required String userId,
    required String topic,
    required String language,
    DateTime? timestamp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _readAttempts(prefs);
    final key = _buildKey(userId, topic, language);
    map[key] = (timestamp ?? DateTime.now()).toIso8601String();
    await _writeAttempts(prefs, map);
  }

  Future<DateTime?> lastStart({
    required String userId,
    required String topic,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _readAttempts(prefs);
    final key = _buildKey(userId, topic, language);
    final raw = map[key];
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  Future<Map<String, dynamic>> _readAttempts(SharedPreferences prefs) async {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // ignore decoding errors
    }
    return <String, dynamic>{};
  }

  Future<void> _writeAttempts(
    SharedPreferences prefs,
    Map<String, dynamic> attempts,
  ) async {
    if (attempts.length > 200) {
      final entries = attempts.entries.toList()
        ..sort((a, b) {
          final aTime = DateTime.tryParse(a.value?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = DateTime.tryParse(b.value?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
      attempts
        ..clear()
        ..addEntries(entries.take(200));
    }
    await prefs.setString(_storageKey, jsonEncode(attempts));
  }

  String _buildKey(String userId, String topic, String language) {
    final user = userId.trim().toLowerCase();
    final normalizedTopic = topic.trim().toLowerCase();
    final lang = language.trim().toLowerCase();
    return '$user|$normalizedTopic|$lang';
  }
}
