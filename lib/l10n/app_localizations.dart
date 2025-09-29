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
  ///
