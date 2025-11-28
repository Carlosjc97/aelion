import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/components/edaptia_card.dart';
import 'package:edaptia/core/design_system/typography.dart';

class LessonTakeawayCard extends StatelessWidget {
  const LessonTakeawayCard({super.key, required this.takeaway});

  final String takeaway;

  @override
  Widget build(BuildContext context) {
    return EdaptiaCard(
      gradient: EdaptiaColors.successGradient,
      padding: const EdgeInsets.all(16),
      child: Text(
        takeaway,
        style: EdaptiaTypography.body.copyWith(color: Colors.white),
      ),
    );
  }
}
