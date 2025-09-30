import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:aelion/features/auth/sign_in_screen.dart';

void main() {
  testWidgets('SignInScreen: supports textScaleFactor 2.0 without overflow', (tester) async {
    // Set up a mock for Firebase Auth
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1080, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      const MaterialApp(home: SignInScreen()),
    );

    // Set text scale factor to 2.0
    binding.window.textScaleFactorTestValue = 2.0;
    addTearDown(() => binding.window.clearAllTestValues());

    await tester.pumpAndSettle();

    // Verify that the key widgets are still present and visible.
    // The presence of these widgets implies no overflow has hidden them.
    expect(find.textContaining('Bienvenido'), findsOneWidget);
    expect(find.textContaining('Aprende a tu ritmo'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);

    // Also check for RenderFlex overflow errors in the logs
    final dynamic exception = tester.takeException();
    expect(exception, isNull);
  });
}