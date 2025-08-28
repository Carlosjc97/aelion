import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aelion/core/router.dart';
import 'package:aelion/features/home/home_view.dart';
import 'package:aelion/features/modules/module_outline_view.dart';

Widget _app() => MaterialApp(
  onGenerateRoute: AppRouter.onGenerateRoute,
  initialRoute: HomeView.routeName,
);

void main() {
  testWidgets('Home -> Module navega con topic String', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byType(HomeView), findsOneWidget);

    // Navega a /module con un topic en arguments (String)
    Navigator.of(tester.element(find.byType(HomeView))).pushNamed(
      ModuleOutlineView.routeName,
      arguments: 'Introducción a Flutter',
    );
    await tester.pumpAndSettle();
    expect(find.byType(ModuleOutlineView), findsOneWidget);
  });

  testWidgets('Ruta inexistente muestra 404', (tester) async {
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/no-existe',
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('No existe la ruta'), findsOneWidget);
  });
}
