import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/components/edaptia_card.dart';
import 'package:edaptia/core/design_system/typography.dart';

class LessonHookCard extends StatelessWidget {
  const LessonHookCard({super.key, required this.hook});

  final String hook;

  @override
  Widget build(BuildContext context) {
    return EdaptiaCard(
      gradient: EdaptiaColors.hookGradient,
      padding: const EdgeInsets.all(16),
      child: Text(
        hook,
        style: EdaptiaTypography.body.copyWith(color: Colors.white),
      ),
    );
  }
}
