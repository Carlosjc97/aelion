import 'package:flutter/material.dart';

import 'package:learning_ia/features/lesson/lesson_view.dart';
import 'package:learning_ia/services/course_api_service.dart';
import 'package:learning_ia/services/progress_service.dart';

class ModuleOutlineView extends StatefulWidget {
  static const routeName = '/module';
  final String? topic;

  const ModuleOutlineView({super.key, this.topic});

  @override
  State<ModuleOutlineView> createState() => _ModuleOutlineViewState();
}

class _ModuleOutlineViewState extends State<ModuleOutlineView> {
  bool _loading = true;
  bool _initialized = false;
  Map<String, dynamic>? _outline;
  late String _courseId;

  @override
  void initState() {
    super.initState();
    _courseId = (widget.topic?.trim().isNotEmpty ?? false)
        ? widget.topic!.trim()
        : 'Curso';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if ((widget.topic == null || widget.topic!.trim().isEmpty) &&
        args is String &&
        args.trim().isNotEmpty) {
      _courseId = args.trim();
    }

    _loadOutline();
  }

  Future<void> _loadOutline() async {
    setState(() => _loading = true);
    final svc = ProgressService();

    try {
      Map<String, dynamic>? outline = await svc.load(_courseId);
      if (outline == null || outline.isEmpty) {
        outline = await CourseApiService.generateOutline(topic: _courseId);
      }

      outline = _ensureUnlockState(outline);
      await svc.save(_courseId, outline);

      if (!mounted) return;
      setState(() {
        _outline = outline;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el outline: $e')),
      );
    }
  }

  Map<String, dynamic> _ensureUnlockState(Map<String, dynamic> outline) {
    final modulesRaw = outline['modules'];
    final modulesList = modulesRaw is List ? modulesRaw : const [];
    final normalizedModules = <Map<String, dynamic>>[];

    for (var mIdx = 0; mIdx < modulesList.length; mIdx++) {
      final rawModule = modulesList[mIdx];
      if (rawModule is! Map) continue;
      final moduleMap = Map<String, dynamic>.from(rawModule);
      final lessonsRaw = moduleMap['lessons'];
      final lessonsList = lessonsRaw is List ? lessonsRaw : const [];
      final normalizedLessons = <Map<String, dynamic>>[];

      for (var lIdx = 0; lIdx < lessonsList.length; lIdx++) {
        final rawLesson = lessonsList[lIdx];
        if (rawLesson is! Map) continue;
        final lessonMap = Map<String, dynamic>.from(rawLesson);
        final unlocked = mIdx == 0 && lIdx == 0;
        lessonMap['id'] =
            lessonMap['id']?.toString() ?? 'lesson-${mIdx + 1}-${lIdx + 1}';
        lessonMap['title'] =
            lessonMap['title']?.toString() ?? 'Leccion ${mIdx + 1}.${lIdx + 1}';
        lessonMap['locked'] = unlocked ? false : (lessonMap['locked'] == true);
        lessonMap['status'] = (lessonMap['status'] as String?) ?? 'todo';
        normalizedLessons.add(lessonMap);
      }

      if (normalizedLessons.isEmpty) {
        normalizedLessons.add({
          'id': 'lesson-${mIdx + 1}-1',
          'title': 'Leccion ${mIdx + 1}.1',
          'locked': mIdx == 0 ? false : true,
          'status': 'todo',
        });
      }

      final moduleLocked = mIdx == 0 ? false : (moduleMap['locked'] == true);
      if (normalizedLessons.isNotEmpty) {
        normalizedLessons[0]['locked'] = moduleLocked ? true : false;
      }

      normalizedModules.add({
        ...moduleMap,
        'id': moduleMap['id']?.toString() ?? 'module-${mIdx + 1}',
        'title': moduleMap['title']?.toString() ?? 'Modulo ${mIdx + 1}',
        'locked': moduleLocked,
        'lessons': normalizedLessons,
      });
    }

    if (normalizedModules.isEmpty) {
      normalizedModules.add({
        'id': 'module-1',
        'title': 'Modulo 1',
        'locked': false,
        'lessons': [
          {
            'id': 'lesson-1-1',
            'title': 'Leccion 1.1',
            'locked': false,
            'status': 'todo',
          },
        ],
      });
    }

    final hoursValue = outline['estimated_hours'];
    final parsedHours = int.tryParse('$hoursValue');

    final sanitized = {
      ...outline,
      'topic': outline['topic']?.toString() ?? _courseId,
      'level': outline['level']?.toString() ?? 'beginner',
      'modules': normalizedModules,
      'estimated_hours':
          parsedHours ?? _fallbackEstimatedHours(normalizedModules),
    };

    return sanitized;
  }

  int _fallbackEstimatedHours(List<Map<String, dynamic>> modules) {
    final totalLessons = modules.fold<int>(0, (sum, module) {
      final lessons = module['lessons'];
      if (lessons is List) return sum + lessons.length;
      return sum;
    });
    if (totalLessons == 0) return 6;
    return (totalLessons * 1.5).ceil();
  }

  Future<void> _regenerate() async {
    setState(() => _loading = true);
    try {
      var outline = await CourseApiService.generateOutline(topic: _courseId);
      outline = _ensureUnlockState(outline);
      await ProgressService().save(_courseId, outline);
      if (!mounted) return;
      setState(() {
        _outline = outline;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo regenerar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _outline?['topic']?.toString() ?? _courseId;

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _outline == null
          ? _EmptyState(onRetry: _loadOutline)
          : RefreshIndicator(
              onRefresh: _loadOutline,
              child: _buildOutline(context),
            ),
      floatingActionButton: _outline == null || _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _regenerate,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Regenerar'),
            ),
    );
  }

  Widget _buildOutline(BuildContext context) {
    final modules = (_outline!['modules'] as List?) ?? const [];
    if (modules.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 120),
        children: const [Center(child: Text('Sin Modulos por ahora'))],
      );
    }

    final level = _outline!['level']?.toString();
    final estimated = _outline!['estimated_hours'];

    final tiles = <Widget>[
      _OutlineSummary(level: level, estimatedHours: estimated),
      const SizedBox(height: 12),
    ];

    for (var i = 0; i < modules.length; i++) {
      final moduleRaw = modules[i];
      if (moduleRaw is! Map) continue;
      final module = Map<String, dynamic>.from(moduleRaw);
      final lessons = (module['lessons'] as List? ?? const [])
          .whereType<Map>()
          .map((lesson) => Map<String, dynamic>.from(lesson))
          .toList();

      tiles.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            initiallyExpanded: i == 0,
            title: Text(module['title']?.toString() ?? 'Modulo ${i + 1}'),
            subtitle: Text(
              module['locked'] == true ? 'Bloqueado' : 'Desbloqueado',
            ),
            children: [
              for (final lesson in lessons)
                _LessonTile(
                  courseId: _courseId,
                  moduleId: module['id']?.toString() ?? 'module-${i + 1}',
                  lesson: lesson,
                  onChanged: (outline) {
                    setState(() => _outline = outline);
                  },
                ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      children: tiles,
    );
  }
}

class _LessonTile extends StatelessWidget {
  final String courseId;
  final String moduleId;
  final Map<String, dynamic> lesson;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _LessonTile({
    required this.courseId,
    required this.moduleId,
    required this.lesson,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final locked = lesson['locked'] == true;
    final done = (lesson['status']?.toString() ?? 'todo') == 'done';
    final premium = lesson['premium'] == true;
    final description = lesson['description']?.toString();

    return ListTile(
      enabled: !locked,
      leading: Icon(
        done
            ? Icons.check_circle
            : (locked ? Icons.lock : Icons.circle_outlined),
        color: done
            ? Colors.green
            : (locked ? Theme.of(context).disabledColor : null),
      ),
      title: Text(lesson['title']?.toString() ?? 'Leccion'),
      subtitle: description != null && description.isNotEmpty
          ? Text(description, maxLines: 2, overflow: TextOverflow.ellipsis)
          : Text(
              locked
                  ? 'Bloqueada'
                  : (premium ? 'Premium' : (done ? 'Completada' : 'Pendiente')),
            ),
      onTap: locked
          ? null
          : () async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonView(
                    courseId: courseId,
                    moduleId: moduleId,
                    lessonId: lesson['id']?.toString() ?? 'lesson',
                    title: (lesson['title'] as String?) ?? 'Leccion',
                    description: description,
                    premium: premium,
                  ),
                ),
              );

              if (ok == true) {
                final outline = await ProgressService().load(courseId);
                if (outline != null) onChanged(outline);
              }
            },
    );
  }
}

class _OutlineSummary extends StatelessWidget {
  final String? level;
  final dynamic estimatedHours;

  const _OutlineSummary({required this.level, required this.estimatedHours});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final levelLabel = (level ?? 'beginner').toUpperCase();
    final hours = _formatHours(estimatedHours);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.track_changes_outlined, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nivel: $levelLabel',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Horas estimadas: $hours',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHours(dynamic value) {
    final number = int.tryParse('$value');
    if (number == null) return 'n/d';
    return '$number h';
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No hay outline disponible'),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
