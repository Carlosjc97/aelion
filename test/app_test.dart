import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/features/auth/login_screen.dart';
import 'package:learning_ia/features/home/home_view.dart';
import 'package:learning_ia/l10n/app_localizations.dart';

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
