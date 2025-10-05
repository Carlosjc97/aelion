// test/router_navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/features/auth/auth_gate.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/l10n/app_localizations.dart';

Widget _app() => MaterialApp(
      home: const SizedBox.shrink(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );

void main() {
  testWidgets('Module route envuelve ModuleOutlineView en AuthGate', (tester) async {
    final route = AppRouter.onGenerateRoute(
      const RouteSettings(
        name: ModuleOutlineView.routeName,
        arguments: 'Introducción a Flutter',
      ),
    );

    expect(route, isA<MaterialPageRoute>());

    Widget? built;
    await tester.pumpWidget(MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) {
          built = (route as MaterialPageRoute).builder(context);
          return const SizedBox.shrink();
        },
      ),
    ));

    expect(built, isA<AuthGate>());
    final gate = built! as AuthGate;
    expect(gate.child, isA<ModuleOutlineView>());
  });

  testWidgets('Ruta inexistente construye pantalla de 404', (tester) async {
    await tester.pumpWidget(_app());

    Navigator.of(tester.element(find.byType(SizedBox)))
        .pushNamed('/__ruta_que_no_existe__');
    await tester.pumpAndSettle();

    final notFoundEn = find.text('Route not found');
    final notFoundEs = find.text('Ruta no encontrada');
    expect(
      notFoundEn.evaluate().isNotEmpty || notFoundEs.evaluate().isNotEmpty,
      isTrue,
      reason: 'Debe mostrar el placeholder de ruta no encontrada en cualquier idioma soportado',
    );
  });
}
