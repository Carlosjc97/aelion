import 'dart:convert';

import 'package:edaptia/services/api_config.dart';

import 'course_api_client.dart';
import 'course_normalizers.dart';
import 'placement_band.dart';

class ModuleService {
  ModuleService._();

  static Future<Map<String, dynamic>> fetchGenerativeModule({
    required String topic,
    required int moduleNumber,
    PlacementBand? band,
    String language = 'en',
    String? previousModuleId,
    Duration timeout = const Duration(seconds: 180),  // 3 minutos para plan adaptativo
    int maxRetries = 3,
  }) async {
    if (moduleNumber < 1) {
      throw ArgumentError('moduleNumber must be >= 1');
    }

    final normalizedLanguage = normalizeLanguage(language);
    final uri = moduleNumber == 1
        ? ApiConfig.outlineGenerative()
        : ApiConfig.fetchNextModule();

    final payload = <String, dynamic>{
      'topic': topic.trim(),
      'lang': normalizedLanguage,
    };

    if (band != null) {
      payload['band'] = placementBandToString(band);
    }

    if (moduleNumber > 1) {
      if (previousModuleId == null || previousModuleId.trim().isEmpty) {
        throw ArgumentError(
          'previousModuleId is required when requesting modules beyond M1',
        );
      }
      payload['moduleNumber'] = moduleNumber;
      payload['previousModuleId'] = previousModuleId.trim();
    }

    final response = await CourseApiClient.postJson(
      uri: Uri.parse(uri),
      body: payload,
      timeout: timeout,
      maxRetries: maxRetries,
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid module response payload.');
    }

    return Map<String, dynamic>.from(decoded);
  }
}
