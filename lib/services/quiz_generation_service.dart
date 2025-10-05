// lib/services/quiz_generation_service.dart
import 'dart:math';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class QuizGenerationService {
  static List<QuizQuestion> generate(String topic, {int count = 10}) {
    final rnd = Random(topic.hashCode);
    return List.generate(count, (i) {
      return QuizQuestion(
        question: 'Pregunta ${i + 1} sobre $topic',
        options: [
          'DefiniciÃ³n bÃ¡sica de $topic',
          'Ejemplo prÃ¡ctico de $topic',
          'Concepto errÃ³neo de $topic',
          'Detalle avanzado de $topic',
        ],
        correctIndex: rnd.nextInt(4),
      );
    });
  }
}
