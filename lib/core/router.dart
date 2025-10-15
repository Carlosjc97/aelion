import 'package:flutter/material.dart';

import 'package:aelion/features/auth/auth.dart';
import 'package:aelion/features/courses/course_entry_view.dart';
import 'package:aelion/features/home/home_view.dart';
import 'package:aelion/features/modules/module_outline_view.dart';
import 'package:aelion/features/quiz/quiz_screen.dart';
import 'package:aelion/features/topics/topic_search_view.dart';
import 'package:aelion/widgets/not_found_view.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _guarded(
          const HomeView(),
          const RouteSettings(name: HomeView.routeName),
        );
      case SignInScreen.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const SignInScreen(),
          settings: const RouteSettings(name: SignInScreen.routeName),
        );
      case HomeView.routeName:
        return _guarded(
          const HomeView(),
          const RouteSettings(name: HomeView.routeName),
        );
      case CourseEntryView.routeName:
        return _guarded(
          const CourseEntryView(),
          const RouteSettings(name: CourseEntryView.routeName),
        );
      case TopicSearchView.routeName:
        return _guarded(
          const TopicSearchView(),
          RouteSettings(
            name: TopicSearchView.routeName,
            arguments: settings.arguments,
          ),
        );
      case ModuleOutlineView.routeName:
        ModuleOutlineArgs? args;
        final rawArgs = settings.arguments;
        if (rawArgs is ModuleOutlineArgs) {
          args = rawArgs;
        } else if (rawArgs is String && rawArgs.trim().isNotEmpty) {
          args = ModuleOutlineArgs(topic: rawArgs.trim());
        }

        if (args == null) {
          return _invalidRoute(
            settings,
            'ModuleOutlineView requires a topic string',
          );
        }

        return _guarded(
          ModuleOutlineView(
            topic: args.topic,
            level: args.level,
            language: args.language,
            goal: args.goal,
          ),
          RouteSettings(
            name: ModuleOutlineView.routeName,
            arguments: args,
          ),
        );
      case QuizScreen.routeName:
        final topic = settings.arguments;
        if (topic is! String || topic.trim().isEmpty) {
          return _invalidRoute(settings, 'QuizScreen requires a topic string');
        }
        return _guarded(
          QuizScreen(topic: topic),
          RouteSettings(
            name: QuizScreen.routeName,
            arguments: topic,
          ),
        );
      default:
        return onUnknownRoute(settings);
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (context) => NotFoundView(routeName: settings.name),
      settings: const RouteSettings(name: 'not-found'),
    );
  }

  static MaterialPageRoute<dynamic> _guarded(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => AuthGate(child: child),
      settings: settings,
    );
  }

  static Route<dynamic> _invalidRoute(RouteSettings settings, String reason) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundView(routeName: settings.name, reason: reason),
      settings: RouteSettings(name: 'invalid-${settings.name ?? 'route'}'),
    );
  }
}
