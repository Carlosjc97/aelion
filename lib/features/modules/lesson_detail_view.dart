// lib/features/modules/lesson_detail_view.dart
import 'package:flutter/material.dart';
import 'package:learning_ia/services/progress_service.dart';

class LessonDetailView extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic> module;
  final Map<String, dynamic> lesson;

  const LessonDetailView({
    super.key,
    required this.courseId,
    required this.module,
    required this.lesson,
  });

  @override
  State<LessonDetailView> createState() => _LessonDetailViewState();
}

class _LessonDetailViewState extends State<LessonDetailView> {
  bool _saving = false;
  String? _selected;
  bool _checked = false;
  bool _isCorrect = false;

  Future<void> _markCompleted() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ProgressService().markLessonCompleted(
        courseId: widget.courseId,
        moduleId: widget.module['id'] as String,
        lessonId: widget.lesson['id'] as String,
      );
      final nextXp = await ProgressService().addXp(50);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Lección completada! 🎉 XP total: $nextXp')),
      );
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _checkAnswer() {
    final quiz = widget.lesson['quiz'] as Map<String, dynamic>?;
    if (quiz == null || _selected == null) return;
    final correct = quiz['correct']?.toString().toLowerCase();
    setState(() {
      _checked = true;
      _isCorrect = (_selected == correct);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lesson = widget.lesson;
    final content = (lesson['content'] as String?) ?? '';
    final quiz = lesson['quiz'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: Text(lesson['title']?.toString() ?? 'Lección')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Objetivo de la lección', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              '• Comprender el concepto principal.\n'
              '• Realizar una pequeña práctica.\n'
              '• Pasar a la siguiente actividad cuando te sientas listo.',
            ),
            const SizedBox(height: 16),

            // Contenido explicativo
            if (content.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(content, style: theme.textTheme.bodyMedium),
              ),

            const SizedBox(height: 20),

            // Bloque de quiz
            if (quiz != null) ...[
              Text('Pregunta', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                quiz['q']?.toString() ?? '',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),

              // Opciones
              for (final opt in ['a', 'b', 'c', 'd'])
                RadioListTile<String>(
                  title: Text('${opt.toUpperCase()}) ${quiz[opt]}'),
                  value: opt,
                  groupValue: _selected,
                  onChanged: (val) {
                    setState(() {
                      _selected = val;
                      _checked = false;
                    });
                  },
                ),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _selected == null ? null : _checkAnswer,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Comprobar respuesta'),
              ),
              if (_checked) ...[
                const SizedBox(height: 8),
                Text(
                  _isCorrect
                      ? '✅ ¡Correcto!'
                      : '❌ Incorrecto. La respuesta era ${quiz['correct'].toString().toUpperCase()}.',
                  style: TextStyle(
                    color: _isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],

            // Botón de completar
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _markCompleted,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.emoji_events_outlined),
                label: const Text('Marcar lección como completada'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Consejo: si algo no te queda claro, vuelve a leer y practica 2 minutos más antes de avanzar.',
            ),
          ],
        ),
      ),
    );
  }
}
