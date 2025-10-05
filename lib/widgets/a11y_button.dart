import 'package:flutter/material.dart';

class A11yButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final String semanticsLabel;
  final String? onTapHint;

  const A11yButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    this.onTapHint,
  });

  @override
  Widget build(BuildContext context) {
    final minSize = const Size(200, 48); // >=48dp touch target

    return Semantics(
      label: semanticsLabel,
      button: true,
      enabled: onPressed != null,
      onTapHint: onTapHint ?? 'Activate',
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
            width: minSize.width, height: minSize.height),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon,
          label: Text(label),
          style: ElevatedButton.styleFrom(
            minimumSize: minSize,
            // Ensure the button text and icon have good contrast
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ).copyWith(
            elevation: ButtonStyleButton.allOrNull(0.0),
          ),
        ),
      ),
    );
  }
}
