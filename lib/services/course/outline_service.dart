import 'dart:convert';

import 'package:edaptia/services/api_config.dart';

import 'course_api_client.dart';
import 'course_normalizers.dart';
import 'models.dart';
import 'placement_band.dart';

typedef OutlineFetcher = Future<Map<String, dynamic>> Function({
  required String topic,
  String? goal,
  String? level,
  required String language,
  required String depth,
  PlacementBand? band,
});

class OutlineService {
  OutlineService._();

  /// Generates an outline plan, returning a strongly typed [OutlinePlan].
  static Future<OutlinePlan> generatePlan({
    required String topic,
    String? goal,
    String? level,
    String language = 'en',
    String depth = 'medium',
    PlacementBand? band,
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 3,
  }) async {
    final cleanedTopic = topic.trim();
    if (cleanedTopic.isEmpty) {
      throw ArgumentError('Topic cannot be empty.');
    }

    final normalizedBand = band != null ? placementBandToString(band) : null;
    final normalizedDepth =
        band != null ? depthForBand(band) : normalizeDepth(depth);
    final normalizedLanguage = normalizeLanguage(language);
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

    final response = await CourseApiClient.postJson(
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
    return _buildOutlinePlan(
      raw: map,
      fallbackTopic: cleanedTopic,
      goalFallback: payload['goal']?.toString() ?? 'Master $cleanedTopic',
      normalizedDepth: normalizedDepth,
      normalizedLanguage: normalizedLanguage,
      normalizedBand: normalizedBand,
    );
  }

  /// Compatibility helper returning the legacy Map structure.
  static Future<Map<String, dynamic>> generateOutlineMap({
    required String topic,
    String? goal,
    String? level,
    String language = 'en',
    String depth = 'medium',
    PlacementBand? band,
    Duration timeout = CourseApiClient.defaultTimeout,
    int maxRetries = 3,
  }) async {
    final plan = await generatePlan(
      topic: topic,
      goal: goal,
      level: level,
      language: language,
      depth: depth,
      band: band,
      timeout: timeout,
      maxRetries: maxRetries,
    );
    return plan.toJson();
  }

  static OutlinePlan _buildOutlinePlan({
    required Map<String, dynamic> raw,
    required String fallbackTopic,
    required String goalFallback,
    required String normalizedDepth,
    required String normalizedLanguage,
    required String? normalizedBand,
  }) {
    final modules = _extractOutline(raw);
    final typedModules = <OutlineModule>[];

    for (var index = 0; index < modules.length; index++) {
      typedModules.add(_mapModule(modules[index], index));
    }

    final cacheExpiresAt = raw['cacheExpiresAt'] is num
        ? (raw['cacheExpiresAt'] as num).toInt()
        : DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;

    final meta = <String, dynamic>{};
    if (raw['meta'] is Map) {
      meta.addAll(Map<String, dynamic>.from(raw['meta'] as Map));
    }
    if (raw['raw'] is Map) {
      meta['raw'] = Map<String, dynamic>.from(raw['raw'] as Map);
    } else {
      meta['raw'] = raw;
    }

    return OutlinePlan(
      topic: raw['topic']?.toString() ?? fallbackTopic,
      goal: raw['goal']?.toString() ?? goalFallback,
      language: raw['language']?.toString() ?? normalizedLanguage,
      depth: normalizedDepth,
      band: raw['band']?.toString() ?? normalizedBand,
      modules: typedModules,
      source: raw['source']?.toString() ?? 'fresh',
      estimatedHours: raw['estimated_hours'] is num
          ? (raw['estimated_hours'] as num).toInt()
          : _estimateHours(typedModules, normalizedDepth),
      cacheExpiresAt: cacheExpiresAt,
      meta: meta,
    );
  }

  static int _estimateHours(List<OutlineModule> modules, String depth) {
    final totalMinutes = modules
        .expand((module) => module.lessons)
        .fold<int>(0, (sum, lesson) => sum + lesson.durationMinutes);
    final depthMultiplier = depth == 'deep'
        ? 1.2
        : depth == 'intro'
            ? 0.75
            : 1.0;
    final estimated = (totalMinutes * depthMultiplier) / 60;
    if (estimated.isNaN || estimated.isInfinite) {
      return 4;
    }
    if (estimated < 4) {
      return 4;
    }
    if (estimated > 60) {
      return 60;
    }
    return estimated.round();
  }

  static OutlineModule _mapModule(Map<String, dynamic> module, int index) {
    final moduleId = module['moduleId']?.toString() ??
        module['id']?.toString() ??
        'module-$index';
    final lessonsRaw = module['lessons'];
    final lessons = <OutlineLesson>[];
    if (lessonsRaw is List) {
      for (var lessonIndex = 0; lessonIndex < lessonsRaw.length; lessonIndex++) {
        final raw = lessonsRaw[lessonIndex];
        if (raw is Map) {
          lessons.add(_mapLesson(Map<String, dynamic>.from(raw), lessonIndex));
        }
      }
    }

    final progressRaw = module['progress'];
    final completed = progressRaw is Map && progressRaw['completed'] is num
        ? (progressRaw['completed'] as num).toInt().clamp(0, lessons.length)
        : 0;
    final total = progressRaw is Map && progressRaw['total'] is num
        ? (progressRaw['total'] as num).toInt().clamp(0, lessons.length)
        : lessons.length;

    final locked = module['locked'] == true || (module['unlocked'] == false);

    return OutlineModule(
      moduleId: moduleId,
      title: module['title']?.toString() ?? 'Module ${index + 1}',
      summary: module['summary']?.toString() ?? '',
      lessons: lessons,
      locked: locked,
      completedLessons: completed,
      totalLessons: total,
    );
  }

  static OutlineLesson _mapLesson(Map<String, dynamic> lesson, int index) {
    final id = lesson['id']?.toString() ?? 'lesson-$index';
    final summary = lesson['summary']?.toString() ?? '';
    final content = lesson['content']?.toString() ?? summary;
    final duration = lesson['durationMinutes'] is num
        ? (lesson['durationMinutes'] as num).toInt().clamp(1, 120)
        : 20;

    return OutlineLesson(
      id: id,
      title: lesson['title']?.toString() ?? 'Lesson ${index + 1}',
      summary: summary,
      objective: lesson['objective']?.toString(),
      type: lesson['type']?.toString() ?? 'lesson',
      durationMinutes: duration,
      content: content,
    );
  }

  static List<Map<String, dynamic>> _extractOutline(Map<String, dynamic> map) {
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
}
