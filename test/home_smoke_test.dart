import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/widgets/course_card.dart';

void main() {
  testWidgets('HomeView smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    // Header
    expect(find.text('Aelion'), findsOneWidget);
    expect(find.text('Aprende en minutos'), findsOneWidget);

    // En lugar de contar tarjetas exactas, validamos las dos importantes:
    expect(find.widgetWithText(CourseCard, 'Toma un curso'), findsOneWidget);
    expect(find.widgetWithText(CourseCard, 'Aprende un idioma'), findsOneWidget);

    // Semantics (accesibilidad)
    expect(find.bySemanticsLabel("Open 'Toma un curso'"), findsOneWidget);
    expect(find.bySemanticsLabel("Open 'Aprende un idioma'"), findsOneWidget);

    // Trending
    expect(find.text('Cursos populares'), findsOneWidget);
    expect(find.text('Introducción a la IA'), findsOneWidget);
  });
}