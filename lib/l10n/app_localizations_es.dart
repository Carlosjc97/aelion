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
    return 'Nivel detectado: $level';
  }

  @override
  String assessmentResultPercentile(int percentile) {
    return 'Obtuviste mejor puntaje que el $percentile% de los aprendices';
  }

  @override
  String get assessmentResultStrengthsTitle => 'Fortalezas';

  @override
  String get assessmentResultGapsTitle => 'Áreas de mejora';

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
      'Creada con Flutter y Firebase; todo el contenido se genera mediante Cloud Functions seguras.';

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
    return 'Solicitud de soporte $appName (v$version · $device)';
  }

  @override
  String helpBugReportSubject(String appName, String version, String device) {
    return 'Reporte de bug $appName (v$version · $device)';
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
  String get helpFaqQuestion1 => '¿Cómo genero mi primer plan de aprendizaje?';

  @override
  String get helpFaqAnswer1 =>
      'En la pantalla Inicio, escribe un tema y toca Generar plan con IA.';

  @override
  String get helpFaqQuestion2 => '¿Dónde encuentro mis planes recientes?';

  @override
  String get helpFaqAnswer2 =>
      'Desplázate a Recientes en Inicio; cada tarjeta abre el plan guardado.';

  @override
  String get helpFaqQuestion3 => '¿Cómo se eligen los temas en tendencia?';

  @override
  String get helpFaqAnswer3 =>
      'Combinamos tus últimas búsquedas con solicitudes populares en tu idioma.';

  @override
  String get helpFaqQuestion4 => '¿Qué es un quiz de colocación?';

  @override
  String get helpFaqAnswer4 =>
      'Es una calibración de 10 preguntas que define el nivel adecuado antes del plan.';

  @override
  String get helpFaqQuestion5 =>
      '¿Puedo cambiar la profundidad del plan después?';

  @override
  String get helpFaqAnswer5 =>
      'Abre el plan, toca Refinar plan y elige la profundidad que se ajuste a tu meta.';

  @override
  String get helpFaqQuestion6 => '¿Cómo cambio el idioma del plan?';

  @override
  String get helpFaqAnswer6 =>
      'Genera nuevamente tras elegir tu idioma preferido en el quiz o en el prompt.';

  @override
  String get helpFaqQuestion7 => '¿Qué sucede si pierdo la conexión?';

  @override
  String get helpFaqAnswer7 =>
      'Los planes y recientes en caché siguen disponibles; las nuevas generaciones esperan a que vuelvas a estar en línea.';

  @override
  String get helpFaqQuestion8 => '¿Cómo se guarda mi progreso?';

  @override
  String get helpFaqAnswer8 =>
      'Guardamos metadatos y planes en caché de forma segura en tu dispositivo con SharedPreferences.';

  @override
  String get helpFaqQuestion9 => '¿Cómo cierro sesión de forma segura?';

  @override
  String get helpFaqAnswer9 =>
      'Usa el icono de salida en la barra superior; cierra sesión en Firebase y en Google en móviles.';

  @override
  String get helpFaqQuestion10 => '¿Cómo cambio de cuenta de Google?';

  @override
  String get helpFaqAnswer10 =>
      'Cierra sesión y elige la otra cuenta cuando aparezca la hoja de inicio de sesión de Google.';

  @override
  String get helpFaqQuestion11 => '¿Cómo borro mis búsquedas recientes?';

  @override
  String get helpFaqAnswer11 =>
      'El historial se limita a las últimas entradas por cuenta y se limpia automáticamente al cerrar sesión.';

  @override
  String get helpFaqQuestion12 => '¿Qué datos guardan en Firestore?';

  @override
  String get helpFaqAnswer12 =>
      'Solo registros anonimizados de planes en caché y métricas de observabilidad creadas por Functions.';

  @override
  String get helpFaqQuestion13 => '¿Cómo reporto contenido incorrecto?';

  @override
  String get helpFaqAnswer13 =>
      'Usa el botón Reportar un error y describe lo que debemos corregir.';

  @override
  String get helpFaqQuestion14 => '¿De dónde salen las recomendaciones?';

  @override
  String get helpFaqAnswer14 =>
      'Mezclan demanda agregada con tu actividad reciente para mostrar temas relevantes.';

  @override
  String get helpFaqQuestion15 => '¿Puedo regenerar un plan después del quiz?';

  @override
  String get helpFaqAnswer15 =>
      'Sí. Al aplicar los resultados se reconstruye el plan con el nuevo nivel.';

  @override
  String get helpFaqQuestion16 =>
      '¿Cuánto tiempo se conservan los planes en caché?';

  @override
  String get helpFaqAnswer16 =>
      'Permanecen hasta que los reemplazas o borras la memoria; la etiqueta Caducado aparece tras 24 horas.';

  @override
  String get helpFaqQuestion17 => '¿Por qué me piden rehacer el quiz?';

  @override
  String get helpFaqAnswer17 =>
      'Lo sugerimos cuando tu nivel parece desactualizado o la caché supera su ventana de vigencia.';

  @override
  String get helpFaqQuestion18 => '¿Puedo usar la app en varios dispositivos?';

  @override
  String get helpFaqAnswer18 =>
      'Sí. Inicia sesión con la misma cuenta de Google en web o Android para mantener la sincronización.';

  @override
  String get helpFaqQuestion19 => '¿La app soporta modo oscuro?';

  @override
  String get helpFaqAnswer19 =>
      'Seguimos el tema del sistema y mantenemos el contraste dentro de las guías de accesibilidad.';

  @override
  String get helpFaqQuestion20 => '¿Cómo reinicio mi racha de aprendizaje?';

  @override
  String get helpFaqAnswer20 =>
      'Borra los datos locales desde los ajustes del sistema o inicia sesión con una cuenta nueva.';

  @override
  String get helpFaqQuestion21 => '¿Cómo solicito una nueva función?';

  @override
  String get helpFaqAnswer21 =>
      'Envía tu idea por el correo de soporte en inglés y añade \'Feature idea\' en el mensaje.';

  @override
  String get helpFaqQuestion22 => '¿Necesito una cuenta para usar la app?';

  @override
  String get helpFaqAnswer22 =>
      'Sí, usamos autenticación de Google para proteger tu contenido y personalización.';

  @override
  String get helpFaqQuestion23 => '¿Qué pasa si cierro la app durante un quiz?';

  @override
  String get helpFaqAnswer23 =>
      'Puedes reiniciar el quiz cuando quieras; el progreso se reinicia para calibrar correctamente.';

  @override
  String get helpFaqQuestion24 => '¿Cómo elimino los planes en caché?';

  @override
  String get helpFaqAnswer24 =>
      'Los planes en caché viven en tu dispositivo; desinstala o borra los datos de la app para quitarlos.';

  @override
  String get helpFaqQuestion25 =>
      '¿Comparten mis datos personales con terceros?';

  @override
  String get helpFaqAnswer25 =>
      'No. Solo usamos telemetría agregada para confiabilidad y nunca vendemos información personal.';

  @override
  String get helpFaqQuestion26 => '¿Puedo usar la app sin Firebase Functions?';

  @override
  String get helpFaqAnswer26 =>
      'No. El acceso directo a Firestore está bloqueado; todas las solicitudes pasan por Functions seguras.';

  @override
  String get helpFaqQuestion27 => '¿Por qué veo la etiqueta Caducado?';

  @override
  String get helpFaqAnswer27 =>
      'Indica que el plan en caché pasó el umbral de frescura y conviene regenerarlo.';

  @override
  String get helpFaqQuestion28 => '¿Cómo me uno a la comunidad?';

  @override
  String get helpFaqAnswer28 =>
      'Toca Unirte a la comunidad para abrir el canal o el chat en Telegram.';

  @override
  String get helpFaqQuestion29 => '¿Cómo reviso la versión de la app?';

  @override
  String get helpFaqAnswer29 =>
      'Abre Ayuda y soporte y desplázate a Acerca de; ahí verás el número de versión.';

  @override
  String get helpFaqQuestion30 =>
      '¿Puedo ejecutar la app con emuladores locales?';

  @override
  String get helpFaqAnswer30 =>
      'Sí. Ajusta USE_FUNCTIONS_EMULATOR=true en env.public y arranca los emuladores de Firebase.';

  @override
  String get helpFaqQuestion31 => '¿Cómo contacto soporte en español?';

  @override
  String get helpFaqAnswer31 =>
      'Usa el botón de correo en español; llega directo a nuestro equipo hispanohablante.';

  @override
  String get helpFaqQuestion32 => '¿Cuánto tardan en responder?';

  @override
  String get helpFaqAnswer32 =>
      'Buscamos responder en un día hábil y normalmente lo hacemos antes.';

  @override
  String get helpFaqQuestion33 => '¿Qué datos ayudan en un reporte de errores?';

  @override
  String get helpFaqAnswer33 =>
      'Incluye la marca de tiempo, tu localidad, versión de la app, dispositivo y pasos para reproducir.';

  @override
  String get helpFaqQuestion34 => '¿Cómo obtengo la versión más reciente?';

  @override
  String get helpFaqAnswer34 =>
      'Actualiza desde tu tienda de apps o haz pull de la rama main si contribuyes al proyecto.';

  @override
  String get helpFaqQuestion35 =>
      '¿Dónde leo la política de privacidad y los términos?';

  @override
  String get helpFaqAnswer35 =>
      'Sigue los enlaces de Política de privacidad y Términos de servicio en la sección Acerca de.';

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
}
