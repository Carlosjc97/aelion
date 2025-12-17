import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/typography.dart';

/// Professional loading indicator for adaptive journey generation.
class AdaptiveLoadingIndicator extends StatelessWidget {
  const AdaptiveLoadingIndicator({
    super.key,
    required this.message,
    this.subtitle,
  });

  final String message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  EdaptiaColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: EdaptiaTypography.title3.copyWith(
                color: EdaptiaColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: EdaptiaTypography.body.copyWith(
                  color: EdaptiaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 16,
                  color: EdaptiaColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Esto puede tomar unos segundos...',
                  style: EdaptiaTypography.caption.copyWith(
                    color: EdaptiaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
