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
  });

  final PlacementBand band;
  final int scorePct;
  final bool recommendRegenerate;
  final String suggestedDepth;

  double get scoreFraction => scorePct / 100;

}
