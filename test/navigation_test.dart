import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/features/topics/topic_search_view.dart';
import 'package:learning_ia/widgets/course_card.dart';

void main() {
  // We define a local onGenerateRoute for this test to handle all necessary
  // routes. This is a workaround because the main AppRouter is missing some
  // routes needed for testing, and the project instructions forbid modifying it.
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeView.routeName:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case ModuleOutlineView.routeName:
        final topic = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => ModuleOutlineView(topic: topic));
      case TopicSearchView.routeName:
        final language = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => const TopicSearchView()); // Simplified for test
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('404')));
    }
  }

  testWidgets('Navigation from HomeView to ModuleOutlineView', (WidgetTester tester) async {
    // Build our app with a route generator and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: onGenerateRoute,
      initialRoute: HomeView.routeName,
    ));

    // Verify we are on the HomeView
    expect(find.byType(HomeView), findsOneWidget);

    // Find the first course card, which is 'Toma un curso'
    final courseCardFinder = find.widgetWithText(CourseCard, 'Toma un curso');
    expect(courseCardFinder, findsOneWidget);

    // Tap the card
    await tester.tap(courseCardFinder);
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Verify that we have navigated to the ModuleOutlineView
    expect(find.byType(ModuleOutlineView), findsOneWidget);
    expect(find.byType(HomeView), findsNothing);

    // Verify the argument was passed correctly by checking the AppBar title
    expect(find.widgetWithText(AppBar, 'Introducción a la IA'), findsOneWidget);
  });
}
