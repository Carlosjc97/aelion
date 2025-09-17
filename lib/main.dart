import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/services/progress_service.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await _loadEnv();

      // Inicializa progreso (singleton con .i)
      await ProgressService().init();

      // Manejo de errores UI
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
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    try {
      await dotenv.load(fileName: 'env.public');
    } catch (_) {
      debugPrint('[Aelion] No se pudo cargar ningún archivo de entorno.');
      debugPrint('API_BASE_URL=${dotenv.env['API_BASE_URL']}');
    }
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
        textTheme:
            const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
              headlineMedium: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              bodyLarge: TextStyle(fontSize: 16, height: 1.35),
              bodyMedium: TextStyle(fontSize: 14, height: 1.35),
              labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ).apply(
              bodyColor: AppColors.onSurface,
              displayColor: AppColors.onSurface,
            ),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
