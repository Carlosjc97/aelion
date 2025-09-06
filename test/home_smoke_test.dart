import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/widgets/course_card.dart';

void main() {
  testWidgets('HomeView smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    // Ahora Home muestra 3 tarjetas (incluida "Resuelve un problema")
    expect(find.byType(CourseCard), findsNWidgets(3));

    // Títulos visibles
    expect(find.text('Toma un curso'), findsOneWidget);
    expect(find.text('Aprende un idioma'), findsOneWidget);

    // Sección de populares
    expect(find.text('Cursos populares'), findsOneWidget);
    expect(find.text('Introducción a la IA'), findsOneWidget);
  });
}