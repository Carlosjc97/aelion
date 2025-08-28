import 'package:flutter/material.dart';

import '../features/home/home_view.dart';
import '../features/modules/module_outline_view.dart';
import '../features/topics/topic_search_view.dart';
import '../features/lesson/lesson_view.dart';
import '../features/quiz/quiz_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Home
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeView());

      // Módulo (recibe String? topic en settings.arguments)
      case ModuleOutlineView.routeName:
        final String? topic = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ModuleOutlineView(topic: topic),
        );

      // Búsqueda de temas
      case TopicSearchView.routeName:
        return MaterialPageRoute(builder: (_) => const TopicSearchView());

      // Lección
      case LessonView.routeName:
        final args = (settings.arguments as Map<String, dynamic>?) ?? const {};
        return MaterialPageRoute(
          builder: (_) => LessonView(
            lessonId: args['lessonId'] as String?,
            title: (args['title'] as String?) ?? 'Lección',
            content: (args['content'] as String?) ?? 'Contenido…',
            // 🔽 soporta flags y lenguaje si vienen en arguments
            isPremiumEnabled: (args['isPremiumEnabled'] as bool?) ?? false,
            isPremiumLesson: (args['isPremiumLesson'] as bool?) ?? false,
            initialLang: (args['initialLang'] as String?) ?? 'es',
          ),
        );

      // Quiz (recibe String topic en settings.arguments; usa 'Curso' por defecto)
      case QuizScreen.routeName:
        final String topic = (settings.arguments as String?) ?? 'Curso';
        return MaterialPageRoute(
          builder: (_) => QuizScreen(topic: topic),
        );

      // 404 amigable
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Ruta no encontrada')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No existe la ruta: ${settings.name}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
    }
  }
}
