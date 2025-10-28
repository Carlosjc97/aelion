// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Aelion';

  @override
  String get loginTitle => 'Learn faster with AI';

  @override
  String get loginSubtitle => 'Your learning path in a few taps';

  @override
  String get loginHighlightPersonalized => 'Personalized outlines in minutes';

  @override
  String get loginHighlightStreak => 'Daily streaks keep you motivated';

  @override
  String get loginHighlightSync =>
      'Sync across web and Android with your Google account';

  @override
  String get loginButton => 'Sign in with Google';

  @override
  String get loginLoading => 'Connecting...';

  @override
  String get loginCancelled => 'Sign-in cancelled by the user';

  @override
  String get loginError => 'We could not complete the sign-in. Try again.';

  @override
  String get authCheckingSession => 'Checking your session...';

  @override
  String get authError => 'We could not verify your session';

  @override
  String get authRetry => 'Try again';

  @override
  String get homeGreeting => 'What do you want to learn today?';

  @override
  String homeGreetingNamedShort(String name) {
    return 'Hi $name 👋';
  }

  @override
  String get homeGreetingWave => 'Hello 👋';

  @override
  String get homeMotivation => 'Let\'s keep your learning streak going today.';

  @override
  String get homePromptTitle => 'What plan should we craft next?';

  @override
  String get homeInputHint =>
      'Example: Algebra in 7 days, conversational English...';

  @override
  String get homeSnackMissingTopic => 'Write a topic to continue';

  @override
  String get homeGenerate => 'Generate AI learning plan';

  @override
  String get homeShortcuts => 'Shortcuts';

  @override
  String get homeShortcutCourse => 'Take a course';

  @override
  String get homeShortcutCourseSubtitle => 'AI generated micro-courses';

  @override
  String get homeShortcutLanguage => 'Learn a language';

  @override
  String get homeShortcutLanguageSubtitle => 'Vocabulary and practical grammar';

  @override
  String get homeShortcutProblem => 'Solve a problem';

  @override
  String get homeShortcutProblemSubtitle => 'From question to guided plan';

  @override
  String get homeLogoutTooltip => 'Sign out';

  @override
  String get homeSignOutError => 'We could not sign you out. Try again.';

  @override
  String get homeUserFallback => 'Aelion user';

  @override
  String get homeUserNoEmail => 'No email';

  @override
  String get homeSuggestionMath => 'Math basics';

  @override
  String get homeSuggestionEnglish => 'Conversational English';

  @override
  String get homeSuggestionHistory => 'History of Rome';

  @override
  String get homePrefillCourse => 'Quick Flutter course';

  @override
  String get homePrefillLanguage => 'English in 1 month';

  @override
  String get homePrefillProblem => 'Solve integrals';

  @override
  String get notFoundRoute => 'Route not found';

  @override
  String get commonRetry => 'Retry';

  @override
  String get dialogContinue => 'Continue';

  @override
  String get quizTitle => 'Placement quiz';

  @override
  String quizHeaderTitle(String topic) {
    return 'Calibrate $topic';
  }

  @override
  String get quizIntroDescription =>
      'Take 10 quick questions to calibrate your plan.';

  @override
  String get startQuiz => 'Start';

  @override
  String quizQuestionCounter(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String quizTimeHint(int minutes) {
    return 'Approx. $minutes min';
  }

  @override
  String get quizAnswerAllPrompt => 'Answer every question before continuing.';

  @override
  String get quizExitTitle => 'Leave quiz?';

  @override
  String get quizExitMessage => 'Your answers will be lost.';

  @override
  String get quizExitCancel => 'Stay';

  @override
  String get quizExitConfirm => 'Leave';

  @override
  String get submit => 'Submit';

  @override
  String get next => 'Next';

  @override
  String quizResultTitle(String band) {
    return 'You are $band';
  }

  @override
  String quizLevelChip(String band) {
    return 'Level: $band';
  }

  @override
  String quizScorePercentage(int score) {
    return 'Score: $score%';
  }

  @override
  String quizRecommendRefine(String band) {
    return 'We will refine your plan for the $band level.';
  }

  @override
  String quizKeepCurrentPlan(String band) {
    return 'Your current plan already matches the $band level.';
  }

  @override
  String get quizDone => 'Done';

  @override
  String get quizUnknownError => 'We could not load the quiz. Try again.';

  @override
  String get quizBandBeginner => 'Beginner';

  @override
  String get quizBandIntermediate => 'Intermediate';

  @override
  String get quizBandAdvanced => 'Advanced';

  @override
  String get courseEntryTitle => 'Take a course';

  @override
  String get courseEntrySubtitle =>
      'Search a topic and launch a quick placement quiz.';

  @override
  String get courseEntryHint =>
      'Example: Flutter fundamentals, linear algebra, SQL...';

  @override
  String get courseEntryStart => 'Start quiz';

  @override
  String get courseEntryFooter =>
      'We keep placement quizzes short (10 questions).';

  @override
  String get courseEntryExampleFlutter => 'Intro to Flutter';

  @override
  String get courseEntryExampleSql => 'SQL for beginners';

  @override
  String get courseEntryExampleDataScience => 'Data science 101';

  @override
  String get courseEntryExampleLogic => 'Logic fundamentals';

  @override
  String courseEntryResultSummary(int score, String band) {
    return 'Score $score% - level $band';
  }

  @override
  String courseEntryResultActionUpdate(String band) {
    return 'Generating a new outline for the $band level.';
  }

  @override
  String courseEntryResultActionReuse(String band) {
    return 'Reusing your existing $band plan.';
  }

  @override
  String get outlineFallbackTitle => 'Outline';

  @override
  String get moduleOutlineFallbackTopic => 'Default topic';

  @override
  String get outlineUpdatePlan => 'Update plan';

  @override
  String get refinePlan => 'Refine plan';

  @override
  String outlineRefineRebuild(String band) {
    return 'New outline will match the $band level.';
  }

  @override
  String outlineRefineNoChanges(String band) {
    return 'Current outline already matches the $band level.';
  }

  @override
  String get outlineSnackCached => 'Loaded your saved plan.';

  @override
  String get outlineSnackUpdated => 'Plan ready with the latest updates.';

  @override
  String get outlineRefineChangeDepthTitle => 'Change depth';

  @override
  String get outlineRefineChangeDepthSubtitle =>
      'Reuse or generate outlines for intro, medium, or deep levels.';

  @override
  String get takePlacementQuiz => 'Take placement quiz';

  @override
  String get outlineRefinePlacementQuizSubtitle =>
      'Answer 10 questions to calibrate your plan.';

  @override
  String get outlineErrorGeneric => 'We could not load the outline.';

  @override
  String get outlineErrorEmpty => 'No outline available for this topic.';

  @override
  String get outlineErrorNoContent => 'No content available for this topic.';

  @override
  String get outlineSourceCached => 'Cached outline';

  @override
  String outlineSavedLabel(String timestamp) {
    return 'Saved $timestamp';
  }

  @override
  String get outlineStaleBadge => 'Stale';

  @override
  String outlineMetaBand(String band) {
    return 'Level: $band';
  }

  @override
  String outlineMetaLevel(String level) {
    return 'Level: $level';
  }

  @override
  String outlineMetaHours(int hours) {
    return '$hours hours';
  }

  @override
  String outlineMetaLanguage(String language) {
    return 'Language: $language';
  }

  @override
  String outlineMetaDepth(String depth) {
    return 'Depth: $depth';
  }

  @override
  String outlineLessonCount(int count) {
    return '$count lessons';
  }

  @override
  String outlineLessonLanguage(String language) {
    return 'Language: $language';
  }

  @override
  String outlineModuleFallback(int index) {
    return 'Module $index';
  }

  @override
  String outlineLessonFallback(int index) {
    return 'Lesson $index';
  }

  @override
  String homeGreetingNamed(String name) {
    return 'Hi $name, what do you want to learn today?';
  }

  @override
  String get homeRecentTitle => 'Recent plans';

  @override
  String get homeRecentEmpty => 'You have no saved plans yet.';

  @override
  String get homeRecentView => 'View outline';

  @override
  String homeRecentMoreCount(int count) {
    return '+$count more modules';
  }

  @override
  String homeRecentSaved(String timestamp) {
    return 'Saved $timestamp';
  }

  @override
  String get homeUpdatedJustNow => 'Updated just now';

  @override
  String homeUpdatedMinutes(int minutes) {
    return 'Updated $minutes min ago';
  }

  @override
  String homeUpdatedHours(int hours) {
    return 'Updated $hours h ago';
  }

  @override
  String homeUpdatedDays(int days) {
    return 'Updated $days d ago';
  }

  @override
  String get homeDepthIntro => 'Intro level';

  @override
  String get homeDepthMedium => 'Intermediate depth';

  @override
  String get homeDepthDeep => 'Deep dive';

  @override
  String buildExpertiseIn(Object topic) {
    return 'Build expertise in $topic';
  }

  @override
  String get depthIntro => 'introductory';

  @override
  String get depthMedium => 'intermediate';

  @override
  String get depthDeep => 'advanced';

  @override
  String get calibratingPlan => 'Calibrating your plan';

  @override
  String get planReady => 'Plan ready';

  @override
  String get homeRecommendationsTitle => 'Recommended';

  @override
  String get homeRecommendationsEmpty => 'No recommendations yet.';

  @override
  String get homeRecommendationsError => 'We could not load recommendations.';

  @override
  String quizCooldownMinutes(Object minutes) {
    return 'Please wait $minutes more minute(s) before retaking the quiz.';
  }

  @override
  String get quizCooldownSeconds =>
      'Please wait a few seconds before retaking the quiz.';

  @override
  String get quizOpenPlan => 'Open plan';

  @override
  String get quizApplyResults => 'Apply results';

  @override
  String get quizResultsNoChanges => 'Results saved without changes.';

  @override
  String get planAlreadyAligned => 'Your plan is already aligned.';

  @override
  String lessonCompleteToast(int xp) {
    return 'Lesson completed! XP total: $xp';
  }

  @override
  String lessonXpReward(int xp) {
    return '+$xp XP';
  }

  @override
  String get lessonUpdateError => 'We couldn\'t update the lesson. Try again.';

  @override
  String get lessonPremiumContent => 'Premium content';

  @override
  String get lessonDescriptionTitle => 'Description';

  @override
  String get lessonMarkCompleted => 'Mark lesson as completed';

  @override
  String get lessonTipTakeNotes => 'Tip: take quick notes before moving on.';

  @override
  String get lessonFallbackTitle => 'Lesson';

  @override
  String get lessonObjectiveTitle => 'Lesson objective';

  @override
  String get lessonObjectiveSummary =>
      '• Understand the core concept.\n• Complete a short practice.\n• Move on once you feel ready.';

  @override
  String get lessonQuizTitle => 'Question';

  @override
  String lessonQuizOption(String letter, String option) {
    return '$letter) $option';
  }

  @override
  String get lessonQuizCheck => 'Check answer';

  @override
  String get lessonQuizCorrect => '✅ Correct!';

  @override
  String lessonQuizIncorrect(String answer) {
    return '❌ Incorrect. The answer was $answer.';
  }

  @override
  String get lessonTipReview =>
      'Tip: if something is unclear, reread and practice for 2 more minutes before moving on.';

  @override
  String get lessonContentComingSoon => 'Content available soon.';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSaving => 'Saving...';

  @override
  String get homeGenerateError => 'We could not generate the plan. Try again.';

  @override
  String get topicSearchMissingTopic => 'Type a topic to continue';

  @override
  String get topicSearchTitleFallback => 'Search a topic';

  @override
  String get topicSearchHintFallback => 'What do you want to learn?';

  @override
  String get topicSearchStartButton => 'Take mini quiz';

  @override
  String get quizPlanCreated => 'Plan created.';
}
