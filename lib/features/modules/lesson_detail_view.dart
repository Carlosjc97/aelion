import 'package:flutter/material.dart';
import 'package:aelion/services/progress_service.dart';

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

  /// Ãndice seleccionado (0=a, 1=b, 2=c, 3=d)
  int? _selectedIndex;

  /// Estado del chequeo.
  bool _checked = false;
  bool _isCorrect = false;

  static const _letters = ['a', 'b', 'c', 'd'];

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
        SnackBar(
            content: Text('Â¡LecciÃ³n completada! ðŸŽ‰ XP total: $nextXp')),
      );
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _checkAnswer() {
    final quiz = widget.lesson['quiz'] as Map<String, dynamic>?;
    if (quiz == null || _selectedIndex == null) return;
    final correctLetter = (quiz['correct']?.toString().toLowerCase() ?? '');
    final correctIndex = _letters.indexOf(correctLetter);
    setState(() {
      _checked = true;
      _isCorrect = (_selectedIndex == correctIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lesson = widget.lesson;
    final content = (lesson['content'] as String?) ?? '';
    final quiz = lesson['quiz'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: Text(lesson['title']?.toString() ?? 'LecciÃ³n')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Objetivo de la lecciÃ³n', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'â€¢ Comprender el concepto principal.\n'
              'â€¢ Realizar una pequeÃ±a prÃ¡ctica.\n'
              'â€¢ Pasar a la siguiente actividad cuando te sientas listo.',
            ),
            const SizedBox(height: 16),

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

              /// âœ… Nuevo patrÃ³n: RadioGroup ancestro controla estado (no deprecado)
              RadioGroup<int>(
                groupValue: _selectedIndex,
                onChanged: (int? idx) {
                  setState(() {
                    _selectedIndex = idx;
                    _checked = false; // reset al cambiar opciÃ³n
                  });
                },
                child: Column(
                  children: [
                    for (var i = 0; i < _letters.length; i++)
                      if (quiz[_letters[i]] != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Radio<int>(value: i),
                          title: Text(
                            '${_letters[i].toUpperCase()}) ${quiz[_letters[i]]}',
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = i;
                              _checked = false;
                            });
                          },
                        ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _selectedIndex == null ? null : _checkAnswer,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Comprobar respuesta'),
              ),
              if (_checked) ...[
                const SizedBox(height: 8),
                Text(
                  _isCorrect
                      ? 'âœ… Â¡Correcto!'
                      : 'âŒ Incorrecto. La respuesta era ${quiz['correct'].toString().toUpperCase()}.',
                  style: TextStyle(
                    color: _isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],

            // BotÃ³n de completar
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
                label: const Text('Marcar lecciÃ³n como completada'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Consejo: si algo no te queda claro, vuelve a leer y practica 2 minutos mÃ¡s antes de avanzar.',
            ),
          ],
        ),
      ),
    );
  }
}