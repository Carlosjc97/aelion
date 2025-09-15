// lib/features/modules/module_outline_view.dart
import 'package:flutter/material.dart';

import 'package:learning_ia/services/progress_service.dart';
import 'package:learning_ia/features/lesson/lesson_view.dart';
// ⬇️ Import CORRECTO (está en lib/services/)
import 'package:learning_ia/services/course_api_service.dart';

class ModuleOutlineView extends StatefulWidget {
  static const routeName = '/module';
  final String? topic;

  const ModuleOutlineView({super.key, this.topic});

  @override
  State<ModuleOutlineView> createState() => _ModuleOutlineViewState();
}

class _ModuleOutlineViewState extends State<ModuleOutlineView> {
  bool _loading = true;
  Map<String, dynamic>? _outline;
  late final String _courseId;

  @override
  void initState() {
    super.initState();
    _courseId =
        widget.topic ??
        (ModalRoute.of(context)?.settings.arguments as String?) ??
        'Curso';
    _loadOutline();
  }

  Future<void> _loadOutline() async {
    setState(() => _loading = true);
    final svc = ProgressService();
    try {
      // 1) intenta cargar outline guardado
      var outline = await svc.load(_courseId);

      // 2) si no hay, genera (proxy/fallback) y guarda
      if (outline == null) {
        outline = await CourseApiService.generateOutline(topic: _courseId);
        await svc.save(_courseId, outline);
      }

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

  @override
  Widget build(BuildContext context) {
    final t = _courseId;

    return Scaffold(
      appBar: AppBar(title: Text(t), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_outline == null)
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No hay outline disponible'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _loadOutline,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _buildOutline(context),
    );
  }

  Widget _buildOutline(BuildContext context) {
    final modules = (_outline!['modules'] as List?) ?? const [];
    if (modules.isEmpty) {
      return const Center(child: Text('Sin módulos por ahora'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      itemCount: modules.length,
      itemBuilder: (context, i) {
        final m = Map<String, dynamic>.from(modules[i] as Map);
        final lessons = (m['lessons'] as List?) ?? const [];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            initiallyExpanded: i == 0,
            title: Text(m['title']?.toString() ?? 'Módulo ${i + 1}'),
            subtitle: Text(m['locked'] == true ? 'Bloqueado' : 'Desbloqueado'),
            children: [
              for (final raw in lessons)
                _LessonTile(
                  courseId: _courseId,
                  module: m,
                  lesson: Map<String, dynamic>.from(raw as Map),
                  onChanged: (updatedOutline) {
                    setState(() => _outline = updatedOutline);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LessonTile extends StatelessWidget {
  final String courseId;
  final Map<String, dynamic> module;
  final Map<String, dynamic> lesson;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _LessonTile({
    required this.courseId,
    required this.module,
    required this.lesson,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final locked = lesson['locked'] == true;
    final done = (lesson['status']?.toString() ?? 'todo') == 'done';
    final premium = lesson['premium'] == true;

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
      title: Text(lesson['title']?.toString() ?? 'Lección'),
      subtitle: Text(
        locked
            ? 'Bloqueada'
            : (premium ? 'Premium' : (done ? 'Completada' : 'Pendiente')),
      ),
      onTap: locked
          ? null
          : () async {
              // Abre la lección
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonView(
                    courseId: courseId,
                    moduleId: module['id'] as String,
                    lessonId: lesson['id'] as String,
                    title: (lesson['title'] as String?) ?? 'Lección',
                    premium: premium,
                  ),
                ),
              );

              // Si volvió con true, recarga outline desde storage
              if (ok == true) {
                final outline = await ProgressService().load(courseId);
                if (outline != null) onChanged(outline);
              }
            },
    );
  }
}
