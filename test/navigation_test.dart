import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/features/topics/topic_search_view.dart';
import 'package:learning_ia/widgets/course_card.dart';

void main() {
  // Generador de rutas local para el test.
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeView.routeName:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case ModuleOutlineView.routeName:
        final topic = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => ModuleOutlineView(topic: topic));
      case TopicSearchView.routeName:
        // No necesitamos el argumento aquí; evitemos variable sin uso.
        return MaterialPageRoute(builder: (_) => const TopicSearchView());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('404'))),
        );
    }
  }

  testWidgets('Navigation from HomeView to ModuleOutlineView',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: onGenerateRoute,
      initialRoute: HomeView.routeName,
    ));

    // Estamos en Home
    expect(find.byType(HomeView), findsOneWidget);

    // Tocar la tarjeta "Toma un curso"
    final courseCardFinder = find.widgetWithText(CourseCard, 'Toma un curso');
    expect(courseCardFinder, findsOneWidget);

    await tester.tap(courseCardFinder);
    await tester.pumpAndSettle();

    // Llegamos a ModuleOutlineView
    expect(find.byType(ModuleOutlineView), findsOneWidget);
    expect(find.byType(HomeView), findsNothing);

    // El título del AppBar refleja el argumento
    expect(find.widgetWithText(AppBar, 'Introducción a la IA'), findsOneWidget);
  });
}