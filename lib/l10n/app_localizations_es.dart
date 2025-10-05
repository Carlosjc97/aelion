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
  String get loginTitle => 'Aprende mas rapido con IA';

  @override
  String get loginSubtitle => 'Tu ruta de aprendizaje en pocos toques';

  @override
  String get loginHighlightPersonalized => 'Esquemas personalizados en minutos';

  @override
  String get loginHighlightStreak => 'Rachas diarias para motivarte';

  @override
  String get loginHighlightSync =>
      'Sincroniza en web y Android con tu cuenta Google';

  @override
  String get loginButton => 'Iniciar sesion con Google';

  @override
  String get loginLoading => 'Conectando...';

  @override
  String get loginCancelled => 'Inicio cancelado por el usuario';

  @override
  String get loginError =>
      'No pudimos completar el inicio de sesion. Intenta de nuevo.';

  @override
  String get authCheckingSession => 'Verificando tu sesion...';

  @override
  String get authError => 'No fue posible validar la sesion';

  @override
  String get authRetry => 'Reintentar';

  @override
  String get homeGreeting => 'Que quieres aprender hoy?';

  @override
  String get homeInputHint =>
      'Ejemplo: Algebra en 7 dias, ingles conversacional...';

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
  String get homeShortcutLanguageSubtitle => 'Vocabulario y gramatica practica';

  @override
  String get homeShortcutProblem => 'Resuelve un problema';

  @override
  String get homeShortcutProblemSubtitle => 'De la duda a un plan guiado';

  @override
  String get homeLogoutTooltip => 'Cerrar sesion';

  @override
  String get homeSignOutError =>
      'No pudimos cerrar la sesion. Intenta de nuevo.';

  @override
  String get homeUserFallback => 'Usuario Aelion';

  @override
  String get homeUserNoEmail => 'Sin correo';

  @override
  String get homeSuggestionMath => 'Matematicas basicas';

  @override
  String get homeSuggestionEnglish => 'Ingles conversacional';

  @override
  String get homeSuggestionHistory => 'Historia de Roma';

  @override
  String get homePrefillCourse => 'Curso rapido de Flutter';

  @override
  String get homePrefillLanguage => 'Ingles en 1 mes';

  @override
  String get homePrefillProblem => 'Resolver integrales';

  @override
  String get notFoundRoute => 'Ruta no encontrada';
}
