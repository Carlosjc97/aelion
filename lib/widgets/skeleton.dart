import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.cornerRadius = 8.0,
  });

  final double? height;
  final double? width;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
          Theme.of(context).colorScheme.surface,
        ),
        borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
      ),
    );
  }
}