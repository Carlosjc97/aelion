part of 'package:edaptia/features/modules/outline/module_outline_view.dart';

class OutlineContent extends StatelessWidget {
  const OutlineContent({
    super.key,
    required this.l10n,
    required this.courseId,
    required this.response,
    required this.modules,
    this.source,
    this.savedAt,
    this.band,
    this.depth,
    required this.onModuleExpansion,
  });

  final AppLocalizations l10n;
  final String courseId;
  final Map<String, dynamic> response;
  final List<Map<String, dynamic>> modules;
  final String? source;
  final DateTime? savedAt;
  final PlacementBand? band;
  final String? depth;
  final void Function(Map<String, dynamic>, int, bool) onModuleExpansion;

  @override
  Widget build(BuildContext context) {
    final topic = response['topic']?.toString() ?? l10n.outlineFallbackTitle;
    final goal = response['goal']?.toString();
    final level = response['level']?.toString();
    final language = response['language']?.toString();
    final estimated = response['estimated_hours'];
    final estimatedLabel =
        estimated is num ? l10n.outlineMetaHours(estimated.round()) : null;
    final bandLabel = band != null ? _bandLabel(l10n, band!) : null;
    final updatedLabel =
        savedAt != null ? _formatUpdatedLabel(l10n, savedAt!) : null;

    final children = <Widget>[
      OutlineHeader(
        l10n: l10n,
        topic: topic,
        goal: goal,
        level: level,
        bandLabel: bandLabel,
        estimated: estimatedLabel,
        language: language,
        depth: depth,
        updatedLabel: updatedLabel,
      ),
      ...modules.asMap().entries.map(
        (entry) {
          final Map<String, dynamic> moduleData =
              Map<String, dynamic>.from(entry.value as Map);
          return ModuleCard(
            key: Key('module-${entry.key}'),
            courseId: courseId,
            moduleIndex: entry.key,
            module: moduleData,
            courseLanguage: language,
            l10n: l10n,
            onExpansionChanged: (expanded) =>
                onModuleExpansion(moduleData, entry.key, expanded),
          );
        },
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: children,
    );
  }
}
