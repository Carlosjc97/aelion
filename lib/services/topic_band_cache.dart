import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:aelion/services/course_api_service.dart';

class TopicBandCache {
  TopicBandCache._();

  static const _storageKey = 'topicBandCache.v1';
  static const _maxEntries = 100;
  static const _ttl = Duration(days: 30);

  static final TopicBandCache instance = TopicBandCache._();

  Future<void> setBand({
    required String userId,
    required String topic,
    required String language,
    required PlacementBand band,
  }) async {
    final normalizedKey = _buildKey(userId, topic, language);
    if (normalizedKey.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cache = await _readCache(prefs);
    cache[normalizedKey] = {
      'band': CourseApiService.placementBandToString(band),
      'savedAt': DateTime.now().toIso8601String(),
    };

    await _writeCache(prefs, cache);
  }

  Future<PlacementBand?> getBand({
    required String userId,
    required String topic,
    required String language,
  }) async {
    final normalizedKey = _buildKey(userId, topic, language);
    if (normalizedKey.isEmpty) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final cache = await _readCache(prefs);
    final record = cache[normalizedKey];
    if (record == null) {
      return null;
    }

    final savedAtRaw = record['savedAt']?.toString();
    final savedAt = savedAtRaw != null ? DateTime.tryParse(savedAtRaw) : null;
    if (savedAt != null && DateTime.now().difference(savedAt) > _ttl) {
      cache.remove(normalizedKey);
      await _writeCache(prefs, cache);
      return null;
    }

    final bandRaw = record['band']?.toString();
    final band = CourseApiService.tryPlacementBandFromString(bandRaw);
    if (band == null) {
      cache.remove(normalizedKey);
      await _writeCache(prefs, cache);
    }
    return band;
  }

  Future<bool> hasBand({
    required String userId,
    required String topic,
    required String language,
  }) async {
    final band = await getBand(
      userId: userId,
      topic: topic,
      language: language,
    );
    return band != null;
  }

  Future<void> clearExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final cache = await _readCache(prefs);
    final now = DateTime.now();
    var modified = false;

    final keys = List<String>.from(cache.keys);
    for (final key in keys) {
      final record = cache[key];
      if (record == null) {
        continue;
      }
      final savedAtRaw = record['savedAt']?.toString();
      final savedAt = savedAtRaw != null ? DateTime.tryParse(savedAtRaw) : null;
      if (savedAt == null || now.difference(savedAt) > _ttl) {
        cache.remove(key);
        modified = true;
      }
    }

    if (modified) {
      await _writeCache(prefs, cache);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  String _buildKey(String userId, String topic, String language) {
    final userSegment = userId.trim().toLowerCase();
    final topicSegment = topic.trim().toLowerCase();
    final languageSegment = language.trim().toLowerCase();
    if (userSegment.isEmpty || topicSegment.isEmpty || languageSegment.isEmpty) {
      return '';
    }
    return '$userSegment|$topicSegment|$languageSegment';
  }

  Future<Map<String, Map<String, dynamic>>> _readCache(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <String, Map<String, dynamic>>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, Map<String, dynamic>>{};
      }
      final entries = decoded.entries.whereType<MapEntry>().map((entry) {
        final value = entry.value is Map
            ? Map<String, dynamic>.from(entry.value as Map)
            : <String, dynamic>{};
        return MapEntry(entry.key.toString(), value);
      });

      return Map<String, Map<String, dynamic>>.fromEntries(entries);
    } catch (_) {
      return <String, Map<String, dynamic>>{};
    }
  }

  Future<void> _writeCache(
    SharedPreferences prefs,
    Map<String, Map<String, dynamic>> cache,
  ) async {
    if (cache.length > _maxEntries) {
      final sortedEntries = cache.entries.toList()
        ..sort((a, b) {
          final aSaved = DateTime.tryParse(a.value['savedAt']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bSaved = DateTime.tryParse(b.value['savedAt']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bSaved.compareTo(aSaved);
        });
      final trimmed = sortedEntries.take(_maxEntries);
      cache
        ..clear()
        ..addEntries(trimmed);
    }

    final encoded = jsonEncode(cache);
    await prefs.setString(_storageKey, encoded);
  }
}

