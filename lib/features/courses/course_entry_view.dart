import 'package:flutter/material.dart';
import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/features/quiz/quiz_screen.dart';

class CourseEntryView extends StatefulWidget {
  const CourseEntryView({super.key});
  static const routeName = '/course-entry';

  @override
  State<CourseEntryView> createState() => _CourseEntryViewState();
}

class _CourseEntryViewState extends State<CourseEntryView> {
  final TextEditingController _ctrl = TextEditingController();
  bool _generating = false;

  final _chips = const [
    'Flutter básico',
    'SQL para principiantes',
    'Data Science 101',
    'Lógica de programación',
  ];

  Future<void> _goToQuiz(String topic) async {
    if (topic.trim().isEmpty) return;
    setState(() => _generating = true);

    // Aquí luego conectaremos la IA para generar preguntas
    // Por ahora solo navegamos al Quiz con el tópico.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(topic: topic.trim())),
    );

    setState(() => _generating = false);

    if (!mounted || result == null) return;

    final score = result['score'] as int? ?? 0;
    final level = result['level'] as String? ?? 'unknown';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Test completado: $score/10 • nivel: $level')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final cs = th.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Text('Toma un curso', style: th.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Busca un tema y genera un mini test de 10 preguntas.',
              style: th.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),

            // Card con buscador y botón
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.neutral),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _goToQuiz,
                    decoration: InputDecoration(
                      hintText:
                          'Ej: Fundamentos de Flutter, Álgebra lineal, SQL…',
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _generating
                          ? null
                          : () => _goToQuiz(_ctrl.text),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: cs.secondaryContainer,
                        foregroundColor: cs.onSecondaryContainer,
                      ),
                      child: _generating
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Generar test'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Para ahorrar tokens: test de 10 preguntas. Luego generamos el curso por niveles y desbloqueo.',
                    textAlign: TextAlign.center,
                    style: th.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _chips.map((c) {
                return ActionChip(
                  label: Text(c),
                  onPressed: () => _goToQuiz(c),
                  backgroundColor: cs.surfaceContainerHighest,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
