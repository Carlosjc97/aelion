import 'package:flutter/material.dart';

import 'package:edaptia/features/auth/auth.dart';
import 'package:edaptia/features/courses/course_entry_view.dart';
import 'package:edaptia/features/home/home_view.dart';
import 'package:edaptia/features/lesson/lesson_detail_page.dart';
import 'package:edaptia/features/modules/outline/module_outline_view.dart';
import 'package:edaptia/features/quiz/quiz_screen.dart';
import 'package:edaptia/features/settings/settings_view.dart';
import 'package:edaptia/features/support/help_support_screen.dart';
import 'package:edaptia/features/topics/topic_search_view.dart';
import 'package:edaptia/widgets/not_found_view.dart';

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
            depth: args.depth,
            preferredBand: args.preferredBand,
            recommendRegenerate: args.recommendRegenerate,
            initialOutline: args.initialOutline,
            initialResponse: args.initialResponse,
            initialSource: args.initialSource,
            initialSavedAt: args.initialSavedAt,
          ),
          RouteSettings(
            name: ModuleOutlineView.routeName,
            arguments: args,
          ),
        );
      case LessonDetailPage.routeName:
        final lessonArgs = settings.arguments;
        if (lessonArgs is! LessonDetailArgs) {
          return _invalidRoute(
            settings,
            'LessonDetailPage requires LessonDetailArgs.',
          );
        }
        return _guarded(
          LessonDetailPage(args: lessonArgs),
          RouteSettings(
            name: LessonDetailPage.routeName,
            arguments: lessonArgs,
          ),
        );
      case QuizScreen.routeName:
        final rawArgs = settings.arguments;
        QuizScreenArgs? args;
        if (rawArgs is QuizScreenArgs) {
          args = rawArgs;
        } else if (rawArgs is String && rawArgs.trim().isNotEmpty) {
          args = QuizScreenArgs(topic: rawArgs.trim(), language: 'en');
        }

        if (args == null) {
          return _invalidRoute(
            settings,
            'QuizScreen requires a topic and language.',
          );
        }

        return _guarded(
          QuizScreen(
            topic: args.topic,
            language: args.language,
            autoOpenOutline: args.autoOpenOutline,
            outlineGenerator: args.outlineGenerator,
          ),
          RouteSettings(
            name: QuizScreen.routeName,
            arguments: args,
          ),
        );
      case SettingsView.routeName:
        return _guarded(
          const SettingsView(),
          const RouteSettings(name: SettingsView.routeName),
        );
      case HelpSupportScreen.routeName:
        return _guarded(
          const HelpSupportScreen(),
          const RouteSettings(name: HelpSupportScreen.routeName),
        );
      case LessonsPage.routeName:
        return _guarded(
          const LessonsPage(),
          const RouteSettings(name: LessonsPage.routeName),
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






