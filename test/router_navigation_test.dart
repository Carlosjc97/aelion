// test/router_navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/l10n/app_localizations.dart';

Widget _app() => MaterialApp(
      home: const HomeView(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      supportedLocales: const [Locale('en'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );

void main() {
  testWidgets('Home -> Module navega con topic String y muestra título', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    expect(find.byType(HomeView), findsOneWidget);

    Navigator.of(tester.element(find.byType(HomeView))).pushNamed(
      ModuleOutlineView.routeName,
      arguments: 'Introducción a Flutter',
    );
    await tester.pumpAndSettle();

    expect(find.byType(ModuleOutlineView), findsOneWidget);
    expect(find.textContaining('Introducción a Flutter'), findsWidgets);
  });

  testWidgets('Ruta inexistente muestra el placeholder del router', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    expect(find.byType(HomeView), findsOneWidget);

    Navigator.of(
      tester.element(find.byType(HomeView)),
    ).pushNamed('/__ruta_que_no_existe__');
    await tester.pumpAndSettle();

    final notFoundEn = find.text('Route not found');
    final notFoundEs = find.text('Ruta no encontrada');
    expect(
      notFoundEn.evaluate().isNotEmpty || notFoundEs.evaluate().isNotEmpty,
      isTrue,
      reason: 'Should show not-found placeholder in any supported locale',
    );
  });
}
