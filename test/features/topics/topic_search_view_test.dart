import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edaptia/features/topics/topic_search_view.dart';
import 'package:edaptia/l10n/app_localizations.dart';

void main() {
  testWidgets('TopicSearchView builds without errors', (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TopicSearchView(),
      ),
    );

    expect(find.byType(TopicSearchView), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}

