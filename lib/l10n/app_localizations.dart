import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Edaptia'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn faster with AI'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your learning path in a few taps'**
  String get loginSubtitle;

  /// No description provided for @loginHighlightPersonalized.
  ///
  /// In en, this message translates to:
  /// **'Personalized outlines in minutes'**
  String get loginHighlightPersonalized;

  /// No description provided for @loginHighlightStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily streaks keep you motivated'**
  String get loginHighlightStreak;

  /// No description provided for @loginHighlightSync.
  ///
  /// In en, this message translates to:
  /// **'Sync across web and Android with your Google account'**
  String get loginHighlightSync;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginButton;

  /// No description provided for @loginLoading.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get loginLoading;

  /// No description provided for @loginCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in cancelled by the user'**
  String get loginCancelled;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'We could not complete the sign-in. Try again.'**
  String get loginError;

  /// No description provided for @authCheckingSession.
  ///
  /// In en, this message translates to:
  /// **'Checking your session...'**
  String get authCheckingSession;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'We could not verify your session'**
  String get authError;

  /// No description provided for @authRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get authRetry;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'What do you want to learn today?'**
  String get homeGreeting;

  /// No description provided for @homeGreetingNamedShort.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}'**
  String homeGreetingNamedShort(String name);

  /// No description provided for @homeGreetingWave.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeGreetingWave;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeMotivation.
  ///
  /// In en, this message translates to:
  /// **'Let\'s keep your learning streak going today.'**
  String get homeMotivation;

  /// No description provided for @homePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'What plan should we craft next?'**
  String get homePromptTitle;

  /// No description provided for @homeInputHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Algebra in 7 days, conversational English...'**
  String get homeInputHint;

  /// No description provided for @homeSnackMissingTopic.
  ///
  /// In en, this message translates to:
  /// **'Write a topic to continue'**
  String get homeSnackMissingTopic;

  /// No description provided for @homeGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate AI learning plan'**
  String get homeGenerate;

  /// No description provided for @homeShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get homeShortcuts;

  /// No description provided for @homeShortcutCourse.
  ///
  /// In en, this message translates to:
  /// **'Take a course'**
  String get homeShortcutCourse;

  /// No description provided for @homeShortcutCourseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI generated micro-courses'**
  String get homeShortcutCourseSubtitle;

  /// No description provided for @homeShortcutLanguage.
  ///
  /// In en, this message translates to:
  /// **'Learn a language'**
  String get homeShortcutLanguage;

  /// No description provided for @homeShortcutLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary and practical grammar'**
  String get homeShortcutLanguageSubtitle;

  /// No description provided for @homeShortcutProblem.
  ///
  /// In en, this message translates to:
  /// **'Solve a problem'**
  String get homeShortcutProblem;

  /// No description provided for @homeShortcutProblemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From question to guided plan'**
  String get homeShortcutProblemSubtitle;

  /// No description provided for @startCalibration.
  ///
  /// In en, this message translates to:
  /// **'Discover your level'**
  String get startCalibration;

  /// No description provided for @module1Free.
  ///
  /// In en, this message translates to:
  /// **'Module 1 FREE'**
  String get module1Free;

  /// No description provided for @unlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get unlockPremium;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @gateQuizPassed.
  ///
  /// In en, this message translates to:
  /// **'You passed! You can continue.'**
  String get gateQuizPassed;

  /// No description provided for @gateQuizFailed.
  ///
  /// In en, this message translates to:
  /// **'You need 70% to advance.'**
  String get gateQuizFailed;

  /// No description provided for @gateQuizReviewTopics.
  ///
  /// In en, this message translates to:
  /// **'Review these topics:'**
  String get gateQuizReviewTopics;

  /// No description provided for @gateQuizRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get gateQuizRetry;

  /// No description provided for @gatePracticeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Practice mode unlocked! Use these hints before retrying.'**
  String get gatePracticeUnlocked;

  /// No description provided for @gatePracticeLocked.
  ///
  /// In en, this message translates to:
  /// **'Practice mode unlocks after 3 attempts. Keep going!'**
  String get gatePracticeLocked;

  /// No description provided for @gatePracticeHintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Try these mini missions:'**
  String get gatePracticeHintsTitle;

  /// No description provided for @gatePracticeAttempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts used: {count}/{total}'**
  String gatePracticeAttempts(int count, int total);

  /// No description provided for @modulePremiumContent.
  ///
  /// In en, this message translates to:
  /// **'Premium content'**
  String get modulePremiumContent;

  /// No description provided for @modulePremiumUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock module {moduleNumber} by starting your free trial.'**
  String modulePremiumUnlock(int moduleNumber);

  /// No description provided for @modulePremiumButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Premium'**
  String get modulePremiumButton;

  /// No description provided for @moduleGatePending.
  ///
  /// In en, this message translates to:
  /// **'Module quiz pending'**
  String get moduleGatePending;

  /// No description provided for @moduleGateRequired.
  ///
  /// In en, this message translates to:
  /// **'Pass the module {moduleNumber} quiz (>=70%) to advance.'**
  String moduleGateRequired(int moduleNumber);

  /// No description provided for @moduleGateTake.
  ///
  /// In en, this message translates to:
  /// **'Take module quiz'**
  String get moduleGateTake;

  /// No description provided for @homeEnglishComingTitle.
  ///
  /// In en, this message translates to:
  /// **'Early Access'**
  String get homeEnglishComingTitle;

  /// No description provided for @homeEnglishComingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Be the first to try new features and suggest improvements'**
  String get homeEnglishComingSubtitle;

  /// No description provided for @homeEnglishNotifyCta.
  ///
  /// In en, this message translates to:
  /// **'Notify me'**
  String get homeEnglishNotifyCta;

  /// No description provided for @homeEnglishNotifyDone.
  ///
  /// In en, this message translates to:
  /// **'Already registered'**
  String get homeEnglishNotifyDone;

  /// No description provided for @homeEnglishNotifySuccess.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be notified when Technical English launches!'**
  String get homeEnglishNotifySuccess;

  /// No description provided for @homeEnglishNotifyError.
  ///
  /// In en, this message translates to:
  /// **'Could not register notification'**
  String get homeEnglishNotifyError;

  /// No description provided for @assessmentResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your level: {level}'**
  String assessmentResultTitle(String level);

  /// No description provided for @assessmentResultLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected level: {level}'**
  String assessmentResultLevelLabel(String level);

  /// No description provided for @assessmentResultPercentile.
  ///
  /// In en, this message translates to:
  /// **'You scored better than {percentile}% of learners'**
  String assessmentResultPercentile(int percentile);

  /// No description provided for @assessmentResultStrengthsTitle.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get assessmentResultStrengthsTitle;

  /// No description provided for @assessmentResultGapsTitle.
  ///
  /// In en, this message translates to:
  /// **'Areas to improve'**
  String get assessmentResultGapsTitle;

  /// No description provided for @assessmentResultPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested plan'**
  String get assessmentResultPlanTitle;

  /// No description provided for @assessmentResultShare.
  ///
  /// In en, this message translates to:
  /// **'Share results'**
  String get assessmentResultShare;

  /// No description provided for @assessmentResultCta.
  ///
  /// In en, this message translates to:
  /// **'Generate my learning plan'**
  String get assessmentResultCta;

  /// No description provided for @assessmentResultShareMessage.
  ///
  /// In en, this message translates to:
  /// **'I just completed my {topic} assessment on Edaptia! Level: {level}, Score: {score}%'**
  String assessmentResultShareMessage(String topic, String level, int score);

  /// No description provided for @assessmentResultClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get assessmentResultClose;

  /// No description provided for @assessmentResultResponsesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your answers'**
  String get assessmentResultResponsesTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @homeLogoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeLogoutTooltip;

  /// No description provided for @homeSignOutError.
  ///
  /// In en, this message translates to:
  /// **'We could not sign you out. Try again.'**
  String get homeSignOutError;

  /// No description provided for @homeUserFallback.
  ///
  /// In en, this message translates to:
  /// **'Aelion user'**
  String get homeUserFallback;

  /// No description provided for @homeUserNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get homeUserNoEmail;

  /// No description provided for @homeSuggestionMath.
  ///
  /// In en, this message translates to:
  /// **'Math basics'**
  String get homeSuggestionMath;

  /// No description provided for @homeSuggestionEnglish.
  ///
  /// In en, this message translates to:
  /// **'Conversational English'**
  String get homeSuggestionEnglish;

  /// No description provided for @homeSuggestionHistory.
  ///
  /// In en, this message translates to:
  /// **'History of Rome'**
  String get homeSuggestionHistory;

  /// No description provided for @homePrefillCourse.
  ///
  /// In en, this message translates to:
  /// **'Quick Flutter course'**
  String get homePrefillCourse;

  /// No description provided for @homePrefillLanguage.
  ///
  /// In en, this message translates to:
  /// **'English in 1 month'**
  String get homePrefillLanguage;

  /// No description provided for @homePrefillProblem.
  ///
  /// In en, this message translates to:
  /// **'Solve integrals'**
  String get homePrefillProblem;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get onboardingTitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get onboardingProgressLabel;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get onboardingStart;

  /// No description provided for @onboardingSelectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get onboardingSelectLabel;

  /// No description provided for @onboardingQuestionAge.
  ///
  /// In en, this message translates to:
  /// **'What\'s your age range?'**
  String get onboardingQuestionAge;

  /// No description provided for @onboardingQuestionInterests.
  ///
  /// In en, this message translates to:
  /// **'Which topics interest you?'**
  String get onboardingQuestionInterests;

  /// No description provided for @onboardingQuestionEducation.
  ///
  /// In en, this message translates to:
  /// **'What\'s your education background?'**
  String get onboardingQuestionEducation;

  /// No description provided for @onboardingQuestionFirstSql.
  ///
  /// In en, this message translates to:
  /// **'Is this your first time learning SQL?'**
  String get onboardingQuestionFirstSql;

  /// No description provided for @onboardingQuestionBeta.
  ///
  /// In en, this message translates to:
  /// **'Do you want to be a beta tester?'**
  String get onboardingQuestionBeta;

  /// No description provided for @onboardingAge18_24.
  ///
  /// In en, this message translates to:
  /// **'18-24'**
  String get onboardingAge18_24;

  /// No description provided for @onboardingAge25_34.
  ///
  /// In en, this message translates to:
  /// **'25-34'**
  String get onboardingAge25_34;

  /// No description provided for @onboardingAge35_44.
  ///
  /// In en, this message translates to:
  /// **'35-44'**
  String get onboardingAge35_44;

  /// No description provided for @onboardingAge45Plus.
  ///
  /// In en, this message translates to:
  /// **'45+'**
  String get onboardingAge45Plus;

  /// No description provided for @onboardingInterestSql.
  ///
  /// In en, this message translates to:
  /// **'SQL'**
  String get onboardingInterestSql;

  /// No description provided for @onboardingInterestPython.
  ///
  /// In en, this message translates to:
  /// **'Python'**
  String get onboardingInterestPython;

  /// No description provided for @onboardingInterestExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel'**
  String get onboardingInterestExcel;

  /// No description provided for @onboardingInterestData.
  ///
  /// In en, this message translates to:
  /// **'Data analysis'**
  String get onboardingInterestData;

  /// No description provided for @onboardingInterestMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get onboardingInterestMarketing;

  /// No description provided for @onboardingEducationSecondary.
  ///
  /// In en, this message translates to:
  /// **'High school'**
  String get onboardingEducationSecondary;

  /// No description provided for @onboardingEducationUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get onboardingEducationUniversity;

  /// No description provided for @onboardingEducationPostgrad.
  ///
  /// In en, this message translates to:
  /// **'Postgraduate'**
  String get onboardingEducationPostgrad;

  /// No description provided for @onboardingEducationSelfTaught.
  ///
  /// In en, this message translates to:
  /// **'Self-taught'**
  String get onboardingEducationSelfTaught;

  /// No description provided for @onboardingBetaDescription.
  ///
  /// In en, this message translates to:
  /// **'Edaptia is in active development. As a beta tester:\\n• You get updates before everyone else\\n• You unlock experimental features\\n• Your feedback helps us improve'**
  String get onboardingBetaDescription;

  /// No description provided for @onboardingBetaOptIn.
  ///
  /// In en, this message translates to:
  /// **'Yes, I want to be a beta tester'**
  String get onboardingBetaOptIn;

  /// No description provided for @onboardingError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your answers. Please try again.'**
  String get onboardingError;

  /// No description provided for @notFoundRoute.
  ///
  /// In en, this message translates to:
  /// **'Route not found'**
  String get notFoundRoute;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @dialogContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get dialogContinue;

  /// No description provided for @quizTitle.
  ///
  /// In en, this message translates to:
  /// **'Placement quiz'**
  String get quizTitle;

  /// No description provided for @quizHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibrate {topic}'**
  String quizHeaderTitle(String topic);

  /// No description provided for @quizIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'Take 10 quick questions to calibrate your plan.'**
  String get quizIntroDescription;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startQuiz;

  /// No description provided for @quizQuestionCounter.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestionCounter(int current, int total);

  /// No description provided for @quizTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Approx. {minutes} min'**
  String quizTimeHint(int minutes);

  /// No description provided for @quizAnswerAllPrompt.
  ///
  /// In en, this message translates to:
  /// **'Answer every question before continuing.'**
  String get quizAnswerAllPrompt;

  /// No description provided for @quizExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave quiz?'**
  String get quizExitTitle;

  /// No description provided for @quizExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Your answers will be lost.'**
  String get quizExitMessage;

  /// No description provided for @quizExitCancel.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get quizExitCancel;

  /// No description provided for @quizExitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get quizExitConfirm;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @quizResultTitle.
  ///
  /// In en, this message translates to:
  /// **'You are {band}'**
  String quizResultTitle(String band);

  /// No description provided for @quizLevelChip.
  ///
  /// In en, this message translates to:
  /// **'Level: {band}'**
  String quizLevelChip(String band);

  /// No description provided for @quizScorePercentage.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}%'**
  String quizScorePercentage(int score);

  /// No description provided for @quizRecommendRefine.
  ///
  /// In en, this message translates to:
  /// **'We will refine your plan for the {band} level.'**
  String quizRecommendRefine(String band);

  /// No description provided for @quizKeepCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Your current plan already matches the {band} level.'**
  String quizKeepCurrentPlan(String band);

  /// No description provided for @quizDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get quizDone;

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get quizNext;

  /// No description provided for @quizSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get quizSubmit;

  /// No description provided for @quizContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get quizContinue;

  /// No description provided for @quizUnknownError.
  ///
  /// In en, this message translates to:
  /// **'We could not load the quiz. Try again.'**
  String get quizUnknownError;

  /// No description provided for @quizBandBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get quizBandBeginner;

  /// No description provided for @quizBandIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get quizBandIntermediate;

  /// No description provided for @quizBandAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get quizBandAdvanced;

  /// No description provided for @courseEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a course'**
  String get courseEntryTitle;

  /// No description provided for @courseEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search a topic and launch a quick placement quiz.'**
  String get courseEntrySubtitle;

  /// No description provided for @courseEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Flutter fundamentals, linear algebra, SQL...'**
  String get courseEntryHint;

  /// No description provided for @courseEntryStart.
  ///
  /// In en, this message translates to:
  /// **'Start quiz'**
  String get courseEntryStart;

  /// No description provided for @courseEntryFooter.
  ///
  /// In en, this message translates to:
  /// **'We keep placement quizzes short (10 questions).'**
  String get courseEntryFooter;

  /// No description provided for @courseEntryExampleFlutter.
  ///
  /// In en, this message translates to:
  /// **'Intro to Flutter'**
  String get courseEntryExampleFlutter;

  /// No description provided for @courseEntryExampleSql.
  ///
  /// In en, this message translates to:
  /// **'SQL for beginners'**
  String get courseEntryExampleSql;

  /// No description provided for @courseEntryExampleDataScience.
  ///
  /// In en, this message translates to:
  /// **'Data science 101'**
  String get courseEntryExampleDataScience;

  /// No description provided for @courseEntryExampleLogic.
  ///
  /// In en, this message translates to:
  /// **'Logic fundamentals'**
  String get courseEntryExampleLogic;

  /// No description provided for @courseEntryResultSummary.
  ///
  /// In en, this message translates to:
  /// **'Score {score}% - level {band}'**
  String courseEntryResultSummary(int score, String band);

  /// No description provided for @courseEntryResultActionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Generating a new outline for the {band} level.'**
  String courseEntryResultActionUpdate(String band);

  /// No description provided for @courseEntryResultActionReuse.
  ///
  /// In en, this message translates to:
  /// **'Reusing your existing {band} plan.'**
  String courseEntryResultActionReuse(String band);

  /// No description provided for @outlineFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Outline'**
  String get outlineFallbackTitle;

  /// No description provided for @moduleOutlineFallbackTopic.
  ///
  /// In en, this message translates to:
  /// **'Default topic'**
  String get moduleOutlineFallbackTopic;

  /// No description provided for @outlineUpdatePlan.
  ///
  /// In en, this message translates to:
  /// **'Update plan'**
  String get outlineUpdatePlan;

  /// No description provided for @refinePlan.
  ///
  /// In en, this message translates to:
  /// **'Refine plan'**
  String get refinePlan;

  /// No description provided for @outlineRefineRebuild.
  ///
  /// In en, this message translates to:
  /// **'New outline will match the {band} level.'**
  String outlineRefineRebuild(String band);

  /// No description provided for @outlineRefineNoChanges.
  ///
  /// In en, this message translates to:
  /// **'Current outline already matches the {band} level.'**
  String outlineRefineNoChanges(String band);

  /// No description provided for @outlineSnackCached.
  ///
  /// In en, this message translates to:
  /// **'Loaded your saved plan.'**
  String get outlineSnackCached;

  /// No description provided for @outlineSnackUpdated.
  ///
  /// In en, this message translates to:
  /// **'Plan ready with the latest updates.'**
  String get outlineSnackUpdated;

  /// No description provided for @outlineRefineChangeDepthTitle.
  ///
  /// In en, this message translates to:
  /// **'Change depth'**
  String get outlineRefineChangeDepthTitle;

  /// No description provided for @outlineRefineChangeDepthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reuse or generate outlines for intro, medium, or deep levels.'**
  String get outlineRefineChangeDepthSubtitle;

  /// No description provided for @takePlacementQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take placement quiz'**
  String get takePlacementQuiz;

  /// No description provided for @outlineRefinePlacementQuizSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer 10 questions to calibrate your plan.'**
  String get outlineRefinePlacementQuizSubtitle;

  /// No description provided for @outlineErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We could not load the outline.'**
  String get outlineErrorGeneric;

  /// No description provided for @outlineErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'No outline available for this topic.'**
  String get outlineErrorEmpty;

  /// No description provided for @outlineErrorNoContent.
  ///
  /// In en, this message translates to:
  /// **'No content available for this topic.'**
  String get outlineErrorNoContent;

  /// No description provided for @outlineSourceCached.
  ///
  /// In en, this message translates to:
  /// **'Cached outline'**
  String get outlineSourceCached;

  /// No description provided for @outlineSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved {timestamp}'**
  String outlineSavedLabel(String timestamp);

  /// No description provided for @outlineStaleBadge.
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get outlineStaleBadge;

  /// No description provided for @outlineMetaBand.
  ///
  /// In en, this message translates to:
  /// **'Level: {band}'**
  String outlineMetaBand(String band);

  /// No description provided for @outlineMetaLevel.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String outlineMetaLevel(String level);

  /// No description provided for @outlineMetaHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String outlineMetaHours(int hours);

  /// No description provided for @outlineMetaLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language: {language}'**
  String outlineMetaLanguage(String language);

  /// No description provided for @outlineMetaDepth.
  ///
  /// In en, this message translates to:
  /// **'Depth: {depth}'**
  String outlineMetaDepth(String depth);

  /// No description provided for @outlineLessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String outlineLessonCount(int count);

  /// No description provided for @outlineLessonLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language: {language}'**
  String outlineLessonLanguage(String language);

  /// No description provided for @outlineModuleFallback.
  ///
  /// In en, this message translates to:
  /// **'Module {index}'**
  String outlineModuleFallback(int index);

  /// No description provided for @outlineLessonFallback.
  ///
  /// In en, this message translates to:
  /// **'Lesson {index}'**
  String outlineLessonFallback(int index);

  /// No description provided for @homeGreetingNamed.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, what do you want to learn today?'**
  String homeGreetingNamed(String name);

  /// No description provided for @homeRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent plans'**
  String get homeRecentTitle;

  /// No description provided for @homeRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have no saved plans yet.'**
  String get homeRecentEmpty;

  /// No description provided for @homeRecentView.
  ///
  /// In en, this message translates to:
  /// **'View outline'**
  String get homeRecentView;

  /// No description provided for @homeRecentMoreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more modules'**
  String homeRecentMoreCount(int count);

  /// No description provided for @homeRecentSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {timestamp}'**
  String homeRecentSaved(String timestamp);

  /// No description provided for @homeUpdatedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get homeUpdatedJustNow;

  /// No description provided for @homeUpdatedMinutes.
  ///
  /// In en, this message translates to:
  /// **'Updated {minutes} min ago'**
  String homeUpdatedMinutes(int minutes);

  /// No description provided for @homeUpdatedHours.
  ///
  /// In en, this message translates to:
  /// **'Updated {hours} h ago'**
  String homeUpdatedHours(int hours);

  /// No description provided for @homeUpdatedDays.
  ///
  /// In en, this message translates to:
  /// **'Updated {days} d ago'**
  String homeUpdatedDays(int days);

  /// No description provided for @homeDepthIntro.
  ///
  /// In en, this message translates to:
  /// **'Intro level'**
  String get homeDepthIntro;

  /// No description provided for @homeDepthMedium.
  ///
  /// In en, this message translates to:
  /// **'Intermediate depth'**
  String get homeDepthMedium;

  /// No description provided for @homeDepthDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep dive'**
  String get homeDepthDeep;

  /// No description provided for @buildExpertiseIn.
  ///
  /// In en, this message translates to:
  /// **'Build expertise in {topic}'**
  String buildExpertiseIn(Object topic);

  /// No description provided for @depthIntro.
  ///
  /// In en, this message translates to:
  /// **'introductory'**
  String get depthIntro;

  /// No description provided for @depthMedium.
  ///
  /// In en, this message translates to:
  /// **'intermediate'**
  String get depthMedium;

  /// No description provided for @depthDeep.
  ///
  /// In en, this message translates to:
  /// **'advanced'**
  String get depthDeep;

  /// No description provided for @calibratingPlan.
  ///
  /// In en, this message translates to:
  /// **'Calibrating your plan'**
  String get calibratingPlan;

  /// No description provided for @planReady.
  ///
  /// In en, this message translates to:
  /// **'Plan ready'**
  String get planReady;

  /// No description provided for @homeRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get homeRecommendationsTitle;

  /// No description provided for @homeRecommendationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recommendations yet.'**
  String get homeRecommendationsEmpty;

  /// No description provided for @homeRecommendationsError.
  ///
  /// In en, this message translates to:
  /// **'We could not load recommendations.'**
  String get homeRecommendationsError;

  /// No description provided for @quizCooldownMinutes.
  ///
  /// In en, this message translates to:
  /// **'Please wait {minutes} more minute(s) before retaking the quiz.'**
  String quizCooldownMinutes(Object minutes);

  /// No description provided for @quizCooldownSeconds.
  ///
  /// In en, this message translates to:
  /// **'Please wait a few seconds before retaking the quiz.'**
  String get quizCooldownSeconds;

  /// No description provided for @quizOpenPlan.
  ///
  /// In en, this message translates to:
  /// **'Open plan'**
  String get quizOpenPlan;

  /// No description provided for @quizApplyResults.
  ///
  /// In en, this message translates to:
  /// **'Apply results'**
  String get quizApplyResults;

  /// No description provided for @quizResultsNoChanges.
  ///
  /// In en, this message translates to:
  /// **'Results saved without changes.'**
  String get quizResultsNoChanges;

  /// No description provided for @planAlreadyAligned.
  ///
  /// In en, this message translates to:
  /// **'Your plan is already aligned.'**
  String get planAlreadyAligned;

  /// No description provided for @lessonCompleteToast.
  ///
  /// In en, this message translates to:
  /// **'Lesson completed! XP total: {xp}'**
  String lessonCompleteToast(int xp);

  /// No description provided for @lessonXpReward.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String lessonXpReward(int xp);

  /// No description provided for @lessonUpdateError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t update the lesson. Try again.'**
  String get lessonUpdateError;

  /// No description provided for @lessonPremiumContent.
  ///
  /// In en, this message translates to:
  /// **'Premium content'**
  String get lessonPremiumContent;

  /// No description provided for @lessonDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get lessonDescriptionTitle;

  /// No description provided for @lessonMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark lesson as completed'**
  String get lessonMarkCompleted;

  /// No description provided for @lessonTipTakeNotes.
  ///
  /// In en, this message translates to:
  /// **'Tip: take quick notes before moving on.'**
  String get lessonTipTakeNotes;

  /// No description provided for @lessonFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lessonFallbackTitle;

  /// No description provided for @lessonObjectiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson objective'**
  String get lessonObjectiveTitle;

  /// No description provided for @lessonObjectiveSummary.
  ///
  /// In en, this message translates to:
  /// **'• Understand the core concept.\n• Complete a short practice.\n• Move on once you feel ready.'**
  String get lessonObjectiveSummary;

  /// No description provided for @lessonQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get lessonQuizTitle;

  /// No description provided for @lessonQuizOption.
  ///
  /// In en, this message translates to:
  /// **'{letter}) {option}'**
  String lessonQuizOption(String letter, String option);

  /// No description provided for @lessonQuizCheck.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get lessonQuizCheck;

  /// No description provided for @lessonQuizCorrect.
  ///
  /// In en, this message translates to:
  /// **'✅ Correct!'**
  String get lessonQuizCorrect;

  /// No description provided for @lessonQuizIncorrect.
  ///
  /// In en, this message translates to:
  /// **'❌ Incorrect. The answer was {answer}.'**
  String lessonQuizIncorrect(String answer);

  /// No description provided for @lessonTipReview.
  ///
  /// In en, this message translates to:
  /// **'Tip: if something is unclear, reread and practice for 2 more minutes before moving on.'**
  String get lessonTipReview;

  /// No description provided for @lessonContentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Content available soon.'**
  String get lessonContentComingSoon;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get commonSaving;

  /// No description provided for @homeGenerateError.
  ///
  /// In en, this message translates to:
  /// **'We could not generate the plan. Try again.'**
  String get homeGenerateError;

  /// No description provided for @topicSearchMissingTopic.
  ///
  /// In en, this message translates to:
  /// **'Type a topic to continue'**
  String get topicSearchMissingTopic;

  /// No description provided for @topicSearchTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Search a topic'**
  String get topicSearchTitleFallback;

  /// No description provided for @topicSearchHintFallback.
  ///
  /// In en, this message translates to:
  /// **'What do you want to learn?'**
  String get topicSearchHintFallback;

  /// No description provided for @topicSearchStartButton.
  ///
  /// In en, this message translates to:
  /// **'Take mini quiz'**
  String get topicSearchStartButton;

  /// No description provided for @quizPlanCreated.
  ///
  /// In en, this message translates to:
  /// **'Plan created.'**
  String get quizPlanCreated;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answers, contact options, and community links.'**
  String get helpSupportSubtitle;

  /// No description provided for @helpFaqSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get helpFaqSectionTitle;

  /// No description provided for @helpCommunitySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get helpCommunitySectionTitle;

  /// No description provided for @helpContactSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact options'**
  String get helpContactSectionTitle;

  /// No description provided for @helpJoinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join Community'**
  String get helpJoinCommunity;

  /// No description provided for @helpJoinCommunityDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to connect with other learners.'**
  String get helpJoinCommunityDescription;

  /// No description provided for @helpJoinCommunityDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Telegram'**
  String get helpJoinCommunityDialogTitle;

  /// No description provided for @helpJoinCommunityChannel.
  ///
  /// In en, this message translates to:
  /// **'News channel'**
  String get helpJoinCommunityChannel;

  /// No description provided for @helpJoinCommunityGroup.
  ///
  /// In en, this message translates to:
  /// **'Community chat'**
  String get helpJoinCommunityGroup;

  /// No description provided for @helpContactSpanish.
  ///
  /// In en, this message translates to:
  /// **'Email support (ES)'**
  String get helpContactSpanish;

  /// No description provided for @helpContactSpanishDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach our Spanish-speaking agents.'**
  String get helpContactSpanishDescription;

  /// No description provided for @helpContactEnglish.
  ///
  /// In en, this message translates to:
  /// **'Email support (EN)'**
  String get helpContactEnglish;

  /// No description provided for @helpContactEnglishDescription.
  ///
  /// In en, this message translates to:
  /// **'Get help in English from the core team.'**
  String get helpContactEnglishDescription;

  /// No description provided for @helpReportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get helpReportBug;

  /// No description provided for @helpReportBugDescription.
  ///
  /// In en, this message translates to:
  /// **'Include screenshots or steps if possible.'**
  String get helpReportBugDescription;

  /// No description provided for @helpAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get helpAboutTitle;

  /// No description provided for @helpAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter and Firebase; all content is generated via secure Cloud Functions.'**
  String get helpAboutDescription;

  /// No description provided for @helpPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get helpPrivacyPolicy;

  /// No description provided for @helpTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get helpTermsOfService;

  /// No description provided for @helpLaunchError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open the link. Please try again.'**
  String get helpLaunchError;

  /// No description provided for @homeOverflowHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get homeOverflowHelpSupport;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneralSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneralSection;

  /// No description provided for @settingsHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingsHelpSupport;

  /// No description provided for @settingsHelpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs, contact, and policies'**
  String get settingsHelpSupportSubtitle;

  /// No description provided for @helpEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'{appName} support request (v{version} · {device})'**
  String helpEmailSubject(String appName, String version, String device);

  /// No description provided for @helpBugReportSubject.
  ///
  /// In en, this message translates to:
  /// **'{appName} bug report (v{version} · {device})'**
  String helpBugReportSubject(String appName, String version, String device);

  /// No description provided for @helpBugReportBody.
  ///
  /// In en, this message translates to:
  /// **'Timestamp: {timestamp}\nLocale: {locale}\nVersion: {version}\nDevice: {device}\n\nSteps to reproduce:\n- '**
  String helpBugReportBody(
      String timestamp, String locale, String version, String device);

  /// No description provided for @helpAboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String helpAboutVersion(String version);

  /// No description provided for @helpFaqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'How do I generate my first learning plan?'**
  String get helpFaqQuestion1;

  /// No description provided for @helpFaqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'On the Home screen, enter a topic and tap Generate AI learning plan.'**
  String get helpFaqAnswer1;

  /// No description provided for @helpFaqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'Where can I find my recent outlines?'**
  String get helpFaqQuestion2;

  /// No description provided for @helpFaqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'Scroll to the Recents section on Home; each card reopens the saved outline instantly.'**
  String get helpFaqAnswer2;

  /// No description provided for @helpFaqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'How are trending topics selected?'**
  String get helpFaqQuestion3;

  /// No description provided for @helpFaqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'We mix your latest searches with popular requests in your language to suggest new ideas.'**
  String get helpFaqAnswer3;

  /// No description provided for @helpFaqQuestion4.
  ///
  /// In en, this message translates to:
  /// **'What is a placement quiz?'**
  String get helpFaqQuestion4;

  /// No description provided for @helpFaqAnswer4.
  ///
  /// In en, this message translates to:
  /// **'It is a 10-question calibration that sets the right level before we build a tailored plan.'**
  String get helpFaqAnswer4;

  /// No description provided for @helpFaqQuestion5.
  ///
  /// In en, this message translates to:
  /// **'Can I change the depth of a plan later?'**
  String get helpFaqQuestion5;

  /// No description provided for @helpFaqAnswer5.
  ///
  /// In en, this message translates to:
  /// **'Open the outline, tap Refine plan, and select the depth that matches your goal.'**
  String get helpFaqAnswer5;

  /// No description provided for @helpFaqQuestion6.
  ///
  /// In en, this message translates to:
  /// **'How do I switch the outline language?'**
  String get helpFaqQuestion6;

  /// No description provided for @helpFaqAnswer6.
  ///
  /// In en, this message translates to:
  /// **'Generate again after choosing your preferred language in the quiz or topic prompt.'**
  String get helpFaqAnswer6;

  /// No description provided for @helpFaqQuestion7.
  ///
  /// In en, this message translates to:
  /// **'What happens if I lose connection?'**
  String get helpFaqQuestion7;

  /// No description provided for @helpFaqAnswer7.
  ///
  /// In en, this message translates to:
  /// **'Cached outlines and recents stay available offline; new generations wait until you are online.'**
  String get helpFaqAnswer7;

  /// No description provided for @helpFaqQuestion8.
  ///
  /// In en, this message translates to:
  /// **'How is my progress saved?'**
  String get helpFaqQuestion8;

  /// No description provided for @helpFaqAnswer8.
  ///
  /// In en, this message translates to:
  /// **'Metadata and cached outlines are stored securely on your device via SharedPreferences.'**
  String get helpFaqAnswer8;

  /// No description provided for @helpFaqQuestion9.
  ///
  /// In en, this message translates to:
  /// **'How do I sign out safely?'**
  String get helpFaqQuestion9;

  /// No description provided for @helpFaqAnswer9.
  ///
  /// In en, this message translates to:
  /// **'Use the logout icon on the Home app bar; it signs you out of Firebase and Google on mobile.'**
  String get helpFaqAnswer9;

  /// No description provided for @helpFaqQuestion10.
  ///
  /// In en, this message translates to:
  /// **'How do I switch Google accounts?'**
  String get helpFaqQuestion10;

  /// No description provided for @helpFaqAnswer10.
  ///
  /// In en, this message translates to:
  /// **'Sign out first, then pick the other account when the Google sign-in sheet appears.'**
  String get helpFaqAnswer10;

  /// No description provided for @helpFaqQuestion11.
  ///
  /// In en, this message translates to:
  /// **'How can I clear my recent searches?'**
  String get helpFaqQuestion11;

  /// No description provided for @helpFaqAnswer11.
  ///
  /// In en, this message translates to:
  /// **'Search history is capped to the latest entries per account and is cleared automatically when you sign out.'**
  String get helpFaqAnswer11;

  /// No description provided for @helpFaqQuestion12.
  ///
  /// In en, this message translates to:
  /// **'What data do you store in Firestore?'**
  String get helpFaqQuestion12;

  /// No description provided for @helpFaqAnswer12.
  ///
  /// In en, this message translates to:
  /// **'Only anonymized outline cache entries and observability metrics generated by Cloud Functions.'**
  String get helpFaqAnswer12;

  /// No description provided for @helpFaqQuestion13.
  ///
  /// In en, this message translates to:
  /// **'How do I report incorrect content?'**
  String get helpFaqQuestion13;

  /// No description provided for @helpFaqAnswer13.
  ///
  /// In en, this message translates to:
  /// **'Use the Report a bug button below and describe what needs to be fixed.'**
  String get helpFaqAnswer13;

  /// No description provided for @helpFaqQuestion14.
  ///
  /// In en, this message translates to:
  /// **'Where do recommendations come from?'**
  String get helpFaqQuestion14;

  /// No description provided for @helpFaqAnswer14.
  ///
  /// In en, this message translates to:
  /// **'They combine aggregated demand with your recent activity to surface relevant topics.'**
  String get helpFaqAnswer14;

  /// No description provided for @helpFaqQuestion15.
  ///
  /// In en, this message translates to:
  /// **'Can I regenerate a plan after finishing a quiz?'**
  String get helpFaqQuestion15;

  /// No description provided for @helpFaqAnswer15.
  ///
  /// In en, this message translates to:
  /// **'Yes. Applying quiz results automatically rebuilds the outline with the new band.'**
  String get helpFaqAnswer15;

  /// No description provided for @helpFaqQuestion16.
  ///
  /// In en, this message translates to:
  /// **'How long are cached outlines kept?'**
  String get helpFaqQuestion16;

  /// No description provided for @helpFaqAnswer16.
  ///
  /// In en, this message translates to:
  /// **'They remain until you replace them or clear storage; stale badges appear after 24 hours.'**
  String get helpFaqAnswer16;

  /// No description provided for @helpFaqQuestion17.
  ///
  /// In en, this message translates to:
  /// **'Why was I asked to retake the quiz?'**
  String get helpFaqQuestion17;

  /// No description provided for @helpFaqAnswer17.
  ///
  /// In en, this message translates to:
  /// **'We prompt a retake when your level looks outdated or the cache exceeded its freshness window.'**
  String get helpFaqAnswer17;

  /// No description provided for @helpFaqQuestion18.
  ///
  /// In en, this message translates to:
  /// **'Can I use the app on multiple devices?'**
  String get helpFaqQuestion18;

  /// No description provided for @helpFaqAnswer18.
  ///
  /// In en, this message translates to:
  /// **'Yes. Sign in with the same Google account on web or Android to stay in sync.'**
  String get helpFaqAnswer18;

  /// No description provided for @helpFaqQuestion19.
  ///
  /// In en, this message translates to:
  /// **'Does the app support dark mode?'**
  String get helpFaqQuestion19;

  /// No description provided for @helpFaqAnswer19.
  ///
  /// In en, this message translates to:
  /// **'The interface follows your system theme and keeps contrast within accessibility guidelines.'**
  String get helpFaqAnswer19;

  /// No description provided for @helpFaqQuestion20.
  ///
  /// In en, this message translates to:
  /// **'How do I reset my learning streak?'**
  String get helpFaqQuestion20;

  /// No description provided for @helpFaqAnswer20.
  ///
  /// In en, this message translates to:
  /// **'Clear local data from system settings or sign in with a new account.'**
  String get helpFaqAnswer20;

  /// No description provided for @helpFaqQuestion21.
  ///
  /// In en, this message translates to:
  /// **'How can I request a new feature?'**
  String get helpFaqQuestion21;

  /// No description provided for @helpFaqAnswer21.
  ///
  /// In en, this message translates to:
  /// **'Send your idea through the English support email and include Feature idea in the message.'**
  String get helpFaqAnswer21;

  /// No description provided for @helpFaqQuestion22.
  ///
  /// In en, this message translates to:
  /// **'Do I need an account to use the app?'**
  String get helpFaqQuestion22;

  /// No description provided for @helpFaqAnswer22.
  ///
  /// In en, this message translates to:
  /// **'Yes, Google authentication protects your content and enables personalization.'**
  String get helpFaqAnswer22;

  /// No description provided for @helpFaqQuestion23.
  ///
  /// In en, this message translates to:
  /// **'What happens if I close the app during a quiz?'**
  String get helpFaqQuestion23;

  /// No description provided for @helpFaqAnswer23.
  ///
  /// In en, this message translates to:
  /// **'You can restart the quiz anytime; progress resets to keep the calibration accurate.'**
  String get helpFaqAnswer23;

  /// No description provided for @helpFaqQuestion24.
  ///
  /// In en, this message translates to:
  /// **'How do I delete cached outlines?'**
  String get helpFaqQuestion24;

  /// No description provided for @helpFaqAnswer24.
  ///
  /// In en, this message translates to:
  /// **'Cached outlines live only on your device; uninstalling or clearing the app data removes them.'**
  String get helpFaqAnswer24;

  /// No description provided for @helpFaqQuestion25.
  ///
  /// In en, this message translates to:
  /// **'Is my personal data shared with third parties?'**
  String get helpFaqQuestion25;

  /// No description provided for @helpFaqAnswer25.
  ///
  /// In en, this message translates to:
  /// **'No. We only use aggregate telemetry for reliability and never sell personal information.'**
  String get helpFaqAnswer25;

  /// No description provided for @helpFaqQuestion26.
  ///
  /// In en, this message translates to:
  /// **'Can I use the app without Firebase Functions?'**
  String get helpFaqQuestion26;

  /// No description provided for @helpFaqAnswer26.
  ///
  /// In en, this message translates to:
  /// **'No. Direct Firestore access is blocked; all requests go through secure HTTPS Functions.'**
  String get helpFaqAnswer26;

  /// No description provided for @helpFaqQuestion27.
  ///
  /// In en, this message translates to:
  /// **'Why do I see a stale badge?'**
  String get helpFaqQuestion27;

  /// No description provided for @helpFaqAnswer27.
  ///
  /// In en, this message translates to:
  /// **'It means the cached outline is older than the freshness threshold and should be regenerated.'**
  String get helpFaqAnswer27;

  /// No description provided for @helpFaqQuestion28.
  ///
  /// In en, this message translates to:
  /// **'How do I join the community?'**
  String get helpFaqQuestion28;

  /// No description provided for @helpFaqAnswer28.
  ///
  /// In en, this message translates to:
  /// **'Tap Join Community to open the Telegram news channel or chat group.'**
  String get helpFaqAnswer28;

  /// No description provided for @helpFaqQuestion29.
  ///
  /// In en, this message translates to:
  /// **'How do I check the app version?'**
  String get helpFaqQuestion29;

  /// No description provided for @helpFaqAnswer29.
  ///
  /// In en, this message translates to:
  /// **'Open Help & Support and scroll to About; the version number is listed there.'**
  String get helpFaqAnswer29;

  /// No description provided for @helpFaqQuestion30.
  ///
  /// In en, this message translates to:
  /// **'Can I run the app with local emulators?'**
  String get helpFaqQuestion30;

  /// No description provided for @helpFaqAnswer30.
  ///
  /// In en, this message translates to:
  /// **'Yes. Set USE_FUNCTIONS_EMULATOR=true in env.public and start the Firebase emulators.'**
  String get helpFaqAnswer30;

  /// No description provided for @helpFaqQuestion31.
  ///
  /// In en, this message translates to:
  /// **'How do I contact support in Spanish?'**
  String get helpFaqQuestion31;

  /// No description provided for @helpFaqAnswer31.
  ///
  /// In en, this message translates to:
  /// **'Use the Spanish email button; it routes directly to our Spanish-speaking support team.'**
  String get helpFaqAnswer31;

  /// No description provided for @helpFaqQuestion32.
  ///
  /// In en, this message translates to:
  /// **'How quickly does support respond?'**
  String get helpFaqQuestion32;

  /// No description provided for @helpFaqAnswer32.
  ///
  /// In en, this message translates to:
  /// **'We aim to reply within one business day and usually respond much sooner.'**
  String get helpFaqAnswer32;

  /// No description provided for @helpFaqQuestion33.
  ///
  /// In en, this message translates to:
  /// **'What details help with a bug report?'**
  String get helpFaqQuestion33;

  /// No description provided for @helpFaqAnswer33.
  ///
  /// In en, this message translates to:
  /// **'Include the timestamp, locale, app version, device, and clear reproduction steps.'**
  String get helpFaqAnswer33;

  /// No description provided for @helpFaqQuestion34.
  ///
  /// In en, this message translates to:
  /// **'How do I get the latest release?'**
  String get helpFaqQuestion34;

  /// No description provided for @helpFaqAnswer34.
  ///
  /// In en, this message translates to:
  /// **'Install updates from your app store or pull the main branch if you are contributing.'**
  String get helpFaqAnswer34;

  /// No description provided for @helpFaqQuestion35.
  ///
  /// In en, this message translates to:
  /// **'Where can I read the privacy policy and terms?'**
  String get helpFaqQuestion35;

  /// No description provided for @helpFaqAnswer35.
  ///
  /// In en, this message translates to:
  /// **'Use the Privacy Policy and Terms of Service links in the About section.'**
  String get helpFaqAnswer35;

  /// No description provided for @adaptiveFlowCta.
  ///
  /// In en, this message translates to:
  /// **'Adaptive flow'**
  String get adaptiveFlowCta;

  /// No description provided for @adaptiveFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Adaptive journey'**
  String get adaptiveFlowTitle;

  /// No description provided for @adaptiveFlowLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading adaptive plan...'**
  String get adaptiveFlowLoading;

  /// No description provided for @adaptiveFlowError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the adaptive plan. Try again.'**
  String get adaptiveFlowError;

  /// No description provided for @adaptiveFlowNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No adaptive plan yet. Generate one to get started.'**
  String get adaptiveFlowNoPlan;

  /// No description provided for @adaptiveFlowLearnerState.
  ///
  /// In en, this message translates to:
  /// **'Learner state'**
  String get adaptiveFlowLearnerState;

  /// No description provided for @adaptiveFlowPlanSection.
  ///
  /// In en, this message translates to:
  /// **'Suggested modules'**
  String get adaptiveFlowPlanSection;

  /// No description provided for @adaptiveFlowModuleSection.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get adaptiveFlowModuleSection;

  /// No description provided for @adaptiveFlowCheckpointSection.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint'**
  String get adaptiveFlowCheckpointSection;

  /// No description provided for @adaptiveFlowBoosterSection.
  ///
  /// In en, this message translates to:
  /// **'Booster'**
  String get adaptiveFlowBoosterSection;

  /// No description provided for @adaptiveFlowGenerateModule.
  ///
  /// In en, this message translates to:
  /// **'Generate module'**
  String get adaptiveFlowGenerateModule;

  /// No description provided for @adaptiveFlowGenerateCheckpoint.
  ///
  /// In en, this message translates to:
  /// **'Create checkpoint'**
  String get adaptiveFlowGenerateCheckpoint;

  /// No description provided for @adaptiveFlowSubmitAnswers.
  ///
  /// In en, this message translates to:
  /// **'Evaluate checkpoint'**
  String get adaptiveFlowSubmitAnswers;

  /// No description provided for @adaptiveFlowBoosterCta.
  ///
  /// In en, this message translates to:
  /// **'Request booster'**
  String get adaptiveFlowBoosterCta;

  /// No description provided for @adaptiveFlowWeakSkills.
  ///
  /// In en, this message translates to:
  /// **'Weak skills: {skills}'**
  String adaptiveFlowWeakSkills(String skills);

  /// No description provided for @adaptiveFlowScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}%'**
  String adaptiveFlowScoreLabel(int score);

  /// No description provided for @adaptiveFlowActionAdvance.
  ///
  /// In en, this message translates to:
  /// **'Great! Advance to the next module.'**
  String get adaptiveFlowActionAdvance;

  /// No description provided for @adaptiveFlowActionBooster.
  ///
  /// In en, this message translates to:
  /// **'Booster recommended before moving on.'**
  String get adaptiveFlowActionBooster;

  /// No description provided for @adaptiveFlowActionReplan.
  ///
  /// In en, this message translates to:
  /// **'Repeating this module with more scaffolding.'**
  String get adaptiveFlowActionReplan;

  /// No description provided for @adaptiveFlowCheckpointMissingSelection.
  ///
  /// In en, this message translates to:
  /// **'Select an answer for each question.'**
  String get adaptiveFlowCheckpointMissingSelection;

  /// No description provided for @adaptiveFlowEmptySkills.
  ///
  /// In en, this message translates to:
  /// **'No skills tracked yet.'**
  String get adaptiveFlowEmptySkills;

  /// No description provided for @adaptiveFlowDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration: {minutes} min'**
  String adaptiveFlowDurationLabel(int minutes);

  /// No description provided for @adaptiveFlowSkillsLabel.
  ///
  /// In en, this message translates to:
  /// **'Skills: {skills}'**
  String adaptiveFlowSkillsLabel(String skills);

  /// No description provided for @adaptiveFlowLockedModule.
  ///
  /// In en, this message translates to:
  /// **'Complete module {module} to unlock this one.'**
  String adaptiveFlowLockedModule(String module);

  /// No description provided for @adaptiveFlowLockedPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium to keep advancing.'**
  String get adaptiveFlowLockedPremium;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
