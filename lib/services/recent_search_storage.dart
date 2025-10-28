import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchEntry {
  const RecentSearchEntry({
    required this.userId,
    required this.topic,
    required this.language,
    required this.savedAt,
  });

  final String userId;
  final String topic;
  final String language;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userId': userId,
        'topic': topic,
        'language': language,
        'savedAt': savedAt.toIso8601String(),
      };

  RecentSearchEntry copyWith({DateTime? savedAt}) {
    return RecentSearchEntry(
      userId: userId,
      topic: topic,
      language: language,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  static RecentSearchEntry fromJson(Map<String, dynamic> json) {
    final savedAtRaw = json['savedAt']?.toString();
    final savedAt = savedAtRaw != null
        ? DateTime.tryParse(savedAtRaw) ?? DateTime.now()
        : DateTime.now();
    return RecentSearchEntry(
      userId: json['userId']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      language: json['language']?.toString() ?? 'en',
      savedAt: savedAt,
    );
  }
}

class RecentSearchStorage {
  RecentSearchStorage._();

  static const _storageKey = 'recentSearches.v1';
  static const _maxEntries = 35;

  static final RecentSearchStorage instance = RecentSearchStorage._();

  Future<void> add({
    required String userId,
    required String topic,
    required String language,
  }) async {
    final normalizedUser = userId.trim();
    final normalizedTopic = _normalizeTopic(topic);
    final normalizedLang = language.trim().toLowerCase();
    if (normalizedUser.isEmpty || normalizedTopic.isEmpty) {
      return;
    }

    final entry = RecentSearchEntry(
      userId: normalizedUser,
      topic: normalizedTopic,
      language: normalizedLang.isEmpty ? 'en' : normalizedLang,
      savedAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final history = await _readAll(prefs);

    final combined = <RecentSearchEntry>[entry, ...history]
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

    final updated = _dedupeAndLimit(combined);

    await _writeAll(prefs, updated);
  }

  Future<List<RecentSearchEntry>> readForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _readAll(prefs);

    return history
        .where((entry) => entry.userId == userId.trim())
        .toList(growable: false);
  }

  Future<void> clearForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _readAll(prefs);
    final filtered =
        history.where((entry) => entry.userId != userId.trim()).toList();
    await _writeAll(prefs, filtered);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<List<RecentSearchEntry>> _readAll(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <RecentSearchEntry>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <RecentSearchEntry>[];
      }
      final entries = decoded.whereType<Map>().map(
            (item) => RecentSearchEntry.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
      final list = entries.toList()
        ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return _dedupeAndLimit(list);
    } catch (_) {
      return <RecentSearchEntry>[];
    }
  }

  Future<void> _writeAll(
    SharedPreferences prefs,
    List<RecentSearchEntry> history,
  ) async {
    final serialized =
        history.map((entry) => entry.toJson()).toList(growable: false);
    await prefs.setString(_storageKey, jsonEncode(serialized));
  }

  static String _normalizeTopic(String value) => value.trim().toLowerCase();

  static List<RecentSearchEntry> _dedupeAndLimit(
    Iterable<RecentSearchEntry> entries,
  ) {
    final result = <RecentSearchEntry>[];
    final seenTopicsPerUser = <String, Set<String>>{};
    final countsPerUser = <String, int>{};

    for (final entry in entries) {
      final key = _normalizeTopic(entry.topic);
      final topicSet =
          seenTopicsPerUser.putIfAbsent(entry.userId, () => <String>{});
      if (!topicSet.add(key)) {
        continue;
      }

      final currentCount = countsPerUser[entry.userId] ?? 0;
      if (currentCount >= _maxEntries) {
        continue;
      }

      countsPerUser[entry.userId] = currentCount + 1;
      result.add(entry);
    }

    return result;
  }
}



