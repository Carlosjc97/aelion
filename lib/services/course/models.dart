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

class GatePracticeState {
  const GatePracticeState({
    required this.enabled,
    required this.hints,
    required this.attempts,
    required this.maxAttempts,
  });

  final bool enabled;
  final List<String> hints;
  final int attempts;
  final int maxAttempts;

  factory GatePracticeState.fromJson(Map<String, dynamic> map) {
    final hintsRaw = map['hints'];
    final hints = hintsRaw is List
        ? hintsRaw
            .map((hint) => hint?.toString().trim() ?? '')
            .where((hint) => hint.isNotEmpty)
            .toList(growable: false)
        : const <String>[];
    final attempts =
        map['attempts'] is num ? (map['attempts'] as num).toInt() : 0;
    final maxAttempts =
        map['maxAttempts'] is num ? (map['maxAttempts'] as num).toInt() : 3;
    final enabled = map['enabled'] == true ||
        map['practiceMode'] == true ||
        hints.isNotEmpty;
    final normalizedAttempts =
        attempts < 0 ? 0 : (attempts > 99 ? 99 : attempts);
    final normalizedMax =
        maxAttempts < 1 ? 1 : (maxAttempts > 99 ? 99 : maxAttempts);
    return GatePracticeState(
      enabled: enabled,
      hints: hints,
      attempts: normalizedAttempts,
      maxAttempts: normalizedMax,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'hints': hints,
        'attempts': attempts,
        'maxAttempts': maxAttempts,
      };
}

class PlacementQuizStart {
  const PlacementQuizStart({
    required this.quizId,
    required this.expiresAt,
    required this.maxMinutes,
    required this.questions,
    int? numQuestions,
    this.practice,
  }) : numQuestions = numQuestions ?? questions.length;

  final String quizId;
  final DateTime expiresAt;
  final int maxMinutes;
  final List<PlacementQuizQuestion> questions;
  final int numQuestions;
  final GatePracticeState? practice;
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
    this.attempts = 0,
    this.practiceUnlocked = false,
  });

  final bool passed;
  final int scorePct;
  final List<String> incorrectQuestions;
  final List<String> incorrectTags;
  final int attempts;
  final bool practiceUnlocked;
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
      moduleNumber: map['moduleNumber'] is num
          ? (map['moduleNumber'] as num).toInt()
          : null,
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
      moduleNumber:
          map['moduleNumber'] is num ? (map['moduleNumber'] as num).toInt() : 0,
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
            .map((raw) =>
                OutlineTweakModule.fromJson(Map<String, dynamic>.from(raw)))
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
      estimatedCost: map['estimatedCost'] is num
          ? (map['estimatedCost'] as num).toDouble()
          : 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] is num
            ? (map['timestamp'] as num).toInt()
            : DateTime.now().millisecondsSinceEpoch,
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
    final totalTokens = totals is Map && totals['tokens'] is num
        ? (totals['tokens'] as num).toInt()
        : 0;
    final totalCost = totals is Map && totals['cost'] is num
        ? (totals['cost'] as num).toDouble()
        : 0.0;

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

class AdaptiveLearnerHistory {
  const AdaptiveLearnerHistory({
    required this.passedModules,
    required this.failedModules,
    required this.commonErrors,
  });

  final List<int> passedModules;
  final List<int> failedModules;
  final List<String> commonErrors;

  factory AdaptiveLearnerHistory.fromJson(Map<String, dynamic> map) {
    List<int> parseModules(dynamic raw) {
      if (raw is List) {
        return raw.whereType<num>().map((value) => value.toInt()).toList();
      }
      return const <int>[];
    }

    List<String> parseErrors(dynamic raw) {
      if (raw is List) {
        return raw.map((value) => value.toString()).toList();
      }
      return const <String>[];
    }

    return AdaptiveLearnerHistory(
      passedModules: parseModules(map['passedModules']),
      failedModules: parseModules(map['failedModules']),
      commonErrors: parseErrors(map['commonErrors']),
    );
  }
}

