import 'placement_band.dart';

class OutlineLesson {
  const OutlineLesson({
    required this.id,
    required this.title,
    required this.summary,
    this.objective,
    required this.type,
    required this.durationMinutes,
    required this.content,
  });

  final String id;
  final String title;
  final String summary;
  final String? objective;
  final String type;
  final int durationMinutes;
  final String content;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        if (objective != null) 'objective': objective,
        'type': type,
        'durationMinutes': durationMinutes,
        'content': content,
      };
}

class OutlineModule {
  const OutlineModule({
    required this.moduleId,
    required this.title,
    required this.summary,
    required this.lessons,
    required this.locked,
    required this.completedLessons,
    required this.totalLessons,
  });

  final String moduleId;
  final String title;
  final String summary;
  final List<OutlineLesson> lessons;
  final bool locked;
  final int completedLessons;
  final int totalLessons;

  Map<String, dynamic> toJson() => {
        'moduleId': moduleId,
        'title': title,
        'summary': summary,
        'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
        'locked': locked,
        'progress': {
          'completed': completedLessons,
          'total': totalLessons,
        },
      };
}

class OutlinePlan {
  const OutlinePlan({
    required this.topic,
    required this.goal,
    required this.language,
    required this.depth,
    required this.band,
    required this.modules,
    required this.source,
    required this.estimatedHours,
    required this.cacheExpiresAt,
    required this.meta,
  });

  final String topic;
  final String goal;
  final String language;
  final String depth;
  final String? band;
  final List<OutlineModule> modules;
  final String source;
  final int estimatedHours;
  final int cacheExpiresAt;
  final Map<String, dynamic> meta;

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'goal': goal,
        'language': language,
        'depth': depth,
        if (band != null) 'band': band,
        'outline': modules.map((module) => module.toJson()).toList(),
        'source': source,
        'estimated_hours': estimatedHours,
        'cacheExpiresAt': cacheExpiresAt,
        'meta': meta,
      };
}

class TrendingTopic {
  const TrendingTopic({
    required this.topic,
    required this.topicKey,
    required this.count,
    this.band,
    this.modules,
  });

  final String topic;
  final String topicKey;
  final int count;
  final String? band;
  final int? modules;

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'topicKey': topicKey,
        'count': count,
        if (band != null) 'band': band,
        if (modules != null) 'modules': modules,
      };
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'choices': choices,
      };
}

class PlacementQuizAnswer {
  const PlacementQuizAnswer({
    required this.id,
    required this.choiceIndex,
  }) : assert(choiceIndex >= 0, 'choiceIndex must be non-negative');

  final String id;
  final int choiceIndex;

  Map<String, dynamic> toJson() => {
        'id': id,
        'choiceIndex': choiceIndex,
      };
}

class PlacementQuizStart {
  const PlacementQuizStart({
    required this.quizId,
    required this.expiresAt,
    required this.maxMinutes,
    required this.questions,
    int? numQuestions,
  }) : numQuestions = numQuestions ?? questions.length;

  final String quizId;
  final DateTime expiresAt;
  final int maxMinutes;
  final List<PlacementQuizQuestion> questions;
  final int numQuestions;
}

class PlacementQuizGrade {
  const PlacementQuizGrade({
    required this.band,
    required this.scorePct,
    required this.recommendRegenerate,
    required this.suggestedDepth,
    this.theta,
    List<bool>? responseCorrectness,
  }) : responseCorrectness = responseCorrectness ?? const <bool>[];

  final PlacementBand band;
  final int scorePct;
  final bool recommendRegenerate;
  final String suggestedDepth;
  final double? theta;
  final List<bool> responseCorrectness;

  double get scoreFraction => scorePct / 100;
}

class ModuleQuizGradeResult {
  const ModuleQuizGradeResult({
    required this.passed,
    required this.scorePct,
    required this.incorrectQuestions,
    required this.incorrectTags,
  });

  final bool passed;
  final int scorePct;
  final List<String> incorrectQuestions;
  final List<String> incorrectTags;
}

class ChallengeValidationResult {
  const ChallengeValidationResult({
    required this.score,
    required this.passed,
    required this.feedback,
    this.badgeId,
    this.moduleNumber,
    this.lessonId,
  });

  final int score;
  final bool passed;
  final String feedback;
  final String? badgeId;
  final int? moduleNumber;
  final String? lessonId;

