import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/components/edaptia_card.dart';
import 'package:edaptia/core/design_system/typography.dart';
import 'package:edaptia/features/paywall/paywall_helper.dart';
import 'package:edaptia/features/paywall/paywall_modal.dart';
import 'package:edaptia/features/quiz/module_gate_quiz_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/providers/streak_provider.dart';
import 'package:edaptia/services/adaptive_module_cache.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:edaptia/services/course/models.dart';
import 'package:edaptia/services/entitlements_service.dart';
import 'package:edaptia/services/learner_state_service.dart';
import 'package:edaptia/services/local_outline_storage.dart';
import 'package:edaptia/services/recent_outlines_storage.dart';

import 'widgets/adaptive_loading_indicator.dart';
import 'models/module_tile_state.dart';
import 'widgets/lesson_card.dart';
import 'widgets/module_tile.dart';

/// Different loading states for the adaptive journey.
enum AdaptiveLoadingState {
  none,
  plan,
  moduleFirst,
  module,
  checkpoint,
  booster,
}

class AdaptiveJourneyScreenArgs {
  const AdaptiveJourneyScreenArgs({
    required this.topic,
    required this.target,
    required this.initialBand,
  });

  final String topic;
  final String target;
  final PlacementBand initialBand;
}

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
  bool _submittingCheckpoint = false;
  AdaptiveLoadingState _loadingState = AdaptiveLoadingState.none;
  String? _error;

  AdaptivePlanDraft? _plan;
  AdaptiveLearnerState? _learnerState;
  AdaptiveModuleOut? _module;
  AdaptiveCheckpointQuiz? _checkpoint;
  AdaptiveEvaluationResponse? _evaluationResponse;
  AdaptiveBooster? _booster;

  final Map<String, String> _checkpointAnswers = <String, String>{};
  final Map<int, ModuleTileState> _timeline = <int, ModuleTileState>{};

  int _activeModuleNumber = 1;
  bool _hasPremium = false;

  // Expansion state for timeline modules
  final Set<int> _expandedModules = <int>{};
  final Map<int, AdaptiveModuleOut> _cachedModules = <int, AdaptiveModuleOut>{};
  final Set<int> _generatingModules = <int>{};

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EntitlementsService _entitlements = EntitlementsService();
  final LearnerStateService _learnerService = LearnerStateService.instance;
  StreamSubscription<AdaptiveLearnerState?>? _stateSubscription;

  bool get _isLoadingCheckpoint =>
      _loadingState == AdaptiveLoadingState.checkpoint;
  bool get _isLoadingBooster => _loadingState == AdaptiveLoadingState.booster;

  static const int _maxTimelineModules = 12;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loadingState = AdaptiveLoadingState.plan;
      _error = null;
      _module = null;
      _checkpoint = null;
      _evaluationResponse = null;
      _booster = null;
      _checkpointAnswers.clear();
      _timeline.clear();
    });

    await _stateSubscription?.cancel();

    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _loadingState = AdaptiveLoadingState.none;
        _error = 'AUTH_REQUIRED';
      });
      return;
    }

    try {
      await _entitlements.ensureLoaded();
      await _loadCachedModules(); // Cargar módulos de caché primero

      // Obtener siempre el recuento total de módulos para construir el esqueleto de la UI
      final countResponse = await CourseApiService.fetchModuleCount(
        topic: widget.topic,
        band: widget.initialBand,
        target: widget.target,
        timeout: const Duration(seconds: 30),
      );
      final int moduleCount = countResponse.moduleCount;

      // Si M1 está en caché, usamos el recuento dinámico para los esqueletos y cargamos M1
      if (_cachedModules.containsKey(1)) {
        final cachedM1 = _cachedModules[1]!;
        final seeds = <int, ModuleTileState>{};

        for (int i = 1; i <= moduleCount && i <= _maxTimelineModules; i++) {
          final cachedModule = _cachedModules[i];
          final suggestion = _suggestionFor(i);

          seeds[i] = ModuleTileState(
            number: i,
            title: cachedModule?.title ?? suggestion?.title ?? 'Módulo $i',
            skills: cachedModule?.skillsTargeted ??
                suggestion?.skills ??
                const <String>[],
            unlocked: i == 1,
            completed: false,
            requiresPremium: i > 1,
          );
        }

        setState(() {
          _timeline
            ..clear()
            ..addAll(seeds);
          _activeModuleNumber = 1;
          _module = cachedM1;
          _hasPremium = _entitlements.hasPremiumAccess;
          _loadingState = AdaptiveLoadingState.none;
        });

        unawaited(_persistPlanSnapshot());
        await _startStateListener(user.uid);

        debugPrint(
            '[AdaptiveJourney] Loaded M1 from cache, showing ${seeds.length} skeleton modules from dynamic count');
        return;
      }

      // Si M1 no está en caché, usamos el recuento ya obtenido para construir el esqueleto
      final seeds = <int, ModuleTileState>{};
      for (int i = 1;
          i <= moduleCount && i <= _maxTimelineModules;
          i++) {
        seeds[i] = ModuleTileState(
          number: i,
          title:
              'Módulo $i', // Placeholder, se llenará después con el contenido real
          skills: const <String>[],
          unlocked: i == 1,
          completed: false,
          requiresPremium: i > 1,
        );
      }

      setState(() {
        _timeline
          ..clear()
          ..addAll(seeds);
        _activeModuleNumber = 1;
        _hasPremium = _entitlements.hasPremiumAccess;
        _loadingState =
            AdaptiveLoadingState.none; // ✅ UI visible inmediatamente
      });

      await _startStateListener(user.uid);

      // FASE 2: Generar M1 (60-90s, pero usuario ya ve skeleton)
      await _generateModule(1);
    } catch (error) {
      setState(() {
        _error = error.toString();
        _loadingState = AdaptiveLoadingState.none;
      });
    }
  }

  Future<void> _startStateListener(String userId) async {
    debugPrint(
        '[AdaptiveJourney] Starting real-time state listener for $userId');
    await _stateSubscription?.cancel();
    _stateSubscription = _learnerService.watchLearnerState().listen(
      (newState) {
        if (!mounted) return;
        debugPrint(
          '[AdaptiveJourney] State update received: ${newState?.visitedLessons.length ?? 0} lessons visited',
        );
        setState(() {
          _learnerState = newState;
          _syncTimelineWithHistory(newState?.history);
          _checkModuleUnlocks();
        });
      },
      onError: (error) {
        debugPrint('[AdaptiveJourney] State listener error: $error');
      },
    );
  }

  void _syncTimelineWithHistory(AdaptiveLearnerHistory? history) {
    if (history == null) return;

    for (final moduleNumber in history.passedModules) {
      _ensureTile(moduleNumber);
      final tile = _timeline[moduleNumber]!;
      tile.completed = true;
      tile.unlocked = true;
    }

    for (final moduleNumber in history.failedModules) {
      _ensureTile(moduleNumber);
      final tile = _timeline[moduleNumber]!;
      tile.completed = false;
      tile.unlocked = true;
    }

    final highestPassed =
        history.passedModules.isEmpty ? 1 : history.passedModules.reduce(math.max) + 1;
    _ensureTile(highestPassed);
    final nextTile = _timeline[highestPassed];
    if (nextTile != null) {
      nextTile.unlocked = true;
    }

    final firstTile = _timeline[1];
    if (firstTile != null) {
      firstTile.unlocked = true;
    }
  }

  void _checkModuleUnlocks() {
    final state = _learnerState;
    if (state == null) return;

    for (final entry in _timeline.entries.toList()) {
      final moduleNumber = entry.key;
      final tile = entry.value;

      final cachedModule = _cachedModules[moduleNumber];
      final totalLessons = cachedModule?.lessons.length ?? 0;
      if (cachedModule != null && totalLessons > 0) {
        final isComplete = _learnerService.isModuleComplete(
          state: state,
          topic: widget.topic,
          moduleNumber: moduleNumber,
          totalLessons: totalLessons,
        );
        tile.completed = isComplete;
        if (isComplete) {
          _ensureTile(moduleNumber + 1);
          final nextTile = _timeline[moduleNumber + 1];
          if (nextTile != null) {
            nextTile.unlocked = true;
          }
        }
      }

      if (moduleNumber == 1) {
        tile.unlocked = true;
        continue;
      }

      final previousModule = _cachedModules[moduleNumber - 1];
      final previousLessons = previousModule?.lessons.length ?? 0;
      if (previousModule != null && previousLessons > 0) {
        final previousComplete = _learnerService.isModuleComplete(
          state: state,
          topic: widget.topic,
          moduleNumber: moduleNumber - 1,
          totalLessons: previousLessons,
        );
        if (previousComplete) {
          tile.unlocked = true;
        }
      }
    }
  }

  Future<void> _persistPlanSnapshot() async {
    if (!mounted || _cachedModules.isEmpty) return;
    try {
      final modules = _cachedModules.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      if (modules.isEmpty) return;

      final language =
          Localizations.maybeLocaleOf(context)?.languageCode ?? 'es';
      final outline = modules.map((entry) {
        final module = entry.value;
        final lessons = module.lessons.asMap().entries.map((lessonEntry) {
          final lesson = lessonEntry.value;
          return <String, dynamic>{
            'index': lessonEntry.key,
            'title': lesson.title,
            'takeaway': lesson.takeaway,
          };
        }).toList(growable: false);
        return <String, dynamic>{
          'moduleNumber': module.moduleNumber,
          'title': module.title,
          'skills': module.skillsTargeted,
          'lessons': lessons,
        };
      }).toList(growable: false);

      await LocalOutlineStorage.instance.save(
        topic: widget.topic,
        payload: <String, dynamic>{
          'outline': outline,
          'band': widget.initialBand.name,
          'language': language,
          'source': 'adaptive_journey',
        },
      );

      final metadata = RecentOutlineMetadata(
        id: RecentOutlineMetadata.buildId(
          topic: widget.topic,
          language: language,
          band: widget.initialBand.name,
        ),
        topic: widget.topic,
        language: language,
        savedAt: DateTime.now(),
        band: widget.initialBand.name,
        depth: null,
      );
      await RecentOutlinesStorage.instance.upsert(metadata);
    } catch (error, stackTrace) {
      debugPrint(
        '[AdaptiveJourney] Failed to persist home snapshot: $error\n$stackTrace',
      );
    }
  }

  void _ensureTile(int moduleNumber) {
    final suggestion = _suggestionFor(moduleNumber);
    _timeline.putIfAbsent(
      moduleNumber,
      () => ModuleTileState(
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
    final moduleLoadingState = moduleNumber == 1
        ? AdaptiveLoadingState.moduleFirst
        : AdaptiveLoadingState.module;
    setState(() {
      _module = null;
      _checkpoint = null;
      _evaluationResponse = null;
      _booster = null;
      _checkpointAnswers.clear();
      _error = null;
      _activeModuleNumber = moduleNumber;
      _generatingModules.add(moduleNumber);
      _loadingState = moduleLoadingState;
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

      // Cache the generated module
      _cachedModules[moduleNumber] = response.module;
      unawaited(AdaptiveModuleCache.instance.saveModule(
        topic: widget.topic,
        language: 'es',
        band: widget.initialBand.name,
        module: response.module,
      ));

      setState(() {
        _module = response.module;
        _learnerState = response.learnerState;
        _timeline[moduleNumber]?.unlocked = true;
        _timeline[moduleNumber]?.completed = false;
        _checkModuleUnlocks();
      });
      unawaited(_persistPlanSnapshot());
    } catch (error) {
      if (!mounted) return;

      // Check if this is a course limit error
      final errorString = error.toString();
      if (errorString.contains('COURSE_LIMIT_REACHED')) {
        // Show paywall modal
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => PaywallModal(
            trigger: 'course_limit_reached',
            onTrialStarted: () {
              // Retry generating the module after trial started
              _generateModule(moduleNumber);
            },
          ),
        );
      } else {
        setState(() {
          _error = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _generatingModules.remove(moduleNumber);
          if (_loadingState == moduleLoadingState) {
            _loadingState = AdaptiveLoadingState.none;
          }
        });
      }
    }
  }

  /// Load all cached modules from persistent storage
  Future<void> _loadCachedModules() async {
    try {
      for (int moduleNumber = 1;
          moduleNumber <= _maxTimelineModules;
          moduleNumber++) {
        final cached = await AdaptiveModuleCache.instance.loadModule(
          topic: widget.topic,
          language: 'es',
          band: widget.initialBand.name,
          moduleNumber: moduleNumber,
        );
        if (cached != null) {
          _cachedModules[moduleNumber] = cached;
        }
      }
    } catch (e) {
      // Fail silently - cache is optional
      debugPrint('[QuizScreen] Error loading cached modules: $e');
    }
  }

  Future<void> _generateCheckpoint() async {
    final module = _module;
    if (module == null || _isLoadingCheckpoint) {
      return;
    }

    setState(() {
      _loadingState = AdaptiveLoadingState.checkpoint;
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
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted && _loadingState == AdaptiveLoadingState.checkpoint) {
        setState(() {
          _loadingState = AdaptiveLoadingState.none;
        });
      }
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
        _isLoadingBooster) {
      return;
    }

    setState(() {
      _loadingState = AdaptiveLoadingState.booster;
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
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted && _loadingState == AdaptiveLoadingState.booster) {
        setState(() {
          _loadingState = AdaptiveLoadingState.none;
        });
      }
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

  Future<void> _startModuleQuiz(
    int moduleNumber,
    AdaptiveModuleOut module,
  ) async {
    final language = Localizations.localeOf(context).languageCode;
    await Navigator.of(context).pushNamed(
      ModuleGateQuizScreen.routeName,
      arguments: ModuleGateQuizArgs(
        moduleNumber: moduleNumber,
        topic: widget.topic,
        language: language,
        moduleTitle: module.title,
        lessonTitles: module.lessons
            .map((lesson) => lesson.title)
            .toList(growable: false),
      ),
    );
  }

  Future<void> _handleModuleTileTap(int moduleNumber) async {
    final l10n = AppLocalizations.of(context)!;
    final tile = _timeline[moduleNumber];
    if (tile == null) return;
    if (_generatingModules.contains(moduleNumber)) {
      return;
    }

    // If module already has cached data, just toggle expansion
    if (_cachedModules.containsKey(moduleNumber)) {
      setState(() {
        if (_expandedModules.contains(moduleNumber)) {
          _expandedModules.remove(moduleNumber);
        } else {
          _expandedModules.add(moduleNumber);
        }
      });
      return;
    }

    // Otherwise, check permissions and generate module
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

    // Generate module and auto-expand it
    await _generateModule(moduleNumber);
    if (mounted && _cachedModules.containsKey(moduleNumber)) {
      setState(() {
        _expandedModules.add(moduleNumber);
      });
    }
  }

  Future<void> _reloadEntitlements() async {
    try {
      await _entitlements.ensureLoaded(forceRefresh: true);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _hasPremium = _entitlements.hasPremiumAccess;
    });
  }

  List<ModuleTileState> get _timelineTiles {
    final tiles = _timeline.values.toList()
      ..sort((a, b) => a.number.compareTo(b.number));
    return tiles.take(_maxTimelineModules).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget body;
    if (_error == 'AUTH_REQUIRED') {
      body = Center(child: Text('Sign in required to continue.'));
    } else if (_error != null) {
      body = _buildErrorView(l10n);
    } else {
      body = _buildMainContent(l10n);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adaptiveFlowTitle)),
      body: body,
    );
  }

  Widget _buildMainContent(AppLocalizations l10n) {
    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildLearnerStateCard(l10n),
        const SizedBox(height: 16),
        _buildPlanCard(l10n),
        const SizedBox(height: 16),
        _buildTimeline(l10n),
        const SizedBox(height: 16),
        _buildCheckpointCard(l10n),
        const SizedBox(height: 16),
        _buildBoosterCard(l10n),
      ],
    );

    if (_loadingState == AdaptiveLoadingState.none) {
      return content;
    }

    if (_timeline.isEmpty) {
      return _buildLoadingView(l10n);
    }

    return Stack(
      children: [
        content,
        Positioned.fill(
          child: Container(
            color: Colors.white.withValues(alpha: 0.85),
            child: _buildLoadingView(l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(AppLocalizations l10n) {
    return Center(
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
              _error ?? '',
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
    );
  }

  Widget _buildLoadingView(AppLocalizations l10n) {
    String message;
    String? subtitle;
    final topic = widget.topic;

    switch (_loadingState) {
      case AdaptiveLoadingState.plan:
        message = 'Generando tu plan personalizado';
        subtitle =
            'Estamos analizando "$topic" para crear el mejor recorrido para ti';
        break;
      case AdaptiveLoadingState.moduleFirst:
        message = 'Creando tu primer módulo';
        subtitle = 'GPT está generando lecciones adaptadas a tu nivel...';
        break;
      case AdaptiveLoadingState.module:
        message = 'Generando siguiente módulo';
        subtitle = 'Preparando nuevas lecciones para ti...';
        break;
      case AdaptiveLoadingState.checkpoint:
        message = 'Creando checkpoint de evaluación';
        subtitle = 'Generando preguntas personalizadas...';
        break;
      case AdaptiveLoadingState.booster:
        message = 'Preparando contenido de refuerzo';
        subtitle = 'Creando ejercicios adicionales...';
        break;
      case AdaptiveLoadingState.none:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdaptiveLoadingIndicator(
            message: message,
            subtitle: subtitle,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.aiDisclaimerGenerating,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnerStateCard(AppLocalizations l10n) {
    final learnerState = _learnerState;
    final mastery = learnerState?.skillMastery ?? const <String, double>{};
    final chips = mastery.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final headline = EdaptiaTypography.title2.copyWith(color: Colors.white);
    final subtitle = EdaptiaTypography.body.copyWith(color: Colors.white70);
    final chipStyle = EdaptiaTypography.caption
        .copyWith(color: Colors.white, fontWeight: FontWeight.w600);

    // Count lessons visited for THIS course only
    final totalVisited = _learnerService.countVisitedLessons(
      state: learnerState,
      topic: widget.topic,
    );

    // Translate level band to Spanish
    String getLevelBandSpanish(String? band) {
      if (band == null || band.isEmpty) return 'Por determinar';
      final normalized = band.toLowerCase();
      switch (normalized) {
        case 'basic':
        case 'beginner':
          return 'Básico';
        case 'intermediate':
          return 'Intermedio';
        case 'advanced':
          return 'Avanzado';
        default:
          return band; // Return original if unknown
      }
    }

    return EdaptiaCard(
      gradient: EdaptiaColors.hookGradient,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adaptiveFlowLearnerState, style: headline),
          const SizedBox(height: 8),
          Text(
            'Objetivo: ${widget.target}',
            style: subtitle,
          ),
          const SizedBox(height: 4),
          Text(
            'Nivel: ${getLevelBandSpanish(learnerState?.levelBand)}',
            style: subtitle,
          ),
          const SizedBox(height: 4),
          Text(
            'Lecciones completadas: $totalVisited',
            style: subtitle,
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.take(12).map((entry) {
                final pct = (entry.value * 100).clamp(0, 100).round();
                return Chip(
                  backgroundColor: Colors.white24,
                  labelStyle: chipStyle,
                  label: Text('${entry.key} $pct%'),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard(AppLocalizations l10n) {
    final plan = _plan;
    if (plan == null) {
      return const SizedBox.shrink();
    }
    return EdaptiaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adaptiveFlowPlanSection,
            style: EdaptiaTypography.title3
                .copyWith(color: EdaptiaColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            plan.notes,
            style: EdaptiaTypography.body
                .copyWith(color: EdaptiaColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(AppLocalizations l10n) {
    final tiles = _timelineTiles;
    final learnerState = _learnerState;
    final topic = widget.topic;
    return EdaptiaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: tiles.map((tile) {
          final isActive = tile.number == _activeModuleNumber;
          final cachedModule = _cachedModules[tile.number];
          final isExpanded = _expandedModules.contains(tile.number);
          final isGenerating = _generatingModules.contains(tile.number);
          final moduleLessons =
              cachedModule?.lessons ?? const <AdaptiveLesson>[];
          final isLockedModule = !tile.unlocked;

          final lessons = cachedModule == null
              ? const <Widget>[]
              : moduleLessons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final lesson = entry.value;
                  final isVisited = _learnerService.isLessonVisited(
                    state: learnerState,
                    topic: topic,
                    moduleNumber: tile.number,
                    lessonIndex: index,
                  );
                  final previousLessonVisited = index == 0
                      ? true
                      : _learnerService.isLessonVisited(
                          state: learnerState,
                          topic: topic,
                          moduleNumber: tile.number,
                          lessonIndex: index - 1,
                        );
                  final isLessonLocked =
                      isLockedModule || (index > 0 && !previousLessonVisited);

                  return LessonCard(
                    index: index,
                    lesson: lesson,
                    moduleTitle: cachedModule.title,
                    moduleNumber: tile.number,
                    courseId: topic,
                    isVisited: isVisited,
                    isLocked: isLessonLocked,
                    allModuleLessons: moduleLessons,
                  );
                }).toList();

          AdaptiveModuleOut? moduleForQuiz;
          if (cachedModule != null &&
              moduleLessons.isNotEmpty &&
              !isLockedModule &&
              (!tile.requiresPremium || _hasPremium)) {
            moduleForQuiz = cachedModule;
          }
          VoidCallback? quizCallback;
          if (moduleForQuiz != null) {
            final module = moduleForQuiz;
            quizCallback = () => _startModuleQuiz(tile.number, module);
          }

          return ModuleTile(
            tile: tile,
            isActive: isActive,
            hasPremium: _hasPremium,
            isExpanded: isExpanded,
            moduleTitle: cachedModule?.title ?? tile.title,
            skills: cachedModule?.skillsTargeted ?? tile.skills,
            emptySkillsLabel: l10n.adaptiveFlowEmptySkills,
            lessonCards: lessons,
            learnerState: learnerState,
            topic: topic,
            totalLessons: moduleLessons.length,
            isGenerating: isGenerating,
            isLocked: isLockedModule,
            onQuizPressed: quizCallback,
            onTap: () => _handleModuleTileTap(tile.number),
          );
        }).toList(),
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
                  onPressed: _isLoadingCheckpoint ? null : _generateCheckpoint,
                  icon: _isLoadingCheckpoint
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
                        initialValue:
                            _checkpointAnswers[item.id]?.isEmpty ?? true
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
                  onPressed: _isLoadingBooster ? null : _requestBooster,
                  icon: _isLoadingBooster
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
                  (entry) => LessonCard(
                    index: entry.key + 1,
                    lesson: entry.value,
                    moduleTitle: 'Booster: ${booster.boosterFor.join(', ')}',
                    moduleNumber: 0, // Booster lessons are not part of a module
                    courseId: widget.topic,
                    isVisited: false, // Boosters don't track visits
                  ),
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
