part of 'package:edaptia/features/modules/outline/module_outline_view.dart';

// GATING ADDED - DÍA 3

class LessonCard extends StatefulWidget {
  const LessonCard({
    super.key,
    required this.moduleIndex,
    required this.lessonIndex,
    required this.lesson,
    required this.courseId,
    required this.moduleTitle,
    required this.l10n,
    this.courseLanguage,
  });

  final int moduleIndex;
  final int lessonIndex;
  final Map<String, dynamic> lesson;
  final String courseId;
  final String moduleTitle;
  final AppLocalizations l10n;
  final String? courseLanguage;

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {

  @override
  Widget build(BuildContext context) {
    final rawLessonTitle = widget.lesson['title']?.toString().trim();
    final lessonTitle = (rawLessonTitle?.isNotEmpty ?? false)
        ? rawLessonTitle!
        : widget.l10n.outlineLessonFallback(widget.lessonIndex + 1);

    final languageLabel =
        widget.lesson['language']?.toString() ?? widget.courseLanguage ?? '';

    // GATING ADDED - DÍA 3: Check if module is locked
    final entitlements = EntitlementsService();
    final moduleId = 'M${widget.moduleIndex + 1}'; // M1, M2, M3, etc.
    final isLocked = !entitlements.isModuleUnlocked(moduleId);

    return ListTile(
      key: Key('lesson-tile-${widget.moduleIndex}-${widget.lessonIndex}'),
      leading: const Icon(Icons.menu_book_outlined),
      title: Text(lessonTitle),
      subtitle: languageLabel.isEmpty
          ? null
          : Text(widget.l10n.outlineLessonLanguage(languageLabel)),
      trailing: isLocked
          ? const Icon(Icons.lock, color: Colors.grey)
          : const Icon(Icons.chevron_right),
      onTap: () async {
        // GATING ADDED - DÍA 3: Check paywall before navigation
        if (isLocked) {
          final hasAccess = await PaywallHelper.checkAndShowPaywall(
            context,
            trigger: 'module_locked',
            onTrialStarted: () {
              // Refresh UI after trial start
              setState(() {});
            },
          );

          if (!hasAccess) return; // User cancelled
        }

        // Original navigation code
        Navigator.of(context).pushNamed(
          LessonDetailPage.routeName,
          arguments: LessonDetailArgs(
            courseId: widget.courseId,
            moduleTitle: widget.moduleTitle,
            lessonTitle: lessonTitle,
            content: widget.lesson['content']?.toString(),
          ),
        );
      },
    );
  }
}
