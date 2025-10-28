import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aelion/services/outline_cache_key.dart';

class StoredOutline {
  const StoredOutline({
    required this.topic,
    required this.outline,
    required this.savedAt,
    required this.source,
    this.cacheExpiresAt,
    this.band,
    this.depth,
    this.lang,
    this.rawResponse = const {},
  });

  final String topic;
  final List<Map<String, dynamic>> outline;
  final DateTime savedAt;
  final String source;
  final int? cacheExpiresAt;
  final String? band;
  final String? depth;
  final String? lang;
  final Map<String, dynamic> rawResponse;

  bool get isStale => DateTime.now().difference(savedAt).inHours >= 24;

  String get dedupeKey => buildOutlineCacheId(
        topic: topic,
        language: lang ?? 'en',
        band: band,
        depth: depth,
      );

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'savedAt': savedAt.toIso8601String(),
        'source': source,
        'cacheExpiresAt': cacheExpiresAt,
        'band': band,
        'depth': depth,
        'lang': lang,
        'payload': rawResponse,
      };

  factory StoredOutline.fromPayload({
    required String topic,
    required DateTime savedAt,
    required Map<String, dynamic> payload,
  }) {
    final outline = payload['outline'];
    final outlineList = outline is List
        ? outline
            .whereType<Map>()
            .map((module) => Map<String, dynamic>.from(module))
            .toList(growable: false)
        : <Map<String, dynamic>>[];

    return StoredOutline(
      topic: topic,
      outline: outlineList,
      savedAt: savedAt,
      source: payload['source']?.toString() ?? 'fresh',
      cacheExpiresAt: payload['cacheExpiresAt'] is num
          ? (payload['cacheExpiresAt'] as num).toInt()
          : null,
      band: payload['band']?.toString(),
      depth: payload['depth']?.toString(),
      lang: payload['lang']?.toString() ?? payload['language']?.toString(),
      rawResponse: Map<String, dynamic>.from(payload),
    );
  }

  factory StoredOutline.fromJson(Map<String, dynamic> json) {
    final payload = (json['payload'] is Map)
        ? Map<String, dynamic>.from(json['payload'] as Map)
        : <String, dynamic>{};

    final outline = payload['outline'];
    final outlineList = outline is List
        ? outline
            .whereType<Map>()
            .map((module) => Map<String, dynamic>.from(module))
            .toList(growable: false)
        : <Map<String, dynamic>>[];

    final savedAtRaw = json['savedAt']?.toString();
    final parsedSavedAt =
        savedAtRaw != null ? DateTime.tryParse(savedAtRaw) : null;

    return StoredOutline(
      topic: json['topic']?.toString() ?? payload['topic']?.toString() ?? 'Unknown topic',
      outline: outlineList,
      savedAt: parsedSavedAt ?? DateTime.now(),
      source: json['source']?.toString() ?? payload['source']?.toString() ?? 'fresh',
      cacheExpiresAt: json['cacheExpiresAt'] is num
          ? (json['cacheExpiresAt'] as num).toInt()
          : payload['cacheExpiresAt'] is num
              ? (payload['cacheExpiresAt'] as num).toInt()
              : null,
      band: json['band']?.toString() ?? payload['band']?.toString(),
      depth: json['depth']?.toString() ?? payload['depth']?.toString(),
      lang: json['lang']?.toString() ??
          payload['lang']?.toString() ??
          payload['language']?.toString(),
      rawResponse: payload,
    );
  }
}

class LocalOutlineStorage {
  LocalOutlineStorage._();

  static final LocalOutlineStorage instance = LocalOutlineStorage._();

  static const _topicKey = 'lastOutlineTopic';
  static const _jsonKey = 'lastOutlineJson';
  static const _savedAtKey = 'lastOutlineSavedAt';
  static const _historyKey = 'outlineHistory.v1';
  static const _maxHistory = 5;

