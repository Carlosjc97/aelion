import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

void main() {
  testWidgets('ModuleOutlineView builds without errors', (widgetTester) async {
    await widgetTester.pumpWidget(const MaterialApp(
      home: ModuleOutlineView(),
    ));

    expect(find.byType(ModuleOutlineView), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
