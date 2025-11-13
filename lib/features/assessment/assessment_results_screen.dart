import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';

class AssessmentResultsScreen extends StatefulWidget {
  const AssessmentResultsScreen({
    super.key,
    required this.theta,
    required this.responseCorrectness,
    required this.bandLabel,
    required this.scorePct,
    required this.isGeneratingPlan,
    required this.onStartPlan,
    required this.onClose,
    required this.topic,
    this.onGapsResolved,
  });

  final double theta;
  final List<bool> responseCorrectness;
  final String bandLabel;
  final int scorePct;
  final bool isGeneratingPlan;
  final VoidCallback onStartPlan;
  final VoidCallback onClose;
  final String topic;
  final ValueChanged<List<String>>? onGapsResolved;

  @override
  State<AssessmentResultsScreen> createState() =>
      _AssessmentResultsScreenState();
}

class _AssessmentResultsScreenState extends State<AssessmentResultsScreen> {
  late final ConfettiController _confettiController;
  bool _emittedGaps = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    )..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fallbackTopic = l10n.quizTitle;
    final topicDisplay =
        widget.topic.trim().isNotEmpty ? widget.topic.trim() : fallbackTopic;
    final topicUpper = topicDisplay.toUpperCase();
    final levelLabel = _levelFromTheta(widget.theta);
    final percentile = _percentileFromTheta(widget.theta);
    final isSpanish = l10n.localeName.startsWith('es');
    final strengths =
        _strengthsForLevel(levelLabel, isSpanish, topicDisplay);
    final gaps = _gapsForLevel(levelLabel, isSpanish, topicDisplay);
    final path = _pathForLevel(levelLabel, isSpanish, topicDisplay);

    if (!_emittedGaps && widget.onGapsResolved != null) {
      _emittedGaps = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onGapsResolved?.call(List<String>.from(gaps));
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.assessmentResultTitle(topicDisplay)),
        actions: [
          IconButton(
            tooltip: l10n.assessmentResultClose,
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildConfettiHeader(
                theme,
                l10n,
                levelLabel,
                percentile,
                topicUpper,
              ),
              const SizedBox(height: 16),
              _buildResponseSummary(l10n, theme),
              const SizedBox(height: 16),
              _buildListCard(
                title: l10n.assessmentResultStrengthsTitle,
                items: strengths,
                icon: Icons.check_circle,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildListCard(
                title: l10n.assessmentResultGapsTitle,
                items: gaps,
                icon: Icons.flag_outlined,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildPathCard(l10n, theme, path),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.share),
                onPressed: () => _shareResults(
                  levelLabel,
                  percentile,
                  topicDisplay,
                  l10n,
                ),
                label: Text(l10n.assessmentResultShare),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: widget.isGeneratingPlan ? null : widget.onStartPlan,
                child: widget.isGeneratingPlan
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.assessmentResultCta),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfettiHeader(
    ThemeData theme,
    AppLocalizations l10n,
    String level,
    int percentile,
    String topicLabel,
  ) {
    final cardColor = theme.colorScheme.primaryContainer;
    final onCard = theme.colorScheme.onPrimaryContainer;
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 25,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              theme.colorScheme.tertiary,
              Colors.orange.shade400,
            ],
          ),
          Card(
            color: cardColor,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.assessmentResultLevelLabel(topicLabel),
                    style: theme.textTheme.titleSmall?.copyWith(color: onCard),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    level,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: onCard,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.assessmentResultPercentile(percentile),
                    style: theme.textTheme.bodyMedium?.copyWith(color: onCard),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseSummary(AppLocalizations l10n, ThemeData theme) {
    final chips = widget.responseCorrectness;
    if (chips.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.assessmentResultResponsesTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(chips.length, (index) {
                final correct = chips[index];
                return Chip(
                  label: Text('Q${index + 1}'),
                  avatar: Icon(
                    correct ? Icons.check : Icons.close,
                    color: correct
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onError,
                    size: 18,
                  ),
                  backgroundColor: correct
                      ? theme.colorScheme.primary
                      : theme.colorScheme.errorContainer,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: correct
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onErrorContainer,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required List<String> items,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathCard(
    AppLocalizations l10n,
    ThemeData theme,
    List<_PathStep> steps,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.assessmentResultPlanTitle,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final step in steps)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(step.label),
                ),
                title: Text(step.title),
                subtitle: Text(step.subtitle),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareResults(
    String level,
    int percentile,
    String topic,
    AppLocalizations l10n,
  ) async {
    final message =
        l10n.assessmentResultShareMessage(level, topic, percentile);
    final slug = topic
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final deepLink = Uri.https(
      'edaptia.app',
      '/plan/share',
      {
        'topic': slug.isEmpty ? 'topic' : slug,
        'level': level,
        'score': widget.scorePct.toString(),
      },
    );
    final dynamicLink = Uri.https(
      'edaptia.page.link',
      '/',
      {
        'link': deepLink.toString(),
        'apn': 'com.aelion.learning',
        'ibi': 'com.aelion.learning',
        'ofl': deepLink.toString(),
      },
    );
    await Share.share('$message\n${dynamicLink.toString()}');
    await AnalyticsService().track(
      'share_results',
      properties: <String, Object?>{
        'topic': topic,
        'level': level,
        'score_pct': widget.scorePct,
        'percentile': percentile,
        'link': deepLink.toString(),
      },
    );
  }
}

int _percentileFromTheta(double theta) {
  final clamped = theta.clamp(-3.0, 3.0);
  final cdf = _normalCdf(clamped);
  return (cdf * 100).round().clamp(1, 99);
}

String _levelFromTheta(double theta) {
  if (theta > 1.5) return 'SENIOR';
  if (theta > 0.5) return 'MID-LEVEL';
  if (theta > -0.5) return 'JUNIOR';
  return 'BEGINNER';
}

List<String> _strengthsForLevel(String level, bool isSpanish, String topic) {
  final topicDisplay = topic.toUpperCase();
  if (isSpanish) {
    return _buildGenericStrengthsEs(level, topicDisplay);
  } else {
    return _buildGenericStrengthsEn(level, topicDisplay);
  }
}

List<String> _gapsForLevel(String level, bool isSpanish, String topic) {
  final topicDisplay = topic.toUpperCase();
  if (isSpanish) {
    return _buildGenericGapsEs(level, topicDisplay);
  } else {
    return _buildGenericGapsEn(level, topicDisplay);
  }
}

List<_PathStep> _pathForLevel(String level, bool isSpanish, String topic) {
  final topicDisplay = topic;
  if (isSpanish) {
    return _buildGenericPathEs(level, topicDisplay);
  } else {
    return _buildGenericPathEn(level, topicDisplay);
  }
}

List<String> _buildGenericStrengthsEs(String level, String topic) {
  switch (level) {
    case 'SENIOR':
      return [
        'Dominas conceptos avanzados de $topic.',
        'Puedes resolver problemas complejos con confianza.',
        'Tu conocimiento te permite enseñar a otros.',
      ];
    case 'MID-LEVEL':
      return [
        'Comprendes los fundamentos de $topic con soltura.',
        'Interpretas y aplicas conceptos intermedios.',
        'Trabajas de forma autónoma en proyectos.',
      ];
    case 'JUNIOR':
      return [
        'Comprendes los conceptos básicos de $topic.',
        'Puedes identificar y corregir errores comunes.',
        'Documentas tu trabajo de forma clara.',
      ];
    default:
      return [
        'Das tus primeros pasos en $topic.',
        'Identificas conceptos clave del tema.',
        'Aprendes rápidamente con ejemplos guiados.',
      ];
  }
}

List<String> _buildGenericStrengthsEn(String level, String topic) {
  switch (level) {
    case 'SENIOR':
      return [
        'You master advanced concepts in $topic.',
        'You solve complex problems confidently.',
        'Your knowledge enables you to teach others.',
      ];
    case 'MID-LEVEL':
      return [
        'You grasp $topic fundamentals with ease.',
        'You interpret and apply intermediate concepts.',
        'You work autonomously on projects.',
      ];
    case 'JUNIOR':
      return [
        'You understand the basics of $topic.',
        'You can identify and fix common mistakes.',
        'You document your work clearly.',
      ];
    default:
      return [
        'You are getting started with $topic.',
        'You recognize key concepts in the subject.',
        'You learn quickly from guided examples.',
      ];
  }
}

List<String> _buildGenericGapsEs(String level, String topic) {
  switch (level) {
    case 'SENIOR':
      return [
        'Profundizar en técnicas avanzadas de $topic.',
        'Experimentar con casos de uso complejos.',
        'Crear recursos y guías para tu equipo.',
      ];
    case 'MID-LEVEL':
      return [
        'Dominar conceptos avanzados de $topic.',
        'Aplicar técnicas en proyectos de mayor escala.',
        'Desarrollar expertise en áreas especializadas.',
      ];
    case 'JUNIOR':
      return [
        'Practicar conceptos intermedios de $topic.',
        'Implementar proyectos completos.',
        'Automatizar procesos repetitivos.',
      ];
    default:
      return [
        'Reforzar conceptos fundamentales de $topic.',
        'Practicar con ejercicios guiados.',
        'Familiarizarte con herramientas básicas.',
      ];
  }
}

List<String> _buildGenericGapsEn(String level, String topic) {
  switch (level) {
    case 'SENIOR':
      return [
        'Go deeper into advanced $topic techniques.',
        'Experiment with complex use cases.',
        'Create resources and guides for your team.',
      ];
    case 'MID-LEVEL':
      return [
        'Master advanced $topic concepts.',
        'Apply techniques to larger-scale projects.',
        'Develop expertise in specialized areas.',
      ];
    case 'JUNIOR':
      return [
        'Practice intermediate $topic concepts.',
        'Implement complete projects.',
        'Automate repetitive processes.',
      ];
    default:
      return [
        'Strengthen fundamental $topic concepts.',
        'Practice with guided exercises.',
        'Get familiar with basic tools.',
      ];
  }
}

List<_PathStep> _buildGenericPathEs(String level, String topic) {
  switch (level) {
    case 'SENIOR':
      return [
        _PathStep(
          label: 'M4',
          title: '$topic Avanzado',
          subtitle: 'Domina técnicas complejas.',
        ),
        _PathStep(
          label: 'M5',
          title: 'Optimización',
          subtitle: 'Mejora tu expertise y eficiencia.',
        ),
        _PathStep(
          label: 'M6',
          title: 'Mentoría',
          subtitle: 'Comparte conocimiento y lidera.',
        ),
      ];
    case 'MID-LEVEL':
      return [
        _PathStep(
          label: 'M2',
          title: '$topic Intermedio',
          subtitle: 'Profundiza en conceptos clave.',
        ),
        _PathStep(
          label: 'M3',
          title: 'Aplicación Práctica',
          subtitle: 'Implementa proyectos reales.',
        ),
        _PathStep(
          label: 'M4',
          title: 'Técnicas Avanzadas',
          subtitle: 'Expande tus habilidades.',
        ),
      ];
    case 'JUNIOR':
      return [
        _PathStep(
          label: 'M1',
          title: 'Fundamentos de $topic',
          subtitle: 'Refuerza conceptos básicos.',
        ),
        _PathStep(
          label: 'M2',
          title: 'Práctica Guiada',
          subtitle: 'Aplica lo aprendido.',
        ),
        _PathStep(
          label: 'M3',
          title: 'Proyectos Simples',
          subtitle: 'Construye confianza práctica.',
        ),
      ];
    default:
      return [
        _PathStep(
          label: 'M0',
          title: 'Introducción a $topic',
          subtitle: 'Aprende paso a paso.',
        ),
        _PathStep(
          label: 'M1',
          title: 'Fundamentos',
          subtitle: 'Domina los conceptos básicos.',
        ),
        _PathStep(
          label: 'M2',
          title: 'Primeros Pasos Prácticos',
          subtitle: 'Aplica lo que aprendes.',
        ),
      ];
  }
}

List<_PathStep> _buildGenericPathEn(String level, String topic) {
  switch (level) {
    case 'SENIOR':
      return [
        _PathStep(
          label: 'M4',
          title: 'Advanced $topic',
          subtitle: 'Master complex techniques.',
        ),
        _PathStep(
          label: 'M5',
          title: 'Optimization',
          subtitle: 'Improve your expertise and efficiency.',
        ),
        _PathStep(
          label: 'M6',
          title: 'Mentorship',
          subtitle: 'Share knowledge and lead.',
        ),
      ];
    case 'MID-LEVEL':
      return [
        _PathStep(
          label: 'M2',
          title: 'Intermediate $topic',
          subtitle: 'Deepen key concepts.',
        ),
        _PathStep(
          label: 'M3',
          title: 'Practical Application',
          subtitle: 'Implement real projects.',
        ),
        _PathStep(
          label: 'M4',
          title: 'Advanced Techniques',
          subtitle: 'Expand your skills.',
        ),
      ];
    case 'JUNIOR':
      return [
        _PathStep(
          label: 'M1',
          title: '$topic Fundamentals',
          subtitle: 'Reinforce basic concepts.',
        ),
        _PathStep(
          label: 'M2',
          title: 'Guided Practice',
          subtitle: 'Apply what you learned.',
        ),
        _PathStep(
          label: 'M3',
          title: 'Simple Projects',
          subtitle: 'Build practical confidence.',
        ),
      ];
    default:
      return [
        _PathStep(
          label: 'M0',
          title: 'Introduction to $topic',
          subtitle: 'Learn step by step.',
        ),
        _PathStep(
          label: 'M1',
          title: 'Fundamentals',
          subtitle: 'Master the basics.',
        ),
        _PathStep(
          label: 'M2',
          title: 'First Practical Steps',
          subtitle: 'Apply what you learn.',
        ),
      ];
  }
}

double _normalCdf(double x) {
  const double a1 = 0.254829592;
  const double a2 = -0.284496736;
  const double a3 = 1.421413741;
  const double a4 = -1.453152027;
  const double a5 = 1.061405429;
  const double p = 0.3275911;

  final sign = x < 0 ? -1.0 : 1.0;
  final absX = x.abs() / math.sqrt2;
  final t = 1.0 / (1.0 + p * absX);
  final y = 1.0 -
      (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) *
          t *
          math.exp(-absX * absX);
  return 0.5 * (1.0 + sign * y);
}

class _PathStep {
  const _PathStep({
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final String title;
  final String subtitle;
}
