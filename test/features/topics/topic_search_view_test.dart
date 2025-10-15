import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aelion/features/topics/topic_search_view.dart';

void main() {
  testWidgets('TopicSearchView builds without errors', (widgetTester) async {
    await widgetTester.pumpWidget(const MaterialApp(
      home: TopicSearchView(),
    ));

    expect(find.byType(TopicSearchView), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}