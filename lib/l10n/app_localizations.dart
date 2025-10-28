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
  /// **'Aelion'**
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
  /// **'Hi {name} 👋'**
  String homeGreetingNamedShort(String name);

  /// No description provided for @homeGreetingWave.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋'**
  String get homeGreetingWave;

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