  Future<void> save({
    required String topic,
    required Map<String, dynamic> payload,
  }) async {
    final outline = payload['outline'];
    if (outline is! List) {
      debugPrint(
        '[LocalOutlineStorage] Cannot persist outline - payload missing outline list.',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyIfNeeded(prefs);

    final entry = StoredOutline.fromPayload(
      topic: topic.trim(),
      savedAt: DateTime.now(),
      payload: payload,
    );

    final history = await _readHistory(prefs);
    final updated = <StoredOutline>[
      entry,
      ...history.where((item) => item.dedupeKey != entry.dedupeKey),
    ].take(_maxHistory).toList(growable: false);

    await _writeHistory(prefs, updated);
    await _persistLegacyLatest(prefs, entry);
  }

  Future<StoredOutline?> findById(String id) async {
    if (id.trim().isEmpty) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyIfNeeded(prefs);
    final history = await _readHistory(prefs);
    for (final outline in history) {
      if (outline.dedupeKey == id) {
        return outline;
      }
    }
    return null;
  }

  Future<List<StoredOutline>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyIfNeeded(prefs);
    return _readHistory(prefs);
  }

  Future<StoredOutline?> read() async {
    final history = await readAll();
    if (history.isEmpty) {
      return null;
    }
    return history.first;
  }

  Future<void> remove(String dedupeKey) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _readHistory(prefs);
    final filtered =
        history.where((outline) => outline.dedupeKey != dedupeKey).toList();
    await _writeHistory(prefs, filtered);
    if (filtered.isEmpty) {
      await _clearLegacy(prefs);
    } else {
      await _persistLegacyLatest(prefs, filtered.first);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await _clearLegacy(prefs);
  }

  Future<void> _migrateLegacyIfNeeded(SharedPreferences prefs) async {
    if (prefs.containsKey(_historyKey)) {
      return;
    }
    final legacy = await _readLegacy(prefs);
    if (legacy == null) {
      return;
    }
    await _writeHistory(prefs, [legacy]);
  }

  Future<StoredOutline?> _readLegacy(SharedPreferences prefs) async {
    final topic = prefs.getString(_topicKey);
    final jsonString = prefs.getString(_jsonKey);
    final savedAtRaw = prefs.getString(_savedAtKey);

    if (topic == null || jsonString == null || savedAtRaw == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final savedAt = DateTime.tryParse(savedAtRaw);
      if (savedAt == null) {
        return null;
      }

      return StoredOutline.fromPayload(
        topic: topic,
        savedAt: savedAt,
        payload: decoded,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[LocalOutlineStorage] Failed legacy migration: $error\n$stackTrace',
      );
      return null;
    }
  }

  Future<List<StoredOutline>> _readHistory(SharedPreferences prefs) async {
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return <StoredOutline>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <StoredOutline>[];
      }

      final items = decoded
          .whereType<Map>()
          .map((entry) => StoredOutline.fromJson(Map<String, dynamic>.from(entry)))
          .toList();

      items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return items;
    } catch (error, stackTrace) {
      debugPrint(
        '[LocalOutlineStorage] Failed to decode outline history: $error\n$stackTrace',
      );
      return <StoredOutline>[];
    }
  }

  Future<void> _writeHistory(
    SharedPreferences prefs,
    List<StoredOutline> history,
  ) async {
    final serialized =
        history.map((outline) => outline.toJson()).toList(growable: false);
    await prefs.setString(_historyKey, jsonEncode(serialized));
  }

  Future<void> _persistLegacyLatest(
    SharedPreferences prefs,
    StoredOutline outline,
  ) async {
    await prefs.setString(_topicKey, outline.topic);
    await prefs.setString(_savedAtKey, outline.savedAt.toIso8601String());
    await prefs.setString(_jsonKey, jsonEncode(outline.rawResponse));
  }

  Future<void> _clearLegacy(SharedPreferences prefs) async {
    await prefs.remove(_topicKey);
    await prefs.remove(_jsonKey);
    await prefs.remove(_savedAtKey);
  }
}
