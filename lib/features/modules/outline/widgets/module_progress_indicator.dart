part of 'package:edaptia/features/modules/outline/module_outline_view.dart';

class ModuleProgressStatus {
  const ModuleProgressStatus({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  double get fraction {
    if (total <= 0) return 0;
    return (completed / total).clamp(0, 1);
  }

  String get label {
    final percentage = (fraction * 100).round();
    return '$percentage%';
  }
}

class ModuleProgressIndicator extends StatelessWidget {
  const ModuleProgressIndicator({
    super.key,
    required this.status,
  });

  final ModuleProgressStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final completedLabel = l10n.outlineLessonCount(status.completed);
    final totalLabel = l10n.outlineLessonCount(status.total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$completedLabel · $totalLabel',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: status.fraction,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status.label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }
}
