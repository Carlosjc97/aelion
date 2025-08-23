import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_colors.dart';
import 'core/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Primero intentamos cargar tu archivo .env local (no subido al repo)
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Si no existe, intentamos cargar el archivo público env.public
    try {
      await dotenv.load(fileName: 'env.public');
    } catch (_) {
      // Si no se puede cargar ninguno, seguimos sin variables y mostramos un aviso en consola
      debugPrint(
        '[Aelion] No se pudo cargar ningún archivo de entorno; continúa sin él.',
      );
    }
  }
  runApp(const AelionApp());
}

class AelionApp extends StatelessWidget {
  const AelionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aelion',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(foregroundColor: Colors.white),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ).copyWith(secondary: AppColors.secondary),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
