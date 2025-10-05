import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aelion/core/router.dart';
import 'package:aelion/features/auth/sign_in_screen.dart';
import 'package:aelion/features/home/home_view.dart';
import 'package:aelion/l10n/app_localizations.dart';

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
