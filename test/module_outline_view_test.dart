// test/features/modules/module_outline_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/core/router.dart';

void main() {
  testWidgets('ModuleOutlineView muestra el topic en el AppBar', (
    tester,
  ) async {
    final app = MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      // Empujamos directamente la ruta del módulo con argumentos
      initialRoute: ModuleOutlineView.routeName,
      routes: {
        // Para initialRoute con onGenerateRoute, algunos entornos requieren que exista
        // la ruta; alternativamente podemos usar onGenerateRoute solamente y usar
        // Navigator.pushNamed en un home. Aquí simplificamos declarando una route inline.
      },
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
    await tester.pumpAndSettle();

    // Está en ModuleOutlineView
    expect(find.byType(ModuleOutlineView), findsOneWidget);

    // El título debe contener el topic
    expect(find.textContaining('Curso de Prueba'), findsWidgets);
  });
}
