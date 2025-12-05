// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Edaptia';

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
  String get homeTitle => 'Home';

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
  String get startCalibration => 'Discover your level';

  @override
  String get module1Free => 'Module 1 FREE';

  @override
  String get unlockPremium => 'Unlock Premium';

  @override
  String get perMonth => '/month';

  @override
  String get gateQuizPassed => 'You passed! You can continue.';

  @override
  String get gateQuizFailed => 'You need 70% to advance.';

  @override
  String get gateQuizReviewTopics => 'Review these topics:';

  @override
  String get gateQuizRetry => 'Try again';

  @override
  String get gatePracticeUnlocked =>
      'Practice mode unlocked! Use these hints before retrying.';

  @override
  String get gatePracticeLocked =>
      'Practice mode unlocks after 3 attempts. Keep going!';

  @override
  String get gatePracticeHintsTitle => 'Try these mini missions:';

  @override
  String gatePracticeAttempts(int count, int total) {
    return 'Attempts used: $count/$total';
  }

  @override
  String get modulePremiumContent => 'Premium content';

  @override
  String modulePremiumUnlock(int moduleNumber) {
    return 'Unlock module $moduleNumber by starting your free trial.';
  }

  @override
  String get modulePremiumButton => 'Unlock with Premium';

  @override
  String get moduleGatePending => 'Module quiz pending';

  @override
  String moduleGateRequired(int moduleNumber) {
    return 'Pass the module $moduleNumber quiz (>=70%) to advance.';
  }

  @override
  String get moduleGateTake => 'Take module quiz';

  @override
  String get homeEnglishComingTitle => 'Early Access';

  @override
  String get homeEnglishComingSubtitle =>
      'Be the first to try new features and suggest improvements';

  @override
  String get homeEnglishNotifyCta => 'Notify me';

  @override
  String get homeEnglishNotifyDone => 'Already registered';

  @override
  String get homeEnglishNotifySuccess =>
      'You\'ll be notified when Technical English launches!';

  @override
  String get homeEnglishNotifyError => 'Could not register notification';

  @override
  String assessmentResultTitle(String level) {
    return 'Your level: $level';
  }

  @override
  String assessmentResultLevelLabel(String level) {
    return 'Your level: $level';
  }

  @override
  String assessmentResultPercentile(int percentile) {
    return 'You scored better than $percentile% of learners';
  }

  @override
  String get assessmentResultStrengthsTitle => 'Strengths';

  @override
  String get assessmentResultGapsTitle => 'Areas to improve';

  @override
  String get assessmentResultPlanTitle => 'Suggested plan';

  @override
  String get assessmentResultShare => 'Share results';

  @override
  String get assessmentResultCta => 'Generate my learning plan';

  @override
  String assessmentResultShareMessage(String topic, String level, int score) {
    return 'I just completed my $topic assessment on Edaptia! Level: $level, Score: $score%';
  }

  @override
  String get assessmentResultClose => 'Close';

  @override
  String get assessmentResultResponsesTitle => 'Your answers';

  @override
  String get settingsLanguageTitle => 'App Language';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get homeLogoutTooltip => 'Sign out';

  @override
  String get homeSignOutError => 'We could not sign you out. Try again.';

  @override
  String get homeUserFallback => 'Edaptia user';

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
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get onboardingTitle => 'Tell us about you';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingProgressLabel => 'Question';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start learning';

  @override
  String get onboardingSelectLabel => 'Select an option';

  @override
  String get onboardingQuestionAge => 'What\'s your age range?';

  @override
  String get onboardingQuestionInterests => 'Which topics interest you?';

  @override
  String get onboardingQuestionEducation =>
      'What\'s your education background?';

  @override
  String get onboardingQuestionFirstSql =>
      'Is this your first time learning SQL?';

  @override
  String get onboardingQuestionBeta => 'Do you want to be a beta tester?';

  @override
  String get onboardingAge18_24 => '18-24';

  @override
  String get onboardingAge25_34 => '25-34';

  @override
  String get onboardingAge35_44 => '35-44';

  @override
  String get onboardingAge45Plus => '45+';

  @override
  String get onboardingInterestSql => 'SQL';

  @override
  String get onboardingInterestPython => 'Python';

  @override
  String get onboardingInterestExcel => 'Excel';

  @override
  String get onboardingInterestData => 'Data analysis';

  @override
  String get onboardingInterestMarketing => 'Marketing';

  @override
  String get onboardingEducationSecondary => 'High school';

  @override
  String get onboardingEducationUniversity => 'University';

  @override
  String get onboardingEducationPostgrad => 'Postgraduate';

  @override
  String get onboardingEducationSelfTaught => 'Self-taught';

  @override
  String get onboardingBetaDescription =>
      'Edaptia is in active development. As a beta tester:\\n• You get updates before everyone else\\n• You unlock experimental features\\n• Your feedback helps us improve';

  @override
  String get onboardingBetaOptIn => 'Yes, I want to be a beta tester';

  @override
  String get onboardingError =>
      'We couldn\'t save your answers. Please try again.';

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
  String get quizNext => 'Next';

  @override
  String get quizSubmit => 'Submit';

  @override
  String get quizContinue => 'Continue';

  @override
  String get quizUnknownError => 'We could not load the quiz. Try again.';

  @override
  String get quizBandBasic => 'Basic';

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
  String get lessonQuizCorrect => 'âœ… Correct!';

  @override
  String lessonQuizIncorrect(String answer) {
    return 'âŒ Incorrect. The answer was $answer.';
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
      'Built with Flutter, Firebase Cloud Functions, and OpenAI; adaptive content is generated securely on demand.';

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
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySubtitle => 'How we handle your data';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsTermsOfServiceSubtitle => 'App usage conditions';

  @override
  String helpEmailSubject(String appName, String version, String device) {
    return '$appName support request (v$version Â· $device)';
  }

  @override
  String helpBugReportSubject(String appName, String version, String device) {
    return '$appName bug report (v$version Â· $device)';
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
  String get adaptiveFlowCta => 'Adaptive flow';

  @override
  String get adaptiveFlowTitle => 'Adaptive journey';

  @override
  String get adaptiveFlowLoading => 'Loading adaptive plan...';

  @override
  String get adaptiveFlowError =>
      'We couldn\'t load the adaptive plan. Try again.';

  @override
  String get adaptiveFlowNoPlan =>
      'No adaptive plan yet. Generate one to get started.';

  @override
  String get adaptiveFlowLearnerState => 'Learner state';

  @override
  String get adaptiveFlowPlanSection => 'Suggested modules';

  @override
  String get adaptiveFlowModuleSection => 'Module';

  @override
  String get adaptiveFlowCheckpointSection => 'Checkpoint';

  @override
  String get adaptiveFlowBoosterSection => 'Booster';

  @override
  String get adaptiveFlowGenerateModule => 'Generate module';

  @override
  String get adaptiveFlowGenerateCheckpoint => 'Create checkpoint';

  @override
  String get adaptiveFlowSubmitAnswers => 'Evaluate checkpoint';

  @override
  String get adaptiveFlowBoosterCta => 'Request booster';

  @override
  String adaptiveFlowWeakSkills(String skills) {
    return 'Weak skills: $skills';
  }

  @override
  String adaptiveFlowScoreLabel(int score) {
    return 'Score: $score%';
  }

  @override
  String get adaptiveFlowActionAdvance => 'Great! Advance to the next module.';

  @override
  String get adaptiveFlowActionBooster =>
      'Booster recommended before moving on.';

  @override
  String get adaptiveFlowActionReplan =>
      'Repeating this module with more scaffolding.';

  @override
  String get adaptiveFlowCheckpointMissingSelection =>
      'Select an answer for each question.';

  @override
  String get adaptiveFlowEmptySkills => 'No skills tracked yet.';

  @override
  String adaptiveFlowDurationLabel(int minutes) {
    return 'Duration: $minutes min';
  }

  @override
  String adaptiveFlowSkillsLabel(String skills) {
    return 'Skills: $skills';
  }

  @override
  String adaptiveFlowLockedModule(String module) {
    return 'Complete module $module to unlock this one.';
  }

  @override
  String get adaptiveFlowLockedPremium => 'Unlock Premium to keep advancing.';

  @override
  String get helpFaqQuestion1 => 'How do I start my first adaptive journey?';

  @override
  String get helpFaqAnswer1 =>
      'On Home enter a topic, tap Generate plan, finish the placement quiz, and we open your adaptive journey with the first module immediately.';

  @override
  String get helpFaqQuestion2 => 'What does the placement quiz calibrate?';

  @override
  String get helpFaqAnswer2 =>
      'The 10-question assessment sets your level (basic, intermediate, or advanced) and surfaces weak skills so every module focuses on what you need.';

  @override
  String get helpFaqQuestion3 => 'When does the next module unlock?';

  @override
  String get helpFaqAnswer3 =>
      'After you visit every lesson and pass the module quiz, the next module unlocks automatically and the timeline refreshes in real time.';

  @override
  String get helpFaqQuestion4 => 'How are modules generated?';

  @override
  String get helpFaqAnswer4 =>
      'Each module is produced through our Cloud Functions + OpenAI pipeline; we enforce a 12-lesson structure and validate the schema before caching it.';

  @override
  String get helpFaqQuestion5 => 'How do checkpoints and boosters work?';

  @override
  String get helpFaqAnswer5 =>
      'Once you finish a module you can generate a checkpoint quiz or a booster; both reuse your weak skills to give fresh exercises before advancing.';

  @override
  String get helpFaqQuestion6 =>
      'Can I regenerate a module or the entire plan?';

  @override
  String get helpFaqAnswer6 =>
      'Use ?Regenerate module? inside the module tile or ?Rebuild plan? from the plan card to request a new version with your latest learner state.';

  @override
  String get helpFaqQuestion7 => 'Can I listen to lessons?';

  @override
  String get helpFaqAnswer7 =>
      'Yes. Every lesson includes a speaker icon powered by text-to-speech so you can keep learning while driving, cooking, or exercising.';

  @override
  String get helpFaqQuestion8 => 'How do I keep my daily streak alive?';

  @override
  String get helpFaqAnswer8 =>
      'Complete at least one lesson or module quiz per day; the app records the streak automatically the moment you mark a lesson as completed.';

  @override
  String get helpFaqQuestion9 => 'What happens if I go offline?';

  @override
  String get helpFaqAnswer9 =>
      'Previously generated modules stay in the local cache, so you can reopen them offline; as soon as you regain connection we sync pending progress.';

  @override
  String get helpFaqQuestion10 => 'How is progress synced across devices?';

  @override
  String get helpFaqAnswer10 =>
      'Your LearnerState lives in Firestore and we listen to it in real time, so visits, unlocks, and streaks stay consistent across phone, tablet, or desktop.';

  @override
  String get helpFaqQuestion11 => 'Where do recommendations come from?';

  @override
  String get helpFaqAnswer11 =>
      'We mix your latest searches with trending topics in your locale; nothing is sponsored or manually curated.';

  @override
  String get helpFaqQuestion12 =>
      'How do I report inaccurate content or get help?';

  @override
  String get helpFaqAnswer12 =>
      'Open Help & Support and tap Email support or Report bug; we attach the module, version, and device info so the team can respond quickly.';

  @override
  String get aiDisclaimerGenerating =>
      'AI-generated content. May contain inaccuracies.';

  @override
  String get aiDisclaimerQuiz =>
      'Questions are AI-generated based on module content.';

  @override
  String get aiDisclaimerPowered => 'AI-powered personalized content';

  @override
  String get aiAboutTitle => 'About AI';

  @override
  String get aiAboutSubtitle => 'How we use artificial intelligence';

  @override
  String get aiAboutDialogIntro =>
      'We use OpenAI GPT-4 to personalize your plans, modules, and quizzes in real time.';

  @override
  String get aiAboutDialogBulletModules =>
      '- Modules and lessons adapt to your skill level.';

  @override
  String get aiAboutDialogBulletQuizzes =>
      '- Quizzes, checkpoints, and boosters are generated from your progress.';

  @override
  String get aiAboutDialogBulletRecommendations =>
      '- Recommendations reflect your goals and recent activity.';

  @override
  String get aiAboutDialogTransparencyTitle => 'Transparency';

  @override
  String get aiAboutDialogTransparencyBody =>
      'AI may still produce mistakes or bias even with guardrails. Double-check important information.';

  @override
  String get aiAboutDialogPrivacyTitle => 'Privacy';

  @override
  String get aiAboutDialogPrivacyBody =>
      'Your prompts are sent securely to OpenAI for processing. We do not sell your data, and you can email privacy@edaptia.io to export or delete your account.';
}
