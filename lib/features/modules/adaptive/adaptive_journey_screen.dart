import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edaptia/features/paywall/paywall_helper.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/providers/streak_provider.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/course/models.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:edaptia/services/entitlements_service.dart';

class AdaptiveJourneyScreen extends StatefulWidget {
  const AdaptiveJourneyScreen({
    super.key,
    required this.topic,
    required this.target,
    required this.initialBand,
  });

  final String topic;
  final String target;
  final PlacementBand initialBand;

  static const routeName = '/adaptiveJourney';

  @override
  State<AdaptiveJourneyScreen> createState() => _AdaptiveJourneyScreenState();
}

class _AdaptiveJourneyScreenState extends State<AdaptiveJourneyScreen> {
  bool _loadingPlan = true;
  bool _loadingModule = false;
  bool _loadingCheckpoint = false;
  bool _submittingCheckpoint = false;
  bool _loadingBooster = false;
  String? _error;

  AdaptivePlanDraft? _plan;
  AdaptiveLearnerState? _learnerState;
  AdaptiveModuleOut? _module;
  AdaptiveCheckpointQuiz? _checkpoint;
  AdaptiveEvaluationResponse? _evaluationResponse;
  AdaptiveBooster? _booster;

  final Map<String, String> _checkpointAnswers = <String, String>{};
  final Map<int, _ModuleTileState> _timeline = <int, _ModuleTileState>{};

  int _activeModuleNumber = 1;
  bool _hasPremium = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EntitlementsService _entitlements = EntitlementsService();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _stateSub;

