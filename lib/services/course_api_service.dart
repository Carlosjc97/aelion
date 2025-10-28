import 'dart:convert';
import 'dart:math' as math;

import 'package:aelion/services/api_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

typedef OutlineFetcher = Future<Map<String, dynamic>> Function({
  required String topic,
  String? goal,
  String? level,
  required String language,
  required String depth,
  PlacementBand? band,
});

enum PlacementBand { beginner, intermediate, advanced }

/// HTTP client for the learning backend.
class CourseApiService {
  CourseApiService._();

  static http.Client httpClient = http.Client();

  static const _timeout = Duration(seconds: 25);

  static const Set<String> _supportedDepths = {'intro', 'medium', 'deep'};

  static const Set<String> _supportedQuizLanguages = {'en', 'es'};

  static const _placementChoices = 4;

  static const _placementMaxMinutesFallback = 15;

  static const Map<String, PlacementBand> _bandLookup = {
    'beginner': PlacementBand.beginner,
    'intermediate': PlacementBand.intermediate,
    'advanced': PlacementBand.advanced,
  };

  static const Map<PlacementBand, String> _bandToDepth = {
    PlacementBand.beginner: 'intro',
    PlacementBand.intermediate: 'medium',
    PlacementBand.advanced: 'deep',
  };

  static const Map<String, PlacementBand> _depthToBand = {
    'intro': PlacementBand.beginner,
    'medium': PlacementBand.intermediate,
    'deep': PlacementBand.advanced,
  };

  static PlacementBand placementBandFromString(String raw) {
    final normalized = raw.trim().toLowerCase();
    return _bandLookup[normalized] ?? PlacementBand.beginner;
  }

  static String placementBandToString(PlacementBand band) {
    switch (band) {
      case PlacementBand.beginner:
        return 'beginner';
      case PlacementBand.intermediate:
        return 'intermediate';
      case PlacementBand.advanced:
        return 'advanced';
    }
  }

  static String depthForBand(PlacementBand band) =>
      _bandToDepth[band] ?? 'intro';

  static PlacementBand bandForDepth(String depth) =>
      _depthToBand[depth] ?? PlacementBand.beginner;

  static PlacementBand placementBandForScore(num score) {
    final normalized = score.isFinite ? score.toInt().clamp(0, 100) : 0;
    if (normalized >= 80) {
      return PlacementBand.advanced;
    }
    if (normalized >= 50) {
      return PlacementBand.intermediate;
    }
    return PlacementBand.beginner;
  }

  static PlacementBand? tryPlacementBandFromString(String? raw) {
    if (raw == null) {
      return null;
    }
    final normalized = raw.trim().toLowerCase();
    return _bandLookup[normalized];
  }

  static String _normalizePlacementLanguage(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (_supportedQuizLanguages.contains(normalized)) {
      return normalized;
    }
    return 'en';
  }

