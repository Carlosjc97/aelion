import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aelion/features/modules/module_outline_view.dart';

void main() {
  testWidgets('ModuleOutlineView builds without errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ModuleOutlineView(),
    ));

    await tester.pump(const Duration(seconds: 5));

    expect(find.byType(ModuleOutlineView), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}