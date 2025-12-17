import 'package:flutter/material.dart';

import 'package:edaptia/config/beta_config.dart';
import 'package:edaptia/features/adaptive_journey/adaptive_journey_screen.dart';
import 'package:edaptia/features/quiz/quiz_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/course_api_service.dart';

/// Micro-lesson intro screen for beta simplified flow.
///
/// Shows a quick 2-3 minute demo lesson BEFORE the quiz to demonstrate value.
/// This reduces friction and shows users what they'll learn before asking for assessment.
class MicroLessonIntroScreen extends StatefulWidget {
  const MicroLessonIntroScreen({
    super.key,
    required this.topic,
    required this.language,
  });

  static const routeName = '/micro-lesson-intro';

  final String topic;
  final String language;

  @override
  State<MicroLessonIntroScreen> createState() => _MicroLessonIntroScreenState();
}

class _MicroLessonIntroScreenState extends State<MicroLessonIntroScreen> {
  bool _loading = false;
  bool _lessonCompleted = false;
  final DateTime _lessonStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Track first lesson viewed
    AnalyticsService().trackFirstLessonViewed(
      topic: widget.topic,
      lessonType: 'micro',
    );
  }

  void _markLessonComplete() {
    if (_lessonCompleted) return;

    setState(() => _lessonCompleted = true);

    final durationSeconds = DateTime.now().difference(_lessonStartTime).inSeconds;
    AnalyticsService().trackFirstLessonCompleted(
      topic: widget.topic,
      durationSeconds: durationSeconds,
    );
  }

  Future<void> _startPersonalizedQuiz() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      // Track quiz choice
      await AnalyticsService().trackQuizStarted(
        topic: widget.topic,
        trigger: 'user_choice',
      );

      if (!mounted) return;

      await Navigator.of(context).pushReplacementNamed(
        QuizScreen.routeName,
        arguments: QuizScreenArgs(
          topic: widget.topic,
          language: widget.language,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _skipToStandardLesson() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      if (!mounted) return;

      // Skip quiz, go directly to lessons with intermediate band (default)
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AdaptiveJourneyScreen(
            topic: widget.topic,
            target: widget.topic,
            initialBand: PlacementBand.intermediate,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Get demo content based on topic (default to SQL for beta)
    final content = _getDemoContent(widget.topic, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(content.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Beta badge
                    if (BetaConfig.simplifiedFlow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '✨ Vista rápida de lo que aprenderás',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Lesson title
                    Text(
                      content.lessonTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.lessonSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Content sections
                    for (final section in content.sections) ...[
                      _ContentSection(section: section),
                      const SizedBox(height: 20),
                    ],

                    // Mark as complete button
                    if (!_lessonCompleted)
                      Center(
                        child: FilledButton.icon(
                          onPressed: _markLessonComplete,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('He terminado esta lección'),
                        ),
                      ),

                    if (_lessonCompleted) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.celebration, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '¡Bien hecho! Ahora elige tu próximo paso',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons (only show after lesson complete)
            if (_lessonCompleted)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Personalized quiz option
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _startPersonalizedQuiz,
                        icon: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.quiz_outlined),
                        label: const Text('Quiero plan personalizado'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tomarás un quiz rápido para adaptar el contenido a tu nivel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (BetaConfig.optionalQuiz) ...[
                      const SizedBox(height: 16),
                      // Skip to standard lesson
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _skipToStandardLesson,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Continuar sin quiz'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comenzarás con nivel intermedio',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.section});

  final _DemoContentSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.icon != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              section.icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
        const SizedBox(height: 12),
        Text(
          section.heading,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          section.body,
          style: theme.textTheme.bodyLarge,
        ),
        if (section.codeExample != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              section.codeExample!,
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.green[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
        if (section.bulletPoints != null) ...[
          const SizedBox(height: 12),
          for (final point in section.bulletPoints!)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: theme.textTheme.bodyLarge),
                  Expanded(
                    child: Text(point, style: theme.textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _DemoContent {
  const _DemoContent({
    required this.title,
    required this.lessonTitle,
    required this.lessonSubtitle,
    required this.sections,
  });

  final String title;
  final String lessonTitle;
  final String lessonSubtitle;
  final List<_DemoContentSection> sections;
}

class _DemoContentSection {
  const _DemoContentSection({
    required this.heading,
    required this.body,
    this.icon,
    this.codeExample,
    this.bulletPoints,
  });

  final String heading;
  final String body;
  final IconData? icon;
  final String? codeExample;
  final List<String>? bulletPoints;
}

_DemoContent _getDemoContent(String topic, AppLocalizations l10n) {
  // For beta, default to SQL content
  // In production, this could be dynamic based on topic
  return _DemoContent(
    title: 'SQL Básico',
    lessonTitle: 'Tu primera consulta SQL',
    lessonSubtitle: 'Aprende a extraer información de una base de datos en minutos',
    sections: [
      _DemoContentSection(
        icon: Icons.lightbulb_outline,
        heading: '¿Qué es SQL?',
        body:
            'SQL (Structured Query Language) es el lenguaje que usas para hablar con bases de datos. Es como hacer preguntas a una hoja de cálculo gigante que contiene información de tu empresa.',
      ),
      _DemoContentSection(
        icon: Icons.code,
        heading: 'Tu primera consulta: SELECT',
        body:
            'La consulta más básica es SELECT, que te permite ver datos. Es como decir "muéstrame esta información".',
        codeExample: 'SELECT nombre, edad\nFROM usuarios;',
      ),
      _DemoContentSection(
        icon: Icons.psychology,
        heading: '¿Qué hace este código?',
        body: 'Esta consulta dice:',
        bulletPoints: [
          'SELECT nombre, edad → "Quiero ver las columnas nombre y edad"',
          'FROM usuarios → "De la tabla llamada usuarios"',
          'El punto y coma (;) termina la consulta',
        ],
      ),
      _DemoContentSection(
        icon: Icons.rocket_launch,
        heading: '¿Por qué es útil?',
        body:
            'Con SQL puedes responder preguntas de negocio en segundos: ¿Cuántos clientes tenemos? ¿Cuál es el producto más vendido? ¿Qué usuarios se registraron hoy?',
      ),
    ],
  );
}
