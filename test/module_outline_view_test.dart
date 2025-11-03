import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edaptia/core/router.dart';
import 'package:edaptia/features/modules/outline/module_outline_view.dart';
import 'package:edaptia/l10n/app_localizations.dart';

void main() {
  testWidgets('ModuleOutlineView muestra el topic en el AppBar', (tester) async {
    final app = MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: ModuleOutlineView.routeName,
      onGenerateInitialRoutes: (initialRoute) => [
        MaterialPageRoute(
          settings: const RouteSettings(
            name: ModuleOutlineView.routeName,
            arguments: 'Curso de Prueba',
          ),
          builder: (_) => const ModuleOutlineView(topic: 'Curso de Prueba'),
        ),
      ],
    );

    await tester.pumpWidget(app);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.byType(ModuleOutlineView), findsOneWidget);
    expect(find.textContaining('Curso de Prueba'), findsWidgets);
  });
}

