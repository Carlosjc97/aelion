import 'dart:convert';

import 'package:edaptia/services/api_config.dart';

import 'course_api_client.dart';
import 'course_normalizers.dart';
import 'models.dart';
import 'placement_band.dart';

class QuizService {
  QuizService._();

  static const int _placementChoices = 4;
  static const int _placementMaxMinutesFallback = 15;

  static Future<PlacementQuizStart> startPlacementQuiz({
    required String topic,
    String language = 'en',
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 1,
  }) async {
    final cleanedTopic = topic.trim();
    if (cleanedTopic.length < 3) {
      throw ArgumentError('Topic must be at least 3 characters long.');
    }

    final normalizedLanguage = normalizePlacementLanguage(language);
    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.placementQuizStartLive()),
      body: {
        'topic': cleanedTopic,
        'lang': normalizedLanguage,
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );

    return _parsePlacementQuizStartResponse(
      response.body,
      normalizedLanguage,
    );
  }

  static Future<PlacementQuizStart> startModuleQuiz({
    required int moduleNumber,
    required String topic,
    String language = 'en',
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 1,
  }) async {
    if (moduleNumber < 1) {
      throw ArgumentError('moduleNumber must be >= 1');
    }
    final normalizedLanguage = normalizePlacementLanguage(language);
    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.moduleQuizStart()),
      body: {
        'moduleNumber': moduleNumber,
        'moduleId': 'module-$moduleNumber',
        'topic': topic.trim(),
        'lang': normalizedLanguage,
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );

    return _parsePlacementQuizStartResponse(
      response.body,
      normalizedLanguage,
    );
  }

  static Future<PlacementQuizGrade> gradePlacementQuiz({
    required String quizId,
    required List<PlacementQuizAnswer> answers,
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 1,
  }) async {
    final trimmedQuizId = quizId.trim();
    if (trimmedQuizId.isEmpty) {
      throw ArgumentError('quizId cannot be empty.');
    }
    if (answers.isEmpty) {
      throw ArgumentError('answers cannot be empty.');
    }

    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.placementQuizGrade()),
      body: {
        'quizId': trimmedQuizId,
        'answers': answers.map((answer) => answer.toJson()).toList(),
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid placement quiz grade payload.');
    }

    final map = Map<String, dynamic>.from(decoded);
    final bandRaw = map['band']?.toString() ?? 'beginner';
    final band = placementBandFromString(bandRaw);
    final suggestedDepth = map['suggestedDepth']?.toString() ??
        depthForBand(band); // fallback to derived depth
    final scorePctRaw = map['scorePct'];
    final scorePct = scorePctRaw is num ? scorePctRaw.toInt().clamp(0, 100) : 0;
    final recommendRegenerate = map['recommendRegenerate'] == true;
    final thetaRaw = map['theta'];
    final theta = thetaRaw is num ? thetaRaw.toDouble() : null;
    final responseCorrectness = _parseResponseCorrectness(map['responses']);

    return PlacementQuizGrade(
      band: band,
      scorePct: scorePct,
      recommendRegenerate: recommendRegenerate,
      suggestedDepth: suggestedDepth,
      theta: theta,
      responseCorrectness: responseCorrectness,
    );
  }

  static Future<ModuleQuizGradeResult> gradeModuleQuiz({
    required String quizId,
    required List<PlacementQuizAnswer> answers,
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 1,
  }) async {
    final trimmedQuizId = quizId.trim();
    if (trimmedQuizId.isEmpty) {
      throw ArgumentError('quizId cannot be empty.');
    }
    if (answers.isEmpty) {
      throw ArgumentError('answers cannot be empty.');
    }

    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.moduleQuizGrade()),
      body: {
        'quizId': trimmedQuizId,
        'answers': answers.map((answer) => answer.toJson()).toList(),
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid module quiz grade payload.');
    }

    final map = Map<String, dynamic>.from(decoded);
    final passed = map['passed'] == true;
    final score = map['scorePct'] is num ? (map['scorePct'] as num).toInt() : 0;
    final incorrectQuestions = (map['incorrectQuestions'] as List?)
            ?.whereType<String>()
            .toList(growable: false) ??
        const <String>[];
    final incorrectTags = (map['incorrectTags'] as List?)
            ?.whereType<String>()
            .toList(growable: false) ??
        const <String>[];
    final attempts = map['attempts'] is num ? (map['attempts'] as num).toInt() : 0;
    final practiceUnlocked = map['practiceUnlocked'] == true;

    return ModuleQuizGradeResult(
      passed: passed,
      scorePct: score,
      incorrectQuestions: incorrectQuestions,
      incorrectTags: incorrectTags,
      attempts: attempts,
      practiceUnlocked: practiceUnlocked,
    );
  }

  static List<bool> _parseResponseCorrectness(dynamic raw) {
    if (raw is! List) return const <bool>[];
    return raw
        .map((entry) => entry == true || entry.toString() == 'true')
        .toList(growable: false);
  }

  static Future<List<QuizQuestionDto>> generateQuiz({
    required String topic,
    int numQuestions = 10,
    String language = 'en',
    String? moduleTitle,
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 2,
  }) async {
    final trimmedTopic = topic.trim();
    final trimmedModule = moduleTitle?.trim() ?? '';

    if (trimmedTopic.isEmpty && trimmedModule.isEmpty) {
      throw ArgumentError('A topic or moduleTitle must be provided.');
    }

    if (numQuestions <= 0) {
      throw ArgumentError('numQuestions must be greater than zero.');
    }

    final payload = <String, dynamic>{
      'numQuestions': numQuestions,
      'language': normalizeLanguage(language),
    };

    if (trimmedTopic.isNotEmpty) {
      payload['topic'] = trimmedTopic;
    }

    if (trimmedModule.isNotEmpty) {
      payload['moduleTitle'] = trimmedModule;
    }

    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.quiz()),
      body: payload,
      timeout: timeout,
      maxRetries: maxRetries,
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid quiz response payload.');
    }

    final map = Map<String, dynamic>.from(decoded);
    final rawQuestions = map['questions'];
    if (rawQuestions is! List) {
      throw const FormatException('Quiz response is missing "questions".');
    }

    return rawQuestions.map((item) {
      if (item is! Map) {
        throw const FormatException('Quiz question must be an object.');
      }
      return QuizQuestionDto.fromMap(Map<String, dynamic>.from(item));
    }).toList(growable: false);
  }

  static PlacementQuizStart _parsePlacementQuizStartResponse(
    String responseBody,
    String normalizedLanguage,
  ) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map) {
      throw const FormatException('Invalid placement quiz start payload.');
    }

    final map = Map<String, dynamic>.from(decoded);
    final quizId = map['quizId']?.toString();
    if (quizId == null || quizId.isEmpty) {
      throw const FormatException('Placement quiz response missing quizId.');
    }

    final expiresAtRaw = map['expiresAt'];
    final expiresAt = expiresAtRaw is num
        ? DateTime.fromMillisecondsSinceEpoch(expiresAtRaw.toInt(), isUtc: true)
            .toLocal()
        : DateTime.now().add(const Duration(hours: 1));

    final policy = map['policy'] is Map
        ? Map<String, dynamic>.from(map['policy'] as Map)
        : const <String, dynamic>{};

    final requestedNumQuestions = policy['numQuestions'] is num
        ? (policy['numQuestions'] as num).toInt()
        : null;

    final questionsRaw = map['questions'];
    if (questionsRaw is! List) {
      throw const FormatException(
        'Placement quiz response missing questions array.',
      );
    }

    final questions = questionsRaw
        .whereType<Map>()
        .map(
          (questionMap) => _parsePlacementQuestion(
            Map<String, dynamic>.from(questionMap),
            normalizedLanguage,
          ),
        )
        .whereType<PlacementQuizQuestion>()
        .toList(growable: false);

    final normalizedQuestions = questions
        .take(requestedNumQuestions ?? questions.length)
        .toList(growable: false);

    final maxMinutes = policy['maxMinutes'] is num
        ? (policy['maxMinutes'] as num).toInt()
        : _placementMaxMinutesFallback;

    return PlacementQuizStart(
      quizId: quizId,
      expiresAt: expiresAt,
      maxMinutes: maxMinutes,
      questions: normalizedQuestions,
    );
  }

  static PlacementQuizQuestion? _parsePlacementQuestion(
    Map<String, dynamic> raw,
    String language,
  ) {
    if (raw.isEmpty) {
      return null;
    }
    final text = raw['text']?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    final idRaw = raw['id']?.toString().trim();
    final normalizedId = idRaw != null && idRaw.isNotEmpty
        ? idRaw
        : 'question-${text.hashCode.abs()}';

    final choices = <String>[];
    final rawChoices = raw['choices'];
    if (rawChoices is List) {
      for (final choice in rawChoices) {
        if (choices.length >= _placementChoices) {
          break;
        }
        final value = choice?.toString().trim();
        if (value == null || value.isEmpty) {
          continue;
        }
        choices.add(value);
      }
    }

    while (choices.length < _placementChoices) {
      choices.add(_fallbackChoiceLabel(choices.length, language));
    }

    return PlacementQuizQuestion(
      id: normalizedId,
      text: text,
      choices: choices,
    );
  }

  static String _fallbackChoiceLabel(int index, String language) {
    final normalized = language.toLowerCase();
    final number = index + 1;
    return normalized == 'es' ? 'Opcion $number' : 'Option $number';
  }
}
