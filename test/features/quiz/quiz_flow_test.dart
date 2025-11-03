import 'package:edaptia/features/courses/course_entry_view.dart';
import 'package:edaptia/features/modules/outline/module_outline_view.dart';
import 'package:edaptia/features/quiz/quiz_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/l10n/app_localizations_en.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'quiz flow completes and navigates to module when regeneration is requested',
    (tester) async {
      final l10n = AppLocalizationsEn();
      var startCalled = 0;
      var gradeCalled = 0;
      ModuleOutlineArgs? capturedArgs;

      final questions = List.generate(
        10,
        (index) => PlacementQuizQuestion(
          id: 'q$index',
          text: 'Question $index',
          choices: const ['Option A', 'Option B', 'Option C', 'Option D'],
        ),
      );

      final startResponse = PlacementQuizStartResponse(
        quizId: 'quiz-42',
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        maxMinutes: 15,
        numQuestions: questions.length,
        questions: questions,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CourseEntryView(),
          onGenerateRoute: (settings) {
            if (settings.name == QuizScreen.routeName) {
              final args = settings.arguments as QuizScreenArgs;
              return MaterialPageRoute<void>(
                builder: (_) => QuizScreen(
                  topic: args.topic,
                  language: args.language,
                  startLoader: ({required topic, required language}) async {
                    startCalled++;
                    expect(topic, 'Algorithms');
                    expect(language, args.language);
                    return startResponse;
                  },
                  grader: ({required quizId, required answers}) async {
                    gradeCalled++;
                    expect(quizId, startResponse.quizId);
                    expect(answers, hasLength(10));
                    return const PlacementQuizGradeResponse(
                      band: PlacementBand.intermediate,
                      scorePct: 76,
                      recommendRegenerate: true,
                      suggestedDepth: 'medium',
                    );
                  },
                  outlineGenerator: ({
                    required topic,
                    String? goal,
                    String? level,
                    required String language,
                    required String depth,
                    PlacementBand? band,
                  }) async {
                    return {
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
                    };
                  },
                ),
                settings: settings,
              );
            }

            if (settings.name == ModuleOutlineView.routeName) {
              capturedArgs = settings.arguments as ModuleOutlineArgs;
              return MaterialPageRoute<void>(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Module Outline Stub')),
                ),
                settings: settings,
              );
            }

            return null;
          },
        ),
      );

      final topicField = find.byType(TextField).first;
      await tester.enterText(topicField, 'Algorithms');
      await tester.pump();

      await tester.tap(find.text(l10n.courseEntryStart));
      await tester.pumpAndSettle();

      expect(find.text(l10n.quizTitle), findsOneWidget);
      expect(find.byKey(const Key('quiz-start')), findsOneWidget);

      await tester.tap(find.byKey(const Key('quiz-start')));
      await tester.pumpAndSettle();

      for (var i = 0; i < questions.length; i++) {
        await tester.tap(find.byType(RadioListTile<int>).first);
        await tester.pump();

        final actionKey =
            ValueKey<String>(i == questions.length - 1 ? 'quiz-submit' : 'quiz-next');
        await tester.tap(find.byKey(actionKey));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
      }

      await tester.pumpAndSettle();

      expect(find.text(l10n.quizResultTitle(l10n.quizBandIntermediate)), findsOneWidget);
      expect(find.byKey(const Key('quiz-open-plan')), findsOneWidget);

      await tester.tap(find.byKey(const Key('quiz-open-plan')));
      await tester.pumpAndSettle();

      expect(startCalled, 1);
      expect(gradeCalled, 1);
      expect(capturedArgs, isNotNull);
      expect(capturedArgs!.topic, 'Algorithms');
      expect(capturedArgs!.preferredBand, 'intermediate');
      expect(capturedArgs!.recommendRegenerate, isTrue);

      expect(find.text('Module Outline Stub'), findsOneWidget);
    },
    skip: true,
  );
}

