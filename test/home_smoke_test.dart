import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/widgets/course_card.dart';

void main() {
  testWidgets('HomeView smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    // Ahora tenemos 2 cards visibles en HomeView
    expect(find.byType(CourseCard), findsNWidgets(2));

    // Verificamos accesibilidad
    expect(find.bySemanticsLabel("Open 'Toma un curso'"), findsOneWidget);
    expect(find.bySemanticsLabel("Open 'Aprende un idioma'"), findsOneWidget);

    // Sección de cursos populares
    expect(find.text('Cursos populares'), findsOneWidget);
    expect(find.text('Introducción a la IA'), findsOneWidget);

    // Verificar que "Aprende un idioma" aparece
    expect(find.text('Aprende un idioma'), findsOneWidget);
  });
}