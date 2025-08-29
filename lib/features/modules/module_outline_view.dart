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
      // 1) intenta cargar desde progreso local
      final local = await progress.load(courseId);
      if (local != null) {
        setState(() => course = local);
        loading = false;
        return;
      }

      // 2) si no hay local, genera outline inicial (API o fallback)
      final outline = await CourseApiService.generateOutline(
        topic: widget.topic ?? 'Curso',
      );

      // Asegura desbloqueo inicial mínimo
      final rawModules = outline['modules'];
      if (rawModules is List) {
        final modules = rawModules.cast<Map<String, dynamic>>();
        if (modules.isNotEmpty) {
          modules.first['locked'] = false;
          final rawLessons = modules.first['lessons'];
          if (rawLessons is List && rawLessons.isNotEmpty) {
            final firstLessons = rawLessons.cast<Map<String, dynamic>>();
            firstLessons.first['locked'] = false;
          }
        }
      }

      setState(() => course = outline);
      await progress.save(courseId, outline);
    } catch (_) {
      // Fallback seguro
      final fallback = {
        "topic": widget.topic ?? "Módulo de ejemplo",
        "level": "beginner",
        "estimated_hours": 2,
        "modules": [
          {
            "id": "m1",
            "title": "Introducción",
            "locked": false,
            "lessons": [
              {"id": "m1l1", "title": "Definición", "locked": false, "status": "todo"},
              {"id": "m1l2", "title": "Ejemplo práctico", "locked": true, "status": "todo", "premium": true},
            ]
          },
          {
            "id": "m2",
            "title": "Práctica intermedia",
            "locked": true,
            "lessons": [
              {"id": "m2l1", "title": "Widgets estatales", "locked": true, "status": "todo"},
            ]
          },
          {
            "id": "m3",
            "title": "Proyecto avanzado",
            "locked": true,
            "premium": true,
            "lessons": [
              {"id": "m3l1", "title": "Integración API", "locked": true, "status": "todo"},
            ]
          }
        ]
      };
      setState(() => course = fallback);
      await progress.save(courseId, fallback);
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
                      courseId: courseId,
                      onCourseUpdated: (updated) async {
                        await progress.save(courseId, updated);
                        if (!mounted) return;
                        setState(() => course = updated);
                      },
                      onApplyLevel: (level) async {
                        if (course == null) return;
                        final updated = _applyLevelToCourse(course!, level);
                        await progress.save(courseId, updated);
                        if (!mounted) return;
                        setState(() => course = updated);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Nivel aplicado: $level')),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Map<String, dynamic> _applyLevelToCourse(Map<String, dynamic> original, String level) {
    final updated = Map<String, dynamic>.from(original);
    final raw = updated['modules'];
    final modules = (raw is List)
        ? raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList()
        : <Map<String, dynamic>>[];

    // 1) Ordenar según nivel (heurística por título si no hay metadata)
    int scoreFor(Map<String, dynamic> m) {
      final t = ((m['title'] as String?) ?? '').toLowerCase();
      final isIntro = t.contains('intro') || t.contains('introduc') || t.contains('básic') || t.contains('fundament');
      final isAdvanced = t.contains('avanz') || t.contains('proyecto') || t.contains('project') || t.contains('advanced');
      switch (level) {
        case 'beginner':
          // Intro primero
          return isIntro ? 0 : (isAdvanced ? 2 : 1);
        case 'intermediate':
          // intermedio al medio
          return isAdvanced ? 2 : (isIntro ? 0 : 1);
        case 'advanced':
        default:
          // Avanzado primero
          return isAdvanced ? 0 : (isIntro ? 2 : 1);
      }
    }

    modules.sort((a, b) => scoreFor(a).compareTo(scoreFor(b)));

    // 2) Bloqueos mínimos por nivel
    for (final m in modules) {
      m['locked'] = true;
      final raws = m['lessons'];
      if (raws is List) {
        for (var l in raws) {
          (l as Map)['locked'] = true;
        }
      }
    }

    int unlockCount;
    switch (level) {
      case 'beginner':
        unlockCount = 1;
        break;
      case 'intermediate':
        unlockCount = modules.length >= 2 ? 2 : 1;
        break;
      case 'advanced':
      default:
        unlockCount = modules.length; // todo habilitado
        break;
    }

    for (var i = 0; i < modules.length && i < unlockCount; i++) {
      modules[i]['locked'] = false;
      final raws = modules[i]['lessons'];
      if (raws is List && raws.isNotEmpty) {
        final first = (raws.first as Map);
        first['locked'] = false;
      }
    }

    updated['modules'] = modules;
    updated['level'] = level;
    return updated;
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
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
                FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
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
  final String courseId;
  final Future<void> Function(Map<String, dynamic> updated) onCourseUpdated;
  final Future<void> Function(String level) onApplyLevel;

  const _OutlineList({
    required this.course,
    required this.courseId,
    required this.onCourseUpdated,
    required this.onApplyLevel,
  });

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
                const Text('10 preguntas para ajustar el nivel y priorizar el contenido.'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          QuizScreen.routeName,
                          arguments: (course['topic'] as String?) ?? 'Curso',
                        );
                        if (!context.mounted) return;
                        if (result is Map && result['quizPassed'] == true) {
                          final String level = (result['level'] as String?) ?? 'beginner';
                          await onApplyLevel(level);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Resultados aplicados: $level')),
                          );
                        }
                      },
                      child: const Text('Sí, hágamoslo'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(onPressed: () {}, child: const Text('Ahora no')),
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
                  title: Row(
                    children: [
                      Expanded(child: Text((m['title'] as String?) ?? 'Módulo')),
                      if ((m['premium'] == true) && AppConfig.premiumEnabled == false)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.lock_outline_rounded, size: 18),
                        ),
                    ],
                  ),
                  children: [
                    for (final raw in (m['lessons'] as List? ?? const []))
                      _LessonTile(
                        courseId: courseId,
                        course: course,
                        module: (m),
                        lesson: (raw as Map).cast<String, dynamic>(),
                        onCourseUpdated: onCourseUpdated,
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
  final String courseId;
  final Map<String, dynamic> course;
  final Map<String, dynamic> module;
  final Map<String, dynamic> lesson;
  final Future<void> Function(Map<String, dynamic> updated) onCourseUpdated;

  const _LessonTile({
    required this.courseId,
    required this.course,
    required this.module,
    required this.lesson,
    required this.onCourseUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final locked = (lesson['locked'] == true);
    final isPremiumLesson = (lesson['premium'] == true);
    final title = (lesson['title'] as String?) ?? 'Lección';
    final lessonId = (lesson['id'] as String?) ?? title;
    final moduleId = (module['id'] as String?) ?? 'm?';

    return ListTile(
      enabled: !locked,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremiumLesson && AppConfig.premiumEnabled == false)
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
                  'courseId': courseId,
                  'moduleId': moduleId,
                  'lessonId': lessonId,
                  'title': title,
                  'content': 'Contenido de $title',
                  'isPremiumEnabled': AppConfig.premiumEnabled,
                  'isPremiumLesson': isPremiumLesson,
                  'initialLang': 'es',
                },
              );
              if (!context.mounted) return;

              if (result is Map && result['completed'] == true) {
                final svc = ProgressService();
                final updated = await svc.markLessonCompleted(
                  courseId: courseId,
                  moduleId: moduleId,
                  lessonId: lessonId,
                );
                if (updated != null) {
                  await onCourseUpdated(updated);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Completaste: $title')),
                  );
                }
              }
            },
    );
  }
}
