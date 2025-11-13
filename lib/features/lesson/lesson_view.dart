import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/progress_service.dart';
import 'package:edaptia/services/streak_service.dart';
import 'package:edaptia/providers/streak_provider.dart';

class LessonView extends StatefulWidget {
  static const routeName = '/lesson';

  final String courseId;
  final String moduleId;
  final String lessonId;
  final String title;
  final String? description;
  final bool premium;

  const LessonView({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
    required this.title,
    this.description,
    this.premium = false,
  });

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView>
    with SingleTickerProviderStateMixin {
  bool _completing = false;

  late final AnimationController _xpCtrl;
  late final Animation<double> _xpOpacity;
  late final Animation<Offset> _xpOffset;
  int _lastXp = 0;
  int _recentXpGain = 0;
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
    final l10n = AppLocalizations.of(context)!;

    try {
      await svc.markLessonCompleted(
        courseId: widget.courseId,
        moduleId: widget.moduleId,
        lessonId: widget.lessonId,
      );

      final streakSnapshot = await _autoCheckIn('lesson_completion');
      if (streakSnapshot?.incremented == true) {
        unawaited(
          AnalyticsService().track(
            'return_day',
            properties: <String, Object?>{
              'day': streakSnapshot!.streakDays,
              'source': 'lesson_completion',
              'streak_len': streakSnapshot.streakDays,
            },
            targets: const {AnalyticsService.targetPosthog},
          ),
        );
      }

      const gained = 20;
      _recentXpGain = gained;
      _lastXp = await svc.addXp(gained);

      HapticFeedback.lightImpact();

      await _playXpToast(gained);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.lessonCompleteToast(_lastXp)),
          action: SnackBarAction(
            label: l10n.commonOk,
            onPressed: () {},
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.lessonUpdateError),
        ),
      );
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _playXpToast(int gained) async {
    setState(() {
      _showXp = true;
      _recentXpGain = gained;
    });
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
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final description = widget.description?.trim();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: [
              if (widget.premium)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: .25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.lessonPremiumContent,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(l10n.lessonDescriptionTitle, style: tt.titleMedium),
              const SizedBox(height: 6),
              Text(
                description?.isNotEmpty == true
                    ? description!
                    : l10n.lessonContentComingSoon,
                style: tt.bodyMedium,
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
                  _completing ? l10n.commonSaving : l10n.lessonMarkCompleted,
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.lessonTipTakeNotes,
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
                                l10n.lessonXpReward(_recentXpGain),
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

  Future<StreakSnapshot?> _autoCheckIn(String source) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      return await container
          .read(streakProvider.notifier)
          .checkIn(userId, silent: true);
    } catch (error, stackTrace) {
      debugPrint('[LessonView] streak auto check-in failed ($source): $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }
}

