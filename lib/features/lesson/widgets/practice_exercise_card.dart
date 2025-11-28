import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/components/edaptia_card.dart';
import 'package:edaptia/core/design_system/typography.dart';

class PracticeExerciseCard extends StatelessWidget {
  const PracticeExerciseCard({
    super.key,
    required this.prompt,
    required this.controller,
    required this.buttonLabel,
    required this.onValidate,
    this.placeholder,
    this.isValidating = false,
    this.feedback,
    this.feedbackColor,
  });

  final String prompt;
  final TextEditingController controller;
  final String buttonLabel;
  final VoidCallback onValidate;
  final String? placeholder;
  final bool isValidating;
  final String? feedback;
  final Color? feedbackColor;

  @override
  Widget build(BuildContext context) {
    return EdaptiaCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: EdaptiaColors.cardLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ejercicio práctico', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          Text(prompt, style: EdaptiaTypography.body),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: placeholder ?? 'Escribe tu respuesta...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: isValidating ? null : onValidate,
            child: isValidating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(buttonLabel),
          ),
          if (feedback != null) ...[
            const SizedBox(height: 8),
            Text(
              feedback!,
              style: EdaptiaTypography.body.copyWith(
                color: feedbackColor ?? EdaptiaColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
