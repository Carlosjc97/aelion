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
  String get loginError =>
      'No pudimos completar el inicio de sesión. Intenta de nuevo.';

  @override
  String get authCheckingSession => 'Verificando tu sesión...';

  @override
  String get authError => 'No fue posible validar la sesión';

  @override
  String get authRetry => 'Reintentar';

  @override
  String get homeGreeting => '¿Qué quieres aprender hoy?';

  @override
  String get homeInputHint =>
      'Ejemplo: Álgebra en 7 días, inglés conversacional...';

  @override
  String get homeSnackMissingTopic => 'Escribe un tema para continuar';

  @override
  String get homeGenerate => 'Generar plan con IA';

  @override
  String get homeShortcuts => 'Atajos';

  @override
  String get homeShortcutCourse => 'Toma un curso';

  @override
  String get homeShortcutCourseSubtitle => 'Microcursos creados por IA';

  @override
  String get homeShortcutLanguage => 'Aprende un idioma';

  @override
  String get homeShortcutLanguageSubtitle =>
      'Vocabulario y gramática práctica';

  @override
  String get homeShortcutProblem => 'Resuelve un problema';

  @override
  String get homeShortcutProblemSubtitle => 'De la duda a un plan guiado';

  @override
  String get homeLogoutTooltip => 'Cerrar sesión';

  @override
  String get homeSignOutError =>
      'No pudimos cerrar la sesión. Intenta de nuevo.';

  @override
  String get homeUserFallback => 'Usuario Aelion';

  @override
  String get homeUserNoEmail => 'Sin correo';

  @override
  String get homeSuggestionMath => 'Matemáticas básicas';

  @override
  String get homeSuggestionEnglish => 'Inglés conversacional';

  @override
  String get homeSuggestionHistory => 'Historia de Roma';

  @override
  String get homePrefillCourse => 'Curso rápido de Flutter';

  @override
  String get homePrefillLanguage => 'Inglés en 1 mes';

  @override
  String get homePrefillProblem => 'Resolver integrales';

  @override
  String get notFoundRoute => 'Ruta no encontrada';
}
