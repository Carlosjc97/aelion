import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/main.dart';

void main() {
  testWidgets('AelionApp builds smoke test', (widgetTester) async {
    // Render the app.
    await widgetTester.pumpWidget(const AelionApp());

    // Verify that no exceptions were thrown.
    expect(find.byType(AelionApp), findsOneWidget);
  });
}
