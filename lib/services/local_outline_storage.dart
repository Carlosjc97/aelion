import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edaptia/services/outline_cache_key.dart';
import 'package:edaptia/services/local_outline_storage_codec.dart';

const Set<String> _outlinePayloadKeysToDrop = <String>{
  'auditTrail',
  'chain',
  'chains',
  'chunks',
  'debug',
  'diagnostics',
  'fullPrompt',
  'messages',
  'prompt',
  'rawOutline',
  'raw_outline',
  'rawPlan',
  'rawPrompt',
  'rawResponse',
  'segments',
  'tokenUsage',
  'tokens',
  'trace',
  'usage',
};

Map<String, dynamic> _sanitizeOutlinePayload(
  Map<String, dynamic> payload, {
  String? topic,
}) {
  final sanitized = <String, dynamic>{};

  payload.forEach((key, value) {
    final keyString = key.toString();
    if (_outlinePayloadKeysToDrop.contains(keyString)) {
      return;
    }
    sanitized[keyString] = _cloneJsonValue(value);
  });

  final normalizedTopic = topic?.trim();
  if (normalizedTopic != null && normalizedTopic.isNotEmpty) {
    sanitized['topic'] ??= normalizedTopic;
  }

  return sanitized;
}

dynamic _cloneJsonValue(dynamic value) {
  if (value is Map) {
    return value.map(
      (key, dynamic nestedValue) =>
          MapEntry(key.toString(), _cloneJsonValue(nestedValue)),
    );
  }
  if (value is List) {
    return value.map(_cloneJsonValue).toList(growable: false);
  }
  if (value is num || value is bool || value is String || value == null) {
    return value;
  }
  return value.toString();
}

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
    final sanitizedPayload = _sanitizeOutlinePayload(payload, topic: topic);
    final outline = sanitizedPayload['outline'];
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
      source: sanitizedPayload['source']?.toString() ?? 'fresh',
      cacheExpiresAt: sanitizedPayload['cacheExpiresAt'] is num
          ? (sanitizedPayload['cacheExpiresAt'] as num).toInt()
          : null,
      band: sanitizedPayload['band']?.toString(),
      depth: sanitizedPayload['depth']?.toString(),
      lang: sanitizedPayload['lang']?.toString() ??
          sanitizedPayload['language']?.toString(),
      rawResponse: sanitizedPayload,
    );
  }

  factory StoredOutline.fromJson(Map<String, dynamic> json) {
    final payload = (json['payload'] is Map)
        ? Map<String, dynamic>.from(json['payload'] as Map)
        : <String, dynamic>{};

    final sanitizedPayload =
        _sanitizeOutlinePayload(payload, topic: json['topic']?.toString());

    final outline = sanitizedPayload['outline'];
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
      topic: json['topic']?.toString() ??
          sanitizedPayload['topic']?.toString() ??
          'Unknown topic',
      outline: outlineList,
      savedAt: parsedSavedAt ?? DateTime.now(),
      source: json['source']?.toString() ??
          sanitizedPayload['source']?.toString() ??
          'fresh',
      cacheExpiresAt: json['cacheExpiresAt'] is num
          ? (json['cacheExpiresAt'] as num).toInt()
          : sanitizedPayload['cacheExpiresAt'] is num
              ? (sanitizedPayload['cacheExpiresAt'] as num).toInt()
              : null,
      band: json['band']?.toString() ?? sanitizedPayload['band']?.toString(),
      depth:
          json['depth']?.toString() ?? sanitizedPayload['depth']?.toString(),
      lang: json['lang']?.toString() ??
          sanitizedPayload['lang']?.toString() ??
          sanitizedPayload['language']?.toString(),
      rawResponse: sanitizedPayload,
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
  static const _encodedHistoryPrefix = 'gz:';
  static const _compressionMinBytes = 512;
  static const Duration _retentionWindow = Duration(days: 14);

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

    final normalizedTopic = topic.trim();
    final now = DateTime.now();
    final entry = StoredOutline.fromPayload(
      topic: normalizedTopic,
      savedAt: now,
      payload: payload,
    );

    final history = await _readHistory(prefs);
    final retentionCutoff = now.subtract(_retentionWindow);
    final updated = <StoredOutline>[
      entry,
      ...history.where(
        (item) =>
            item.dedupeKey != entry.dedupeKey &&
            item.savedAt.isAfter(retentionCutoff),
      ),
    ];

    updated.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    final trimmed = updated.take(_maxHistory).toList(growable: false);

    await _writeHistory(prefs, trimmed);
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

    final decoded = _decodeHistory(raw);
    if (decoded == null || decoded.isEmpty) {
      return <StoredOutline>[];
    }

    final items = decoded
        .whereType<Map>()
        .map(
          (entry) =>
              StoredOutline.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();

    items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return items;
  }

  static List<dynamic>? _decodeHistory(String raw) {
    try {
      final String jsonString;
      if (raw.startsWith(_encodedHistoryPrefix)) {
        final compressed = raw.substring(_encodedHistoryPrefix.length);
        final compressedBytes = base64Decode(compressed);
        final decodedBytes = decompressOutlineHistory(compressedBytes);
        if (decodedBytes == null) {
          return null;
        }
        jsonString = utf8.decode(decodedBytes);
      } else {
        jsonString = raw;
      }
      final decoded = jsonDecode(jsonString);
      return decoded is List ? decoded : null;
    } catch (error, stackTrace) {
      debugPrint(
        '[LocalOutlineStorage] Failed to decode outline history: $error\n$stackTrace',
      );
      return null;
    }
  }

  Future<void> _writeHistory(
    SharedPreferences prefs,
    List<StoredOutline> history,
  ) async {
    if (history.isEmpty) {
      await prefs.remove(_historyKey);
      return;
    }

    final serialized =
        history.map((outline) => outline.toJson()).toList(growable: false);
    final encoded = _encodeHistory(serialized);
    await prefs.setString(_historyKey, encoded);
  }

  static String _encodeHistory(List<Map<String, dynamic>> history) {
    final jsonString = jsonEncode(history);
    if (jsonString.isEmpty) {
      return jsonString;
    }

    try {
      final utf8Bytes = utf8.encode(jsonString);
      if (utf8Bytes.length < _compressionMinBytes) {
        return jsonString;
      }
      final compressedBytes = compressOutlineHistory(utf8Bytes);
      if (compressedBytes == null ||
          compressedBytes.length + _encodedHistoryPrefix.length >=
              utf8Bytes.length) {
        return jsonString;
      }
      final encoded = base64Encode(compressedBytes);
      return '$_encodedHistoryPrefix$encoded';
    } catch (error, stackTrace) {
      debugPrint(
        '[LocalOutlineStorage] Failed to compress outline history: $error\n$stackTrace',
      );
      return jsonString;
    }
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

