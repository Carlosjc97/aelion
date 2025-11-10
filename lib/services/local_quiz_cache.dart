import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:edaptia/services/course/models.dart';

class CachedQuizSession {
  const CachedQuizSession({
    required this.quizId,
    required this.topic,
    required this.language,
    required this.expiresAt,
    required this.questions,
    required this.answers,
  });

  final String quizId;
  final String topic;
  final String language;
  final DateTime expiresAt;
  final List<PlacementQuizQuestion> questions;
  final List<int?> answers;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'quizId': quizId,
        'topic': topic,
        'language': language,
        'expiresAt': expiresAt.toIso8601String(),
        'answers': answers,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  factory CachedQuizSession.fromJson(Map<String, dynamic> map) {
    final expiresAt = DateTime.tryParse(map['expiresAt']?.toString() ?? '');
    final questionList = map['questions'];
    final questions = questionList is List
        ? questionList
            .whereType<Map>()
            .map(
              (raw) => PlacementQuizQuestion(
                id: raw['id']?.toString() ?? '',
                text: raw['text']?.toString() ?? '',
                choices: (raw['choices'] as List<dynamic>? ?? const [])
                    .map((choice) => choice.toString())
                    .toList(growable: false),
              ),
            )
            .toList(growable: false)
        : const <PlacementQuizQuestion>[];

    final answersRaw = map['answers'];
    final answers = answersRaw is List
        ? answersRaw
            .map((value) => value is num ? value.toInt() : null)
            .toList(growable: false)
        : List<int?>.filled(questions.length, null);

    return CachedQuizSession(
      quizId: map['quizId']?.toString() ?? '',
      topic: map['topic']?.toString() ?? '',
      language: map['language']?.toString() ?? 'en',
      expiresAt: expiresAt ?? DateTime.now(),
      questions: questions,
      answers: answers,
    );
  }
}

class LocalQuizCache {
  LocalQuizCache._();

  static const _storageKey = 'placementQuiz.cache.v1';
  static final LocalQuizCache instance = LocalQuizCache._();

  Future<void> saveSession({
    required String userId,
    required CachedQuizSession session,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = await _readCacheMap(prefs);
    cache[_buildKey(userId, session.topic, session.language)] = session.toJson();
    await prefs.setString(_storageKey, jsonEncode(cache));
  }

  Future<CachedQuizSession?> restoreSession({
    required String userId,
    required String topic,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = await _readCacheMap(prefs);
    final entry = cache[_buildKey(userId, topic, language)];
    if (entry is Map<String, dynamic>) {
      final session = CachedQuizSession.fromJson(entry);
      if (!session.isExpired) {
        return session;
      }
    }
    return null;
  }

  Future<void> saveAnswers({
    required String userId,
    required String topic,
    required String language,
    required List<int?> answers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = await _readCacheMap(prefs);
    final key = _buildKey(userId, topic, language);
    final entry = cache[key];
    if (entry is Map<String, dynamic>) {
      entry['answers'] = answers;
      cache[key] = entry;
      await prefs.setString(_storageKey, jsonEncode(cache));
    }
  }

  Future<void> clear({
    required String userId,
    required String topic,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = await _readCacheMap(prefs);
    cache.remove(_buildKey(userId, topic, language));
    await prefs.setString(_storageKey, jsonEncode(cache));
  }

  Future<Map<String, dynamic>> _readCacheMap(SharedPreferences prefs) async {
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
      await prefs.remove(_storageKey);
    }
    return <String, dynamic>{};
  }

  String _buildKey(String userId, String topic, String lang) {
    return '${userId.trim().toLowerCase()}|${topic.trim().toLowerCase()}|${lang.trim().toLowerCase()}';
  }
}