class AdaptiveLearnerState {
  const AdaptiveLearnerState({
    required this.levelBand,
    required this.skillMastery,
    required this.history,
    required this.target,
    this.visitedLessons = const {},
  });

  final String levelBand;
  final Map<String, double> skillMastery;
  final AdaptiveLearnerHistory history;
  final String target;
  final Map<String, bool> visitedLessons; // Keys: "topic_m1_l0", etc.

  factory AdaptiveLearnerState.fromJson(Map<String, dynamic> map) {
    final mastery = <String, double>{};
    final masteryRaw = map['skill_mastery'];
    if (masteryRaw is Map) {
      masteryRaw.forEach((key, value) {
        if (value is num) {
          mastery[key.toString()] = value.toDouble();
        }
      });
    }

    final visited = <String, bool>{};
    final visitedRaw = map['visitedLessons'];
    if (visitedRaw is Map) {
      visitedRaw.forEach((key, value) {
        if (value == true) {
          visited[key.toString()] = true;
        }
      });
    }

    return AdaptiveLearnerState(
      levelBand: map['level_band']?.toString() ?? 'basic',
      skillMastery: mastery,
      history: AdaptiveLearnerHistory.fromJson(
        Map<String, dynamic>.from(map['history'] as Map? ?? const {}),
      ),
      target: map['target']?.toString() ?? 'general',
      visitedLessons: visited,
    );
  }
}

class AdaptivePlanModuleSuggestion {
  const AdaptivePlanModuleSuggestion({
    required this.moduleNumber,
    required this.title,
    required this.skills,
    required this.objective,
  });

  final int moduleNumber;
  final String title;
  final List<String> skills;
  final String objective;

  factory AdaptivePlanModuleSuggestion.fromJson(Map<String, dynamic> map) {
    final skillsRaw = map['skills'];
    final skills = skillsRaw is List
        ? skillsRaw.map((value) => value.toString()).toList(growable: false)
        : const <String>[];
    return AdaptivePlanModuleSuggestion(
      moduleNumber:
          map['moduleNumber'] is num ? (map['moduleNumber'] as num).toInt() : 0,
      title: map['title']?.toString() ?? '',
      skills: skills,
      objective: map['objective']?.toString() ?? '',
    );
  }
}

class AdaptiveSkillDescriptor {
  const AdaptiveSkillDescriptor({
    required this.tag,
    required this.description,
  });

  final String tag;
  final String description;

  factory AdaptiveSkillDescriptor.fromJson(Map<String, dynamic> map) {
    return AdaptiveSkillDescriptor(
      tag: map['tag']?.toString() ?? '',
      description: map['desc']?.toString() ?? '',
    );
  }
}

class AdaptivePlanDraft {
  const AdaptivePlanDraft({
    required this.suggestedModules,
    required this.catalog,
    required this.notes,
  });

  final List<AdaptivePlanModuleSuggestion> suggestedModules;
  final List<AdaptiveSkillDescriptor> catalog;
  final String notes;

  factory AdaptivePlanDraft.fromJson(Map<String, dynamic> map) {
    final modulesRaw = map['suggestedModules'];
    final modules = modulesRaw is List
        ? modulesRaw
            .whereType<Map>()
            .map((raw) => AdaptivePlanModuleSuggestion.fromJson(
                  Map<String, dynamic>.from(raw),
                ))
            .toList(growable: false)
        : const <AdaptivePlanModuleSuggestion>[];

    final catalogRaw = map['skillCatalog'];
    final catalog = catalogRaw is List
        ? catalogRaw
            .whereType<Map>()
            .map((raw) => AdaptiveSkillDescriptor.fromJson(
                  Map<String, dynamic>.from(raw),
                ))
            .toList(growable: false)
        : const <AdaptiveSkillDescriptor>[];

    return AdaptivePlanDraft(
      suggestedModules: modules,
      catalog: catalog,
      notes: map['notes']?.toString() ?? '',
    );
  }
}

/// Response from /adaptiveModuleCount endpoint
class ModuleCountResponse {
  const ModuleCountResponse({
    required this.moduleCount,
    required this.rationale,
    required this.topic,
    required this.band,
  });

