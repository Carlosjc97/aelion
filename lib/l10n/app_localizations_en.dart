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
  String get notFoundRoute => 'Route not found';
}
