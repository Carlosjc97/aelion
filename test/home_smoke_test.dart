import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/widgets/course_card.dart';

void main() {
  testWidgets('HomeView smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    // Deben renderizarse exactamente 2 CourseCard en el carrusel
    expect(find.byType(CourseCard), findsNWidgets(2));

    // Semantics de accesibilidad
    expect(find.bySemanticsLabel("Open 'Toma un curso'"), findsOneWidget);
    expect(find.bySemanticsLabel("Open 'Aprende un idioma'"), findsOneWidget);

    // Sección de populares
    expect(find.text('Cursos populares'), findsOneWidget);
    expect(find.text('Introducción a la IA'), findsOneWidget);
  });
}