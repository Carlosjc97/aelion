import 'dart:convert';

import 'package:edaptia/services/api_config.dart';

import 'course_api_client.dart';
import 'course_normalizers.dart';
import 'models.dart';

class TrendingService {
  TrendingService._();

  static Future<List<TrendingTopic>> fetchTrending({
    required String language,
    Duration timeout = const Duration(seconds: 12),
    int maxRetries = 1,
  }) async {
    final normalizedLanguage = normalizePlacementLanguage(language);
    final response = await CourseApiClient.get(
      uri: Uri.parse(ApiConfig.trending(normalizedLanguage)),
      timeout: timeout,
      maxRetries: maxRetries,
    );

    if (response.body.isEmpty) {
      return const <TrendingTopic>[];
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Trending response must be a JSON object.');
    }

    final topicsRaw = decoded['topics'];
    if (topicsRaw is! List) {
      return const <TrendingTopic>[];
    }

    final results = <TrendingTopic>[];
    final seenKeys = <String>{};
    for (final entry in topicsRaw) {
      if (entry is! Map) {
        continue;
      }
      final rawTopic = entry['topic']?.toString().trim() ?? '';
      if (rawTopic.isEmpty) {
        continue;
      }
      final topicKeyRaw = entry['topicKey']?.toString().trim() ?? '';
      final fallbackKey =
          rawTopic.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
      final topicKey = topicKeyRaw.isNotEmpty ? topicKeyRaw : fallbackKey;
      if (!seenKeys.add(topicKey)) {
        continue;
      }
      final countRaw = entry['count'];
      final count = countRaw is num ? countRaw.toInt() : 0;
      final band = entry['band']?.toString();
      final modules = entry['modules'] is num ? (entry['modules'] as num).toInt() : null;
      results.add(
        TrendingTopic(
          topic: rawTopic,
          topicKey: topicKey,
          count: count,
          band: band?.isEmpty == true ? null : band,
          modules: modules,
        ),
      );
    }
    return results;
  }
}
