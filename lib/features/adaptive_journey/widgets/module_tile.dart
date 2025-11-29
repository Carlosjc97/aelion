import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/typography.dart';
import 'package:edaptia/services/course/models.dart';
import 'package:edaptia/services/learner_state_service.dart';

import '../models/module_tile_state.dart';

class ModuleTile extends StatelessWidget {
  const ModuleTile({
    super.key,
    required this.tile,
    required this.isActive,
    required this.hasPremium,
    required this.isExpanded,
    required this.moduleTitle,
    required this.skills,
    required this.emptySkillsLabel,
    required this.lessonCards,
    required this.learnerState,
    required this.topic,
    required this.totalLessons,
    required this.onTap,
  });

  final ModuleTileState tile;
  final bool isActive;
  final bool hasPremium;
  final bool isExpanded;
  final String moduleTitle;
  final List<String> skills;
  final String emptySkillsLabel;
  final List<Widget> lessonCards;
  final AdaptiveLearnerState? learnerState;
  final String topic;
  final int totalLessons;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = tile.completed
        ? EdaptiaColors.successGradient
        : isActive
            ? EdaptiaColors.hookGradient
            : null;
    final baseColor = tile.completed
        ? EdaptiaColors.success
        : isActive
            ? EdaptiaColors.primary
            : EdaptiaColors.border;
    final foreground =
        (tile.completed || isActive) ? Colors.white : EdaptiaColors.textPrimary;

    IconData icon;
    if (tile.completed) {
      icon = Icons.check_circle;
    } else if (!tile.unlocked) {
      icon = Icons.lock_outline;
    } else if (tile.requiresPremium && !hasPremium) {
      icon = Icons.lock;
    } else {
      icon = Icons.play_circle;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: background == null ? EdaptiaColors.cardLight : null,
            gradient: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: baseColor.withValues(alpha: baseColor.a * 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(icon, color: foreground, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'M${tile.number}',
                                  style: EdaptiaTypography.title3
                                      .copyWith(color: foreground),
                                ),
                                if (isActive) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Activo',
                                      style: EdaptiaTypography.caption
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              moduleTitle,
                              style: EdaptiaTypography.body
                                  .copyWith(color: foreground),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              skills.isEmpty
                                  ? emptySkillsLabel
                                  : skills.take(2).join(', '),
                              style: EdaptiaTypography.caption.copyWith(
                                color: foreground.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: foreground,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                const Divider(height: 1, color: Colors.white24),
                if (lessonCards.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressBar(context),
                        ...lessonCards,
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 16,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Generando módulo ${tile.number}...',
                            style: EdaptiaTypography.body.copyWith(
                              color: foreground.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    if (totalLessons <= 0) {
      return const SizedBox.shrink();
    }
    final progress = LearnerStateService.instance.getModuleProgress(
      state: learnerState,
      topic: topic,
      moduleNumber: tile.number,
      totalLessons: totalLessons,
    );
    final pct = (progress * 100).round();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso del módulo',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '$pct%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: progress >= 1
                    ? EdaptiaColors.success
                    : EdaptiaColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1 ? EdaptiaColors.success : EdaptiaColors.primary,
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
