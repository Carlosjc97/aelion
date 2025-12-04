import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/features/lesson/lesson_router.dart';
import 'package:edaptia/services/course/models.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.index,
    required this.lesson,
    required this.moduleTitle,
    required this.moduleNumber,
    required this.courseId,
    this.isVisited = false,
    this.isLocked = false,
    this.allModuleLessons = const <AdaptiveLesson>[],
  });

  final int index;
  final AdaptiveLesson lesson;
  final String moduleTitle;
  final int moduleNumber;
  final String courseId;
  final bool isVisited;
  final bool isLocked;
  final List<AdaptiveLesson> allModuleLessons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isLocked
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
        : isVisited
            ? EdaptiaColors.success.withValues(alpha: 0.03)
            : theme.colorScheme.surfaceContainerHighest;
    final borderColor = isLocked
        ? theme.colorScheme.outline.withValues(alpha: 0.2)
        : isVisited
            ? EdaptiaColors.success.withValues(alpha: 0.3)
            : theme.colorScheme.outline.withValues(alpha: 0.3);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLocked
            ? null
            : () {
                LessonRouter.navigateToLesson(
                  context: context,
                  lesson: lesson,
                  moduleTitle: moduleTitle,
                  moduleNumber: moduleNumber,
                  lessonIndex: index,
                  courseId: courseId,
                  allModuleLessons: allModuleLessons,
                );
              },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: isVisited ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isLocked) ...[
                    Icon(
                      Icons.lock,
                      color: theme.colorScheme.outline,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                  ] else if (isVisited) ...[
                    Icon(
                      Icons.check_circle,
                      color: EdaptiaColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      'L${index + 1} - ${lesson.title}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isLocked
                            ? theme.colorScheme.outline
                            : theme.textTheme.titleSmall?.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                lesson.hook,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isLocked
                        ? Icons.lock_outline
                        : isVisited
                            ? Icons.check
                            : Icons.arrow_forward,
                    size: 16,
                    color: isLocked
                        ? theme.colorScheme.outline
                        : isVisited
                            ? EdaptiaColors.success
                            : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isLocked
                        ? 'Bloqueada — completa la lección anterior'
                        : isVisited
                            ? 'Completada'
                            : 'Abrir lección',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isLocked
                          ? theme.colorScheme.outline
                          : isVisited
                              ? EdaptiaColors.success
                              : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
