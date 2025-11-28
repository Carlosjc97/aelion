import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/typography.dart';

import '../models/lesson_view_config.dart';
import '../widgets/lesson_header_widget.dart';
import '../widgets/lesson_takeaway_card.dart';
import '../widgets/practice_exercise_card.dart';

class GuidedPracticeScreen extends StatefulWidget {
  const GuidedPracticeScreen({super.key, required this.config});

  static const routeName = '/lesson/guided-practice';

  final LessonViewConfig config;

  @override
  State<GuidedPracticeScreen> createState() => _GuidedPracticeScreenState();
}

class _GuidedPracticeScreenState extends State<GuidedPracticeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _validated = false;
  String? _feedback;
  bool _validating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final practice = widget.config.practice;
    return Scaffold(
      appBar: AppBar(title: Text(widget.config.lessonTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LessonHeaderWidget(
            moduleTitle: widget.config.moduleTitle,
            hook: widget.config.hook,
          ),
          const SizedBox(height: 16),
          Text('Conceptos clave', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          MarkdownBody(
            data: widget.config.theory,
            selectable: true,
          ),
          if (practice != null) ...[
            const SizedBox(height: 20),
            PracticeExerciseCard(
              prompt: practice.prompt,
              controller: _controller,
              buttonLabel: _validated ? 'Completado' : 'Validar',
              onValidate: _validated
                  ? () {}
                  : () => _validatePractice(practice.expected),
              isValidating: _validating,
              feedback: _feedback,
              feedbackColor: _validated
                  ? EdaptiaColors.success
                  : EdaptiaColors.textSecondary,
            ),
            if (widget.config.hint?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('¿Necesitas una pista?'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(widget.config.hint!,
                        style: EdaptiaTypography.body),
                  ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 16),
          Text('Ejemplo', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          Text(widget.config.exampleGlobal, style: EdaptiaTypography.body),
          const SizedBox(height: 24),
          LessonTakeawayCard(takeaway: widget.config.takeaway),
        ],
      ),
    );
  }

  Future<void> _validatePractice(String expected) async {
    final answer = _controller.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comparte tu respuesta para validarla.')),
      );
      return;
    }

    setState(() {
      _validating = true;
      _feedback = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));
    final isCorrect = answer.toLowerCase() == expected.trim().toLowerCase();
    setState(() {
      _validating = false;
      _validated = isCorrect;
      _feedback = isCorrect
          ? '¡Excelente! Tu respuesta coincide con la solución esperada.'
          : 'Revisa la teoría y vuelve a intentarlo.';
    });
  }
}
