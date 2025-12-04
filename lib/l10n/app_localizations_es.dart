// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Edaptia';

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
    return 'Hola $name';
  }

  @override
  String get homeGreetingWave => 'Hola';

  @override
  String get homeTitle => 'Inicio';

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
  String get startCalibration => 'Descubre tu nivel';

  @override
  String get module1Free => 'Modulo 1 GRATIS';

  @override
  String get unlockPremium => 'Desbloquear Premium';

  @override
  String get perMonth => '/mes';

  @override
  String get gateQuizPassed => 'Aprobaste! Ya puedes continuar.';

  @override
  String get gateQuizFailed => 'Necesitas 70% para avanzar.';

  @override
  String get gateQuizReviewTopics => 'Refuerza estos temas:';

  @override
  String get gateQuizRetry => 'Volver a intentar';

  @override
  String get gatePracticeUnlocked =>
      'Modo práctica activado. Usa estas pistas antes de reintentar.';

  @override
  String get gatePracticeLocked =>
      'El modo práctica se activa tras 3 intentos. ¡Sigue!';

  @override
  String get gatePracticeHintsTitle => 'Pistas sugeridas:';

  @override
  String gatePracticeAttempts(int count, int total) {
    return 'Intentos usados: $count/$total';
  }

  @override
  String get modulePremiumContent => 'Contenido premium';

  @override
  String modulePremiumUnlock(int moduleNumber) {
    return 'Desbloquea el modulo $moduleNumber iniciando tu prueba gratis.';
  }

  @override
  String get modulePremiumButton => 'Desbloquear con Premium';

  @override
  String get moduleGatePending => 'Quiz de modulo pendiente';

  @override
  String moduleGateRequired(int moduleNumber) {
    return 'Aprueba el quiz del modulo $moduleNumber (>=70%) para avanzar.';
  }

  @override
  String get moduleGateTake => 'Tomar quiz del modulo';

  @override
  String get homeEnglishComingTitle => 'Acceso Anticipado';

  @override
  String get homeEnglishComingSubtitle =>
      'Sé el primero en probar nuevas funciones y sugerir mejoras';

  @override
  String get homeEnglishNotifyCta => 'Notificarme';

  @override
  String get homeEnglishNotifyDone => 'Ya registrado';

  @override
  String get homeEnglishNotifySuccess =>
      '¡Te notificaremos cuando lance Inglés Técnico!';

  @override
  String get homeEnglishNotifyError => 'No se pudo registrar la notificación';

  @override
  String assessmentResultTitle(String level) {
    return 'Tu nivel: $level';
  }

  @override
  String assessmentResultLevelLabel(String level) {
    return 'Tu nivel: $level';
  }

  @override
  String assessmentResultPercentile(int percentile) {
    return 'Obtuviste mejor puntaje que el $percentile% de los aprendices';
  }

  @override
  String get assessmentResultStrengthsTitle => 'Fortalezas';

  @override
  String get assessmentResultGapsTitle => 'Ãreas de mejora';

  @override
  String get assessmentResultPlanTitle => 'Plan sugerido';

  @override
  String get assessmentResultShare => 'Compartir resultados';

  @override
  String get assessmentResultCta => 'Generar mi plan de aprendizaje';

  @override
  String assessmentResultShareMessage(String topic, String level, int score) {
    return '¡Acabo de completar mi evaluación de $topic en Edaptia! Nivel: $level, Puntuación: $score%';
  }

  @override
  String get assessmentResultClose => 'Cerrar';

  @override
  String get assessmentResultResponsesTitle => 'Tus respuestas';

  @override
  String get settingsLanguageTitle => 'Idioma de la App';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get homeLogoutTooltip => 'Cerrar sesion';

  @override
  String get homeSignOutError =>
      'No pudimos cerrar la sesion. Intenta de nuevo.';

  @override
  String get homeUserFallback => 'Usuario Edaptia';

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
  String get commonYes => 'Si';

  @override
  String get commonNo => 'No';

  @override
  String get onboardingTitle => 'Cuentanos sobre ti';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingProgressLabel => 'Pregunta';

  @override
  String get onboardingBack => 'Anterior';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String get onboardingSelectLabel => 'Selecciona una opcion';

  @override
  String get onboardingQuestionAge => 'Cual es tu rango de edad?';

  @override
  String get onboardingQuestionInterests => 'Que temas te interesan?';

  @override
  String get onboardingQuestionEducation => 'Cual es tu nivel educativo?';

  @override
  String get onboardingQuestionFirstSql => 'Es tu primera vez con SQL?';

  @override
  String get onboardingQuestionBeta => 'Quieres ser beta tester?';

  @override
  String get onboardingAge18_24 => '18-24 anos';

  @override
  String get onboardingAge25_34 => '25-34 anos';

  @override
  String get onboardingAge35_44 => '35-44 anos';

  @override
  String get onboardingAge45Plus => '45+';

  @override
  String get onboardingInterestSql => 'SQL';

  @override
  String get onboardingInterestPython => 'Python';

  @override
  String get onboardingInterestExcel => 'Excel';

  @override
  String get onboardingInterestData => 'Analisis de datos';

  @override
  String get onboardingInterestMarketing => 'Marketing';

  @override
  String get onboardingEducationSecondary => 'Secundaria';

  @override
  String get onboardingEducationUniversity => 'Universidad';

  @override
  String get onboardingEducationPostgrad => 'Posgrado';

  @override
  String get onboardingEducationSelfTaught => 'Autodidacta';

  @override
  String get onboardingBetaDescription =>
      'Edaptia esta en desarrollo activo. Como beta tester:\\n• Recibiras actualizaciones antes que nadie\\n• Tendras acceso a features experimentales\\n• Tu feedback nos ayuda a mejorar';

  @override
  String get onboardingBetaOptIn => 'Si, quiero ser beta tester';

  @override
  String get onboardingError =>
      'No pudimos guardar tus respuestas. Intenta de nuevo.';

  @override
  String get notFoundRoute => 'Ruta no encontrada';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get dialogContinue => 'Continuar';

  @override
  String get quizTitle => 'Quiz de colocación';

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
  String get quizNext => 'Siguiente';

  @override
  String get quizSubmit => 'Enviar';

  @override
  String get quizContinue => 'Continuar';

  @override
  String get quizUnknownError => 'No pudimos cargar el quiz. Intenta de nuevo.';

  @override
  String get quizBandBasic => 'Básico';

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
      'Busca un tema y lanza un quiz de colocación rápido.';

  @override
  String get courseEntryHint =>
      'Ejemplo: Fundamentos de Flutter, álgebra lineal, SQL...';

  @override
  String get courseEntryStart => 'Iniciar quiz';

  @override
  String get courseEntryFooter =>
      'Los quizzes de colocación tienen solo 10 preguntas.';

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
    return 'El nuevo plan usará el nivel $band.';
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
  String get outlineSourceCached => 'Plan en caché';

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
    return 'Módulo $index';
  }

  @override
  String outlineLessonFallback(int index) {
    return 'Lección $index';
  }

  @override
  String homeGreetingNamed(String name) {
    return 'Hola $name, ¿qué quieres aprender hoy?';
  }

  @override
  String get homeRecentTitle => 'Planes recientes';

  @override
  String get homeRecentEmpty => 'Aún no tienes planes guardados.';

  @override
  String get homeRecentView => 'Ver plan';

  @override
  String homeRecentMoreCount(int count) {
    return '+$count módulos más';
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
  String get lessonQuizCorrect => 'âœ… ¡Correcto!';

  @override
  String lessonQuizIncorrect(String answer) {
    return 'âŒ Incorrecto. La respuesta era $answer.';
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

  @override
  String get helpSupportTitle => 'Ayuda y soporte';

  @override
  String get helpSupportSubtitle =>
      'Respuestas, formas de contacto y enlaces a la comunidad.';

  @override
  String get helpFaqSectionTitle => 'Preguntas frecuentes';

  @override
  String get helpCommunitySectionTitle => 'Comunidad';

  @override
  String get helpContactSectionTitle => 'Opciones de contacto';

  @override
  String get helpJoinCommunity => 'Unirte a la comunidad';

  @override
  String get helpJoinCommunityDescription =>
      'Elige cómo conectarte con otros estudiantes.';

  @override
  String get helpJoinCommunityDialogTitle => 'Abrir Telegram';

  @override
  String get helpJoinCommunityChannel => 'Canal de noticias';

  @override
  String get helpJoinCommunityGroup => 'Chat de la comunidad';

  @override
  String get helpContactSpanish => 'Correo de soporte (ES)';

  @override
  String get helpContactSpanishDescription =>
      'Escríbenos en español; respondemos rápido.';

  @override
  String get helpContactEnglish => 'Correo de soporte (EN)';

  @override
  String get helpContactEnglishDescription =>
      'Recibe ayuda en inglés del equipo principal.';

  @override
  String get helpReportBug => 'Reportar un error';

  @override
  String get helpReportBugDescription =>
      'Incluye capturas o pasos si es posible.';

  @override
  String get helpAboutTitle => 'Acerca de esta app';

  @override
  String get helpAboutDescription =>
      'Creada con Flutter, Firebase Cloud Functions y OpenAI; el contenido adaptativo se genera de forma segura bajo demanda.';

  @override
  String get helpPrivacyPolicy => 'Política de privacidad';

  @override
  String get helpTermsOfService => 'Términos de servicio';

  @override
  String get helpLaunchError => 'No pudimos abrir el enlace. Intenta de nuevo.';

  @override
  String get homeOverflowHelpSupport => 'Ayuda y soporte';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsHelpSupport => 'Ayuda y soporte';

  @override
  String get settingsHelpSupportSubtitle => 'Preguntas, contacto y políticas';

  @override
  String helpEmailSubject(String appName, String version, String device) {
    return 'Solicitud de soporte $appName (v$version Â· $device)';
  }

  @override
  String helpBugReportSubject(String appName, String version, String device) {
    return 'Reporte de bug $appName (v$version Â· $device)';
  }

  @override
  String helpBugReportBody(
      String timestamp, String locale, String version, String device) {
    return 'Marca de tiempo: $timestamp\nLocalización: $locale\nVersión: $version\nDispositivo: $device\n\nPasos para reproducir:\n- ';
  }

  @override
  String helpAboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get adaptiveFlowCta => 'Flujo adaptativo';

  @override
  String get adaptiveFlowTitle => 'Recorrido adaptativo';

  @override
  String get adaptiveFlowLoading => 'Cargando plan adaptativo...';

  @override
  String get adaptiveFlowError =>
      'No pudimos cargar el plan adaptativo. Intenta de nuevo.';

  @override
  String get adaptiveFlowNoPlan =>
      'Aún no tienes plan adaptativo. Généralo para comenzar.';

  @override
  String get adaptiveFlowLearnerState => 'Estado del alumno';

  @override
  String get adaptiveFlowPlanSection => 'Módulos sugeridos';

  @override
  String get adaptiveFlowModuleSection => 'Módulo';

  @override
  String get adaptiveFlowCheckpointSection => 'Checkpoint';

  @override
  String get adaptiveFlowBoosterSection => 'Refuerzo';

  @override
  String get adaptiveFlowGenerateModule => 'Generar módulo';

  @override
  String get adaptiveFlowGenerateCheckpoint => 'Crear checkpoint';

  @override
  String get adaptiveFlowSubmitAnswers => 'Evaluar checkpoint';

  @override
  String get adaptiveFlowBoosterCta => 'Pedir refuerzo';

  @override
  String adaptiveFlowWeakSkills(String skills) {
    return 'Habilidades débiles: $skills';
  }

  @override
  String adaptiveFlowScoreLabel(int score) {
    return 'Puntaje: $score%';
  }

  @override
  String get adaptiveFlowActionAdvance =>
      '¡Genial! Avanza al siguiente módulo.';

  @override
  String get adaptiveFlowActionBooster =>
      'Necesitas un refuerzo antes de avanzar.';

  @override
  String get adaptiveFlowActionReplan =>
      'Repite este módulo con más andamiaje.';

  @override
  String get adaptiveFlowCheckpointMissingSelection =>
      'Selecciona una respuesta por pregunta.';

  @override
  String get adaptiveFlowEmptySkills => 'Aún no hay dominio registrado.';

  @override
  String adaptiveFlowDurationLabel(int minutes) {
    return 'Duración: $minutes min';
  }

  @override
  String adaptiveFlowSkillsLabel(String skills) {
    return 'Habilidades: $skills';
  }

  @override
  String adaptiveFlowLockedModule(String module) {
    return 'Completa el módulo $module para desbloquearlo.';
  }

  @override
  String get adaptiveFlowLockedPremium =>
      'Activa Premium para seguir avanzando.';

  @override
  String get helpFaqQuestion1 => '¿Cómo inicio mi primer recorrido adaptativo?';

  @override
  String get helpFaqAnswer1 =>
      'En Inicio escribe un tema, toca Generar plan, completa el placement quiz y abrimos tu recorrido adaptativo con el primer módulo al instante.';

  @override
  String get helpFaqQuestion2 => '¿Qué calibra el placement quiz?';

  @override
  String get helpFaqAnswer2 =>
      'El cuestionario de 10 preguntas define tu nivel (básico, intermedio o avanzado) e identifica tus skills débiles para enfocar cada módulo.';

  @override
  String get helpFaqQuestion3 => '¿Cuándo se desbloquea el siguiente módulo?';

  @override
  String get helpFaqAnswer3 =>
      'Cuando visitas todas las lecciones y apruebas el quiz del módulo, el siguiente se desbloquea automáticamente y el timeline se actualiza en tiempo real.';

  @override
  String get helpFaqQuestion4 => '¿Cómo se generan los módulos?';

  @override
  String get helpFaqAnswer4 =>
      'Cada módulo se produce mediante nuestras Cloud Functions con OpenAI; imponemos una estructura de 12 lecciones y validamos el esquema antes de guardarlo.';

  @override
  String get helpFaqQuestion5 => '¿Cómo funcionan los checkpoints y boosters?';

  @override
  String get helpFaqAnswer5 =>
      'Al terminar un módulo puedes generar un checkpoint o un booster; ambos reutilizan tus skills débiles para darte ejercicios frescos antes de avanzar.';

  @override
  String get helpFaqQuestion6 =>
      '¿Puedo regenerar un módulo o el plan completo?';

  @override
  String get helpFaqAnswer6 =>
      'Sí. Usa \"Regenerar módulo\" dentro del módulo o \"Reconstruir plan\" en la tarjeta principal para pedir una versión nueva con tu estado más reciente.';

  @override
  String get helpFaqQuestion7 => '¿Puedo escuchar las lecciones?';

  @override
  String get helpFaqAnswer7 =>
      'Sí. Cada lección incluye un ícono de audio con texto a voz para escuchar el contenido mientras conduces, cocinas o entrenas.';

  @override
  String get helpFaqQuestion8 => '¿Cómo mantengo viva la racha diaria?';

  @override
  String get helpFaqAnswer8 =>
      'Completa al menos una lección o quiz por día; registramos la racha automáticamente cuando marcas una lección como completada.';

  @override
  String get helpFaqQuestion9 => '¿Qué ocurre si me quedo sin conexión?';

  @override
  String get helpFaqAnswer9 =>
      'Los módulos generados se guardan en caché local, así puedes reabrirlos sin conexión; al reconectarte sincronizamos el progreso pendiente.';

  @override
  String get helpFaqQuestion10 =>
      '¿Cómo se sincroniza mi progreso entre dispositivos?';

  @override
  String get helpFaqAnswer10 =>
      'Tu LearnerState vive en Firestore y lo escuchamos en tiempo real, por lo que visitas, desbloqueos y rachas se mantienen entre móvil, tablet o escritorio.';

  @override
  String get helpFaqQuestion11 => '¿De dónde salen las recomendaciones?';

  @override
  String get helpFaqAnswer11 =>
      'Combinamos tus búsquedas recientes con temas en tendencia en tu idioma; no existe contenido patrocinado.';

  @override
  String get helpFaqQuestion12 =>
      '¿Cómo reporto contenido incorrecto o pido ayuda?';

  @override
  String get helpFaqAnswer12 =>
      'En Ayuda y soporte toca Enviar correo o Reportar bug; adjuntamos el módulo, la versión y el dispositivo para responder rápido.';
}
