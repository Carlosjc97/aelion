import 'package:flutter/material.dart';

import 'package:edaptia/features/adaptive_journey/adaptive_journey_screen.dart';
import 'package:edaptia/services/course_api_service.dart';

/// Adaptation Result Screen - Shows the user EXACTLY what adapted based on their quiz.
///
/// This screen is the KEY to solving P3: "La magia adaptativa no se visualiza"
/// It explicitly shows:
/// - Detected level
/// - Strengths identified
/// - Areas to improve
/// - What content was adjusted (omitted, prioritized, reinforced)
///
/// This transforms the quiz from "useless exam" to "powerful personalization tool"
class AdaptationResultScreen extends StatefulWidget {
  const AdaptationResultScreen({
    super.key,
    required this.topic,
    required this.band,
    required this.scorePct,
    this.strengths = const [],
    this.areasToImprove = const [],
  });

  final String topic;
  final PlacementBand band;
  final int scorePct;
  final List<String> strengths;
  final List<String> areasToImprove;

  @override
  State<AdaptationResultScreen> createState() => _AdaptationResultScreenState();
}

class _AdaptationResultScreenState extends State<AdaptationResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startLearning() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AdaptiveJourneyScreen(
            topic: widget.topic,
            target: widget.topic,
            initialBand: widget.band,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _getBandLabel(PlacementBand band) {
    switch (band) {
      case PlacementBand.basic:
        return 'Principiante';
      case PlacementBand.intermediate:
        return 'Intermedio';
      case PlacementBand.advanced:
        return 'Avanzado';
    }
  }

  Color _getBandColor(PlacementBand band) {
    switch (band) {
      case PlacementBand.basic:
        return Colors.green;
      case PlacementBand.intermediate:
        return Colors.blue;
      case PlacementBand.advanced:
        return Colors.purple;
    }
  }

  IconData _getBandIcon(PlacementBand band) {
    switch (band) {
      case PlacementBand.basic:
        return Icons.eco;
      case PlacementBand.intermediate:
        return Icons.trending_up;
      case PlacementBand.advanced:
        return Icons.rocket_launch;
    }
  }

  List<_AdaptationDetail> _getAdaptations() {
    switch (widget.band) {
      case PlacementBand.basic:
        return [
          _AdaptationDetail(
            icon: Icons.fast_forward,
            title: 'Empezamos desde cero',
            subtitle: 'Cubriremos los fundamentos paso a paso',
            color: Colors.green,
          ),
          _AdaptationDetail(
            icon: Icons.lightbulb_outline,
            title: 'Más explicaciones',
            subtitle: 'Incluimos ejemplos detallados y analogías simples',
            color: Colors.amber,
          ),
          _AdaptationDetail(
            icon: Icons.psychology,
            title: 'Práctica guiada',
            subtitle: 'Ejercicios con retroalimentación inmediata',
            color: Colors.blue,
          ),
        ];
      case PlacementBand.intermediate:
        return [
          _AdaptationDetail(
            icon: Icons.check_circle_outline,
            title: 'Omitimos lo básico',
            subtitle: 'Ya dominas los fundamentos, avanzamos directo',
            color: Colors.green,
          ),
          _AdaptationDetail(
            icon: Icons.trending_up,
            title: 'Priorizamos técnicas intermedias',
            subtitle: 'JOINs, subconsultas y optimización',
            color: Colors.blue,
          ),
          _AdaptationDetail(
            icon: Icons.build,
            title: 'Proyectos prácticos',
            subtitle: 'Casos de uso reales del mundo laboral',
            color: Colors.orange,
          ),
        ];
      case PlacementBand.advanced:
        return [
          _AdaptationDetail(
            icon: Icons.rocket_launch,
            title: 'Directo a lo avanzado',
            subtitle: 'Saltamos conceptos básicos e intermedios',
            color: Colors.purple,
          ),
          _AdaptationDetail(
            icon: Icons.speed,
            title: 'Optimización y rendimiento',
            subtitle: 'Índices, planes de ejecución, tuning',
            color: Colors.deepOrange,
          ),
          _AdaptationDetail(
            icon: Icons.architecture,
            title: 'Arquitectura y patrones',
            subtitle: 'Diseño de bases de datos escalables',
            color: Colors.indigo,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bandLabel = _getBandLabel(widget.band);
    final bandColor = _getBandColor(widget.band);
    final bandIcon = _getBandIcon(widget.band);
    final adaptations = _getAdaptations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Plan Personalizado'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Celebration icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                bandColor.withValues(alpha: 0.2),
                                bandColor.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            size: 40,
                            color: bandColor,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Main message
                        Text(
                          '¡Listo! Personalizamos tu camino',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Basándonos en tus respuestas, detectamos tu nivel y ajustamos todo el contenido para ti',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Detected level card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                bandColor.withValues(alpha: 0.1),
                                bandColor.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: bandColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(bandIcon, size: 48, color: bandColor),
                              const SizedBox(height: 12),
                              Text(
                                'Nivel detectado',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bandLabel,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: bandColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: widget.scorePct / 100,
                                backgroundColor: bandColor.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation(bandColor),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.scorePct}% de aciertos',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // What we adjusted
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Esto es lo que ajustamos para ti:',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Adaptation cards
                        for (final adaptation in adaptations) ...[
                          _AdaptationCard(adaptation: adaptation),
                          const SizedBox(height: 12),
                        ],

                        const SizedBox(height: 24),

                        // Value proposition
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.tips_and_updates,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Cada lección se adaptará a tu progreso. '
                                  'Si dominas un tema, avanzamos más rápido. '
                                  'Si necesitas refuerzo, profundizamos más.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // CTA Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _startLearning,
                      icon: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.school),
                      label: const Text('Comenzar mi plan personalizado'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: bandColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdaptationDetail {
  const _AdaptationDetail({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

class _AdaptationCard extends StatelessWidget {
  const _AdaptationCard({required this.adaptation});

  final _AdaptationDetail adaptation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: adaptation.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              adaptation.icon,
              color: adaptation.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adaptation.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  adaptation.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
