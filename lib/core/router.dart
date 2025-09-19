// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Home
      case HomeView.routeName:
        return MaterialPageRoute(
          builder: (_) => const HomeView(),
          settings: const RouteSettings(name: HomeView.routeName),
        );

      // Module outline
      case ModuleOutlineView.routeName:
        final arg = settings.arguments;
        final topic = (arg is String) ? arg : null;
        return MaterialPageRoute(
          builder: (_) => ModuleOutlineView(topic: topic),
          settings: settings,
        );

      // 404
      default:
        return MaterialPageRoute(
          builder: (_) => const _NotFoundPage(),
          settings: settings,
        );
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const _NotFoundPage(),
      settings: const RouteSettings(name: '/404'),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Ruta no encontrada')),
    );
  }
}
