import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:edaptia/services/local_outline_storage.dart';
import 'package:edaptia/services/recent_outlines_storage.dart';
import 'package:edaptia/services/recent_search_storage.dart';
import 'package:edaptia/services/topic_band_cache.dart';

class HomeRecentOutline {
  const HomeRecentOutline({
    required this.metadata,
    this.cached,
  });

  final RecentOutlineMetadata metadata;
  final StoredOutline? cached;
}

enum HomeRecommendationSource { trending, recent }

class HomeRecommendation {
  const HomeRecommendation({
    required this.label,
    required this.source,
  });

  final String label;
  final HomeRecommendationSource source;
}

class HomeController extends ChangeNotifier {
  HomeController({
    RecentOutlinesStorage? outlinesStorage,
    LocalOutlineStorage? outlineCache,
    RecentSearchStorage? recentSearchStorage,
    TopicBandCache? bandCache,
    AnalyticsService? analyticsService,
  })  : _outlinesStorage = outlinesStorage ?? RecentOutlinesStorage.instance,
        _outlineCache = outlineCache ?? LocalOutlineStorage.instance,
        _recentSearchStorage =
            recentSearchStorage ?? RecentSearchStorage.instance,
        _bandCache = bandCache ?? TopicBandCache.instance,
        _analytics = analyticsService ?? AnalyticsService();

  static const int maxRecommendationItems = 35;
  static const int maxRecentOutlineItems = 5;

  final RecentOutlinesStorage _outlinesStorage;
  final LocalOutlineStorage _outlineCache;
  final RecentSearchStorage _recentSearchStorage;
  final TopicBandCache _bandCache;
  final AnalyticsService _analytics;

  bool _loadingRecommendations = false;
  bool _recommendationsError = false;
  List<HomeRecentOutline> _recentOutlines = const [];
  List<TrendingTopic> _trendingTopics = const [];
  List<RecentSearchEntry> _recentSearches = const [];

  bool get loadingRecommendations => _loadingRecommendations;
  bool get recommendationsError => _recommendationsError;
  List<HomeRecentOutline> get recentOutlines => _recentOutlines;
  List<TrendingTopic> get trendingTopics => _trendingTopics;
  List<RecentSearchEntry> get recentSearches => _recentSearches;

  Future<void> loadRecents() async {
    final metadata = await _outlinesStorage.readAll();
    if (metadata.isEmpty) {
      _recentOutlines = const [];
      notifyListeners();
      return;
    }

    final sorted =
        metadata.where((entry) => entry.id.trim().isNotEmpty).toList()
          ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

    final seen = <String>{};
    final limited = <RecentOutlineMetadata>[];
    for (final entry in sorted) {
      final key = entry.id.trim();
      if (key.isEmpty || !seen.add(key)) {
        continue;
      }
      limited.add(entry);
      if (limited.length >= maxRecentOutlineItems) {
        break;
      }
    }

    final items = await Future.wait(
      limited.map(
        (entry) async {
          final cached = await _outlineCache.findById(entry.id);
          return HomeRecentOutline(metadata: entry, cached: cached);
        },
      ),
    );

    _recentOutlines = items;
    notifyListeners();
  }

