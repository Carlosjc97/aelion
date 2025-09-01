import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/core/router.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await _loadEnv();

      // New error handlers from user
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
        // Forward to zone so runZonedGuarded can catch as well.
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      };

      ErrorWidget.builder = (FlutterErrorDetails details) {
        return Material(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    // Short summary + the exception; avoid huge stack floods
                    'Widget build error:\n${details.exceptionAsString()}',
                  ),
                ),
              ),
            ),
          ),
        );
      };

      runApp(const AelionApp());
    },
    (error, stack) {
      // This is the zoned error handler, good for logging
      debugPrint('[runZonedGuarded] $error');
      debugPrint(stack.toString());
    },
  );
}

/// Carga .env o env.public (fallback).
Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    try {
      await dotenv.load(fileName: 'env.public');
    } catch (_) {
      debugPrint('[Aelion] No se pudo cargar ningún archivo de entorno.');
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size.fromHeight(56),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.neutral,
            foregroundColor: AppColors.onSurface,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: Color(0xFF7A8797)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.neutral),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.neutral),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.zero,
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: AppColors.neutral,
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
          elevation: 0,
          side: BorderSide(color: Colors.transparent),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        ),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
