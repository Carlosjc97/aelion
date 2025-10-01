import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'helpers/test_sign_in_screen.dart';

extension on SemanticsFlags {
  bool has(SemanticsFlag flag) {
    if (identical(flag, SemanticsFlag.hasCheckedState)) {
      return hasCheckedState;
    }
    if (identical(flag, SemanticsFlag.isChecked)) {
      return isChecked;
    }
    if (identical(flag, SemanticsFlag.isSelected)) {
      return isSelected;
    }
    if (identical(flag, SemanticsFlag.isButton)) {
      return isButton;
    }
    if (identical(flag, SemanticsFlag.isTextField)) {
      return isTextField;
    }
    if (identical(flag, SemanticsFlag.isFocused)) {
      return isFocused;
    }
    if (identical(flag, SemanticsFlag.hasEnabledState)) {
      return hasEnabledState;
    }
    if (identical(flag, SemanticsFlag.isEnabled)) {
      return isEnabled;
    }
    if (identical(flag, SemanticsFlag.isInMutuallyExclusiveGroup)) {
      return isInMutuallyExclusiveGroup;
    }
    if (identical(flag, SemanticsFlag.isHeader)) {
      return isHeader;
    }
    if (identical(flag, SemanticsFlag.isObscured)) {
      return isObscured;
    }
    if (identical(flag, SemanticsFlag.scopesRoute)) {
      return scopesRoute;
    }
    if (identical(flag, SemanticsFlag.namesRoute)) {
      return namesRoute;
    }
    if (identical(flag, SemanticsFlag.isHidden)) {
      return isHidden;
    }
    if (identical(flag, SemanticsFlag.isImage)) {
      return isImage;
    }
    if (identical(flag, SemanticsFlag.isLiveRegion)) {
      return isLiveRegion;
    }
    if (identical(flag, SemanticsFlag.hasToggledState)) {
      return hasToggledState;
    }
    if (identical(flag, SemanticsFlag.isToggled)) {
      return isToggled;
    }
    if (identical(flag, SemanticsFlag.hasImplicitScrolling)) {
      return hasImplicitScrolling;
    }
    if (identical(flag, SemanticsFlag.isMultiline)) {
      return isMultiline;
    }
    if (identical(flag, SemanticsFlag.isReadOnly)) {
      return isReadOnly;
    }
    if (identical(flag, SemanticsFlag.isFocusable)) {
      return isFocusable;
    }
    if (identical(flag, SemanticsFlag.isLink)) {
      return isLink;
    }
    if (identical(flag, SemanticsFlag.isSlider)) {
      return isSlider;
    }
    if (identical(flag, SemanticsFlag.isKeyboardKey)) {
      return isKeyboardKey;
    }
    if (identical(flag, SemanticsFlag.isCheckStateMixed)) {
      return isCheckStateMixed;
    }
    if (identical(flag, SemanticsFlag.hasExpandedState)) {
      return hasExpandedState;
    }
    if (identical(flag, SemanticsFlag.isExpanded)) {
      return isExpanded;
    }
    if (identical(flag, SemanticsFlag.hasSelectedState)) {
      return hasSelectedState;
    }
    if (identical(flag, SemanticsFlag.hasRequiredState)) {
      return hasRequiredState;
    }
    if (identical(flag, SemanticsFlag.isRequired)) {
      return isRequired;
    }
    throw ArgumentError.value(flag, 'flag', 'Unsupported SemanticsFlag');
  }
}

void main() {
  testWidgets('SignInScreen: Google sign-in button has correct semantics', (tester) async {
    // The tester.ensureSemantics() is crucial for accessing the semantics tree.
    final SemanticsHandle semantics = tester.ensureSemantics();

    await tester.pumpWidget(const MaterialApp(home: TestSignInScreen()));

    // Find the button by its text content.
    final buttonFinder = find.text('Continuar con Google');
    expect(buttonFinder, findsOneWidget);

    // Get the semantics node associated with the button.
    final SemanticsNode semanticsNode = tester.getSemantics(buttonFinder);

    // Assert that the node has the properties of a button.
    expect(
      semanticsNode.flagsCollection.has(SemanticsFlag.isButton),
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