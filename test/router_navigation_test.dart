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
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/no-existe',
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('No existe la ruta'), findsOneWidget);
  });
}
