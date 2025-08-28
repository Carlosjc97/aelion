import 'package:flutter/material.dart';

import '../features/home/home_view.dart';
import '../features/modules/module_outline_view.dart';
import '../features/topics/topic_search_view.dart';
import '../features/lesson/lesson_view.dart'; // si aún no la creas, puedes quitar esta línea y el case

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Home
      case HomeView.routeName:
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeView());

      // Módulo (recibe un String? topic en settings.arguments)
      case ModuleOutlineView.routeName:
        final String? topic = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ModuleOutlineView(topic: topic),
        );

      // Búsqueda de temas
      case TopicSearchView.routeName:
        return MaterialPageRoute(builder: (_) => const TopicSearchView());

      // Lección (opcional; si no la usas aún, comenta este bloque y el import)
      case LessonView.routeName:
        final args = (settings.arguments as Map<String, dynamic>?) ?? const {};
        return MaterialPageRoute(
          builder: (_) => LessonView(
            lessonId: args['lessonId'] as String?,
            title: (args['title'] as String?) ?? 'Lección',
            content: (args['content'] as String?) ?? 'Contenido…',
          ),
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
