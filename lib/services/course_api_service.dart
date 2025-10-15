import 'dart:convert';
import 'dart:math' as math;

import 'package:aelion/services/api_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// HTTP client for the learning backend.
class CourseApiService {
  CourseApiService._();

  static const _timeout = Duration(seconds: 25);

  static Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  /// Calls `/outline` and returns the normalized payload.
  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
    String? goal,
    String? level,
    String language = 'en',
    Duration timeout = _timeout,
    int maxRetries = 3,
  }) async {
    final cleanedTopic = topic.trim();
    if (cleanedTopic.isEmpty) {
      throw ArgumentError('Topic cannot be empty.');
    }

    final payload = <String, dynamic>{
      'topic': cleanedTopic,
      'goal': (goal?.trim().isNotEmpty ?? false)
          ? goal!.trim()
          : 'Master $cleanedTopic',
      'language': _normalizeLanguage(language),
    };

    final normalizedLevel = level?.trim();
    if (normalizedLevel != null && normalizedLevel.isNotEmpty) {
      payload['level'] = normalizedLevel.toLowerCase();
    }

    final response = await _postJsonWithRetry(
      path: '/outline',
      body: payload,
      timeout: timeout,
      maxRetries: maxRetries,
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid outline response payload.');
    }
    final map = Map<String, dynamic>.from(decoded);

    if (map['modules'] is! List) {
      throw const FormatException('Outline response is missing "modules".');
    }

    return map;
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
      path: '/quiz',
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

  static Future<http.Response> _postJsonWithRetry({
    required String path,
    required Map<String, dynamic> body,
    required Duration timeout,
    required int maxRetries,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    int attempt = 0;
    Object? lastError;
    while (attempt <= maxRetries) {
      try {
        final response = await http
            .post(
              _uri(path),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                if (idToken != null) 'Authorization': 'Bearer $idToken',
                if (user != null) 'X-User-Id': user.uid,
              },
              body: jsonEncode(body),
            )
            .timeout(timeout);

        if (response.statusCode == 200) {
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
          'Request to $path failed (${response.statusCode}): $detail',
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

    throw Exception('Request to $path failed. Last error: $lastError');
  }

  static String _normalizeLanguage(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 'en';
    }
    return trimmed;
  }

  static int _backoffWithJitterMs(int attempt) {
    const base = 400;
    const cap = 3000;
    final expo = base * math.pow(2, attempt - 1).toInt();
    final jitter = math.Random().nextInt(250);
    return math.min(cap, expo + jitter);
  }
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
