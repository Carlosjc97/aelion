import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:provider/provider.dart';
import 'package:learning_ia/models/module.dart';

void main() {
  testWidgets('HomeView smoke test', (WidgetTester tester) async {
    // 1. Mockea los datos que HomeView necesita.
    // Esto simula que los datos vienen de una fuente externa.
    final mockModules = [
      Module(
        id: 1,
        name: 'Introducción a la IA',
        description: 'Una descripción de prueba',
        topics: [],
        videoUrl: 'https://ejemplo.com/video1.mp4',
      ),
      Module(
        id: 2,
        name: 'Aprende un idioma',
        description: 'Descripción de prueba',
        topics: [],
        videoUrl: 'https://ejemplo.com/video2.mp4',
      ),
    ];

    // 2. Envuelve HomeView con MultiProvider para simular
    // el estado de la aplicación.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // Proporciona los módulos que HomeView espera.
          Provider<List<Module>>.value(value: mockModules),
          // Si HomeView depende de otros Providers, añádelos aquí.
        ],
        child: const MaterialApp(home: HomeView()),
      ),
    );

    // 3. Ahora las verificaciones deberían pasar.
    // Confirma que las cartas están presentes.
    expect(find.byType(CourseCard), findsNWidgets(2));
    
    // Y los textos también.
    expect(find.text('Cursos populares'), findsOneWidget);
    expect(find.text('Introducción a la IA'), findsOneWidget);
    expect(find.text('Aprende un idioma'), findsOneWidget);

    // Las verificaciones de accesibilidad también deberían funcionar.
    expect(find.bySemanticsLabel("Open 'Toma un curso'"), findsOneWidget);
    expect(find.bySemanticsLabel("Open 'Aprende un idioma'"), findsOneWidget);
  });
}
