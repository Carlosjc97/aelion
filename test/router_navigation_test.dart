// test/router_navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

Widget _app() => MaterialApp(
  // Usamos HomeView como pantalla inicial directa
  // y dejamos onGenerateRoute para las rutas pushNamed.
  home: const HomeView(),
  onGenerateRoute: AppRouter.onGenerateRoute,
);

void main() {
  testWidgets('Home -> Module navega con topic String y muestra título', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    expect(find.byType(HomeView), findsOneWidget);

    // Navega programáticamente con argumento topic
    Navigator.of(tester.element(find.byType(HomeView))).pushNamed(
      ModuleOutlineView.routeName,
      arguments: 'Introducción a Flutter',
    );
    await tester.pumpAndSettle();

    // Llega a la vista correcta
    expect(find.byType(ModuleOutlineView), findsOneWidget);

    // Verifica que el título contenga el topic (AppBar/AelionAppBar)
    expect(find.textContaining('Introducción a Flutter'), findsWidgets);
  });

  testWidgets('Ruta inexistente muestra el placeholder del router', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    expect(find.byType(HomeView), findsOneWidget);

    // Empujar una ruta que no existe
    Navigator.of(
      tester.element(find.byType(HomeView)),
    ).pushNamed('/__ruta_que_no_existe__');
    await tester.pumpAndSettle();

    // El router actual muestra “Ruta no encontrada”
    expect(find.text('Ruta no encontrada'), findsOneWidget);
  });
}
