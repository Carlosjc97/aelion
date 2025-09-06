import 'package:flutter/material.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/features/topics/topic_search_view.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeView.routeName:
        return MaterialPageRoute(builder: (_) => const HomeView());

      case ModuleOutlineView.routeName:
        final topic = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ModuleOutlineView(topic: topic),
        );

      case TopicSearchView.routeName:
        return MaterialPageRoute(builder: (_) => const TopicSearchView());

      default:
        // 404 limpio, compatible con el test
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                '404',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        );
    }
  }
}