import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/components/edaptia_card.dart';
import 'package:edaptia/core/design_system/typography.dart';

class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.stem,
    required this.options,
    this.selectedIndex,
    this.onSelect,
    this.correctIndex,
    this.showResult = false,
  });

  final String stem;
  final List<String> options;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;
  final int? correctIndex;
  final bool showResult;

  @override
  Widget build(BuildContext context) {
    return EdaptiaCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: EdaptiaColors.cardLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stem, style: EdaptiaTypography.title3),
          const SizedBox(height: 12),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedIndex == index;
            final isCorrect = correctIndex == index;
            final showCorrect = showResult && isCorrect;
            final showWrong = showResult && isSelected && !isCorrect;

            Color? bgColor;
            Color borderColor = EdaptiaColors.border;
            Color iconColor = EdaptiaColors.textSecondary;
            IconData icon = Icons.radio_button_unchecked;

            if (showCorrect) {
              bgColor = EdaptiaColors.success.withValues(alpha: 0.1);
              borderColor = EdaptiaColors.success;
              iconColor = EdaptiaColors.success;
              icon = Icons.check_circle;
            } else if (showWrong) {
              bgColor = Colors.red.withValues(alpha: 0.1);
              borderColor = Colors.red;
              iconColor = Colors.red;
              icon = Icons.cancel;
            } else if (isSelected) {
              bgColor = EdaptiaColors.primary.withValues(alpha: 0.1);
              borderColor = EdaptiaColors.primary;
              iconColor = EdaptiaColors.primary;
              icon = Icons.radio_button_checked;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: onSelect != null ? () => onSelect!(index) : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor ?? EdaptiaColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: iconColor),
                      const SizedBox(width: 12),
                      Expanded(child: Text(option)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