  final int moduleCount;
  final String rationale;
  final String topic;
  final PlacementBand band;

  factory ModuleCountResponse.fromJson(Map<String, dynamic> map) {
    return ModuleCountResponse(
      moduleCount: map['moduleCount'] as int? ?? 4,
      rationale: map['rationale']?.toString() ?? '',
      topic: map['topic']?.toString() ?? '',
      band: placementBandFromString(map['band']?.toString() ?? 'basic'),
    );
  }

  @override
  String toString() => 'ModuleCountResponse($moduleCount modules for $topic)';
}

class AdaptivePlanResponse {
  const AdaptivePlanResponse({
    required this.plan,
    required this.learnerState,
  });

  final AdaptivePlanDraft plan;
  final AdaptiveLearnerState learnerState;

  factory AdaptivePlanResponse.fromJson(Map<String, dynamic> map) {
    return AdaptivePlanResponse(
      plan: AdaptivePlanDraft.fromJson(
        Map<String, dynamic>.from(map['plan'] as Map? ?? const {}),
      ),
      learnerState: AdaptiveLearnerState.fromJson(
        Map<String, dynamic>.from(map['learnerState'] as Map? ?? const {}),
      ),
    );
  }
}

class AdaptiveLessonPractice {
  const AdaptiveLessonPractice({
    required this.prompt,
    required this.expected,
  });

  final String prompt;
  final String expected;

  factory AdaptiveLessonPractice.fromJson(Map<String, dynamic> map) {
    return AdaptiveLessonPractice(
      prompt: map['prompt']?.toString() ?? '',
      expected: map['expected']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'expected': expected,
    };
  }
}

class AdaptiveMcq {
  const AdaptiveMcq({
    required this.id,
    required this.stem,
    required this.options,
    required this.correct,
    required this.skillTag,
    required this.rationale,
  });

  final String id;
  final String stem;
  final Map<String, String> options;
  final String correct;
  final String skillTag;
  final String rationale;

  factory AdaptiveMcq.fromJson(Map<String, dynamic> map) {
    final options = <String, String>{};
    final rawOptions = map['options'];
    if (rawOptions is Map) {
      rawOptions.forEach((key, value) {
        options[key.toString()] = value?.toString() ?? '';
      });
    }
    return AdaptiveMcq(
      id: map['id']?.toString() ?? '',
      stem: map['stem']?.toString() ?? '',
      options: options,
      correct: map['correct']?.toString() ?? '',
      skillTag: map['skillTag']?.toString() ?? '',
      rationale: map['rationale']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stem': stem,
      'options': options,
      'correct': correct,
      'skillTag': skillTag,
      'rationale': rationale,
    };
  }
}

class AdaptiveLesson {
  const AdaptiveLesson({
    required this.title,
    required this.hook,
    required this.lessonType,
    required this.theory,
    required this.exampleGlobal,
    required this.practice,
    required this.microQuiz,
    this.hint,
    this.motivation,
    required this.takeaway,
  });

  final String title;
  final String hook;
  final String lessonType;
  final String theory;
  final String exampleGlobal;
  final AdaptiveLessonPractice practice;
  final List<AdaptiveMcq> microQuiz;
  final String? hint;
  final String? motivation;
  final String takeaway;

  factory AdaptiveLesson.fromJson(Map<String, dynamic> map) {
    final quizRaw = map['microQuiz'];
    final microQuiz = quizRaw is List
        ? quizRaw
            .whereType<Map>()
            .map((raw) => AdaptiveMcq.fromJson(Map<String, dynamic>.from(raw)))
            .toList(growable: false)
        : const <AdaptiveMcq>[];
    return AdaptiveLesson(
      title: map['title']?.toString() ?? '',
      hook: map['hook']?.toString() ?? '',
      lessonType: map['lessonType']?.toString() ?? 'welcome_summary',
      theory: map['theory']?.toString() ?? '',
      exampleGlobal: map['exampleGlobal']?.toString() ??
          map['exampleLATAM']?.toString() ?? '',  // Backward compatibility
      practice: AdaptiveLessonPractice.fromJson(
        Map<String, dynamic>.from(map['practice'] as Map? ?? const {}),
      ),
      microQuiz: microQuiz,
      hint: map['hint']?.toString(),
      motivation: map['motivation']?.toString(),
      takeaway: map['takeaway']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'hook': hook,
      'lessonType': lessonType,
      'theory': theory,
      'exampleGlobal': exampleGlobal,
      'practice': practice.toJson(),
      'microQuiz': microQuiz.map((q) => q.toJson()).toList(),
      'hint': hint,
      'motivation': motivation,
      'takeaway': takeaway,
    };
  }
}

