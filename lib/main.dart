import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_colors.dart';
import 'core/router.dart';

Future<void> main() async {
  // Atrapa errores de frameworks externos
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await _loadEnv();

      // Atrapa errores del framework Flutter
      FlutterError.onError = (errorDetails) {
        // TODO: Reemplazar por un logger de verdad
        debugPrint('[FlutterError] ${errorDetails.exception}');
        debugPrint(errorDetails.stack.toString());
        Zone.current.handleUncaughtError(
          errorDetails.exception,
          errorDetails.stack ?? StackTrace.empty,
        );
      };

      // Muestra un widget de error visible en modo debug
      if (kDebugMode) {
        ErrorWidget.builder = (errorDetails) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error de renderizado:\n\n${errorDetails.exception}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        };
      }
      runApp(const AelionApp());
    },
    (error, stack) {
      // TODO: Reemplazar por un logger de verdad
      debugPrint('[runZonedGuarded] $error');
      debugPrint(stack.toString());
    },
  );
}

/// Carga el fichero de entorno `.env` o en su defecto `env.public`.
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

        // Esquema de color sin background/onBackground (deprecados)
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

        // Fondo del scaffold (equivalente al background anterior)
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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

        // <-- Aquí el cambio importante
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
