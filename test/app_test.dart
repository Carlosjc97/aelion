import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edaptia/core/router.dart';
import 'package:edaptia/features/auth/sign_in_screen.dart';
import 'package:edaptia/features/home/home_view.dart';
import 'package:edaptia/l10n/app_localizations.dart';

Widget _buildApp() => MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: HomeView.routeName,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );

void main() {
  testWidgets('boots and renders initial screen (login when signed out)',
      (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(SignInScreen), findsOneWidget);
  });
}

