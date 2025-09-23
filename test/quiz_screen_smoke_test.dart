import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/quiz/quiz_screen.dart';

void main() {
  testWidgets('QuizScreen smoke: recorre preguntas y muestra resultados', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: const QuizScreen(topic: 'Algoritmos')),
    );

    // Debe existir el AppBar con el título del tópico
    expect(find.textContaining('Algoritmos'), findsWidgets);

    // Hay 10 preguntas. Para cada una: seleccionar opción 0 y avanzar.
    for (var i = 0; i < 10; i++) {
      // Busca el primer Radio de la pantalla actual y lo selecciona.
      final radios = find.byType(Radio<int>);
      expect(radios, findsWidgets);

      await tester.tap(radios.first);
      await tester.pump();

      // El botón debe estar habilitado
      final isLast = i == 9;
      final nextLabel = isLast ? 'Terminar' : 'Siguiente';
      final nextButton = find.widgetWithText(FilledButton, nextLabel);
      expect(nextButton, findsOneWidget);

      await tester.tap(nextButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
    }

    // Al final debe salir el diálogo de resultados
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Aciertos:'), findsOneWidget);
    expect(find.textContaining('Nivel asignado:'), findsOneWidget);

    // Cierra el diálogo
    final continuarBtn = find.widgetWithText(TextButton, 'Continuar');
    expect(continuarBtn, findsOneWidget);
    await tester.tap(continuarBtn);
    await tester.pumpAndSettle();

    // La pantalla no debe crashear (seguimos en el QuizScreen o ya hace pop en integración real)
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
