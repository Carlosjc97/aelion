import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aelion/features/modules/module_outline_view.dart';
import 'package:aelion/l10n/app_localizations.dart';

void main() {
  testWidgets('ModuleOutlineView builds without errors', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ModuleOutlineView(),
    ));

    await tester.pump(const Duration(seconds: 5));

    expect(find.byType(ModuleOutlineView), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
