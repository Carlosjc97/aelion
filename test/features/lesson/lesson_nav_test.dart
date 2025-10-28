import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aelion/features/lesson/lesson_detail_page.dart';
import 'package:aelion/features/modules/module_outline_view.dart';
import 'package:aelion/l10n/app_localizations.dart';
import 'package:aelion/services/course_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tap first lesson opens detail', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ModuleOutlineView(
          topic: 'Physics',
          language: 'en',
          initialOutline: const [
            {
              'title': 'Module 1',
              'lessons': [
                {'title': 'Lesson Alpha', 'content': 'Content body'},
                {'title': 'Lesson Beta', 'content': 'Content beta'},
              ],
            },
          ],
          outlineFetcher: ({
            required String topic,
            String? goal,
            String? level,
            required String language,
            required String depth,
            PlacementBand? band,
          }) async =>
              {
                'topic': topic,
                'language': language,
                'depth': depth,
                'band': 'beginner',
                'source': 'test',
                'outline': const [
                  {
                    'title': 'Module 1',
                    'lessons': [
                      {'title': 'Lesson Alpha', 'content': 'Content body'},
                      {'title': 'Lesson Beta', 'content': 'Content beta'},
                    ],
                  },
                ],
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

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    final lessonTile = find.byKey(const Key('lesson-tile-0-0'));
    for (var attempts = 0; attempts < 100; attempts++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (lessonTile.evaluate().isNotEmpty) {
        break;
      }
    }
    expect(lessonTile, findsOneWidget);

    await tester.tap(lessonTile);
    for (var attempts = 0; attempts < 100; attempts++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(LessonDetailPage).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.byType(LessonDetailPage), findsOneWidget);
    expect(find.text('Lesson Alpha'), findsWidgets);
    expect(find.text('Content body'), findsOneWidget);
  });
}
