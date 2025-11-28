import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/typography.dart';

import '../models/lesson_view_config.dart';
import '../widgets/lesson_header_widget.dart';
import '../widgets/lesson_takeaway_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.config});

  static const routeName = '/lesson/activity';

  final LessonViewConfig config;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final List<String> _steps = [
    'Comprende la teoría: ${widget.config.theory.split('.').first.trim()}',
    'Aplica el ejemplo: ${widget.config.exampleGlobal}',
    if (widget.config.practice != null) widget.config.practice!.prompt,
    'Comparte una mejora o idea adicional',
  ];
  late final List<bool> _completedSteps =
      List<bool>.filled(_steps.length, false, growable: false);
  final TextEditingController _notesController = TextEditingController();

  bool _finished = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Actividad guiada', style: EdaptiaTypography.title3),
          const SizedBox(height: 12),
          ..._steps.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value;
            return CheckboxListTile(
              value: _completedSteps[index],
              onChanged: (value) => setState(() {
                _completedSteps[index] = value ?? false;
              }),
              title: Text(text),
            );
          }),
          const SizedBox(height: 12),
          Text('Notas rápidas', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              hintText:
                  'Describe cómo ejecutarías esta actividad en tu contexto',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _finished ? null : _completeActivity,
            child: Text(
                _finished ? 'Actividad completada' : 'Marcar como completada'),
          ),
          const SizedBox(height: 16),
          if (_finished) LessonTakeawayCard(takeaway: widget.config.takeaway),
        ],
      ),
    );
  }

  void _completeActivity() {
    final allChecked = _completedSteps.every((value) => value);
    if (!allChecked || _notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Completa todos los pasos y agrega notas.')),
      );
      return;
    }
    setState(() => _finished = true);
  }
}
