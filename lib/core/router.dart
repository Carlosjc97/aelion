// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:learning_ia/features/auth/auth_gate.dart';
import 'package:learning_ia/features/auth/login_screen.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const AuthGate(),
          settings: const RouteSettings(name: '/'),
        );
      case LoginScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: const RouteSettings(name: LoginScreen.routeName),
        );
      case HomeView.routeName:
        return MaterialPageRoute(
          builder: (_) => const HomeView(),
          settings: const RouteSettings(name: HomeView.routeName),
        );
      case ModuleOutlineView.routeName:
        final arg = settings.arguments;
        final topic = (arg is String) ? arg : null;
        return MaterialPageRoute(
          builder: (_) => ModuleOutlineView(topic: topic),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const _NotFoundPage(),
          settings: const RouteSettings(name: '/404'),
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
