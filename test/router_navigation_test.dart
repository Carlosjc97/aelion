// test/router_navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

Widget _app() => MaterialApp(
  onGenerateRoute: AppRouter.onGenerateRoute,
  initialRoute: HomeView.routeName,
);

void main() {
  testWidgets('Home -> Module navega con topic String', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byType(HomeView), findsOneWidget);

    Navigator.of(tester.element(find.byType(HomeView))).pushNamed(
      ModuleOutlineView.routeName,
      arguments: 'Introducción a Flutter',
    );
    await tester.pumpAndSettle();

    expect(find.byType(ModuleOutlineView), findsOneWidget);
  });

  testWidgets('Ruta inexistente muestra 404', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byType(HomeView), findsOneWidget);

    // Empujar una ruta que no existe
    Navigator.of(tester.element(find.byType(HomeView)))
        .pushNamed('/__ruta_que_no_existe__');
    await tester.pumpAndSettle();

    // Tu router pinta exactamente este texto:
    expect(find.text('404 - No existe la ruta'), findsOneWidget);
  });
}