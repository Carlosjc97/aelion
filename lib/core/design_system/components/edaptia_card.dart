import 'package:flutter/material.dart';

import '../colors.dart';

/// Card genérico con estilo Edaptia (Material 3 + gradientes).
class EdaptiaCard extends StatelessWidget {
  const EdaptiaCard({
    super.key,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
    this.elevation = 2,
    this.margin,
  });

  final Widget child;
  final Gradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackground = backgroundColor ?? EdaptiaColors.cardLight;
    final card = Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      color: resolvedBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
    if (margin != null) {
      return Padding(
        padding: margin!,
        child: card,
      );
    }
    return card;
  }
}
