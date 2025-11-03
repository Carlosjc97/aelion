part of 'package:edaptia/features/modules/outline/module_outline_view.dart';

class LessonCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final rawLessonTitle = lesson['title']?.toString().trim();
    final lessonTitle = (rawLessonTitle?.isNotEmpty ?? false)
        ? rawLessonTitle!
        : l10n.outlineLessonFallback(lessonIndex + 1);

    final languageLabel =
        lesson['language']?.toString() ?? courseLanguage ?? '';

    return ListTile(
      key: Key('lesson-tile-$moduleIndex-$lessonIndex'),
      leading: const Icon(Icons.menu_book_outlined),
      title: Text(lessonTitle),
      subtitle: languageLabel.isEmpty
          ? null
          : Text(l10n.outlineLessonLanguage(languageLabel)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).pushNamed(
          LessonDetailPage.routeName,
          arguments: LessonDetailArgs(
            courseId: courseId,
            moduleTitle: moduleTitle,
            lessonTitle: lessonTitle,
            content: lesson['content']?.toString(),
          ),
        );
      },
    );
  }
}
