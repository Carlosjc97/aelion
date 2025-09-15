import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learning_ia/services/progress_service.dart';

class LessonView extends StatefulWidget {
  static const routeName = '/lesson';

  final String courseId;
  final String moduleId;
  final String lessonId;
  final String title;
  final bool premium;

  const LessonView({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
    required this.title,
    this.premium = false,
  });

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView>
    with SingleTickerProviderStateMixin {
  bool _completing = false;

  // Animación de +XP
  late final AnimationController _xpCtrl;
  late final Animation<double> _xpOpacity;
  late final Animation<Offset> _xpOffset;
  int _lastXp = 0;
  bool _showXp = false;

  @override
  void initState() {
    super.initState();
    _xpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _xpOpacity = CurvedAnimation(parent: _xpCtrl, curve: Curves.easeOutCubic);
    _xpOffset = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: const Offset(0, -0.6),
    ).animate(CurvedAnimation(parent: _xpCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _xpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (_completing) return;
    setState(() => _completing = true);

    final svc = ProgressService();

    try {
      // Actualiza outline (marca done + desbloquea siguiente)
      await svc.markLessonCompleted(
        courseId: widget.courseId,
        moduleId: widget.moduleId,
        lessonId: widget.lessonId,
      );

      // Racha diaria
      await svc.tickDailyStreak();

      // XP ganado (ajústalo si quieres)
      const gained = 20;
      _lastXp = await svc.addXp(gained);

      // Haptics
      HapticFeedback.lightImpact();

      // Animación
      await _playXpToast(gained);

      if (!mounted) return;

      // Mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('¡Lección completada! 🔓  XP total: $_lastXp'),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );

      Navigator.of(context).pop(true); // devolvemos éxito
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('No se pudo marcar la lección. Intenta de nuevo. ($e)'),
        ),
      );
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _playXpToast(int gained) async {
    setState(() => _showXp = true);
    _xpCtrl
      ..reset()
      ..forward();
    await _xpCtrl.forward();
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _showXp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (widget.premium)
                Card(
                  color: cs.secondaryContainer,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Contenido Premium',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Text('Objetivo de la lección', style: tt.titleMedium),
              const SizedBox(height: 6),
              Text(
                '• Comprender el concepto principal.\n'
                '• Realizar una pequeña práctica.\n'
                '• Pasar a la siguiente actividad cuando te sientas listo.',
                style: tt.bodyMedium,
              ),

              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline.withValues(alpha: .15)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contenido', style: tt.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Aquí va tu contenido real de la lección (texto, imágenes o widgets). '
                      'Puedes reemplazar este bloque con lo que ya tengas generado por IA o curado.',
                      style: tt.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _completing ? null : _handleComplete,
                icon: _completing
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.emoji_events_outlined),
                label: Text(
                  _completing
                      ? 'Guardando...'
                      : 'Marcar lección como completada',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'Consejo: si algo no te queda claro, vuelve a leer y practica 2 minutos más antes de avanzar.',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: .7),
                ),
              ),
            ],
          ),

          if (_showXp)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: SlideTransition(
                    position: _xpOffset,
                    child: FadeTransition(
                      opacity: _xpOpacity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: .25),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '+20 XP',
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
