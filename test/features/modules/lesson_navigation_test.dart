import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edaptia/features/lesson/lesson_detail_page.dart';
import 'package:edaptia/features/modules/outline/module_outline_view.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/course_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tapping a lesson opens the lesson detail page',
      (WidgetTester tester) async {
    const topic = 'Analytics';
    const language = 'en';
    final initialOutline = [
      {
        'title': 'Module 1',
        'lessons': [
          {
            'title': 'Lesson A',
            'content': 'Understand key metrics',
            'language': 'en',
          },
        ],
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ModuleOutlineView(
          topic: topic,
          language: language,
          initialOutline: initialOutline,
          outlineFetcher: ({
            required String topic,
            String? goal,
            String? level,
            required String language,
            required String depth,
            PlacementBand? band,
          }) async {
            return {
              'outline': initialOutline,
              'language': language,
              'depth': depth,
              'band': band != null
                  ? CourseApiService.placementBandToString(band)
                  : null,
              'source': 'test',
              'topic': topic,
            };
          },
        ),
        onGenerateRoute: (settings) {
          if (settings.name == LessonDetailPage.routeName) {
            final args = settings.arguments as LessonDetailArgs;
            return MaterialPageRoute<void>(
              builder: (_) => LessonDetailPage(args: args),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );

    await tester.pumpAndSettle();

    final textWidgets = tester
        .widgetList(find.byType(Text))
        .map((widget) => (widget as Text).data)
        .whereType<String>()
        .toList();
    // ignore: avoid_print
    print('Rendered texts: $textWidgets');

    expect(find.text('Module 1'), findsOneWidget);

    // If the module list is already expanded, we can skip tapping the header.

    final lessonTile = find.text('Lesson A');
    expect(lessonTile, findsOneWidget);

    await tester.ensureVisible(lessonTile);
    await tester.pumpAndSettle();
    await tester.tap(lessonTile);
    await tester.pumpAndSettle();

    expect(find.text('Lesson A'), findsWidgets);
    expect(find.text('Understand key metrics'), findsOneWidget);
  });
}

