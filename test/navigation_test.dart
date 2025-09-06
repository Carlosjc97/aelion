import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

void main() {
  Widget app({String? initialRoute}) => MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: initialRoute ?? HomeView.routeName,
      );

  testWidgets('Home -> Module navega con topic String', (tester) async {
    await tester.pumpWidget(app());
    expect(find.byType(HomeView), findsOneWidget);

    await tester.tap(find.text('Toma un curso'));
    await tester.pumpAndSettle();

    expect(find.byType(ModuleOutlineView), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Introducción a la IA'), findsOneWidget);
  });

  testWidgets('Ruta inexistente muestra 404', (tester) async {
    await tester.pumpWidget(app(initialRoute: '/no-existe'));
    await tester.pumpAndSettle();

    // Coincide con el texto del default del router
    expect(find.textContaining('No existe la ruta'), findsOneWidget);
  });
}