  static const int _maxTimelineModules = 12;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loadingPlan = true;
      _error = null;
      _module = null;
      _checkpoint = null;
      _evaluationResponse = null;
      _booster = null;
      _checkpointAnswers.clear();
      _timeline.clear();
    });

    await _stateSub?.cancel();

    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _loadingPlan = false;
        _error = 'AUTH_REQUIRED';
      });
      return;
    }

    try {
      await _entitlements.ensureLoaded();
      final planResponse = await CourseApiService.fetchAdaptivePlanDraft(
        topic: widget.topic,
        band: widget.initialBand,
        target: widget.target,
        timeout: const Duration(seconds: 120),
      );

      final suggestions = planResponse.plan.suggestedModules
          .take(_maxTimelineModules)
          .toList(growable: false);

      final seeds = <int, _ModuleTileState>{};
      for (final suggestion in suggestions) {
        seeds[suggestion.moduleNumber] = _ModuleTileState(
          number: suggestion.moduleNumber,
          title: suggestion.title,
          skills: suggestion.skills,
          unlocked: suggestion.moduleNumber == 1,
          completed: false,
          requiresPremium: suggestion.moduleNumber > 1,
        );
      }
      seeds.putIfAbsent(
        1,
        () => _ModuleTileState(
          number: 1,
          title: 'M1',
          skills: const <String>[],
          unlocked: true,
          completed: false,
          requiresPremium: false,
        ),
      );

      setState(() {
        _plan = planResponse.plan;
        _learnerState = planResponse.learnerState;
        _timeline
          ..clear()
          ..addAll(seeds);
        _syncTimelineWithHistory(planResponse.learnerState.history);
        _activeModuleNumber = 1;
        _hasPremium = _entitlements.isPremium;
        _loadingPlan = false;
      });

      await _startStateListener(user.uid);
      await _generateModule(1);
    } catch (error) {
      setState(() {
        _error = error.toString();
        _loadingPlan = false;
      });
    }
  }

  Future<void> _startStateListener(String userId) async {
    await _stateSub?.cancel();
    _stateSub = _firestore
        .collection('users')
        .doc(userId)
        .collection('adaptiveState')
        .doc('summary')
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return;
      }
      final state = AdaptiveLearnerState.fromJson(
        Map<String, dynamic>.from(data),
      );
      if (!mounted) return;
      setState(() {
        _learnerState = state;
        _syncTimelineWithHistory(state.history);
      });
    });
  }

  void _syncTimelineWithHistory(AdaptiveLearnerHistory history) {
    for (final entry in _timeline.values) {
      entry.unlocked = entry.number == 1;
      entry.completed = false;
    }

    for (final moduleNumber in history.passedModules) {
      _ensureTile(moduleNumber);
      final tile = _timeline[moduleNumber]!;
      tile.completed = true;
      tile.unlocked = true;
    }

    for (final moduleNumber in history.failedModules) {
      _ensureTile(moduleNumber);
      final tile = _timeline[moduleNumber]!;
      tile.unlocked = true;
      tile.completed = false;
    }

    if (history.passedModules.isNotEmpty) {
      final nextNumber = history.passedModules.reduce(math.max) + 1;
      _ensureTile(nextNumber);
      _timeline[nextNumber]!.unlocked = true;
    }
  }

  void _ensureTile(int moduleNumber) {
    final suggestion = _suggestionFor(moduleNumber);
    _timeline.putIfAbsent(
      moduleNumber,
      () => _ModuleTileState(
        number: moduleNumber,
        title: suggestion?.title ?? 'M$moduleNumber',
        skills: suggestion?.skills ?? const <String>[],
        unlocked: moduleNumber == 1,
        completed: false,
        requiresPremium: moduleNumber > 1,
      ),
    );
  }

  Future<void> _generateModule(int moduleNumber) async {
    setState(() {
      _loadingModule = true;
      _module = null;
      _checkpoint = null;
      _evaluationResponse = null;
      _booster = null;
      _checkpointAnswers.clear();
      _error = null;
      _activeModuleNumber = moduleNumber;
    });

    try {
      var focus = List<String>.from(
          _timeline[moduleNumber]?.skills ?? const <String>[]);
      if (focus.isEmpty) {
        focus = _topDeficits();
      }
      final response = await CourseApiService.generateAdaptiveModule(
        topic: widget.topic,
        moduleNumber: moduleNumber,
        focusSkills: focus,
      );

      if (!mounted) return;

      setState(() {
        _module = response.module;
        _learnerState = response.learnerState;
        _timeline[moduleNumber]?.unlocked = true;
        _timeline[moduleNumber]?.completed = false;
        _loadingModule = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loadingModule = false;
      });
    }
  }

  Future<void> _generateCheckpoint() async {
    final module = _module;
    if (module == null || _loadingCheckpoint) {
      return;
    }

    setState(() {
      _loadingCheckpoint = true;
      _checkpoint = null;
      _evaluationResponse = null;
      _booster = null;
      _checkpointAnswers.clear();
      _error = null;
    });

    try {
      final response = await CourseApiService.generateAdaptiveCheckpoint(
        topic: widget.topic,
        moduleNumber: module.moduleNumber,
        skillsTargeted: module.skillsTargeted,
      );

      if (!mounted) return;

      setState(() {
        _checkpoint = response.quiz;
        _learnerState = response.learnerState;
        for (final item in response.quiz.items) {
          _checkpointAnswers[item.id] = '';
        }
        _loadingCheckpoint = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loadingCheckpoint = false;
      });
    }
  }

  Future<void> _submitCheckpoint(AppLocalizations l10n) async {
    final module = _module;
    final checkpoint = _checkpoint;
    if (module == null || checkpoint == null || _submittingCheckpoint) {
      return;
    }

    final unanswered = _checkpointAnswers.values.any((value) => value.isEmpty);
    if (unanswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adaptiveFlowCheckpointMissingSelection)),
      );
      return;
    }

    setState(() {
      _submittingCheckpoint = true;
      _error = null;
    });

    try {
      final answers = _checkpointAnswers.entries
          .map((entry) =>
              <String, String>{'id': entry.key, 'choice': entry.value})
          .toList(growable: false);

      final response = await CourseApiService.evaluateAdaptiveCheckpoint(
        moduleNumber: module.moduleNumber,
        answers: answers,
        skillsTargeted: module.skillsTargeted,
      );

      if (!mounted) return;

      setState(() {
        _evaluationResponse = response;
        _learnerState = response.learnerState;
        _submittingCheckpoint = false;
      });

      if (response.action == 'advance') {
        _markCompleted(module.moduleNumber);
        _ensureTile(module.moduleNumber + 1);
        _timeline[module.moduleNumber + 1]!.unlocked = true;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _submittingCheckpoint = false;
      });
    }
  }

  Future<void> _requestBooster() async {
    final evaluation = _evaluationResponse;
    if (evaluation == null ||
        evaluation.result.weakSkills.isEmpty ||
        _loadingBooster) {
      return;
    }

    setState(() {
      _loadingBooster = true;
      _error = null;
    });

    try {
      final response = await CourseApiService.requestAdaptiveBooster(
        topic: widget.topic,
        weakSkills: evaluation.result.weakSkills,
      );

      if (!mounted) return;

      setState(() {
        _booster = response.booster;
        _learnerState = response.learnerState;
        _loadingBooster = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loadingBooster = false;
      });
    }
  }

  List<String> _topDeficits() {
    final mastery = _learnerState?.skillMastery;
    if (mastery == null || mastery.isEmpty) {
      return const <String>[];
    }
    final entries = mastery.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return entries.take(3).map((entry) => entry.key).toList(growable: false);
  }

  AdaptivePlanModuleSuggestion? _suggestionFor(int moduleNumber) {
    return _plan?.suggestedModules.firstWhere(
      (module) => module.moduleNumber == moduleNumber,
      orElse: () => AdaptivePlanModuleSuggestion(
        moduleNumber: moduleNumber,
        title: 'M$moduleNumber',
        skills: const <String>[],
        objective: '',
      ),
    );
  }

  void _markCompleted(int moduleNumber) {
    final tile = _timeline[moduleNumber];
    if (tile == null) return;
    tile.completed = true;
    unawaited(_recordDailyCheckIn('adaptive_module_$moduleNumber'));
  }

  Future<void> _handleModuleTileTap(int moduleNumber) async {
    final l10n = AppLocalizations.of(context)!;
    final tile = _timeline[moduleNumber];
    if (tile == null) return;

    if (!tile.unlocked) {
      final previous = moduleNumber - 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adaptiveFlowLockedModule('$previous'))),
      );
      return;
    }

    if (tile.requiresPremium && moduleNumber > 1 && !_hasPremium) {
      final granted = await PaywallHelper.checkAndShowPaywall(
        context,
        trigger: 'adaptive_module_$moduleNumber',
        onTrialStarted: _reloadEntitlements,
      );
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.adaptiveFlowLockedPremium)),
          );
        }
        return;
      }
      await _reloadEntitlements();
      if (!_hasPremium) {
        return;
      }
    }

    await _generateModule(moduleNumber);
  }

  Future<void> _reloadEntitlements() async {
    try {
      await _entitlements.ensureLoaded(forceRefresh: true);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _hasPremium = _entitlements.isPremium;
    });
  }

  List<_ModuleTileState> get _timelineTiles {
    final tiles = _timeline.values.toList()
      ..sort((a, b) => a.number.compareTo(b.number));
    return tiles.take(_maxTimelineModules).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loadingPlan) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adaptiveFlowTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error == 'AUTH_REQUIRED') {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adaptiveFlowTitle)),
        body: Center(child: Text('Sign in required to continue.')),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adaptiveFlowTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.adaptiveFlowError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _bootstrap,
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adaptiveFlowTitle)),
      body: RefreshIndicator(
        onRefresh: _bootstrap,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildLearnerStateCard(l10n),
            const SizedBox(height: 16),
            _buildPlanCard(l10n),
            const SizedBox(height: 16),
            _buildTimeline(l10n),
            const SizedBox(height: 16),
            _buildModuleCard(l10n),
            const SizedBox(height: 16),
            _buildCheckpointCard(l10n),
            const SizedBox(height: 16),
            _buildBoosterCard(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnerStateCard(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final mastery = _learnerState?.skillMastery ?? const <String, double>{};
    final chips = mastery.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.adaptiveFlowLearnerState,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${widget.topic} • ${widget.target}'),
            const SizedBox(height: 4),
            Text(
                'Band: ${_learnerState?.levelBand ?? widget.initialBand.name}'),
            const SizedBox(height: 12),
            if (chips.isEmpty)
              Text(l10n.adaptiveFlowEmptySkills)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips.take(12).map((entry) {
                  final pct = (entry.value * 100).clamp(0, 100).round();
                  return Chip(label: Text('${entry.key} $pct%'));
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(AppLocalizations l10n) {
    final plan = _plan;
    if (plan == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.adaptiveFlowPlanSection,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(plan.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(AppLocalizations l10n) {
    final tiles = _timelineTiles;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tiles.map((tile) {
            final isActive = tile.number == _activeModuleNumber;
            final colorScheme = Theme.of(context).colorScheme;
            final background = tile.completed
                ? colorScheme.secondaryContainer
                : isActive
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest;
            final foreground = tile.completed
                ? colorScheme.onSecondaryContainer
                : isActive
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant;

            IconData icon;
            if (tile.completed) {
              icon = Icons.check_circle;
            } else if (!tile.unlocked) {
              icon = Icons.lock_outline;
            } else if (tile.requiresPremium && !_hasPremium) {
              icon = Icons.lock;
            } else {
              icon = Icons.play_circle_outline;
            }

            return InkWell(
              onTap: () => _handleModuleTileTap(tile.number),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('M${tile.number}',
                            style: TextStyle(color: foreground)),
                        Icon(icon, size: 18, color: foreground),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tile.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: foreground),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModuleCard(AppLocalizations l10n) {
    final module = _module;
    if (_loadingModule) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (module == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.adaptiveFlowGenerateModule),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _generateModule(_activeModuleNumber),
                child: Text(l10n.adaptiveFlowGenerateModule),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.adaptiveFlowModuleSection,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('M${module.moduleNumber} • ${module.title}'),
            const SizedBox(height: 4),
            Text(l10n.adaptiveFlowDurationLabel(module.durationMinutes)),
            const SizedBox(height: 4),
            Text(
                l10n.adaptiveFlowSkillsLabel(module.skillsTargeted.join(', '))),
            const SizedBox(height: 12),
            ...module.lessons.asMap().entries.map((entry) {
              final lesson = entry.value;
              return _LessonCard(index: entry.key + 1, lesson: lesson);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckpointCard(AppLocalizations l10n) {
    final checkpoint = _checkpoint;
    final evaluation = _evaluationResponse;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.adaptiveFlowCheckpointSection,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _loadingCheckpoint ? null : _generateCheckpoint,
                  icon: _loadingCheckpoint
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.quiz),
                  label: Text(l10n.adaptiveFlowGenerateCheckpoint),
                ),
              ],
            ),
            if (checkpoint != null) ...[
              const SizedBox(height: 12),
              ...checkpoint.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.stem),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _checkpointAnswers[item.id]?.isEmpty ?? true
                            ? null
                            : _checkpointAnswers[item.id],
                        decoration: InputDecoration(
                          labelText: item.skillTag,
                          border: const OutlineInputBorder(),
                        ),
                        items: item.options.entries
                            .map(
                              (entry) => DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text('${entry.key}. ${entry.value}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _checkpointAnswers[item.id] = value ?? '';
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              FilledButton(
                onPressed: _submittingCheckpoint
                    ? null
                    : () => _submitCheckpoint(l10n),
                child: _submittingCheckpoint
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.adaptiveFlowSubmitAnswers),
              ),
            ],
            if (evaluation != null) ...[
              const SizedBox(height: 16),
              Text(l10n.adaptiveFlowScoreLabel(evaluation.result.score)),
              const SizedBox(height: 8),
              Text(
                evaluation.action == 'advance'
                    ? l10n.adaptiveFlowActionAdvance
                    : evaluation.action == 'booster'
                        ? l10n.adaptiveFlowActionBooster
                        : l10n.adaptiveFlowActionReplan,
              ),
              if (evaluation.result.weakSkills.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.adaptiveFlowWeakSkills(
                    evaluation.result.weakSkills.join(', '))),
              ],
              if (evaluation.action == 'advance') ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      _handleModuleTileTap(_activeModuleNumber + 1),
                  child: Text(l10n.adaptiveFlowGenerateModule),
                ),
              ],
              if (evaluation.action == 'booster') ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loadingBooster ? null : _requestBooster,
                  icon: _loadingBooster
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.flash_on),
                  label: Text(l10n.adaptiveFlowBoosterCta),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBoosterCard(AppLocalizations l10n) {
    final booster = _booster;
    if (booster == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.adaptiveFlowBoosterSection,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(booster.boosterFor.join(', ')),
            const SizedBox(height: 12),
            ...booster.lessons.asMap().entries.map(
                  (entry) =>
                      _LessonCard(index: entry.key + 1, lesson: entry.value),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordDailyCheckIn(String source) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final snapshot = await container
          .read(streakProvider.notifier)
          .checkIn(userId, silent: true);
      if (snapshot?.incremented == true) {
        unawaited(
          AnalyticsService().track(
            'return_day',
            properties: <String, Object?>{
              'day': snapshot!.streakDays,
              'source': source,
              'streak_len': snapshot.streakDays,
            },
            targets: const {AnalyticsService.targetPosthog},
          ),
        );
      }
    } catch (error) {
      debugPrint('[AdaptiveJourneyScreen] streak auto check-in failed: $error');
    }
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.index,
    required this.lesson,
  });

  final int index;
  final AdaptiveLesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('L$index • ${lesson.title}',
                  style: theme.textTheme.titleSmall),
              Chip(
                label: Text(lesson.lessonType.replaceAll('_', ' ')),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(lesson.hook),
          const SizedBox(height: 8),
          Text(lesson.theory),
          const SizedBox(height: 8),
          Text(lesson.exampleLatam),
          const SizedBox(height: 8),
          Text('Practice: ${lesson.practice.prompt}'),
          if (lesson.hint != null && lesson.hint!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Hint: ${lesson.hint!}'),
          ],
          if (lesson.motivation != null && lesson.motivation!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(lesson.motivation!),
          ],
          const SizedBox(height: 8),
          Text('Takeaway: ${lesson.takeaway}'),
        ],
      ),
    );
  }
}

class _ModuleTileState {
  _ModuleTileState({
    required this.number,
    required this.title,
    required this.skills,
    required this.unlocked,
    required this.completed,
    required this.requiresPremium,
  });

  final int number;
  final String title;
  final List<String> skills;
  bool unlocked;
  bool completed;
  bool requiresPremium;
}
