import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'package:edaptia/core/design_system/typography.dart';

import '../models/lesson_view_config.dart';
import '../widgets/lesson_header_widget.dart';
import '../widgets/lesson_takeaway_card.dart';

class AppliedProjectScreen extends StatefulWidget {
  const AppliedProjectScreen({super.key, required this.config});

  static const routeName = '/lesson/applied-project';

  final LessonViewConfig config;

  @override
  State<AppliedProjectScreen> createState() => _AppliedProjectScreenState();
}

class _AppliedProjectScreenState extends State<AppliedProjectScreen> {
  final TextEditingController _approachController = TextEditingController();
  final TextEditingController _deliverableController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _approachController.dispose();
    _deliverableController.dispose();
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
          Text('Reto aplicado', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          MarkdownBody(data: widget.config.theory),
          const SizedBox(height: 16),
          Text('Ejemplo guía', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          Text(widget.config.exampleGlobal, style: EdaptiaTypography.body),
          const SizedBox(height: 20),
          _buildField(
            controller: _approachController,
            label: 'Plan de acción',
            hint: 'Describe cómo resolverás este proyecto paso a paso',
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _deliverableController,
            label: 'Entregable esperado',
            hint:
                '¿Qué entregable concreto generarás? (ej. dashboard, storyline, briefing)',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitted ? null : _submitProject,
            child: Text(_submitted ? 'Proyecto enviado' : 'Enviar proyecto'),
          ),
          const SizedBox(height: 16),
          if (_submitted) LessonTakeawayCard(takeaway: widget.config.takeaway),
        ],
      ),
    );
  }

  Widget _buildField({
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
          maxLines: 6,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _submitProject() {
    if (_approachController.text.trim().isEmpty ||
        _deliverableController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Completa los campos para enviar tu proyecto.')),
      );
      return;
    }
    setState(() => _submitted = true);
  }
}
