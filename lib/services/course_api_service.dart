import 'package:http/http.dart' as http;

import 'course/course_api_client.dart';
import 'course/models.dart';
import 'course/outline_service.dart' as outline_service;
import 'course/placement_band.dart' as band_utils;
import 'course/placement_band.dart';
import 'course/quiz_service.dart' as quiz_service;
import 'course/search_service.dart' as search_service;
import 'course/trending_service.dart' as trending_service;

export 'course/models.dart'
    show
        OutlinePlan,
        OutlineModule,
        OutlineLesson,
        TrendingTopic,
        QuizQuestionDto,
        PlacementQuizQuestion,
        PlacementQuizAnswer;
export 'course/placement_band.dart' show PlacementBand;

typedef PlacementQuizStartResponse = PlacementQuizStart;
typedef PlacementQuizGradeResponse = PlacementQuizGrade;
typedef OutlineFetcher = outline_service.OutlineFetcher;

/// Backwards compatible façade over the modular course services.
class CourseApiService {
  CourseApiService._();

  static http.Client get httpClient => CourseApiClient.httpClient;
  static set httpClient(http.Client client) =>
      CourseApiClient.httpClient = client;

  static const Duration _timeout = CourseApiClient.defaultTimeout;

  static PlacementBand placementBandFromString(String raw) =>
      band_utils.placementBandFromString(raw);

  static String placementBandToString(PlacementBand band) =>
      band_utils.placementBandToString(band);

  static String depthForBand(PlacementBand band) =>
      band_utils.depthForBand(band);

  static PlacementBand bandForDepth(String depth) =>
      band_utils.bandForDepth(depth);

  static PlacementBand placementBandForScore(num score) =>
      band_utils.placementBandForScore(score);

  static PlacementBand? tryPlacementBandFromString(String? raw) =>
      band_utils.tryPlacementBandFromString(raw);

  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
    String? goal,
    String? level,
    String language = 'en',
    String depth = 'medium',
    PlacementBand? band,
    Duration timeout = _timeout,
    int maxRetries = 3,
  }) {
    return outline_service.OutlineService.generateOutlineMap(
      topic: topic,
      goal: goal,
      level: level,
      language: language,
      depth: depth,
      band: band,
      timeout: timeout,
      maxRetries: maxRetries,
    );
  }

  static Future<PlacementQuizStartResponse> startPlacementQuiz({
    required String topic,
    String language = 'en',
    Duration timeout = _timeout,
    int maxRetries = 1,
  }) {
    return quiz_service.QuizService.startPlacementQuiz(
      topic: topic,
      language: language,
      timeout: timeout,
      maxRetries: maxRetries,
    );
  }

  static Future<PlacementQuizGradeResponse> gradePlacementQuiz({
    required String quizId,
    required List<PlacementQuizAnswer> answers,
    Duration timeout = _timeout,
    int maxRetries = 1,
  }) {
    return quiz_service.QuizService.gradePlacementQuiz(
      quizId: quizId,
      answers: answers,
      timeout: timeout,
      maxRetries: maxRetries,
    );
  }

  static Future<void> trackSearch({
    required String topic,
    required String language,
    Duration timeout = const Duration(seconds: 8),
    int maxRetries = 0,
  }) {
    return search_service.SearchService.trackSearch(
      topic: topic,
      language: language,
      timeout: timeout,
      maxRetries: maxRetries,
    );
  }

  static Future<List<TrendingTopic>> fetchTrending({
    required String language,
    Duration timeout = const Duration(seconds: 12),
    int maxRetries = 1,
  }) {
    return trending_service.TrendingService.fetchTrending(
      language: language,
      timeout: timeout,
      maxRetries: maxRetries,
    );
  }

  static Future<List<QuizQuestionDto>> generateQuiz({
    required String topic,
    int numQuestions = 10,
    String language = 'en',
    String? moduleTitle,
    Duration timeout = _timeout,
    int maxRetries = 2,
  }) {
    return quiz_service.QuizService.generateQuiz(
      topic: topic,
      numQuestions: numQuestions,
      language: language,
      moduleTitle: moduleTitle,
      timeout: timeout,
      maxRetries: maxRetries,
    );
  }
}
