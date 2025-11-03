part of 'package:edaptia/features/modules/outline/module_outline_view.dart';

class OutlineHeader extends StatelessWidget {
  const OutlineHeader({
    super.key,
    required this.l10n,
    required this.topic,
    this.goal,
    this.level,
    this.bandLabel,
    this.estimated,
    this.language,
    this.depth,
    this.updatedLabel,
  });

  final AppLocalizations l10n;
  final String topic;
  final String? goal;
  final String? level;
  final String? bandLabel;
  final String? estimated;
  final String? language;
  final String? depth;
  final String? updatedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <Widget>[];

    if (bandLabel != null && bandLabel!.isNotEmpty) {
      chips.add(
        OutlineMetaItem(
          icon: Icons.workspace_premium_outlined,
          label: l10n.outlineMetaBand(bandLabel!),
        ),
      );
    } else if (level != null && level!.isNotEmpty) {
      chips.add(
        OutlineMetaItem(
          icon: Icons.school_outlined,
          label: l10n.outlineMetaLevel(level!),
        ),
      );
    }

    if (estimated != null && estimated!.isNotEmpty) {
      chips.add(
        OutlineMetaItem(
          icon: Icons.schedule_outlined,
          label: estimated!,
        ),
      );
    }

    if (language != null && language!.isNotEmpty) {
      chips.add(
        OutlineMetaItem(
          icon: Icons.translate,
          label: l10n.outlineMetaLanguage(language!),
        ),
      );
    }

    if (depth != null && depth!.isNotEmpty) {
      chips.add(
        OutlineMetaItem(
          icon: Icons.assessment_outlined,
          label: l10n.outlineMetaDepth(depth!),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topic, style: theme.textTheme.headlineSmall),
            if (updatedLabel != null && updatedLabel!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                updatedLabel!,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (goal != null && goal!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(goal!, style: theme.textTheme.bodyMedium),
            ],
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: chips,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
