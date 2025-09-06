import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/widgets/course_card.dart';

void main() {
  testWidgets('HomeView smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    // HomeView ahora muestra 3 CourseCard
    expect(find.byType(CourseCard), findsNWidgets(3));

    // Textos visibles
    expect(find.text('Toma un curso'), findsOneWidget);
    expect(find.text('Aprende un idioma'), findsOneWidget);
    expect(find.text('Resuelve un problema'), findsOneWidget);

    // Sección de cursos populares
    expect(find.text('Cursos populares'), findsOneWidget);
    expect(find.text('Introducción a la IA'), findsOneWidget);
  });
}