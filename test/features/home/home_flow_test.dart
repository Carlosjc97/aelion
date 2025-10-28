import 'dart:convert';

import 'package:aelion/features/home/home_view.dart';
import 'package:aelion/features/modules/module_outline_view.dart';
import 'package:aelion/features/quiz/quiz_screen.dart';
import 'package:aelion/l10n/app_localizations.dart';
import 'package:aelion/l10n/app_localizations_en.dart';
import 'package:aelion/services/course_api_service.dart';
import 'package:aelion/services/topic_band_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class _FakeClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url;
    final body = <String, dynamic>{};
    var status = 200;

    if (request.method == 'GET' && uri.path.endsWith('/trending')) {
      body.addAll({
        'lang': uri.queryParameters['lang'] ?? 'en',
        'topics': <Map<String, dynamic>>[
          {
            'topicKey': 'flutter',
            'topic': 'Flutter',
            'count': 3,
          },
        ],
        'windowHours': 24,
      });
    } else if (request.method == 'POST' && uri.path.endsWith('/trackSearch')) {
      status = 202;
      body.addAll({'recorded': true});
    } else if (request.method == 'POST' && uri.path.endsWith('/outline')) {
      body.addAll({
        'outline': [
          {
            'title': 'Module 1',
            'lessons': [
              {'title': 'Lesson 1'},
            ],
          },
        ],
        'source': 'fresh',
        'band': 'intermediate',
        'depth': 'medium',
        'language': 'en',
      });
    }

    final encoded = utf8.encode(jsonEncode(body));
    return http.StreamedResponse(
      Stream<List<int>>.value(encoded),
      status,
      headers: {'content-type': 'application/json'},
    );
  }
}

PlacementQuizStartResponse _fakeStartResponse(int numQuestions) {
  final questions = List.generate(
    numQuestions,
    (index) => PlacementQuizQuestion(
      id: 'q$index',
      text: 'Question $index',
      choices: const [
        'Option A',
        'Option B',
        'Option C',
        'Option D',
      ],
    ),
  );
  return PlacementQuizStartResponse(
    quizId: 'quiz-$numQuestions',
    expiresAt: DateTime.now().add(const Duration(minutes: 30)),
    maxMinutes: 15,
    numQuestions: numQuestions,
    questions: questions,
  );
}

Future<Map<String, dynamic>> _outlineStub({
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
  TestWidgetsFlutterBinding.ensureInitialized();

  late http.Client originalClient;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    originalClient = CourseApiService.httpClient;
    CourseApiService.httpClient = _FakeClient();
  });

  tearDown(() {
    CourseApiService.httpClient = originalClient;
  });

  testWidgets('Home new topic runs placement quiz and opens module outline', (tester) async {
    final en = AppLocalizationsEn();
    final startResponse = _fakeStartResponse(10);

    ModuleOutlineArgs? capturedArgs;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute<void>(
                builder: (_) => const HomeView(),
                settings: settings,
              );
            case QuizScreen.routeName:
              final args = settings.arguments as QuizScreenArgs;
              return MaterialPageRoute<void>(
                builder: (_) => QuizScreen(
                  topic: args.topic,
                  language: args.language,
                  autoOpenOutline: args.autoOpenOutline,
                  startLoader: ({required topic, required language}) async =>
                      startResponse,
                  grader: ({required quizId, required answers}) async =>
                      const PlacementQuizGradeResponse(
                    band: PlacementBand.intermediate,
                    scorePct: 82,
                    recommendRegenerate: true,
                    suggestedDepth: 'medium',
                  ),
                  outlineGenerator: _outlineStub,
                ),
                settings: settings,
              );
            case ModuleOutlineView.routeName:
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

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Neural Networks');
    await tester.pump();
    await tester.tap(find.text(en.homeGenerate));
    await tester.pumpAndSettle();

    expect(find.text(en.quizTitle), findsOneWidget);
    final startBtn = find.byKey(const Key('quiz-start'));
    await tester.ensureVisible(startBtn);
    await tester.pumpAndSettle();
    await tester.tap(startBtn);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Asegura que las opciones estén presentes antes de iterar
    await tester.pumpAndSettle();
    expect(find.byType(RadioListTile), findsWidgets);

    for (var i = 0; i < startResponse.questions.length; i++) {
      final firstRadio = find.byType(RadioListTile).first;
      await tester.ensureVisible(firstRadio);
      await tester.pump();
      await tester.tap(firstRadio);
      await tester.pump();
      final actionKey = ValueKey<String>(
        i == startResponse.questions.length - 1 ? 'quiz-submit' : 'quiz-next',
      );
      final actionFinder = find.byKey(actionKey);
      await tester.ensureVisible(actionFinder);
      await tester.pumpAndSettle();
      await tester.tap(actionFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }

    await tester.pumpAndSettle();

    // Acepta el stub o el widget real si la navegación monta el componente directamente
    final hasStub = find.text('Module Outline Stub').evaluate().isNotEmpty;
    final hasWidget = find.byType(ModuleOutlineView).evaluate().isNotEmpty;
    expect(hasStub || hasWidget, isTrue);
    expect(capturedArgs, isNotNull);
    expect(capturedArgs!.topic, 'Neural Networks');
    expect(capturedArgs!.preferredBand, 'intermediate');
  });

  testWidgets('Home uses cached band to open outline directly', (tester) async {
    final en = AppLocalizationsEn();

    await TopicBandCache.instance.setBand(
      userId: 'user-1',
      topic: 'Graph Theory',
      language: 'en',
      band: PlacementBand.beginner,
    );

    ModuleOutlineArgs? capturedArgs;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute<void>(
                builder: (_) => const HomeView(),
                settings: settings,
              );
            case QuizScreen.routeName:
              // Ruta stub del quiz para evitar errores si se empuja inadvertidamente
              return MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: SizedBox.shrink()),
                settings: settings,
              );
            case ModuleOutlineView.routeName:
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

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Graph Theory');
    await tester.pump();
    await tester.tap(find.text(en.homeGenerate));
    await tester.pumpAndSettle();

    expect(find.text('Module Outline Stub'), findsOneWidget);
    expect(capturedArgs, isNotNull);
    expect(capturedArgs!.preferredBand, 'beginner');
  });
}
