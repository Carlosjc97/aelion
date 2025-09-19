import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:learning_ia/core/app_colors.dart';
// 👇 usamos alias para evitar conflictos con tear-offs
import 'package:learning_ia/core/router.dart' as app;
import 'package:learning_ia/services/progress_service.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await _loadEnv(); // carga variables de entorno

      await ProgressService().init();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };
      ErrorWidget.builder = (details) {
        return Material(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Oops! ${details.exceptionAsString()}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      };

      runApp(const AelionApp());
    },
    (error, stack) {
      debugPrint('[runZonedGuarded] Uncaught error: $error');
      debugPrint(stack.toString());
    },
  );
}

Future<void> _loadEnv() async {
  // Intentamos primero el que esta en assets (declarado en pubspec.yaml)
  try {
    await dotenv.load(fileName: 'env.public');
    debugPrint(
      '[Aelion] Cargado env.public (assets). '
      'API_BASE_URL=${dotenv.env['API_BASE_URL']}',
    );
    return;
  } catch (_) {
    // sigue abajo
  }

  // Si no hay env.public, intentamos un .env local (no en assets)
  try {
    await dotenv.load(fileName: '.env');
    debugPrint(
      '[Aelion] Cargado .env (filesystem). '
      'API_BASE_URL=${dotenv.env['API_BASE_URL']}',
    );
  } catch (_) {
    debugPrint('[Aelion] No se pudo cargar env.public ni .env');
  }
}

class AelionApp extends StatelessWidget {
  const AelionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aelion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          error: AppColors.error,
          onError: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          centerTitle: true,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, height: 1.35),
          bodyMedium: TextStyle(fontSize: 14, height: 1.35),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ).apply(
          bodyColor: AppColors.onSurface,
          displayColor: AppColors.onSurface,
        ),
      ),
      // 👇 usamos closures + alias
      onGenerateRoute: (settings) => app.AppRouter.onGenerateRoute(settings),
      onUnknownRoute: (settings) => app.AppRouter.onUnknownRoute(settings),
      initialRoute: '/',
    );
  }
}
