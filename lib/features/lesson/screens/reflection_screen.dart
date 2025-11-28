import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/typography.dart';

import '../models/lesson_view_config.dart';
import '../widgets/lesson_header_widget.dart';
import '../widgets/lesson_takeaway_card.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key, required this.config});

  static const routeName = '/lesson/reflection';

  final LessonViewConfig config;

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final TextEditingController _insightController = TextEditingController();
  final TextEditingController _nextStepController = TextEditingController();
  final Set<int> _selectedPrompts = <int>{};
  bool _submitted = false;

  List<String> get _prompts => [
        '¿Qué concepto te retó más?',
        '¿Cómo aplicarías esto mañana?',
        '¿Qué dato te sorprendió?',
        '¿Qué necesitas investigar más?',
      ];

  @override
  void dispose() {
    _insightController.dispose();
    _nextStepController.dispose();
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
          Text('Reflexiona sobre tu progreso', style: EdaptiaTypography.title3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _prompts.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;
              final isSelected = _selectedPrompts.contains(index);
              return FilterChip(
                label: Text(text),
                selected: isSelected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedPrompts.add(index);
                    } else {
                      _selectedPrompts.remove(index);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _buildInput(
            controller: _insightController,
            label: 'Insight principal',
            hint: 'Escribe la idea que más resonó contigo',
          ),
          const SizedBox(height: 12),
          _buildInput(
            controller: _nextStepController,
            label: 'Próximo paso',
            hint: 'Define cómo aplicarás este aprendizaje',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitted ? null : _submitReflection,
            child:
                Text(_submitted ? 'Reflexión guardada' : 'Guardar reflexión'),
          ),
          if (_submitted) ...[
            const SizedBox(height: 16),
            LessonTakeawayCard(takeaway: widget.config.takeaway),
          ],
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: EdaptiaTypography.title3),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _submitReflection() {
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reflexión registrada')),
    );
  }
}
