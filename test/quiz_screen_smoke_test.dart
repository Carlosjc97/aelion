import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aelion/features/quiz/quiz_screen.dart';
import 'package:aelion/services/course_api_service.dart';

Future<List<QuizQuestionDto>> _fakeQuizLoader({
  required String topic,
  required int numQuestions,
  required String language,
}) async {
  return List.generate(
    numQuestions,
    (index) => QuizQuestionDto(
      question: 'Question ${index + 1} about $topic',
      options: const [
        'Option A',
        'Option B',
        'Option C',
        'Option D',
      ],
      answer: 'Option A',
    ),
  );
}

void main() {
  testWidgets('QuizScreen smoke: walks through questions and shows results',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QuizScreen(
          topic: 'Algorithms',
          quizLoader: _fakeQuizLoader,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('Mini quiz'), findsWidgets);

    for (var i = 0; i < 10; i++) {
      final radios = find.byType(Radio<int>);
      expect(radios, findsWidgets);

      await tester.tap(radios.first);
      await tester.pump();

      final isLast = i == 9;
      final nextLabel = isLast ? 'Finish' : 'Next';
      final nextButton = find.widgetWithText(FilledButton, nextLabel);
      expect(nextButton, findsOneWidget);

      await tester.tap(nextButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
    }

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Correct answers'), findsOneWidget);
    expect(find.textContaining('Suggested level'), findsOneWidget);

    final continueButton = find.widgetWithText(TextButton, 'Continue');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
  });
}
