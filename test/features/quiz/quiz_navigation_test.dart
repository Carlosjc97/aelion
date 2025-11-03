import 'package:edaptia/features/quiz/quiz_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/l10n/app_localizations_en.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'navigates from home stub through quiz start, questions, and result using stage keys',
    (tester) async {
      final l10n = AppLocalizationsEn();
      final mockAuth = MockFirebaseAuth(mockUser: MockUser(uid: 'tester'));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    key: const Key('home-start-quiz'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => QuizScreen(
                            topic: 'History',
                            language: 'en',
                            autoOpenOutline: false,
                            outlineGenerator: ({
                              required String topic,
                              String? goal,
                              String? level,
                              required String language,
                              required String depth,
                              PlacementBand? band,
                            }) async => {
                              'topic': topic,
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
                            },
                            startLoader: ({required topic, required language}) async {
                              return PlacementQuizStartResponse(
                                quizId: 'quiz-001',
                                expiresAt: DateTime.now().add(const Duration(minutes: 15)),
                                maxMinutes: 10,
                                numQuestions: 2,
                                questions: [
                                  PlacementQuizQuestion(
                                    id: 'q1',
                                    text: 'Question 1',
                                    choices: const [
                                      'Option 1',
                                      'Option 2',
                                      'Option 3',
                                      'Option 4',
                                    ],
                                  ),
                                  PlacementQuizQuestion(
                                    id: 'q2',
                                    text: 'Question 2',
                                    choices: const [
                                      'Option 1',
                                      'Option 2',
                                      'Option 3',
                                      'Option 4',
                                    ],
                                  ),
                                ],
                              );
                            },
                            grader: ({required quizId, required answers}) async {
                              return const PlacementQuizGradeResponse(
                                band: PlacementBand.beginner,
                                scorePct: 40,
                                recommendRegenerate: false,
                                suggestedDepth: 'intro',
                              );
                            },
                              firebaseAuth: mockAuth,
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Quiz'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('home-start-quiz')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(l10n.quizTitle), findsOneWidget);
      expect(find.byKey(const Key('quiz-start')), findsOneWidget);

      await tester.tap(find.byKey(const Key('quiz-start')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key('quiz-next')), findsWidgets);

      Future<void> pumpUntilVisible(Finder finder) async {
        for (var attempts = 0; attempts < 40; attempts++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (finder.evaluate().isNotEmpty) {
            return;
          }
        }
        fail('Timed out waiting for $finder');
      }

      Finder radioFinder() => find.byWidgetPredicate(
            (widget) => widget is RadioListTile<int> || widget is RadioListTile<int?>,
          );

      await tester.tap(radioFinder().first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(const Key('quiz-next')).first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(radioFinder().first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('quiz-submit')), findsWidgets);
      await tester.tap(find.byKey(const Key('quiz-submit')).first, warnIfMissed: false);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      final resultDoneFinder = find.byKey(const Key('quiz-result-done'));
      await pumpUntilVisible(resultDoneFinder);
      expect(resultDoneFinder, findsWidgets);
      expect(find.text(l10n.quizResultTitle(l10n.quizBandBeginner)), findsOneWidget);
    },
    skip: true,
  );
}