  /// Calls `/outline` and returns the normalized payload.
  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
    String? goal,
    String? level,
    String language = 'en',
    String depth = 'medium',
    PlacementBand? band,
    Duration timeout = _timeout,
    int maxRetries = 3,
  }) async {
    final cleanedTopic = topic.trim();
    if (cleanedTopic.isEmpty) {
      throw ArgumentError('Topic cannot be empty.');
    }

    final normalizedBand =
        band != null ? placementBandToString(band) : null;
    final normalizedDepth =
        band != null ? depthForBand(band) : _normalizeDepth(depth);
    final normalizedLanguage = _normalizeLanguage(language);
    final payload = <String, dynamic>{
      'topic': cleanedTopic,
      'goal': (goal?.trim().isNotEmpty ?? false)
          ? goal!.trim()
          : 'Master $cleanedTopic',
      'depth': normalizedDepth,
      'lang': normalizedLanguage,
      'language': normalizedLanguage,
    };

    final normalizedLevel = level?.trim();
    if (normalizedLevel != null && normalizedLevel.isNotEmpty) {
      payload['level'] = normalizedLevel.toLowerCase();
    }
    if (normalizedBand != null) {
      payload['band'] = normalizedBand;
    }

    final response = await _postJsonWithRetry(
      uri: Uri.parse(ApiConfig.outline()),
      body: payload,
      timeout: timeout,
      maxRetries: maxRetries,
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid outline response payload.');
    }
    final map = Map<String, dynamic>.from(decoded);
    final outline = _extractOutline(map);

    final normalizedResponse = <String, dynamic>{
      'outline': outline,
      'source': map['source']?.toString() ?? 'fresh',
    };

    final expiresAt = map['cacheExpiresAt'];
    if (expiresAt is num) {
      normalizedResponse['cacheExpiresAt'] = expiresAt.toInt();
    }

    if (map['meta'] is Map) {
      normalizedResponse['meta'] = Map<String, dynamic>.from(
        map['meta'] as Map,
      );
    }

    if (map['raw'] is Map) {
      normalizedResponse['raw'] = Map<String, dynamic>.from(map['raw'] as Map);
    } else {
      normalizedResponse['raw'] = map;
    }

    normalizedResponse['topic'] = map['topic']?.toString() ?? cleanedTopic;
    if (map['goal'] != null) {
      normalizedResponse['goal'] = map['goal'];
    } else {
      normalizedResponse['goal'] = payload['goal'];
    }
    if (map['level'] != null) {
      normalizedResponse['level'] = map['level'];
    } else if (normalizedLevel != null && normalizedLevel.isNotEmpty) {
      normalizedResponse['level'] = normalizedLevel;
    }
    normalizedResponse['language'] =
        map['language']?.toString() ?? normalizedLanguage;
    normalizedResponse['depth'] = normalizedDepth;
    final responseBand = map['band']?.toString() ?? normalizedBand;
    if (responseBand != null && responseBand.isNotEmpty) {
      normalizedResponse['band'] = responseBand;
    }
    if (map['estimated_hours'] != null) {
      normalizedResponse['estimated_hours'] = map['estimated_hours'];
    }

    return normalizedResponse;
  }

  /// Starts a placement quiz session and returns questions without solutions.
  static Future<PlacementQuizStartResponse> startPlacementQuiz({
    required String topic,
    String language = 'en',
    Duration timeout = _timeout,
    int maxRetries = 1,
  }) async {
    final cleanedTopic = topic.trim();
    if (cleanedTopic.length < 3) {
      throw ArgumentError('Topic must be at least 3 characters long.');
    }

    final normalizedLanguage = _normalizePlacementLanguage(language);
    final response = await _postJsonWithRetry(
      uri: Uri.parse(ApiConfig.placementQuizStart()),
      body: {
        'topic': cleanedTopic,
        'lang': normalizedLanguage,
      },
      timeout: timeout,
      maxRetries: maxRetries,
    );

    final decoded = jsonDecode(response.body);
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
        .map((questionMap) => _parsePlacementQuestion(
              questionMap,
              normalizedLanguage,
            ))
        .whereType<PlacementQuizQuestion>()
        .toList(growable: false);

    final normalizedQuestions = questions
        .take(requestedNumQuestions ?? questions.length)
        .toList(growable: false);

    final maxMinutes = policy['maxMinutes'] is num
        ? (policy['maxMinutes'] as num).toInt()
        : _placementMaxMinutesFallback;

    return PlacementQuizStartResponse(
      quizId: quizId,
      expiresAt: expiresAt,
      maxMinutes: maxMinutes,
      numQuestions: normalizedQuestions.length,
      questions: normalizedQuestions,
    );
  }

  /// Grades a placement quiz attempt against the authoritative answers.
  static Future<PlacementQuizGradeResponse> gradePlacementQuiz({
    required String quizId,
    required List<PlacementQuizAnswer> answers,
    Duration timeout = _timeout,
    int maxRetries = 1,
  }) async {
    final trimmedQuizId = quizId.trim();
    if (trimmedQuizId.isEmpty) {
      throw ArgumentError('quizId cannot be empty.');
    }
    if (answers.isEmpty) {
      throw ArgumentError('answers cannot be empty.');
    }

    final response = await _postJsonWithRetry(
      uri: Uri.parse(ApiConfig.placementQuizGrade()),
      body: {
        'quizId': trimmedQuizId,
        'answers': answers
            .map(
              (answer) => {
                'id': answer.id,
                'choiceIndex': answer.choiceIndex,
              },
            )
            .toList(growable: false),
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
    final scorePct = scorePctRaw is num
        ? scorePctRaw.toInt().clamp(0, 100)
        : 0;
    final recommendRegenerate = map['recommendRegenerate'] == true;

    return PlacementQuizGradeResponse(
      band: band,
      scorePct: scorePct,
      recommendRegenerate: recommendRegenerate,
      suggestedDepth: suggestedDepth,
    );
  }

  /// Records a search event for recommendation purposes. 429 responses are treated as success.
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
    final normalizedLanguage = _normalizePlacementLanguage(language);
    await _postJsonWithRetry(
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

  /// Returns the top trending topics for the given language.
  static Future<List<TrendingTopic>> fetchTrending({
    required String language,
    Duration timeout = const Duration(seconds: 12),
    int maxRetries = 1,
  }) async {
    final normalizedLanguage = _normalizePlacementLanguage(language);
    final response = await _getWithRetry(
      uri: Uri.parse(ApiConfig.trending(normalizedLanguage)),
      timeout: timeout,
      maxRetries: maxRetries,
    );

    if (response.body.isEmpty) {
      return const <TrendingTopic>[];
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException(
        'Trending response must be a JSON object.',
      );
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
      final fallbackKey = rawTopic.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
      final topicKey = topicKeyRaw.isNotEmpty ? topicKeyRaw : fallbackKey;
      if (!seenKeys.add(topicKey)) {
        continue;
      }
      final countRaw = entry['count'];
      final count = countRaw is num ? countRaw.toInt() : 0;
      results.add(
        TrendingTopic(
          topic: rawTopic,
          topicKey: topicKey,
          count: count,
        ),
      );
    }
    return results;
  }

  static PlacementQuizQuestion? _parsePlacementQuestion(
    Map<dynamic, dynamic> raw,
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
    final normalizedId =
        idRaw != null && idRaw.isNotEmpty ? idRaw : 'question-${text.hashCode.abs()}';

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
    if (normalized == 'es') {
      return 'Opción $number';
    }
    return 'Option $number';
  }

  /// Calls `/quiz` and returns the list of deterministic questions.
  static Future<List<QuizQuestionDto>> generateQuiz({
    required String topic,
    int numQuestions = 10,
    String language = 'en',
    String? moduleTitle,
    Duration timeout = _timeout,
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
      'language': _normalizeLanguage(language),
    };

    if (trimmedTopic.isNotEmpty) {
      payload['topic'] = trimmedTopic;
    }

    if (trimmedModule.isNotEmpty) {
      payload['moduleTitle'] = trimmedModule;
    }

    final response = await _postJsonWithRetry(
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

  static Future<http.Response> _getWithRetry({
    required Uri uri,
    required Duration timeout,
    required int maxRetries,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    int attempt = 0;
    Object? lastError;
    while (attempt <= maxRetries) {
      try {
        final response = await httpClient
            .get(
              uri,
              headers: {
                'Accept': 'application/json',
                if (idToken != null) 'Authorization': 'Bearer $idToken',
                if (user != null) 'X-User-Id': user.uid,
              },
            )
            .timeout(timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        if (response.statusCode == 429 ||
            (response.statusCode >= 500 && response.statusCode < 600)) {
          attempt++;
          if (attempt > maxRetries) {
            final detail =
                response.body.isNotEmpty ? response.body : 'No details';
            throw Exception(
              'Failed after retries (${response.statusCode}): $detail',
            );
          }
          final delayMs = _backoffWithJitterMs(attempt);
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }

        final detail = response.body.isNotEmpty ? response.body : 'No details';
        throw Exception(
          'Request to ${uri.path} failed (${response.statusCode}): $detail',
        );
      } catch (error) {
        lastError = error;
        attempt++;
        if (attempt > maxRetries) {
          rethrow;
        }
        final delayMs = _backoffWithJitterMs(attempt);
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    throw Exception('Request to ${uri.path} failed. Last error: $lastError');
  }

  static Future<http.Response> _postJsonWithRetry({
    required Uri uri,
    required Map<String, dynamic> body,
    required Duration timeout,
    required int maxRetries,
    Set<int> additionalSuccessCodes = const <int>{},
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    int attempt = 0;
    Object? lastError;
    while (attempt <= maxRetries) {
      try {
        final response = await httpClient
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                if (idToken != null) 'Authorization': 'Bearer $idToken',
                if (user != null) 'X-User-Id': user.uid,
              },
              body: jsonEncode(body),
            )
            .timeout(timeout);

        if ((response.statusCode >= 200 && response.statusCode < 300) ||
            additionalSuccessCodes.contains(response.statusCode)) {
          return response;
        }

        if (response.statusCode == 429 ||
            (response.statusCode >= 500 && response.statusCode < 600)) {
          attempt++;
          if (attempt > maxRetries) {
            final detail =
                response.body.isNotEmpty ? response.body : 'No details';
            throw Exception(
              'Failed after retries (${response.statusCode}): $detail',
            );
          }
          final delayMs = _backoffWithJitterMs(attempt);
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }

        final detail = response.body.isNotEmpty ? response.body : 'No details';
        throw Exception(
          'Request to ${uri.path} failed (${response.statusCode}): $detail',
        );
      } catch (error) {
        lastError = error;
        attempt++;
        if (attempt > maxRetries) {
          rethrow;
        }
        final delayMs = _backoffWithJitterMs(attempt);
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    throw Exception('Request to ${uri.path} failed. Last error: $lastError');
  }

  static String _normalizeLanguage(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 'en';
    }
    return trimmed;
  }

  static String _normalizeDepth(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (_supportedDepths.contains(normalized)) {
      return normalized;
    }
    throw ArgumentError(
      'Invalid depth "$raw". Supported values: ${_supportedDepths.join(', ')}.',
    );
  }

  static List<Map<String, dynamic>> _extractOutline(
    Map<String, dynamic> map,
  ) {
    final outline = map['outline'];
    if (outline is List) {
      return outline
          .whereType<Map>()
          .map((element) => Map<String, dynamic>.from(element))
          .toList(growable: false);
    }

    final modules = map['modules'];
    if (modules is List) {
      return modules
          .whereType<Map>()
          .map((element) => Map<String, dynamic>.from(element))
          .toList(growable: false);
    }

    throw const FormatException('Outline response is missing "outline".');
  }

  static int _backoffWithJitterMs(int attempt) {
    const base = 400;
    const cap = 3000;
    final expo = base * math.pow(2, attempt - 1).toInt();
    final jitter = math.Random().nextInt(250);
    return math.min(cap, expo + jitter);
  }
}

class TrendingTopic {
  const TrendingTopic({
    required this.topic,
    required this.topicKey,
    required this.count,
  });

  final String topic;
  final String topicKey;
  final int count;
}

class QuizQuestionDto {
  const QuizQuestionDto({
    required this.question,
    required this.options,
    required this.answer,
  });

  final String question;
  final List<String> options;
  final String answer;

  int get correctIndex => options.indexOf(answer);

  factory QuizQuestionDto.fromMap(Map<String, dynamic> map) {
    final question = map['question']?.toString().trim() ?? '';
    final answer = map['answer']?.toString().trim() ?? '';
    final rawOptions = map['options'];

    final options = rawOptions is List
        ? rawOptions.map((option) => option.toString()).toList(growable: false)
        : <String>[];

    if (question.isEmpty) {
      throw const FormatException('Quiz question is missing "question".');
    }

    if (options.length != 4) {
      throw const FormatException(
        'Quiz question must include exactly 4 options.',
      );
    }

    if (answer.isEmpty || !options.contains(answer)) {
      throw const FormatException(
        'Quiz question "answer" must match one of the options.',
      );
    }

    return QuizQuestionDto(
      question: question,
      options: options,
      answer: answer,
    );
  }
}

class PlacementQuizQuestion {
  const PlacementQuizQuestion({
    required this.id,
    required this.text,
    required this.choices,
  });

  final String id;
  final String text;
  final List<String> choices;
}

class PlacementQuizAnswer {
  const PlacementQuizAnswer({
    required this.id,
    required this.choiceIndex,
  }) : assert(choiceIndex >= 0, 'choiceIndex must be non-negative');

  final String id;
  final int choiceIndex;
}

class PlacementQuizStartResponse {
  const PlacementQuizStartResponse({
    required this.quizId,
    required this.expiresAt,
    required this.maxMinutes,
    required this.numQuestions,
    required this.questions,
  });

  final String quizId;
  final DateTime expiresAt;
  final int maxMinutes;
  final int numQuestions;
  final List<PlacementQuizQuestion> questions;
}

class PlacementQuizGradeResponse {
  const PlacementQuizGradeResponse({
    required this.band,
    required this.scorePct,
    required this.recommendRegenerate,
    required this.suggestedDepth,
  });

  final PlacementBand band;
  final int scorePct;
  final bool recommendRegenerate;
  final String suggestedDepth;

  double get scoreFraction => scorePct / 100;
}
