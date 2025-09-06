import 'package:flutter/material.dart';

import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/features/topics/topic_search_view.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Home
      case HomeView.routeName:
        return MaterialPageRoute(builder: (_) => const HomeView());

      // Módulo / Curso (acepta topic opcional)
      case ModuleOutlineView.routeName:
        final topic = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ModuleOutlineView(topic: topic),
        );

      // Buscar / Aprender un idioma (pantalla de búsqueda existente)
      case TopicSearchView.routeName:
        return MaterialPageRoute(builder: (_) => const TopicSearchView());

      // 404 por defecto
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: SafeArea(
              child: Center(
                child: Text('No existe la ruta'),
              ),
            ),
          ),
        );
    }
  }
}