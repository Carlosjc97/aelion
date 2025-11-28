import 'dart:convert';

import 'package:edaptia/services/api_config.dart';

import 'course_api_client.dart';
import 'models.dart';
import 'placement_band.dart';

class AdaptiveService {
  AdaptiveService._();

  /// Obtiene el número óptimo de módulos para un topic/band (5-10 segundos)
  static Future<ModuleCountResponse> fetchModuleCount({
    required String topic,
    required PlacementBand band,
    required String target,
    Duration timeout = const Duration(seconds: 30),
    int maxRetries = 1,
  }) async {
    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.adaptiveModuleCount()),
      body: <String, dynamic>{
        'topic': topic.trim(),
        'band': placementBandToString(band),
        'target': target.trim(),
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid module count payload.');
    }
    return ModuleCountResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

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

    // Fix mojibake in response (UTF-8 bytes interpreted as Windows-1252)
    final cleanedBody = response.body
        .replaceAll('\u00e2\u0080\u00a2', '\u2022')  // bullet point
        .replaceAll('\u00e2\u0080\u0094', '\u2014')  // em dash
        .replaceAll('\u00c3\u00a1', '\u00e1')        // á
        .replaceAll('\u00c3\u00a9', '\u00e9')        // é
        .replaceAll('\u00c3\u00ad', '\u00ed')        // í
        .replaceAll('\u00c3\u00b3', '\u00f3')        // ó
        .replaceAll('\u00c3\u00ba', '\u00fa')        // ú
        .replaceAll('\u00c3\u00b1', '\u00f1')        // ñ
        .replaceAll('\u00c3\u0081', '\u00c1')        // Á
        .replaceAll('\u00c3\u0089', '\u00c9')        // É
        .replaceAll('\u00c3\u008d', '\u00cd')        // Í
        .replaceAll('\u00c3\u0093', '\u00d3')        // Ó
        .replaceAll('\u00c3\u009a', '\u00da')        // Ú
        .replaceAll('\u00c3\u0091', '\u00d1');       // Ñ

    final decoded = jsonDecode(cleanedBody);
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
