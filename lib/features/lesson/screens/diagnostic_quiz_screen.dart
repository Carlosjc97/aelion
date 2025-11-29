import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/components/edaptia_card.dart';
import 'package:edaptia/core/design_system/typography.dart';
import 'package:edaptia/services/course/models.dart';
import 'package:edaptia/services/course_api_service.dart';

import '../models/lesson_view_config.dart';
import '../widgets/lesson_header_widget.dart';
import '../widgets/lesson_takeaway_card.dart';
import '../widgets/quiz_question_card.dart';

class DiagnosticQuizScreen extends StatefulWidget {
  const DiagnosticQuizScreen({super.key, required this.config});

  static const routeName = '/lesson/diagnostic-quiz';

  final LessonViewConfig config;

  @override
  State<DiagnosticQuizScreen> createState() => _DiagnosticQuizScreenState();
}

class _DiagnosticQuizScreenState extends State<DiagnosticQuizScreen> {
  late final List<AdaptiveMcq> _questions = widget.config.microQuiz;
  late final List<int?> _responses =
      List<int?>.filled(_questions.length, null, growable: false);
  bool _validated = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    // Mark lesson as visited automatically
    CourseApiService.markLessonVisited(
      topic: widget.config.courseId,
      moduleNumber: widget.config.moduleNumber,
      lessonIndex: widget.config.lessonIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.config.lessonTitle)),
        body: Center(
          child: Text(
            'No hay preguntas disponibles para esta lección.',
            style: EdaptiaTypography.body,
          ),
        ),
      );
    }

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
          ..._questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final options = _optionsFor(question);
            final correctIndex = _correctIndex(question);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: QuizQuestionCard(
                stem: 'Pregunta ${index + 1}: ${question.stem}',
                options: options,
                selectedIndex: _responses[index],
                correctIndex: _validated ? correctIndex : null,
                showResult: _validated,
                onSelect: _validated
                    ? null
                    : (choice) {
                        setState(() => _responses[index] = choice);
                      },
              ),
            );
          }),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _validated ? null : _validateAnswers,
            child: const Text('Validar respuestas'),
          ),
          if (_validated) ...[
            const SizedBox(height: 16),
            _buildScoreCard(),
            const SizedBox(height: 16),
            LessonTakeawayCard(takeaway: widget.config.takeaway),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Continuar'),
            ),
          ],
        ],
      ),
    );
  }

  void _validateAnswers() {
    if (_responses.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Responde todas las preguntas para continuar.')),
      );
      return;
    }

    var correct = 0;
    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (_responses[i] == _correctIndex(question)) {
        correct++;
      }
    }

    setState(() {
      _validated = true;
      _score = ((correct / _questions.length) * 100).round();
    });
  }

  Widget _buildScoreCard() {
    return EdaptiaCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: EdaptiaColors.cardLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tu resultado', style: EdaptiaTypography.title3),
          const SizedBox(height: 8),
          Text('$_score / 100', style: EdaptiaTypography.title2),
          const SizedBox(height: 8),
          Text(
            'Sigue practicando para dominar ${widget.config.moduleTitle}.',
            style: EdaptiaTypography.body,
          ),
        ],
      ),
    );
  }

  List<String> _optionsFor(AdaptiveMcq question) {
    final entries = question.options.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) => '${entry.key}. ${entry.value}').toList();
  }

  int _correctIndex(AdaptiveMcq question) {
    final entries = question.options.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.indexWhere((entry) => entry.key == question.correct);
  }
}
