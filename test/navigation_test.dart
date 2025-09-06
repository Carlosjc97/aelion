import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

void main() {
  Widget _app({String? initialRoute}) => MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: initialRoute ?? HomeView.routeName,
      );

  testWidgets('Home -> Module navega con topic String', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byType(HomeView), findsOneWidget);

    // Toca la tarjeta por su texto visible
    await tester.tap(find.text('Toma un curso'));
    await tester.pumpAndSettle();

    expect(find.byType(ModuleOutlineView), findsOneWidget);
    // Verifica el título recibido por argumentos
    expect(find.widgetWithText(AppBar, 'Introducción a la IA'), findsOneWidget);
  });

  testWidgets('Ruta inexistente muestra 404', (tester) async {
    await tester.pumpWidget(_app(initialRoute: '/no-existe'));
    await tester.pumpAndSettle();
    // Texto EXACTO que pinta el router en el default
    expect(find.textContaining('No existe la ruta'), findsOneWidget);
  });
}