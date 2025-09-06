import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/features/topics/topic_search_view.dart';
import 'package:learning_ia/widgets/course_card.dart';
import 'package:learning_ia/core/router.dart';

void main() {
  testWidgets('Home -> ModuleOutlineView navega con argumento',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: HomeView.routeName,
    ));

    // Estamos en Home
    expect(find.byType(HomeView), findsOneWidget);

    // Tap en "Toma un curso"
    final courseCardFinder = find.widgetWithText(CourseCard, 'Toma un curso');
    expect(courseCardFinder, findsOneWidget);

    await tester.tap(courseCardFinder);
    await tester.pumpAndSettle();

    // Debemos estar en ModuleOutlineView
    expect(find.byType(ModuleOutlineView), findsOneWidget);
  });

  testWidgets('Ruta inexistente muestra 404', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/ruta-inexistente',
    ));

    expect(find.text('404'), findsOneWidget);
  });

  testWidgets('Home -> TopicSearchView navega correctamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: HomeView.routeName,
    ));

    // Tap en "Aprende un idioma"
    final courseCardFinder = find.widgetWithText(CourseCard, 'Aprende un idioma');
    expect(courseCardFinder, findsOneWidget);

    await tester.tap(courseCardFinder);
    await tester.pumpAndSettle();

    // Debemos estar en TopicSearchView
    expect(find.byType(TopicSearchView), findsOneWidget);
  });
}