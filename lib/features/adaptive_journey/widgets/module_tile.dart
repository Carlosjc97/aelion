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
    this.isGenerating = false,
    this.isLocked = false,
    this.onQuizPressed,
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
  final bool isGenerating;
  final bool isLocked;
  final VoidCallback? onQuizPressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Colors.white;
    final borderColor = tile.completed
        ? EdaptiaColors.success.withValues(alpha: 0.5)
        : isActive
            ? EdaptiaColors.primary.withValues(alpha: 0.5)
            : EdaptiaColors.border.withValues(alpha: 0.3);
    final foreground = tile.completed
        ? EdaptiaColors.success
        : isLocked
            ? EdaptiaColors.textSecondary
            : EdaptiaColors.textPrimary;

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
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
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
                                if (isActive && !tile.completed) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: EdaptiaColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Activo',
                                      style: EdaptiaTypography.caption.copyWith(
                                        color: EdaptiaColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              moduleTitle,
                              style: EdaptiaTypography.body.copyWith(
                                color: EdaptiaColors.textPrimary,
                              ),
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
                Divider(
                  height: 1,
                  color: EdaptiaColors.border.withValues(alpha: 0.2),
                ),
                if (isGenerating)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Generando lecciones...',
                            style: EdaptiaTypography.body.copyWith(
                              color: foreground.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (lessonCards.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressBar(context),
                        ...lessonCards,
                        const SizedBox(height: 8),
                        _buildQuizButton(context),
                      ],
                    ),
                  )
                else if (!isGenerating)
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

  Widget _buildQuizButton(BuildContext context) {
    if (onQuizPressed == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onQuizPressed,
        icon: const Icon(Icons.quiz_outlined),
        label: Text('Quiz módulo ${tile.number}'),
      ),
    );
  }
}
