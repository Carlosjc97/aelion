import 'dart:convert';

import 'package:edaptia/services/api_config.dart';

import 'course_api_client.dart';
import 'models.dart';
import 'placement_band.dart';

class AdaptiveService {
  AdaptiveService._();

  static Future<AdaptivePlanResponse> fetchPlanDraft({
    required String topic,
    required PlacementBand band,
    required String target,
    String? persona,
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 1,
  }) async {
    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.adaptivePlanDraft()),
      body: <String, dynamic>{
        'topic': topic.trim(),
        'band': placementBandToString(band),
        'target': target.trim(),
        if (persona != null && persona.trim().isNotEmpty)
          'persona': persona.trim(),
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid adaptive plan payload.');
    }
    return AdaptivePlanResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

  static Future<AdaptiveModuleResponse> generateModule({
    required String topic,
    required int moduleNumber,
    List<String> focusSkills = const <String>[],
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 1,
  }) async {
    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.adaptiveModule()),
      body: <String, dynamic>{
        'topic': topic.trim(),
        'moduleNumber': moduleNumber,
        if (focusSkills.isNotEmpty) 'focusSkills': focusSkills,
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid adaptive module payload.');
    }
    return AdaptiveModuleResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

  static Future<AdaptiveCheckpointResponse> generateCheckpoint({
    required String topic,
    required int moduleNumber,
    required List<String> skillsTargeted,
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 1,
  }) async {
    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.adaptiveCheckpointQuiz()),
      body: <String, dynamic>{
        'topic': topic.trim(),
        'moduleNumber': moduleNumber,
        'skillsTargeted': skillsTargeted,
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid adaptive checkpoint payload.');
    }
    return AdaptiveCheckpointResponse.fromJson(
        Map<String, dynamic>.from(decoded));
  }

  static Future<AdaptiveEvaluationResponse> evaluateCheckpoint({
    required int moduleNumber,
    required List<Map<String, String>> answers,
    required List<String> skillsTargeted,
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 1,
  }) async {
    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.adaptiveEvaluateCheckpoint()),
      body: <String, dynamic>{
        'moduleNumber': moduleNumber,
        'answers': answers,
        'skillsTargeted': skillsTargeted,
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid adaptive evaluation payload.');
    }
    return AdaptiveEvaluationResponse.fromJson(
        Map<String, dynamic>.from(decoded));
  }

  static Future<AdaptiveBoosterResponse> requestBooster({
    required String topic,
    required List<String> weakSkills,
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 1,
  }) async {
    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.adaptiveBooster()),
      body: <String, dynamic>{
        'topic': topic.trim(),
        'weakSkills': weakSkills,
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid adaptive booster payload.');
    }
    return AdaptiveBoosterResponse.fromJson(Map<String, dynamic>.from(decoded));
  }
}
