import 'package:flutter/material.dart';
import '../../widgets/aelion_appbar.dart';
import '../../core/app_colors.dart';
import '../../services/course_api_service.dart';
import '../../services/progress_service.dart';
import '../quiz/quiz_screen.dart';
import '../lesson/lesson_view.dart';
import '../../services/api_config.dart';

class ModuleOutlineView extends StatefulWidget {
  static const routeName = '/module';
  final String? topic;

  const ModuleOutlineView({super.key, this.topic});

  @override
  State<ModuleOutlineView> createState() => _ModuleOutlineViewState();
}

class _ModuleOutlineViewState extends State<ModuleOutlineView> {
  bool loading = true;
  Map<String, dynamic>? course; // outline JSON
  final progress = ProgressService();
  String get courseId =>
      (widget.topic ?? 'Curso').toLowerCase().replaceAll(' ', '_');

  @override
  void initState() {
    super.initState();
    _loadOutline();
  }

  Future<void> _loadOutline() async {
    setState(() => loading = true);
    try {
      final outline = await CourseApiService.generateOutline(
        topic: widget.topic ?? 'Curso',
      );

      // Asegura mínimo desbloqueo inicial
      final rawModules = outline['modules'];
      if (rawModules is List) {
        final modules = rawModules.cast<Map<String, dynamic>>();
        if (modules.isNotEmpty) {
          modules.first['locked'] = false;
          final rawLessons = modules.first['lessons'];
          if (rawLessons is List && rawLessons.isNotEmpty) {
            final firstLessons =
                rawLessons.cast<Map<String, dynamic>>();
            firstLessons.first['locked'] = false;
          }
        }
      }

      setState(() => course = outline);
      await progress.saveProgress(courseId, outline);
    } catch (_) {
      // Fallback seguro (nunca pantalla blanca)
      setState(() {
        course = {
          "topic": widget.topic ?? "Módulo de ejemplo",
          "level": "beginner",
          "estimated_hours": 2,
          "modules": [
            {
              "id": "m1",
              "title": "Introducción",
              "locked": false,
              "lessons": [
                {
                  "id": "m1l1",
                  "title": "Definición",
                  "locked": false,
                  "status": "todo"
                },
                {
                  "id": "m1l2",
                  "title": "Ejemplo práctico",
                  "locked": true,
                  "status": "todo",
                  "premium": true
                },
              ]
            }
          ]
        };
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.topic ?? (course?['topic'] as String? ?? 'Módulo');

    return Scaffold(
      appBar: AelionAppBar(title: title),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const _SkeletonList()
            : (course == null)
                ? _ErrorReload(onRetry: _loadOutline)
                : RefreshIndicator(
                    onRefresh: _loadOutline,
                    child: _OutlineList(
                      course: course!,
                      onReload: _loadOutline,
                    ),
                  ),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    // ListView para evitar overflows en pantallas pequeñas
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, i) => Container(
        height: 76,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.neutral.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _ErrorReload extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorReload({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Card(
          color: AppColors.neutral,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('No se pudo cargar el curso.'),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OutlineList extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onReload;
  const _OutlineList({required this.course, required this.onReload});

  @override
  Widget build(BuildContext context) {
    final rawModules = course['modules'];
    final modules = (rawModules is List)
        ? rawModules.cast<Map<String, dynamic>>()
        : const <Map<String, dynamic>>[];

    return ListView(
      children: [
        // Mini test opt-in
        Card(
          color: AppColors.neutral,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Te gustaría hacer un mini test de conocimiento?',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  '10 preguntas para ajustar el nivel y priorizar el contenido.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          QuizScreen.routeName,
                          arguments:
                              (course['topic'] as String?) ?? 'Curso',
                        );
                      },
                      child: const Text('Sí, hágamoslo'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Ahora no'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        if (modules.isEmpty)
          Card(
            color: AppColors.neutral,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aún no hay módulos para este curso.'),
            ),
          )
        else
          for (final m in modules)
            Opacity(
              opacity: (m['locked'] == true) ? 0.5 : 1,
              child: Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text((m['title'] as String?) ?? 'Módulo'),
                  children: [
                    for (final raw in (m['lessons'] as List? ?? const []))
                      _LessonTile(
                        module: m,
                        lesson: (raw as Map).cast<String, dynamic>(),
                        onCompleted: onReload,
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Map<String, dynamic> module;
  final Map<String, dynamic> lesson;
  final VoidCallback onCompleted;

  const _LessonTile({
    required this.module,
    required this.lesson,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final locked = (lesson['locked'] == true);
    final isPremiumLesson = (lesson['premium'] == true); // opcional en JSON
    final title = (lesson['title'] as String?) ?? 'Lección';
    final lessonId = (lesson['id'] as String?) ?? title;

    return ListTile(
      enabled: !locked,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremiumLesson)
            const Icon(Icons.lock_outline_rounded, size: 18),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: locked
          ? null
          : () async {
              final result = await Navigator.pushNamed(
                context,
                LessonView.routeName,
                arguments: {
                  'lessonId': lessonId,
                  'title': title,
                  'content': 'Contenido de $title',
                  // Flag premium global (OFF por defecto en MVP)
                  'isPremiumEnabled': AppConfig.premiumEnabled, // ← en vez de true/false fijo
                  'isPremiumLesson': isPremiumLesson,
                  'initialLang': 'es',
                },
              );

              // Evita usar BuildContext si el widget fue desmontado
              if (!context.mounted) return;

              if (result is Map && result['completed'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Completaste: $title')),
                );
                onCompleted(); // refresca outline si quieres reconsultar
              }
            },
    );
  }
}
