import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aelion/features/quiz/quiz_screen.dart';

void main() {
  testWidgets('QuizScreen smoke: walks through questions and shows results',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: QuizScreen(topic: 'Algorithms')),
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
