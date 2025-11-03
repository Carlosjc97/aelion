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
    return 'Hi $name';
  }

  @override
  String get homeGreetingWave => 'Hello';

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

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get helpSupportSubtitle =>
      'Answers, contact options, and community links.';

  @override
  String get helpFaqSectionTitle => 'Frequently asked questions';

  @override
  String get helpCommunitySectionTitle => 'Community';

  @override
  String get helpContactSectionTitle => 'Contact options';

  @override
  String get helpJoinCommunity => 'Join Community';

  @override
  String get helpJoinCommunityDescription =>
      'Choose how you want to connect with other learners.';

  @override
  String get helpJoinCommunityDialogTitle => 'Open Telegram';

  @override
  String get helpJoinCommunityChannel => 'News channel';

  @override
  String get helpJoinCommunityGroup => 'Community chat';

  @override
  String get helpContactSpanish => 'Email support (ES)';

  @override
  String get helpContactSpanishDescription =>
      'Reach our Spanish-speaking agents.';

  @override
  String get helpContactEnglish => 'Email support (EN)';

  @override
  String get helpContactEnglishDescription =>
      'Get help in English from the core team.';

  @override
  String get helpReportBug => 'Report a bug';

  @override
  String get helpReportBugDescription =>
      'Include screenshots or steps if possible.';

  @override
  String get helpAboutTitle => 'About this app';

  @override
  String get helpAboutDescription =>
      'Built with Flutter and Firebase; all content is generated via secure Cloud Functions.';

  @override
  String get helpPrivacyPolicy => 'Privacy Policy';

  @override
  String get helpTermsOfService => 'Terms of Service';

  @override
  String get helpLaunchError => 'We couldn\'t open the link. Please try again.';

  @override
  String get homeOverflowHelpSupport => 'Help & Support';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsHelpSupport => 'Help & Support';

  @override
  String get settingsHelpSupportSubtitle => 'FAQs, contact, and policies';

  @override
  String helpEmailSubject(String appName, String version, String device) {
    return '$appName support request (v$version · $device)';
  }

  @override
  String helpBugReportSubject(String appName, String version, String device) {
    return '$appName bug report (v$version · $device)';
  }

  @override
  String helpBugReportBody(
      String timestamp, String locale, String version, String device) {
    return 'Timestamp: $timestamp\nLocale: $locale\nVersion: $version\nDevice: $device\n\nSteps to reproduce:\n- ';
  }

  @override
  String helpAboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get helpFaqQuestion1 => 'How do I generate my first learning plan?';

  @override
  String get helpFaqAnswer1 =>
      'On the Home screen, enter a topic and tap Generate AI learning plan.';

  @override
  String get helpFaqQuestion2 => 'Where can I find my recent outlines?';

  @override
  String get helpFaqAnswer2 =>
      'Scroll to the Recents section on Home; each card reopens the saved outline instantly.';

  @override
  String get helpFaqQuestion3 => 'How are trending topics selected?';

  @override
  String get helpFaqAnswer3 =>
      'We mix your latest searches with popular requests in your language to suggest new ideas.';

  @override
  String get helpFaqQuestion4 => 'What is a placement quiz?';

  @override
  String get helpFaqAnswer4 =>
      'It is a 10-question calibration that sets the right level before we build a tailored plan.';

  @override
  String get helpFaqQuestion5 => 'Can I change the depth of a plan later?';

  @override
  String get helpFaqAnswer5 =>
      'Open the outline, tap Refine plan, and select the depth that matches your goal.';

  @override
  String get helpFaqQuestion6 => 'How do I switch the outline language?';

  @override
  String get helpFaqAnswer6 =>
      'Generate again after choosing your preferred language in the quiz or topic prompt.';

  @override
  String get helpFaqQuestion7 => 'What happens if I lose connection?';

  @override
  String get helpFaqAnswer7 =>
      'Cached outlines and recents stay available offline; new generations wait until you are online.';

  @override
  String get helpFaqQuestion8 => 'How is my progress saved?';

  @override
  String get helpFaqAnswer8 =>
      'Metadata and cached outlines are stored securely on your device via SharedPreferences.';

  @override
  String get helpFaqQuestion9 => 'How do I sign out safely?';

  @override
  String get helpFaqAnswer9 =>
      'Use the logout icon on the Home app bar; it signs you out of Firebase and Google on mobile.';

  @override
  String get helpFaqQuestion10 => 'How do I switch Google accounts?';

  @override
  String get helpFaqAnswer10 =>
      'Sign out first, then pick the other account when the Google sign-in sheet appears.';

  @override
  String get helpFaqQuestion11 => 'How can I clear my recent searches?';

  @override
  String get helpFaqAnswer11 =>
      'Search history is capped to the latest entries per account and is cleared automatically when you sign out.';

  @override
  String get helpFaqQuestion12 => 'What data do you store in Firestore?';

  @override
  String get helpFaqAnswer12 =>
      'Only anonymized outline cache entries and observability metrics generated by Cloud Functions.';

  @override
  String get helpFaqQuestion13 => 'How do I report incorrect content?';

  @override
  String get helpFaqAnswer13 =>
      'Use the Report a bug button below and describe what needs to be fixed.';

  @override
  String get helpFaqQuestion14 => 'Where do recommendations come from?';

  @override
  String get helpFaqAnswer14 =>
      'They combine aggregated demand with your recent activity to surface relevant topics.';

  @override
  String get helpFaqQuestion15 =>
      'Can I regenerate a plan after finishing a quiz?';

  @override
  String get helpFaqAnswer15 =>
      'Yes. Applying quiz results automatically rebuilds the outline with the new band.';

  @override
  String get helpFaqQuestion16 => 'How long are cached outlines kept?';

  @override
  String get helpFaqAnswer16 =>
      'They remain until you replace them or clear storage; stale badges appear after 24 hours.';

  @override
  String get helpFaqQuestion17 => 'Why was I asked to retake the quiz?';

  @override
  String get helpFaqAnswer17 =>
      'We prompt a retake when your level looks outdated or the cache exceeded its freshness window.';

  @override
  String get helpFaqQuestion18 => 'Can I use the app on multiple devices?';

  @override
  String get helpFaqAnswer18 =>
      'Yes. Sign in with the same Google account on web or Android to stay in sync.';

  @override
  String get helpFaqQuestion19 => 'Does the app support dark mode?';

  @override
  String get helpFaqAnswer19 =>
      'The interface follows your system theme and keeps contrast within accessibility guidelines.';

  @override
  String get helpFaqQuestion20 => 'How do I reset my learning streak?';

  @override
  String get helpFaqAnswer20 =>
      'Clear local data from system settings or sign in with a new account.';

  @override
  String get helpFaqQuestion21 => 'How can I request a new feature?';

  @override
  String get helpFaqAnswer21 =>
      'Send your idea through the English support email and include Feature idea in the message.';

  @override
  String get helpFaqQuestion22 => 'Do I need an account to use the app?';

  @override
  String get helpFaqAnswer22 =>
      'Yes, Google authentication protects your content and enables personalization.';

  @override
  String get helpFaqQuestion23 =>
      'What happens if I close the app during a quiz?';

  @override
  String get helpFaqAnswer23 =>
      'You can restart the quiz anytime; progress resets to keep the calibration accurate.';

  @override
  String get helpFaqQuestion24 => 'How do I delete cached outlines?';

  @override
  String get helpFaqAnswer24 =>
      'Cached outlines live only on your device; uninstalling or clearing the app data removes them.';

  @override
  String get helpFaqQuestion25 =>
      'Is my personal data shared with third parties?';

  @override
  String get helpFaqAnswer25 =>
      'No. We only use aggregate telemetry for reliability and never sell personal information.';

  @override
  String get helpFaqQuestion26 =>
      'Can I use the app without Firebase Functions?';

  @override
  String get helpFaqAnswer26 =>
      'No. Direct Firestore access is blocked; all requests go through secure HTTPS Functions.';

  @override
  String get helpFaqQuestion27 => 'Why do I see a stale badge?';

  @override
  String get helpFaqAnswer27 =>
      'It means the cached outline is older than the freshness threshold and should be regenerated.';

  @override
  String get helpFaqQuestion28 => 'How do I join the community?';

  @override
  String get helpFaqAnswer28 =>
      'Tap Join Community to open the Telegram news channel or chat group.';

  @override
  String get helpFaqQuestion29 => 'How do I check the app version?';

  @override
  String get helpFaqAnswer29 =>
      'Open Help & Support and scroll to About; the version number is listed there.';

  @override
  String get helpFaqQuestion30 => 'Can I run the app with local emulators?';

  @override
  String get helpFaqAnswer30 =>
      'Yes. Set USE_FUNCTIONS_EMULATOR=true in env.public and start the Firebase emulators.';

  @override
  String get helpFaqQuestion31 => 'How do I contact support in Spanish?';

  @override
  String get helpFaqAnswer31 =>
      'Use the Spanish email button; it routes directly to our Spanish-speaking support team.';

  @override
  String get helpFaqQuestion32 => 'How quickly does support respond?';

  @override
  String get helpFaqAnswer32 =>
      'We aim to reply within one business day and usually respond much sooner.';

  @override
  String get helpFaqQuestion33 => 'What details help with a bug report?';

  @override
  String get helpFaqAnswer33 =>
      'Include the timestamp, locale, app version, device, and clear reproduction steps.';

  @override
  String get helpFaqQuestion34 => 'How do I get the latest release?';

  @override
  String get helpFaqAnswer34 =>
      'Install updates from your app store or pull the main branch if you are contributing.';

  @override
  String get helpFaqQuestion35 =>
      'Where can I read the privacy policy and terms?';

  @override
  String get helpFaqAnswer35 =>
      'Use the Privacy Policy and Terms of Service links in the About section.';
}
