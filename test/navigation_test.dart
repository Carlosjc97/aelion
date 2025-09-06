import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/features/topics/topic_search_view.dart';
import 'package:learning_ia/widgets/course_card.dart';

void main() {
  testWidgets('Home -> ModuleOutlineView navega con argumento',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: HomeView.routeName,
    ));

    final tomaUnCurso = find.widgetWithText(CourseCard, 'Toma un curso');
    expect(tomaUnCurso, findsOneWidget);

    await tester.tap(tomaUnCurso);
    await tester.pumpAndSettle();

    expect(find.byType(ModuleOutlineView), findsOneWidget);
    expect(find.textContaining('Introducción a la IA'), findsWidgets);
  });

  testWidgets('Home -> TopicSearchView navega correctamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: HomeView.routeName,
    ));

    final aprendeIdioma = find.widgetWithText(CourseCard, 'Aprende un idioma');
    expect(aprendeIdioma, findsOneWidget);

    await tester.tap(aprendeIdioma);
    await tester.pumpAndSettle();

    expect(find.byType(TopicSearchView), findsOneWidget);
    expect(find.textContaining('5 minutos al día'), findsOneWidget);
  });

  testWidgets('Ruta inexistente muestra 404 (o mensaje equivalente)',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/ruta-que-no-existe',
    ));

    final ok = find.byWidgetPredicate((w) {
      if (w is Text) {
        final t = w.data ?? '';
        return t.contains('404') || t.contains('No existe la ruta');
      }
      return false;
    });

    expect(ok, findsOneWidget);
  });
}