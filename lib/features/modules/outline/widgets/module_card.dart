part of 'package:edaptia/features/modules/outline/module_outline_view.dart';

// GATING ADDED - DÍA 3

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.courseId,
    required this.moduleIndex,
    required this.module,
    required this.l10n,
    this.courseLanguage,
    this.onExpansionChanged,
  });

  final String courseId;
  final int moduleIndex;
  final Map<String, dynamic> module;
  final AppLocalizations l10n;
  final String? courseLanguage;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final rawTitle = module['title']?.toString().trim();
    final title = (rawTitle?.isNotEmpty ?? false)
        ? rawTitle!
        : l10n.outlineModuleFallback(moduleIndex + 1);

    // GATING ADDED - DÍA 3: Use entitlements to check lock status
    final entitlements = EntitlementsService();
    final moduleId = 'M${moduleIndex + 1}'; // M1, M2, M3, etc.
    final locked = !entitlements.isModuleUnlocked(moduleId);

    final lessons = _parseLessons(module['lessons']);
    final languageLabel = courseLanguage ?? '';

    final progress = _buildProgressStatus(module['progress'], lessons.length);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        key: Key('module-$moduleIndex-tile'),
        initiallyExpanded: !locked,
        leading: Icon(locked ? Icons.lock_outline : Icons.check_circle_outline),
        title: Text(title),
        subtitle: Text(l10n.outlineLessonCount(lessons.length)),
        onExpansionChanged: onExpansionChanged,
        children: [
          if (progress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ModuleProgressIndicator(status: progress),
            ),
          ...lessons.asMap().entries.map(
            (entry) {
              final lessonIndex = entry.key;
              final lesson = entry.value;
              return LessonCard(
                key: Key('lesson-card-$moduleIndex-$lessonIndex'),
                moduleIndex: moduleIndex,
                lessonIndex: lessonIndex,
                lesson: lesson,
                courseId: courseId,
                moduleTitle: title,
                l10n: l10n,
                courseLanguage: languageLabel,
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _parseLessons(dynamic raw) {
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((lesson) => Map<String, dynamic>.from(lesson))
        .toList(growable: false);
  }

  ModuleProgressStatus? _buildProgressStatus(dynamic raw, int totalLessons) {
    if (raw == null) return null;
    if (raw is num) {
      final fraction = raw.toDouble().clamp(0, 1);
      return ModuleProgressStatus(
        completed: (fraction * totalLessons).round().clamp(0, totalLessons),
        total: totalLessons,
      );
    }
    if (raw is Map<String, dynamic>) {
      final completed = (raw['completed'] as num?)?.toInt();
      final total = (raw['total'] as num?)?.toInt() ?? totalLessons;
      if (completed == null || total <= 0) {
        return null;
      }
      return ModuleProgressStatus(
        completed: completed.clamp(0, total),
        total: total,
      );
    }
    return null;
  }
}
