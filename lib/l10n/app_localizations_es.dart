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
  String homeGreetingNamedShort(String name) {
    return 'Hola $name ð';
  }

  @override
  String get homeGreetingWave => 'Hola ð';

  @override
  String get homeMotivation => 'Sigue con tu impulso de aprendizaje hoy.';

  @override
  String get homePromptTitle => 'Que plan generamos hoy?';

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

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get dialogContinue => 'Continuar';

  @override
  String get quizTitle => 'Quiz de colocaciÃ³n';

  @override
  String quizHeaderTitle(String topic) {
    return 'Calibra $topic';
  }

  @override
  String get quizIntroDescription =>
      'Responde 10 preguntas rapidas para calibrar tu plan.';

  @override
  String get startQuiz => 'Comenzar';

  @override
  String quizQuestionCounter(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String quizTimeHint(int minutes) {
    return 'Aprox. $minutes min';
  }

  @override
  String get quizAnswerAllPrompt =>
      'Responde todas las preguntas antes de continuar.';

  @override
  String get quizExitTitle => 'Salir del quiz?';

  @override
  String get quizExitMessage => 'Perderas tus respuestas.';

  @override
  String get quizExitCancel => 'Quedarme';

  @override
  String get quizExitConfirm => 'Salir';

  @override
  String get submit => 'Enviar';

  @override
  String get next => 'Siguiente';

  @override
  String quizResultTitle(String band) {
    return 'Nivel $band';
  }

  @override
  String quizLevelChip(String band) {
    return 'Nivel: $band';
  }

  @override
  String quizScorePercentage(int score) {
    return 'Puntaje: $score%';
  }

  @override
  String quizRecommendRefine(String band) {
    return 'Refinaremos tu plan para el nivel $band.';
  }

  @override
  String quizKeepCurrentPlan(String band) {
    return 'Tu plan actual ya coincide con el nivel $band.';
  }

  @override
  String get quizDone => 'Listo';

  @override
  String get quizUnknownError => 'No pudimos cargar el quiz. Intenta de nuevo.';

  @override
  String get quizBandBeginner => 'Principiante';

  @override
  String get quizBandIntermediate => 'Intermedio';

  @override
  String get quizBandAdvanced => 'Avanzado';

  @override
  String get courseEntryTitle => 'Tomar un curso';

  @override
  String get courseEntrySubtitle =>
      'Busca un tema y lanza un quiz de colocaciÃ³n rÃ¡pido.';

  @override
  String get courseEntryHint =>
      'Ejemplo: Fundamentos de Flutter, Ã¡lgebra lineal, SQL...';

  @override
  String get courseEntryStart => 'Iniciar quiz';

  @override
  String get courseEntryFooter =>
      'Los quizzes de colocaciÃ³n tienen solo 10 preguntas.';

  @override
  String get courseEntryExampleFlutter => 'Introducción a Flutter';

  @override
  String get courseEntryExampleSql => 'SQL para principiantes';

  @override
  String get courseEntryExampleDataScience => 'Ciencia de datos 101';

  @override
  String get courseEntryExampleLogic => 'Fundamentos de lógica';

  @override
  String courseEntryResultSummary(int score, String band) {
    return 'Puntaje $score% - nivel $band';
  }

  @override
  String courseEntryResultActionUpdate(String band) {
    return 'Generando un nuevo plan para el nivel $band.';
  }

  @override
  String courseEntryResultActionReuse(String band) {
    return 'Usando tu plan $band ya existente.';
  }

  @override
  String get outlineFallbackTitle => 'Plan';

  @override
  String get moduleOutlineFallbackTopic => 'Tema predeterminado';

  @override
  String get outlineUpdatePlan => 'Actualizar plan';

  @override
  String get refinePlan => 'Refinar plan';

  @override
  String outlineRefineRebuild(String band) {
    return 'El nuevo plan usarÃ¡ el nivel $band.';
  }

  @override
  String outlineRefineNoChanges(String band) {
    return 'El plan actual ya corresponde al nivel $band.';
  }

  @override
  String get outlineSnackCached => 'Se cargo tu plan guardado.';

  @override
  String get outlineSnackUpdated => 'Plan actualizado con los ultimos cambios.';

  @override
  String get outlineRefineChangeDepthTitle => 'Cambiar profundidad';

  @override
  String get outlineRefineChangeDepthSubtitle =>
      'Reutiliza o genera planes para niveles intro, intermedio o profundo.';

  @override
  String get takePlacementQuiz => 'Tomar quiz de colocación';

  @override
  String get outlineRefinePlacementQuizSubtitle =>
      'Responde 10 preguntas para calibrar tu plan.';

  @override
  String get outlineErrorGeneric => 'No pudimos cargar el plan.';

  @override
  String get outlineErrorEmpty => 'No hay un plan disponible para este tema.';

  @override
  String get outlineErrorNoContent =>
      'No hay contenido disponible para este tema.';

  @override
  String get outlineSourceCached => 'Plan en cachÃ©';

  @override
  String outlineSavedLabel(String timestamp) {
    return 'Guardado $timestamp';
  }

  @override
  String get outlineStaleBadge => 'Caducado';

  @override
  String outlineMetaBand(String band) {
    return 'Nivel: $band';
  }

  @override
  String outlineMetaLevel(String level) {
    return 'Nivel: $level';
  }

  @override
  String outlineMetaHours(int hours) {
    return '$hours horas';
  }

  @override
  String outlineMetaLanguage(String language) {
    return 'Idioma: $language';
  }

  @override
  String outlineMetaDepth(String depth) {
    return 'Profundidad: $depth';
  }

  @override
  String outlineLessonCount(int count) {
    return '$count lecciones';
  }

  @override
  String outlineLessonLanguage(String language) {
    return 'Idioma: $language';
  }

  @override
  String outlineModuleFallback(int index) {
    return 'MÃ³dulo $index';
  }

  @override
  String outlineLessonFallback(int index) {
    return 'LecciÃ³n $index';
  }

  @override
  String homeGreetingNamed(String name) {
    return 'Hola $name, Â¿quÃ© quieres aprender hoy?';
  }

  @override
  String get homeRecentTitle => 'Planes recientes';

  @override
  String get homeRecentEmpty => 'AÃºn no tienes planes guardados.';

  @override
  String get homeRecentView => 'Ver plan';

  @override
  String homeRecentMoreCount(int count) {
    return '+$count mÃ³dulos mÃ¡s';
  }

  @override
  String homeRecentSaved(String timestamp) {
    return 'Guardado $timestamp';
  }

  @override
  String get homeUpdatedJustNow => 'Actualizado hace un instante';

  @override
  String homeUpdatedMinutes(int minutes) {
    return 'Actualizado hace $minutes min';
  }

  @override
  String homeUpdatedHours(int hours) {
    return 'Actualizado hace $hours h';
  }

  @override
  String homeUpdatedDays(int days) {
    return 'Actualizado hace $days d';
  }

  @override
  String get homeDepthIntro => 'Nivel introductorio';

  @override
  String get homeDepthMedium => 'Profundidad intermedia';

  @override
  String get homeDepthDeep => 'Profundidad avanzada';

  @override
  String buildExpertiseIn(Object topic) {
    return 'Desarrolla experiencia en $topic';
  }

  @override
  String get depthIntro => 'introductoria';

  @override
  String get depthMedium => 'intermedia';

  @override
  String get depthDeep => 'profunda';

  @override
  String get calibratingPlan => 'Calibrando tu plan';

  @override
  String get planReady => 'Plan creado';

  @override
  String get homeRecommendationsTitle => 'Recomendados';

  @override
  String get homeRecommendationsEmpty => 'Sin recomendaciones por ahora.';

  @override
  String get homeRecommendationsError =>
      'No pudimos cargar las recomendaciones.';

  @override
  String quizCooldownMinutes(Object minutes) {
    return 'Espera $minutes minuto(s) antes de rehacer el quiz.';
  }

  @override
  String get quizCooldownSeconds =>
      'Espera unos segundos antes de rehacer el quiz.';

  @override
  String get quizOpenPlan => 'Abrir plan';

  @override
  String get quizApplyResults => 'Aplicar resultados';

  @override
  String get quizResultsNoChanges => 'Resultados guardados sin cambios.';

  @override
  String get planAlreadyAligned => 'Tu plan ya está alineado.';

  @override
  String lessonCompleteToast(int xp) {
    return '¡Lección completada! XP total: $xp';
  }

  @override
  String lessonXpReward(int xp) {
    return '+$xp XP';
  }

  @override
  String get lessonUpdateError =>
      'No pudimos actualizar la lección. Intenta de nuevo.';

  @override
  String get lessonPremiumContent => 'Contenido premium';

  @override
  String get lessonDescriptionTitle => 'Descripción';

  @override
  String get lessonMarkCompleted => 'Marcar lección como completada';

  @override
  String get lessonTipTakeNotes =>
      'Consejo: toma notas rápidas antes de continuar.';

  @override
  String get lessonFallbackTitle => 'Lección';

  @override
  String get lessonObjectiveTitle => 'Objetivo de la lección';

  @override
  String get lessonObjectiveSummary =>
      '• Comprende el concepto principal.\n• Realiza una práctica breve.\n• Avanza cuando te sientas listo.';

  @override
  String get lessonQuizTitle => 'Pregunta';

  @override
  String lessonQuizOption(String letter, String option) {
    return '$letter) $option';
  }

  @override
  String get lessonQuizCheck => 'Comprobar respuesta';

  @override
  String get lessonQuizCorrect => '✅ ¡Correcto!';

  @override
  String lessonQuizIncorrect(String answer) {
    return '❌ Incorrecto. La respuesta era $answer.';
  }

  @override
  String get lessonTipReview =>
      'Consejo: si algo no queda claro, vuelve a leer y practica 2 minutos más antes de avanzar.';

  @override
  String get lessonContentComingSoon => 'Contenido disponible pronto.';

  @override
  String get commonOk => 'Aceptar';

  @override
  String get commonSaving => 'Guardando...';

  @override
  String get homeGenerateError =>
      'No pudimos generar el plan. Intenta de nuevo.';

  @override
  String get topicSearchMissingTopic => 'Escribe un tema para continuar';

  @override
  String get topicSearchTitleFallback => 'Buscar un tema';

  @override
  String get topicSearchHintFallback => '¿Qué quieres aprender?';

  @override
  String get topicSearchStartButton => 'Tomar mini quiz';

  @override
  String get quizPlanCreated => 'Plan creado.';
}
