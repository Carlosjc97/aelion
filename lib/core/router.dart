import 'package:flutter/material.dart';
import 'package:learning_ia/features/auth/auth.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/widgets/not_found_view.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const AuthGate(child: HomeView()),
          settings: const RouteSettings(name: '/'),
        );
      case SignInScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const SignInScreen(),
          settings: const RouteSettings(name: SignInScreen.routeName),
        );
      case HomeView.routeName:
        return MaterialPageRoute(
          builder: (_) => const AuthGate(child: HomeView()),
          settings: const RouteSettings(name: HomeView.routeName),
        );
      case ModuleOutlineView.routeName:
        final arg = settings.arguments;
        final topic = (arg is String) ? arg : null;
        return MaterialPageRoute(
          builder: (_) => AuthGate(child: ModuleOutlineView(topic: topic)),
          settings: settings,
        );
      default:
        return onUnknownRoute(settings);
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const SignInScreen(),
      settings: const RouteSettings(name: SignInScreen.routeName),
    );
  }
}