  Future<void> loadRecommendations({
    required String languageCode,
    required String userId,
  }) async {
    _loadingRecommendations = true;
    _recommendationsError = false;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        CourseApiService.fetchTrending(language: languageCode),
        _recentSearchStorage.readForUser(userId),
      ]);

      final trending =
          (results.first as List<TrendingTopic>).toList(growable: false)
            ..sort((a, b) {
              final countComparison = b.count.compareTo(a.count);
              if (countComparison != 0) {
                return countComparison;
              }
              return a.topic.toLowerCase().compareTo(b.topic.toLowerCase());
            });

      final recent =
          (results.last as List<RecentSearchEntry>).toList(growable: false)
            ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

      _trendingTopics =
          trending.take(maxRecommendationItems).toList(growable: false);
      _recentSearches =
          recent.take(maxRecommendationItems).toList(growable: false);
      _recommendationsError = false;
    } catch (error) {
      debugPrint('[HomeController] Failed recommendations: $error');
      _recommendationsError = true;
    } finally {
      _loadingRecommendations = false;
      notifyListeners();
    }
  }

  List<HomeRecommendation> buildRecommendationItems() {
    const replacements = <String, String>{
      'á': 'a',
      'ä': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'å': 'a',
      'é': 'e',
      'ë': 'e',
      'è': 'e',
      'ê': 'e',
      'í': 'i',
      'ï': 'i',
      'ì': 'i',
      'î': 'i',
      'ó': 'o',
      'ö': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ü': 'u',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ñ': 'n',
      'ç': 'c',
    };

    final allowedAlphaNumeric = RegExp(r'[a-z0-9]');

    String normalizeKey({String? label, String? topicKey}) {
      final preferred = topicKey?.trim();
      if (preferred != null && preferred.isNotEmpty) {
        return preferred.toLowerCase();
      }

      final raw = label?.toLowerCase().trim() ?? '';
      if (raw.isEmpty) {
        return '';
      }

      final buffer = StringBuffer();
      for (final rune in raw.runes) {
        final char = String.fromCharCode(rune);
        final replacement = replacements[char];
        if (replacement != null) {
          buffer.write(replacement);
          continue;
        }
        if (allowedAlphaNumeric.hasMatch(char)) {
          buffer.write(char);
        } else if (char == ' ') {
          buffer.write('-');
        }
      }
      return buffer.toString();
    }

    final seen = <String>{};
    final items = <HomeRecommendation>[];

    for (final topic in _trendingTopics) {
      if (items.length >= maxRecommendationItems) break;
      final label = topic.topic.trim();
      if (label.isEmpty) continue;
      final key = normalizeKey(label: label, topicKey: topic.topicKey);
      if (key.isEmpty || !seen.add(key)) {
        continue;
      }
      items.add(
        HomeRecommendation(
          label: label,
          source: HomeRecommendationSource.trending,
        ),
      );
    }

    for (final recent in _recentSearches) {
      if (items.length >= maxRecommendationItems) {
        break;
      }
      final label = recent.topic.trim();
      if (label.isEmpty) continue;
      final key = normalizeKey(label: label);
      if (key.isEmpty || !seen.add(key)) {
        continue;
      }
      items.add(
        HomeRecommendation(
          label: label,
          source: HomeRecommendationSource.recent,
        ),
      );
    }

    if (items.length <= maxRecommendationItems) {
      return items;
    }
    return items.take(maxRecommendationItems).toList(growable: false);
  }

  Future<void> recordSearch({
    required String userId,
    required String topic,
    required String language,
  }) async {
    await _recentSearchStorage.add(
      userId: userId,
      topic: topic,
      language: language,
    );
  }

  Future<PlacementBand?> cachedBand({
    required String userId,
    required String topic,
    required String language,
  }) async {
    return _bandCache.getBand(
      userId: userId,
      topic: topic,
      language: language,
    );
  }

  Future<void> trackQuizOpen({
    required String topic,
    required String language,
  }) async {
    try {
      await _analytics.track(
        'home_open_quiz',
        properties: <String, Object?>{
          'topic': topic,
          'language': language,
        },
        targets: const {AnalyticsService.targetPosthog},
      );
    } catch (error, stackTrace) {
      debugPrint('[HomeController] analytics home_open_quiz failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> trackOutlineGenerated({
    required String topic,
    required String language,
    required String band,
    required String depth,
    required String source,
    required String cachedBand,
  }) async {
    try {
      await _analytics.track(
        'outline_generated',
        properties: <String, Object?>{
          'topic': topic,
          'language': language,
          'band': band,
          'depth': depth,
          'source': source,
          'cached_band': cachedBand,
        },
      );
    } catch (error, stackTrace) {
      debugPrint('[HomeController] outline_generated failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
