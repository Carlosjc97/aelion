import 'package:flutter/material.dart';
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
  testWidgets('SignInScreen supports textScaleFactor 2.0 without overflow',
      (tester) async {
    final binding = tester.binding;

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    binding.platformDispatcher.textScaleFactorTestValue = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      binding.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(_localizedApp(const SignInScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aprende mas rapido'), findsWidgets);
    expect(find.textContaining('Tu ruta de aprendizaje'), findsOneWidget);
    expect(find.text('Iniciar sesion con Google'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
