import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// In en, this message translates to: **'Aelion'**
  String get appTitle;

  /// In en, this message translates to: **'Learn faster with AI'**
  String get loginTitle;

  /// In en, this message translates to: **'Your learning path in a few taps'**
  String get loginSubtitle;

  /// In en, this message translates to: **'Personalized outlines in minutes'**
  String get loginHighlightPersonalized;

  /// In en, this message translates to: **'Daily streaks keep you motivated'**
  String get loginHighlightStreak;

  /// In en, this message translates to: **'Sync across web and Android with your Google account'**
  String get loginHighlightSync;

  /// In en, this message translates to: **'Sign in with Google'**
  String get loginButton;

  /// In en, this message translates to: **'Connecting...'**
  String get loginLoading;

  /// In en, this message translates to: **'Sign-in cancelled by the user'**
  String get loginCancelled;

  /// In en, this message translates to: **'We could not complete the sign-in. Try again.'**
  String get loginError;

  /// In en, this message translates to: **'Checking your session...'**
  String get authCheckingSession;

  /// In en, this message translates to: **'We could not verify your session'**
  String get authError;

  /// In en, this message translates to: **'Try again'**
  String get authRetry;

  /// In en, this message translates to: **'What do you want to learn today?'**
  String get homeGreeting;

  /// In en, this message translates to: **'Example: Algebra in 7 days, conversational English...'**
  String get homeInputHint;

  /// In en, this message translates to: **'Write a topic to continue'**
  String get homeSnackMissingTopic;

  /// In en, this message translates to: **'Generate AI learning plan'**
  String get homeGenerate;

  /// In en, this message translates to: **'Shortcuts'**
  String get homeShortcuts;

  /// In en, this message translates to: **'Take a course'**
  String get homeShortcutCourse;

  /// In en, this message translates to: **'AI generated micro-courses'**
  String get homeShortcutCourseSubtitle;

  /// In en, this message translates to: **'Learn a language'**
  String get homeShortcutLanguage;

  /// In en, this message translates to: **'Vocabulary and practical grammar'**
  String get homeShortcutLanguageSubtitle;

  /// In en, this message translates to: **'Solve a problem'**
  String get homeShortcutProblem;

  /// In en, this message translates to: **'From question to guided plan'**
  String get homeShortcutProblemSubtitle;

  /// In en, this message translates to: **'Sign out'**
  String get homeLogoutTooltip;

  /// In en, this message translates to: **'We could not sign you out. Try again.'**
  String get homeSignOutError;

  /// In en, this message translates to: **'Aelion user'**
  String get homeUserFallback;

  /// In en, this message translates to: **'No email'**
  String get homeUserNoEmail;

  /// In en, this message translates to: **'Math basics'**
  String get homeSuggestionMath;

  /// In en, this message translates to: **'Conversational English'**
  String get homeSuggestionEnglish;

  /// In en, this message translates to: **'History of Rome'**
  String get homeSuggestionHistory;

  /// In en, this message translates to: **'Quick Flutter course'**
  String get homePrefillCourse;

  /// In en, this message translates to: **'English in 1 month'**
  String get homePrefillLanguage;

  /// In en, this message translates to: **'Solve integrals'**
  String get homePrefillProblem;

  /// In en, this message translates to: **'Route not found'**
  String get notFoundRoute;
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
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". '
      'This is likely an issue with the localizations generation tool. '
      'Please file an issue on GitHub with a reproducible sample app and the gen-l10n configuration that was used.');
}
