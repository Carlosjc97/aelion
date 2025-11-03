import 'package:edaptia/features/lesson/lesson_detail_page.dart';
import 'package:edaptia/features/modules/outline/module_outline_view.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edaptia/services/course_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tapping a lesson opens LessonDetailPage with content', (tester) async {
    final outline = [
      {
        'title': 'Module Alpha',
        'lessons': [
          {
            'title': 'Lesson Zero',
            'content': 'Detailed lesson content',
          },
        ],
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute<void>(
                builder: (_) => ModuleOutlineView(
                  topic: 'Testing Module',
                  initialOutline: outline
                      .map((module) => Map<String, dynamic>.from(module))
                      .toList(),
                  initialSource: 'cache',
                  outlineFetcher: ({
                    required String topic,
                    String? goal,
                    String? level,
                    required String language,
                    required String depth,
                    PlacementBand? band,
                  }) async {
                    return {
                      'outline': outline,
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
              );
            case LessonDetailPage.routeName:
              final args = settings.arguments as LessonDetailArgs;
              return MaterialPageRoute<void>(
                builder: (_) => LessonDetailPage(args: args),
              );
          }
          return null;
        },
      ),
    );

    await tester.pumpAndSettle();

    final lessonTile = find.byKey(const Key('lesson-tile-0-0'));
    expect(lessonTile, findsOneWidget);

    await tester.ensureVisible(lessonTile);
    await tester.pumpAndSettle();
    await tester.tap(lessonTile);
    await tester.pumpAndSettle();

    expect(find.text('Lesson Zero'), findsOneWidget);
    expect(find.text('Detailed lesson content'), findsOneWidget);
  });
}