  factory ChallengeValidationResult.fromJson(Map<String, dynamic> map) {
    final rawScore = map['score'];
    return ChallengeValidationResult(
      score: rawScore is num ? rawScore.clamp(0, 100).toInt() : 0,
      passed: map['passed'] == true,
      feedback: map['feedback']?.toString() ?? '',
      badgeId: map['badgeId']?.toString(),
      moduleNumber: map['moduleNumber'] is num ? (map['moduleNumber'] as num).toInt() : null,
      lessonId: map['lessonId']?.toString(),
    );
  }
}

class OutlineTweakModule {
  const OutlineTweakModule({
    required this.moduleNumber,
    required this.title,
    required this.objective,
    required this.focus,
  });

  final int moduleNumber;
  final String title;
  final String objective;
  final String focus;

  factory OutlineTweakModule.fromJson(Map<String, dynamic> map) {
    return OutlineTweakModule(
      moduleNumber: map['moduleNumber'] is num ? (map['moduleNumber'] as num).toInt() : 0,
      title: map['title']?.toString() ?? '',
      objective: map['objective']?.toString() ?? '',
      focus: map['focus']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'moduleNumber': moduleNumber,
        'title': title,
        'objective': objective,
        'focus': focus,
      };
}

class OutlineTweakResult {
  const OutlineTweakResult({
    required this.modules,
    required this.recommendedModules,
    required this.summary,
    required this.promptVersion,
  });

  final List<OutlineTweakModule> modules;
  final int recommendedModules;
  final String summary;
  final String promptVersion;

  factory OutlineTweakResult.fromJson(Map<String, dynamic> map) {
    final modulesRaw = map['modules'];
    final modules = modulesRaw is List
        ? modulesRaw
            .whereType<Map>()
            .map((raw) => OutlineTweakModule.fromJson(Map<String, dynamic>.from(raw)))
            .toList(growable: false)
        : const <OutlineTweakModule>[];

    return OutlineTweakResult(
      modules: modules,
      recommendedModules: map['recommendedModules'] is num
          ? (map['recommendedModules'] as num).toInt().clamp(4, 12)
          : modules.length,
      summary: map['summary']?.toString() ?? '',
      promptVersion: map['promptVersion']?.toString() ?? 'unknown',
    );
  }
}

class UsageEntry {
  const UsageEntry({
    required this.id,
    required this.endpoint,
    required this.tokens,
    required this.estimatedCost,
    required this.timestamp,
    this.promptVersion,
  });

  final String id;
  final String endpoint;
  final int tokens;
  final double estimatedCost;
  final DateTime timestamp;
  final String? promptVersion;

  factory UsageEntry.fromJson(Map<String, dynamic> map) {
    return UsageEntry(
      id: map['id']?.toString() ?? '',
      endpoint: map['endpoint']?.toString() ?? 'unknown',
      tokens: map['tokens'] is num ? (map['tokens'] as num).toInt() : 0,
      estimatedCost: map['estimatedCost'] is num ? (map['estimatedCost'] as num).toDouble() : 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] is num ? (map['timestamp'] as num).toInt() : DateTime.now().millisecondsSinceEpoch,
      ),
      promptVersion: map['promptVersion']?.toString(),
    );
  }
}

class UsageMetrics {
  const UsageMetrics({
    required this.entries,
    required this.totalTokens,
    required this.totalCost,
    required this.byEndpoint,
  });

  final List<UsageEntry> entries;
  final int totalTokens;
  final double totalCost;
  final Map<String, int> byEndpoint;

  factory UsageMetrics.fromJson(Map<String, dynamic> map) {
    final entriesRaw = map['entries'];
    final entries = entriesRaw is List
        ? entriesRaw
            .whereType<Map>()
            .map((raw) => UsageEntry.fromJson(Map<String, dynamic>.from(raw)))
            .toList(growable: false)
        : const <UsageEntry>[];

    final totals = map['totals'];
    final totalTokens = totals is Map && totals['tokens'] is num ? (totals['tokens'] as num).toInt() : 0;
    final totalCost = totals is Map && totals['cost'] is num ? (totals['cost'] as num).toDouble() : 0.0;

    final byEndpointRaw = map['byEndpoint'];
    final byEndpoint = <String, int>{};
    if (byEndpointRaw is Map) {
      byEndpointRaw.forEach((key, value) {
        if (value is num) {
          byEndpoint[key.toString()] = value.toInt();
        }
      });
    }

    return UsageMetrics(
      entries: entries,
      totalTokens: totalTokens,
      totalCost: totalCost,
      byEndpoint: byEndpoint,
    );
  }
}
