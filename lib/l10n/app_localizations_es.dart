// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Aelion';

  @override
  String get loginTitle => 'Aprende más rápido con IA';

  @override
  String get loginButton => 'Iniciar sesión con Google';

  @override
  String get loginLoading => 'Conectando...';

  @override
  String get loginCancelled => 'Inicio cancelado por el usuario';

  @override
  String get loginError => 'No pudimos completar el inicio de sesión. Intenta de nuevo.';

  @override
  String get notFoundRoute => 'Ruta no encontrada';
}
