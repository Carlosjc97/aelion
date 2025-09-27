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
}
