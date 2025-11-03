import 'package:edaptia/services/api_config.dart';

import 'course_api_client.dart';
import 'course_normalizers.dart';

class SearchService {
  SearchService._();

  /// Records a search event for recommendation purposes.
  static Future<void> trackSearch({
    required String topic,
    required String language,
    Duration timeout = const Duration(seconds: 8),
    int maxRetries = 0,
  }) async {
    final cleanedTopic = topic.trim();
    if (cleanedTopic.length < 2) {
      throw ArgumentError('Topic must be at least two characters long.');
    }
    final normalizedLanguage = normalizePlacementLanguage(language);

    await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.trackSearch()),
      body: {
        'topic': cleanedTopic,
        'lang': normalizedLanguage,
      },
      timeout: timeout,
      maxRetries: maxRetries,
      additionalSuccessCodes: const {429},
    );
  }
}
