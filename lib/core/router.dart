import 'package:flutter/material.dart';
import '../features/home/home_view.dart';
import '../features/topics/topic_search_view.dart';
import '../features/modules/module_outline_view.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case TopicSearchView.routeName:
        return MaterialPageRoute(builder: (_) => const TopicSearchView());
      case ModuleOutlineView.routeName:
        return MaterialPageRoute(builder: (_) => const ModuleOutlineView());
      case HomeView.routeName:
      default:
        return MaterialPageRoute(builder: (_) => const HomeView());
    }
  }
}
