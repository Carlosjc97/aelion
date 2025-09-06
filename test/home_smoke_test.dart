import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/home/home_view.dart';

void main() {
  testWidgets('HomeView smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    // Verify that the main featured cards are present.
    // We expect 2 cards since "Resuelve un problema" is hidden.
    expect(find.byType(CourseCard), findsNWidgets(2));

    // Verify the Semantics labels for accessibility.
    expect(find.bySemanticsLabel("Open 'Toma un curso'"), findsOneWidget);
    expect(find.bySemanticsLabel("Open 'Aprende un idioma'"), findsOneWidget);

    // Verify the trending courses section is present
    expect(find.text('Cursos populares'), findsOneWidget);
    expect(find.text('Introducción a la IA'), findsOneWidget);

    // Verify the 'Aprende un idioma' card is present
    expect(find.text('Aprende un idioma'), findsOneWidget);
  });
}