class AdaptiveChallenge {
  const AdaptiveChallenge({
    required this.description,
    required this.expected,
    required this.rubric,
  });

  final String description;
  final String expected;
  final List<String> rubric;

  factory AdaptiveChallenge.fromJson(Map<String, dynamic> map) {
    final rubricRaw = map['rubric'];
    final rubric = rubricRaw is List
        ? rubricRaw.map((value) => value.toString()).toList(growable: false)
        : const <String>[];
    return AdaptiveChallenge(
      description: map['desc']?.toString() ?? '',
      expected: map['expected']?.toString() ?? '',
      rubric: rubric,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'desc': description,
      'expected': expected,
      'rubric': rubric,
    };
  }
}

class AdaptiveBlueprintItem {
  const AdaptiveBlueprintItem({
    required this.id,
    required this.skillTag,
    required this.type,
  });

  final String id;
  final String skillTag;
  final String type;

  factory AdaptiveBlueprintItem.fromJson(Map<String, dynamic> map) {
    return AdaptiveBlueprintItem(
      id: map['id']?.toString() ?? '',
      skillTag: map['skillTag']?.toString() ?? '',
      type: map['type']?.toString() ?? 'mcq',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillTag': skillTag,
      'type': type,
    };
  }
}

class AdaptiveCheckpointBlueprint {
  const AdaptiveCheckpointBlueprint({
    required this.items,
    required this.targetReliability,
  });

  final List<AdaptiveBlueprintItem> items;
  final String targetReliability;

  factory AdaptiveCheckpointBlueprint.fromJson(Map<String, dynamic> map) {
    final itemsRaw = map['items'];
    final items = itemsRaw is List
        ? itemsRaw
            .whereType<Map>()
            .map((raw) => AdaptiveBlueprintItem.fromJson(
                  Map<String, dynamic>.from(raw),
                ))
            .toList(growable: false)
        : const <AdaptiveBlueprintItem>[];
    return AdaptiveCheckpointBlueprint(
      items: items,
      targetReliability: map['targetReliability']?.toString() ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'targetReliability': targetReliability,
    };
  }
}

class AdaptiveModuleOut {
  const AdaptiveModuleOut({
    required this.moduleNumber,
    required this.title,
    required this.durationMinutes,
    required this.skillsTargeted,
    required this.lessons,
    required this.challenge,
    required this.blueprint,
  });

  final int moduleNumber;
  final String title;
  final int durationMinutes;
  final List<String> skillsTargeted;
  final List<AdaptiveLesson> lessons;
  final AdaptiveChallenge challenge;
  final AdaptiveCheckpointBlueprint blueprint;

