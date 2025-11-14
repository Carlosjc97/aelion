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
    this.isLocked = false,
  });

  final int moduleIndex;
  final int lessonIndex;
  final Map<String, dynamic> lesson;
  final String courseId;
  final String moduleTitle;
  final AppLocalizations l10n;
  final String? courseLanguage;
  final bool isLocked;

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

    final isLocked = widget.isLocked;

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
        final navigator = Navigator.of(context);
        // GATING ADDED - DÍA 3: Check paywall before navigation
        if (isLocked) {
          final hasAccess = await PaywallHelper.checkAndShowPaywall(
            context,
            trigger: 'module_locked',
            onTrialStarted: () {
              // Refresh UI after trial start
              if (mounted) {
                setState(() {});
              }
            },
          );

          if (!hasAccess || !mounted) return; // User cancelled or widget disposed
        }

        if (!mounted) return;
        // Original navigation code
        navigator.pushNamed(
          LessonDetailPage.routeName,
          arguments: LessonDetailArgs(
            courseId: widget.courseId,
            moduleTitle: widget.moduleTitle,
            lessonTitle: lessonTitle,
            content: widget.lesson['content']?.toString(),
            lesson: Map<String, dynamic>.from(widget.lesson),
          ),
        );
      },
    );
  }
}
