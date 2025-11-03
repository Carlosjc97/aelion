import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:edaptia/services/outline_cache_key.dart';

class RecentOutlineMetadata {
  const RecentOutlineMetadata({
    required this.id,
    required this.topic,
    required this.language,
    required this.savedAt,
    this.band,
    this.depth,
  });

  final String id;
  final String topic;
  final String language;
  final DateTime savedAt;
  final String? band;
  final String? depth;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'topic': topic,
        'language': language,
        'savedAt': savedAt.toIso8601String(),
        if (band != null) 'band': band,
        if (depth != null) 'depth': depth,
      };

  RecentOutlineMetadata copyWith({
    DateTime? savedAt,
  }) {
    return RecentOutlineMetadata(
      id: id,
      topic: topic,
      language: language,
      savedAt: savedAt ?? this.savedAt,
      band: band,
      depth: depth,
    );
  }

  static RecentOutlineMetadata fromJson(Map<String, dynamic> json) {
    final rawSavedAt = json['savedAt']?.toString();
    return RecentOutlineMetadata(
      id: json['id']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      language: json['language']?.toString() ?? 'en',
      band: json['band']?.toString(),
      depth: json['depth']?.toString(),
      savedAt: rawSavedAt != null
          ? DateTime.tryParse(rawSavedAt) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static String buildId({
    required String topic,
    required String language,
    String? band,
    String? depth,
  }) {
    return buildOutlineCacheId(
      topic: topic,
      language: language,
      band: band,
      depth: depth,
    );
  }
}

class RecentOutlinesStorage {
  RecentOutlinesStorage._();

  static const _storageKey = 'recentOutlines.meta.v1';
  static const _maxEntries = 5;

  static final RecentOutlinesStorage instance = RecentOutlinesStorage._();

  Future<void> upsert(RecentOutlineMetadata entry) async {
    if (entry.id.trim().isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final history = await _readHistory(prefs);
    final filtered =
        history.where((existing) => existing.id != entry.id).toList();
    final updated = <RecentOutlineMetadata>[
      entry,
      ...filtered,
    ].take(_maxEntries).toList(growable: false);

    await _writeHistory(prefs, updated);
  }

  Future<List<RecentOutlineMetadata>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _readHistory(prefs);
    return history;
  }

  Future<RecentOutlineMetadata?> findById(String id) async {
    if (id.trim().isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final history = await _readHistory(prefs);
    for (final entry in history) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  Future<void> remove(String id) async {
    if (id.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final history = await _readHistory(prefs);
    final filtered =
        history.where((entry) => entry.id != id).toList(growable: false);
    await _writeHistory(prefs, filtered);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<List<RecentOutlineMetadata>> _readHistory(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <RecentOutlineMetadata>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <RecentOutlineMetadata>[];
      }

      final list = decoded.whereType<Map>().map(
        (entry) => RecentOutlineMetadata.fromJson(
          Map<String, dynamic>.from(entry),
        ),
      );
      final items = list.toList(growable: false);
      items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return items.take(_maxEntries).toList(growable: false);
    } catch (_) {
      return <RecentOutlineMetadata>[];
    }
  }

  Future<void> _writeHistory(
    SharedPreferences prefs,
    List<RecentOutlineMetadata> history,
  ) async {
    final serialized = history
        .map((entry) => entry.toJson())
        .toList(growable: false);
    await prefs.setString(_storageKey, jsonEncode(serialized));
  }
}


