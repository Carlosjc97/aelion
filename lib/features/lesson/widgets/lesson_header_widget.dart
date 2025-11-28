import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/typography.dart';

import 'lesson_hook_card.dart';

class LessonHeaderWidget extends StatelessWidget {
  const LessonHeaderWidget({
    super.key,
    required this.moduleTitle,
    required this.hook,
  });

  final String moduleTitle;
  final String hook;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          moduleTitle,
          style: EdaptiaTypography.title2.copyWith(
            color: EdaptiaColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        LessonHookCard(hook: hook),
      ],
    );
  }
}
