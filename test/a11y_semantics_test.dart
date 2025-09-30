import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:aelion/features/auth/sign_in_screen.dart';

void main() {
  testWidgets('SignInScreen: Google sign-in button has correct semantics', (tester) async {
    // The tester.ensureSemantics() is crucial for accessing the semantics tree.
    final SemanticsHandle semantics = tester.ensureSemantics();

    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    // Find the button by its text content.
    final buttonFinder = find.text('Continuar con Google');
    expect(buttonFinder, findsOneWidget);

    // Get the semantics node associated with the button.
    final SemanticsNode semanticsNode = tester.getSemantics(buttonFinder);

    // Assert that the node has the properties of a button.
    expect(
      semanticsNode.getSemanticsData().hasFlag(SemanticsFlag.isButton),
      isTrue,
      reason: 'The widget should be marked as a button for accessibility services.',
    );

    // Assert that the semantic label is correct.
    expect(
      semanticsNode.getSemanticsData().label,
      'Botón: Iniciar sesión con Google',
      reason: 'The semantic label should be descriptive for screen readers.',
    );

    // Clean up the semantics handle.
    semantics.dispose();
  });
}