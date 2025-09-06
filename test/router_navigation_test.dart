// test/router_navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

Widget _app({String? initialRoute}) => MaterialApp(
  onGenerateRoute: AppRouter.onGenerateRoute,
  // Si pasamos una ruta inicial, úsala; si no, vete al Home.
  initialRoute: initialRoute ?? HomeView.routeName,
);

void main() {
  testWidgets('Home -> Module navega con topic String', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byType(HomeView), findsOneWidget);

    // Empuja ModuleOutlineView con un topic.
    Navigator.of(tester.element(find.byType(HomeView))).pushNamed(
      ModuleOutlineView.routeName,
      arguments: 'Introducción a Flutter',
    );
    await tester.pumpAndSettle();

    expect(find.byType(ModuleOutlineView), findsOneWidget);
  });

  testWidgets('Ruta inexistente muestra 404', (tester) async {
    // Inicia directamente con una ruta que NO existe para forzar el fallback.
    await tester.pumpWidget(_app(initialRoute: '/__ruta_que_no_existe__'));
    await tester.pumpAndSettle();

    // Busca el texto que renderiza el fallback del router.
    expect(find.textContaining('404'), findsOneWidget);
    expect(find.textContaining('No existe la ruta'), findsOneWidget);
  });
}