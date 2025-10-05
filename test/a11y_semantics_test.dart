import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aelion/features/auth/sign_in_screen.dart';
import 'package:aelion/l10n/app_localizations.dart';

Widget _localizedApp(Widget child, {Locale locale = const Locale('es')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

void main() {
  testWidgets('SignInScreen exposes accessible Google button', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await tester.pumpWidget(_localizedApp(const SignInScreen()));
    await tester.pumpAndSettle();

    final buttonFinder = find.text('Iniciar sesion con Google');
    expect(buttonFinder, findsOneWidget);

    final SemanticsNode node = tester.getSemantics(buttonFinder);
    final SemanticsData data = node.getSemanticsData();

    expect(data.flagsCollection.isButton, isTrue);
    expect(data.label, 'Iniciar sesion con Google');

    semantics.dispose();
  });
}
