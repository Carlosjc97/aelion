import 'package:flutter_test/flutter_test.dart';
import 'package:edaptia/main.dart'; // Use the correct import path

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // This is a basic test to ensure the app doesn't crash on startup.
    await tester.pumpWidget(const AelionApp());

    // The test passes if no exceptions were thrown.
    expect(find.byType(AelionApp), findsOneWidget);
  });
}
