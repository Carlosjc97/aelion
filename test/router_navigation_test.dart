import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aelion/core/router.dart';
import 'package:aelion/features/auth/auth_gate.dart';
import 'package:aelion/features/modules/module_outline_view.dart';
import 'package:aelion/l10n/app_localizations.dart';

Widget _app({Locale locale = const Locale('es')}) => MaterialApp(
      locale: locale,
      home: const SizedBox.shrink(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );

void main() {
  testWidgets('Module route envuelve ModuleOutlineView en AuthGate',
      (tester) async {
    final route = AppRouter.onGenerateRoute(
      const RouteSettings(
        name: ModuleOutlineView.routeName,
        arguments: 'Introduccion a Flutter',
      ),
    );
    expect(route, isA<MaterialPageRoute>());

    Widget? built;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
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

    expect(
      find.text('Ruta no encontrada'),
      findsOneWidget,
      reason: 'El router debe mostrar el placeholder para rutas desconocidas',
    );
  });
}