  factory AdaptiveModuleOut.fromJson(Map<String, dynamic> map) {
    final skillsRaw = map['skillsTargeted'];
    final skills = skillsRaw is List
        ? skillsRaw.map((value) => value.toString()).toList(growable: false)
        : const <String>[];

    final lessonsRaw = map['lessons'];
    final lessons = lessonsRaw is List
        ? lessonsRaw
            .whereType<Map>()
            .map((raw) =>
                AdaptiveLesson.fromJson(Map<String, dynamic>.from(raw)))
            .toList(growable: false)
        : const <AdaptiveLesson>[];

    return AdaptiveModuleOut(
      moduleNumber:
          map['moduleNumber'] is num ? (map['moduleNumber'] as num).toInt() : 1,
      title: map['title']?.toString() ?? '',
      durationMinutes: map['durationMinutes'] is num
          ? (map['durationMinutes'] as num).toInt()
          : 30,
      skillsTargeted: skills,
      lessons: lessons,
      challenge: AdaptiveChallenge.fromJson(
        Map<String, dynamic>.from(map['challenge'] as Map? ?? const {}),
      ),
      blueprint: AdaptiveCheckpointBlueprint.fromJson(
        Map<String, dynamic>.from(
            map['checkpointBlueprint'] as Map? ?? const {}),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleNumber': moduleNumber,
      'title': title,
      'durationMinutes': durationMinutes,
      'skillsTargeted': skillsTargeted,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      'challenge': challenge.toJson(),
      'checkpointBlueprint': blueprint.toJson(),
    };
  }
}

class AdaptiveModuleResponse {
  const AdaptiveModuleResponse({
    required this.module,
    required this.learnerState,
    required this.focusSkills,
  });

  final AdaptiveModuleOut module;
  final AdaptiveLearnerState learnerState;
  final List<String> focusSkills;

  factory AdaptiveModuleResponse.fromJson(Map<String, dynamic> map) {
    final focusRaw = map['focusSkills'];
    final focus = focusRaw is List
        ? focusRaw.map((value) => value.toString()).toList(growable: false)
        : const <String>[];
    return AdaptiveModuleResponse(
      module: AdaptiveModuleOut.fromJson(
        Map<String, dynamic>.from(map['module'] as Map? ?? const {}),
      ),
      learnerState: AdaptiveLearnerState.fromJson(
        Map<String, dynamic>.from(map['learnerState'] as Map? ?? const {}),
      ),
      focusSkills: focus,
    );
  }
}

class AdaptiveCheckpointQuestion extends AdaptiveMcq {
  const AdaptiveCheckpointQuestion({
    required super.id,
    required super.stem,
    required super.options,
    required super.correct,
    required super.skillTag,
    required super.rationale,
    required this.difficulty,
  }) : super();

  final String difficulty;

  factory AdaptiveCheckpointQuestion.fromJson(Map<String, dynamic> map) {
    final base = AdaptiveMcq.fromJson(map);
    return AdaptiveCheckpointQuestion(
      id: base.id,
      stem: base.stem,
      options: base.options,
      correct: base.correct,
      skillTag: base.skillTag,
      rationale: base.rationale,
      difficulty: map['difficulty']?.toString() ?? 'medium',
    );
  }
}

class AdaptiveCheckpointQuiz {
  const AdaptiveCheckpointQuiz({
    required this.moduleNumber,
    required this.items,
  });

  final int moduleNumber;
  final List<AdaptiveCheckpointQuestion> items;

  factory AdaptiveCheckpointQuiz.fromJson(Map<String, dynamic> map) {
    final itemsRaw = map['items'];
    final items = itemsRaw is List
        ? itemsRaw
            .whereType<Map>()
            .map((raw) => AdaptiveCheckpointQuestion.fromJson(
                  Map<String, dynamic>.from(raw),
                ))
            .toList(growable: false)
        : const <AdaptiveCheckpointQuestion>[];
    return AdaptiveCheckpointQuiz(
      moduleNumber: map['module'] is num ? (map['module'] as num).toInt() : 1,
      items: items,
    );
  }
}

class AdaptiveCheckpointResponse {
  const AdaptiveCheckpointResponse({
    required this.quiz,
    required this.learnerState,
  });

  final AdaptiveCheckpointQuiz quiz;
  final AdaptiveLearnerState learnerState;

  factory AdaptiveCheckpointResponse.fromJson(Map<String, dynamic> map) {
    return AdaptiveCheckpointResponse(
      quiz: AdaptiveCheckpointQuiz.fromJson(
        Map<String, dynamic>.from(map['quiz'] as Map? ?? const {}),
      ),
      learnerState: AdaptiveLearnerState.fromJson(
        Map<String, dynamic>.from(map['learnerState'] as Map? ?? const {}),
      ),
    );
  }
}

class AdaptiveEvaluationResult {
  const AdaptiveEvaluationResult({
    required this.score,
    required this.masteryDelta,
    required this.updatedMastery,
    required this.weakSkills,
    required this.recommendation,
  });

