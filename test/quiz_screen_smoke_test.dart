import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aelion/features/quiz/quiz_screen.dart';
import 'package:aelion/l10n/app_localizations.dart';
import 'package:aelion/l10n/app_localizations_en.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aelion/services/course_api_service.dart';

Future<Map<String, dynamic>> _fakeOutline({
  required String topic,
  String? goal,
  String? level,
  required String language,
  required String depth,
  PlacementBand? band,
}) {
  return Future.value({
    'topic': topic,
    'goal': goal ?? '',
    'level': level,
    'language': language,
    'depth': depth,
    'band': band != null
        ? CourseApiService.placementBandToString(band)
        : 'beginner',
    'source': 'test',
    'outline': [
      {
        'title': 'Module 1',
        'lessons': [
          {'title': 'Lesson 1'},
        ],
      },
    ],
  });
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  PlacementQuizStartResponse fakeStartLoader({
    required String topic,
    required String language,
  }) {
    final questions = List.generate(
      3,
      (index) => PlacementQuizQuestion(
        id: 'q',
        text: 'Question  about ',
        choices: const ['Option A', 'Option B', 'Option C', 'Option D'],
      ),
    );

    return PlacementQuizStartResponse(
      quizId: 'quiz-123',
      expiresAt: DateTime.now().add(const Duration(minutes: 60)),
      maxMinutes: 15,
      numQuestions: questions.length,
      questions: questions,
    );
  }

  PlacementQuizGradeResponse fakeGrader({
    required String quizId,
    required List<PlacementQuizAnswer> answers,
  }) {
    return const PlacementQuizGradeResponse(
      band: PlacementBand.intermediate,
      scorePct: 67,
      recommendRegenerate: true,
      suggestedDepth: 'medium',
    );
  }

  testWidgets(
    'quiz flow advances through questions and shows result screen',
    (tester) async {
    final l10n = AppLocalizationsEn();
    final mockAuth = MockFirebaseAuth(mockUser: MockUser(uid: 'tester'));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: QuizScreen(
          topic: 'Algorithms',
          language: 'en',
          startLoader: ({required topic, required language}) async =>
              fakeStartLoader(topic: topic, language: language),
          grader: ({required quizId, required answers}) async =>
              fakeGrader(quizId: quizId, answers: answers),
          outlineGenerator: _fakeOutline,
          firebaseAuth: mockAuth,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text(l10n.quizTitle), findsOneWidget);
    expect(find.text(l10n.startQuiz), findsOneWidget);

    await tester.tap(find.text(l10n.startQuiz));
    await tester.pump();

    Future<void> pumpUntilVisible(Finder finder) async {
      for (var attempts = 0; attempts < 40; attempts++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (finder.evaluate().isNotEmpty) {
          return;
        }
      }
      fail('Timed out waiting for finder: $finder');
    }

    await pumpUntilVisible(find.byKey(const ValueKey('quiz-next')));

    Finder radioFinder() => find.byWidgetPredicate(
          (widget) => widget is RadioListTile<int> || widget is RadioListTile<int?>,
        );

    for (var i = 0; i < 3; i++) {
      final optionFinder = radioFinder();
      await pumpUntilVisible(optionFinder);

      final optionWidget = optionFinder.first;
      await tester.ensureVisible(optionWidget);
      await tester.tap(optionWidget, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));

      final buttonKey =
          ValueKey<String>(i == 2 ? 'quiz-submit' : 'quiz-next');
      final buttonFinder = find.byKey(buttonKey).first;
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
    }

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l10n.quizResultTitle(l10n.quizBandIntermediate)), findsOneWidget);
    expect(find.text(l10n.quizDone), findsOneWidget);
    expect(find.byKey(const ValueKey('quiz-open-plan')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quiz-result-done')));
    await tester.pump(const Duration(milliseconds: 300));
    },
    skip: true,
  );
}

