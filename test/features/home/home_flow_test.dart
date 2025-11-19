import 'dart:convert';

import 'package:edaptia/features/home/home_view.dart';
import 'package:edaptia/features/modules/outline/module_outline_view.dart';
import 'package:edaptia/features/quiz/quiz_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/l10n/app_localizations_en.dart';
import 'package:edaptia/providers/streak_provider.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:edaptia/services/streak_service.dart';
import 'package:edaptia/services/topic_band_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        'band': 'beginner',
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

class _RouteTracker extends NavigatorObserver {
  final List<Route<dynamic>> pushes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes.add(route);
    super.didPush(route, previousRoute);
  }

  bool hasRoute(String name) =>
      pushes.any((route) => route.settings.name == name);

  List<String?> get routeNames =>
      pushes.map((route) => route.settings.name).toList(growable: false);
}

Future<bool> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration step = const Duration(milliseconds: 50),
  Duration timeout = const Duration(seconds: 5),
}) async {
  var elapsed = Duration.zero;
  while (!condition()) {
    if (elapsed >= timeout) {
      return false;
    }
    await tester.pump(step);
    elapsed += step;
  }
  return true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late http.Client originalClient;
  late _RouteTracker routeTracker;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    originalClient = CourseApiService.httpClient;
    CourseApiService.httpClient = _FakeClient();
    routeTracker = _RouteTracker();
  });

  tearDown(() {
    CourseApiService.httpClient = originalClient;
  });

  testWidgets(
      'Home new topic runs placement quiz and opens module outline', (tester) async {
    final en = AppLocalizationsEn();

    ModuleOutlineArgs? capturedModuleArgs;
    QuizScreenArgs? capturedQuizArgs;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          streakProvider.overrideWith((ref) => StreakNotifier(
                _MockStreakService(),
              )),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorObservers: [routeTracker],
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute<void>(
                  builder: (_) => const HomeView(),
                  settings: settings,
                );
              case QuizScreen.routeName:
                capturedQuizArgs = settings.arguments as QuizScreenArgs;
                return MaterialPageRoute<void>(
                  builder: (context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushNamed(
                        ModuleOutlineView.routeName,
                        arguments: ModuleOutlineArgs(
                          topic: capturedQuizArgs!.topic,
                          language: capturedQuizArgs!.language,
                          preferredBand: 'intermediate',
                          recommendRegenerate: true,
                        ),
                      );
                    });
                    return const Scaffold(body: SizedBox.shrink());
                  },
                  settings: settings,
                );
              case ModuleOutlineView.routeName:
                capturedModuleArgs = settings.arguments as ModuleOutlineArgs;
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
      ),
    );

    await tester.pump();
    await pumpUntil(
      tester,
      () => find.byType(TextField).evaluate().isNotEmpty,
    );

    await tester.enterText(find.byType(TextField).first, 'Neural Networks');
    await tester.pump();
    expect(find.text(en.homeGenerate), findsWidgets);

    await tester.tap(find.text(en.homeGenerate), warnIfMissed: false);

    final sawQuiz = await pumpUntil(
      tester,
      () => routeTracker.hasRoute(QuizScreen.routeName),
      timeout: const Duration(seconds: 30),
    );
    expect(
      sawQuiz,
      isTrue,
      reason: 'Navigator pushes: ${routeTracker.routeNames}',
    );
    final sawOutline = await pumpUntil(
      tester,
      () => find.text('Module Outline Stub').evaluate().isNotEmpty,
      timeout: const Duration(seconds: 30),
    );
    expect(sawOutline, isTrue);

    expect(capturedQuizArgs, isNotNull);
    expect(capturedQuizArgs!.topic, 'Neural Networks');
    expect(capturedQuizArgs!.language, 'en');

    expect(capturedModuleArgs, isNotNull);
    expect(capturedModuleArgs!.topic, 'Neural Networks');
    expect(capturedModuleArgs!.preferredBand, 'intermediate');
    expect(capturedModuleArgs!.recommendRegenerate, isTrue);
  });

  testWidgets('Home uses cached band to open outline directly', (tester) async {
    final en = AppLocalizationsEn();

    await TopicBandCache.instance.setBand(
      userId: 'anonymous',
      topic: 'Graph Theory',
      language: 'en',
      band: PlacementBand.beginner,
    );

    ModuleOutlineArgs? capturedModuleArgs;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          streakProvider.overrideWith((ref) => StreakNotifier(
                _MockStreakService(),
              )),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorObservers: [routeTracker],
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute<void>(
                  builder: (_) => const HomeView(),
                  settings: settings,
                );
              case QuizScreen.routeName:
                return MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: SizedBox.shrink()),
                  settings: settings,
                );
              case ModuleOutlineView.routeName:
                capturedModuleArgs = settings.arguments as ModuleOutlineArgs;
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
      ),
    );

    await tester.pump();
    await pumpUntil(
      tester,
      () => find.byType(TextField).evaluate().isNotEmpty,
    );

    await tester.enterText(find.byType(TextField).first, 'Graph Theory');
    await tester.pump();
    await tester.tap(find.text(en.homeGenerate), warnIfMissed: false);

    final sawOutline = await pumpUntil(
      tester,
      () => find.text('Module Outline Stub').evaluate().isNotEmpty,
      timeout: const Duration(seconds: 30),
    );
    expect(sawOutline, isTrue, reason: 'Navigator pushes: ${routeTracker.routeNames}');

    expect(capturedModuleArgs, isNotNull);
    expect(capturedModuleArgs!.preferredBand, 'beginner');
  });
}

class _MockStreakService implements StreakService {
  @override
  Future<StreakSnapshot> fetch(String userId) async {
    return const StreakSnapshot(
      streakDays: 0,
      lastCheckIn: null,
      incremented: false,
    );
  }

  @override
  Future<StreakSnapshot> checkIn(String userId, {int retryCount = 0}) async {
    return StreakSnapshot(
      streakDays: 1,
      lastCheckIn: DateTime.now(),
      incremented: true,
    );
  }
}