  final int score;
  final Map<String, double> masteryDelta;
  final Map<String, double> updatedMastery;
  final List<String> weakSkills;
  final String recommendation;

  factory AdaptiveEvaluationResult.fromJson(Map<String, dynamic> map) {
    Map<String, double> parseMap(dynamic raw) {
      if (raw is Map) {
        final result = <String, double>{};
        raw.forEach((key, value) {
          if (value is num) {
            result[key.toString()] = value.toDouble();
          }
        });
        return result;
      }
      return const <String, double>{};
    }

    final weakRaw = map['weakSkills'];
    final weakSkills = weakRaw is List
        ? weakRaw.map((value) => value.toString()).toList(growable: false)
        : const <String>[];

    return AdaptiveEvaluationResult(
      score: map['score'] is num ? (map['score'] as num).round() : 0,
      masteryDelta: parseMap(map['masteryDelta']),
      updatedMastery: parseMap(map['updatedMastery']),
      weakSkills: weakSkills,
      recommendation: map['recommendation']?.toString() ?? 'advance',
    );
  }
}

class AdaptiveEvaluationResponse {
  const AdaptiveEvaluationResponse({
    required this.result,
    required this.learnerState,
    required this.action,
  });

  final AdaptiveEvaluationResult result;
  final AdaptiveLearnerState learnerState;
  final String action;

  factory AdaptiveEvaluationResponse.fromJson(Map<String, dynamic> map) {
    return AdaptiveEvaluationResponse(
      result: AdaptiveEvaluationResult.fromJson(
        Map<String, dynamic>.from(map['result'] as Map? ?? const {}),
      ),
      learnerState: AdaptiveLearnerState.fromJson(
        Map<String, dynamic>.from(map['learnerState'] as Map? ?? const {}),
      ),
      action: map['action']?.toString() ?? 'advance',
    );
  }
}

class AdaptiveBooster {
  const AdaptiveBooster({
    required this.boosterFor,
    required this.lessons,
    required this.microQuiz,
  });

  final List<String> boosterFor;
  final List<AdaptiveLesson> lessons;
  final List<AdaptiveMcq> microQuiz;

  factory AdaptiveBooster.fromJson(Map<String, dynamic> map) {
    final skillsRaw = map['boosterFor'];
    final boosterFor = skillsRaw is List
        ? skillsRaw.map((value) => value.toString()).toList(growable: false)
        : const <String>[];
    final lessonsRaw = map['lessons'];
    final lessons = lessonsRaw is List
        ? lessonsRaw
            .whereType<Map>()
            .map((raw) =>
                AdaptiveLesson.fromJson(Map<String, dynamic>.from(raw)))
            .toList(growable: false)
        : const <AdaptiveLesson>[];
    final quizRaw = map['microQuiz'];
    final microQuiz = quizRaw is List
        ? quizRaw
            .whereType<Map>()
            .map((raw) => AdaptiveMcq.fromJson(Map<String, dynamic>.from(raw)))
            .toList(growable: false)
        : const <AdaptiveMcq>[];
    return AdaptiveBooster(
      boosterFor: boosterFor,
      lessons: lessons,
      microQuiz: microQuiz,
    );
  }
}

class AdaptiveBoosterResponse {
  const AdaptiveBoosterResponse({
    required this.booster,
    required this.learnerState,
  });

  final AdaptiveBooster booster;
  final AdaptiveLearnerState learnerState;

  factory AdaptiveBoosterResponse.fromJson(Map<String, dynamic> map) {
    return AdaptiveBoosterResponse(
      booster: AdaptiveBooster.fromJson(
        Map<String, dynamic>.from(map['booster'] as Map? ?? const {}),
      ),
      learnerState: AdaptiveLearnerState.fromJson(
        Map<String, dynamic>.from(map['learnerState'] as Map? ?? const {}),
      ),
    );
  }
}
