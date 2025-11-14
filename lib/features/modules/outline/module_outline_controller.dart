part of 'package:edaptia/features/modules/outline/module_outline_view.dart';

mixin ModuleOutlineController on State<ModuleOutlineView> {
  late final OutlineFetcher _outlineFetcher;

  bool _isLoading = true;

  String? _error;

  Map<String, dynamic>? _outlineResponse;

  String? _outlineSource;

  DateTime? _lastSavedAt;

  String _courseId = '';

  bool _didInitialLoad = false;

  String? _preferredBand;

  bool _forceRefreshOnNextLoad = false;

  PlacementBand? _activeBand;

  String? _activeDepth;

  String? _activeLanguage;

  final Set<String> _reportedModuleStarts = <String>{};
  final Set<int> _generatingModules = <int>{};
  final Set<int> _hydratedModules = <int>{};

  @override
  void initState() {
    super.initState();
    _outlineFetcher = widget.outlineFetcher ?? CourseApiService.generateOutline;
    _courseId =
        (widget.topic?.trim().isNotEmpty ?? false) ? widget.topic!.trim() : '';

    _preferredBand = widget.preferredBand;

    _forceRefreshOnNextLoad = widget.recommendRegenerate ?? false;

    final initialResponse = widget.initialResponse;

    if (initialResponse != null) {
      _outlineResponse = Map<String, dynamic>.from(initialResponse);

      _outlineSource = initialResponse['source']?.toString();

      _lastSavedAt = widget.initialSavedAt;

      _activeLanguage =
          initialResponse['language']?.toString() ?? widget.language;

      final responseBand = initialResponse['band']?.toString();

      _preferredBand ??= responseBand;

      _activeBand = CourseApiService.tryPlacementBandFromString(
        _preferredBand ?? responseBand,
      );

      _activeDepth = initialResponse['depth']?.toString() ?? widget.depth;

      _isLoading = false;
    } else if (widget.initialOutline != null) {
      _outlineResponse = {
        'outline': widget.initialOutline,
        'source': widget.initialSource ?? 'cache',
      };

      _outlineSource = widget.initialSource ?? 'cache';

      _lastSavedAt = widget.initialSavedAt;

      _activeLanguage = widget.language;

      _activeBand = CourseApiService.tryPlacementBandFromString(_preferredBand);

      _activeDepth = widget.depth;

      _isLoading = false;
    } else {
      _activeBand = CourseApiService.tryPlacementBandFromString(_preferredBand);

      _activeDepth = widget.depth;

      _activeLanguage = widget.language;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_courseId.isEmpty) {
      final fallbackTopic =
          AppLocalizations.of(context)?.moduleOutlineFallbackTopic ??
              'Default Topic';
      _courseId = fallbackTopic;
    }

    if (!_didInitialLoad) {
      _didInitialLoad = true;

      unawaited(
        _loadOutline(
          showLoading: _outlineResponse == null,
          forceRefresh: _forceRefreshOnNextLoad,
          preferredBandOverride: _preferredBand,
          notify: false,
        ),
      );

      _forceRefreshOnNextLoad = false;
    }
  }

  void _handleModuleExpansion(
    Map<String, dynamic> module,
    int moduleIndex,
    bool expanded,
  ) {
    if (!expanded) {
      return;
    }
    unawaited(_onModuleExpansionAsync(module, moduleIndex));
  }

  int _lessonCount(Map<String, dynamic> module) {
    final dynamic lessons = module['lessons'];

    if (lessons is List) {
      return lessons.length;
    }

    return 0;
  }

  Future<void> _loadOutline({
    bool forceRefresh = false,
    bool showLoading = true,
    String? preferredBandOverride,
    String? depthOverride,
    bool notify = true,
    bool preferCache = true,
  }) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    setState(() => _error = null);

    final AnalyticsService analytics = AnalyticsService();

    DateTime requestStartedAt = DateTime.now();

    try {
      final localeLanguage = Localizations.localeOf(context).languageCode;

      final preferredLanguage = (widget.language?.trim().isNotEmpty ?? false)
          ? widget.language!.trim()
          : localeLanguage;

      final effectiveBandString = preferredBandOverride ??
          (depthOverride == null ? _preferredBand : null);

      final bandEnum =
          CourseApiService.tryPlacementBandFromString(effectiveBandString);

      final resolvedDepth = depthOverride ??
          (bandEnum != null
              ? CourseApiService.depthForBand(bandEnum)
              : widget.depth ?? 'medium');

      final Map<String, Object?> outlineRequestProps = <String, Object?>{
        'topic': _courseId,
        'depth': resolvedDepth,
      };

      final cacheId = RecentOutlineMetadata.buildId(
        topic: _courseId,
        language: preferredLanguage,
        band: bandEnum != null
            ? CourseApiService.placementBandToString(bandEnum)
            : null,
        depth: bandEnum == null ? resolvedDepth : null,
      );

      if (!forceRefresh && preferCache) {
        final cached = await LocalOutlineStorage.instance.findById(cacheId);

        if (cached != null) {
          if (!mounted) return;

          _applyCachedOutline(cached);

          unawaited(
            analytics.track(
              'outline_rendered',
              properties: <String, Object?>{
                ...outlineRequestProps,
                'cache_hit': true,
                'latency_ms': 0,
              },
              targets: const {AnalyticsService.targetGa4},
            ),
          );

          if (notify && mounted) {
            _notifyPlanReady(fromCache: true);
          }

          return;
        }
      }

      requestStartedAt = DateTime.now();

      unawaited(
        analytics.track(
          'outline_requested',
          properties: outlineRequestProps,
          targets: const {AnalyticsService.targetGa4},
        ),
      );

      final response = await _outlineFetcher(
        topic: _courseId,
        goal: widget.goal,
        level: widget.level,
        language: preferredLanguage,
        depth: resolvedDepth,
        band: bandEnum,
      );

      await LocalOutlineStorage.instance.save(
        topic: _courseId,
        payload: response,
      );

      final responseBand = response['band']?.toString();

      final responseDepth = response['depth']?.toString() ?? resolvedDepth;

      final responseLanguage =
          response['language']?.toString() ?? preferredLanguage;

      final metadata = RecentOutlineMetadata(
        id: RecentOutlineMetadata.buildId(
          topic: _courseId,
          language: responseLanguage,
          band: responseBand,
          depth: responseBand?.isEmpty ?? true ? responseDepth : null,
        ),
        topic: _courseId,
        language: responseLanguage,
        band: responseBand?.isNotEmpty == true ? responseBand : null,
        depth: responseDepth,
        savedAt: DateTime.now(),
      );

      await RecentOutlinesStorage.instance.upsert(metadata);

      if (!mounted) return;

      setState(() {
        _outlineResponse = response;

        _outlineSource = response['source']?.toString();

        _lastSavedAt = DateTime.now();

        _preferredBand = responseBand ?? effectiveBandString;

        _activeBand = CourseApiService.tryPlacementBandFromString(
          responseBand ?? effectiveBandString,
        );

        _activeDepth = responseDepth;

        _activeLanguage = responseLanguage;

        _generatingModules.clear();
        _hydratedModules
          ..clear()
          ..addAll(_detectGeneratedModules(response['outline']));
      });

      if (!_hydratedModules.contains(1)) {
        unawaited(
          _fetchGenerativeModule(
            moduleNumber: 1,
            language: responseLanguage,
          ),
        );
      }

      final int latencyMs =
          (DateTime.now().difference(requestStartedAt).inMilliseconds)
              .clamp(0, 600000)
              .toInt();

      final bool cacheHit =
          (response['source']?.toString().toLowerCase() ?? '') == 'cache';

      unawaited(
        analytics.track(
          'outline_rendered',
          properties: <String, Object?>{
            ...outlineRequestProps,
            'cache_hit': cacheHit,
            'latency_ms': latencyMs,
          },
          targets: const {AnalyticsService.targetGa4},
        ),
      );

      if (notify) {
        _notifyPlanReady(fromCache: false);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onModuleExpansionAsync(
    Map<String, dynamic> module,
    int moduleIndex,
  ) async {
    final String rawId = module['id']?.toString() ?? '';

    final String moduleId =
        rawId.trim().isNotEmpty ? rawId.trim() : 'module-$moduleIndex';

    if (_reportedModuleStarts.add(moduleId)) {
      final String? band = module['band']?.toString() ?? _preferredBand;
      final int lessonCount = _lessonCount(module);

      unawaited(
        AnalyticsService().trackModuleStarted(
          moduleId: moduleId,
          topic: _courseId,
          band: band,
          lessonCount: lessonCount,
        ),
      );
    }

    final int moduleNumber = moduleIndex + 1;

    if (moduleNumber > 1 &&
        !_hydratedModules.contains(moduleNumber) &&
        !_generatingModules.contains(moduleNumber)) {
      final allowed = await _ensureModuleAccess(moduleNumber);
      if (!allowed) {
        return;
      }
    }

    if (moduleNumber <= 1 ||
        _hydratedModules.contains(moduleNumber) ||
        _generatingModules.contains(moduleNumber)) {
      return;
    }

    final String resolvedLanguage =
        _resolveModuleLanguage(module['language']?.toString());

    unawaited(
      _fetchGenerativeModule(
        moduleNumber: moduleNumber,
        language: resolvedLanguage,
      ),
    );
  }

  Future<bool> _ensureModuleAccess(int moduleNumber) async {
    if (moduleNumber <= 1) {
      return true;
    }
    final entitlements = EntitlementsService();
    try {
      await entitlements.ensureLoaded();
      if (entitlements.isPremium) {
        return true;
      }
    } catch (error, stackTrace) {
      debugPrint('[ModuleOutline] entitlements ensure failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (!mounted) {
      return false;
    }

    return PaywallHelper.checkAndShowPaywall(
      context,
      trigger: 'module_detected',
    );
  }

  Future<void> _fetchGenerativeModule({
    required int moduleNumber,
    String? language,
  }) async {
    if (_generatingModules.contains(moduleNumber) ||
        _hydratedModules.contains(moduleNumber)) {
      return;
    }

    if (!mounted) return;

    try {
      final resolvedLanguage = _resolveModuleLanguage(language);
      final previousModuleId = _resolvePreviousModuleId(moduleNumber);

      if (moduleNumber > 1 && previousModuleId == null) {
        debugPrint(
          '[ModuleOutline] Unable to resolve previous module id for M$moduleNumber',
        );
        return;
      }

      setState(() {
        _generatingModules.add(moduleNumber);
      });

      final moduleResponse = await CourseApiService.fetchGenerativeModule(
        topic: _courseId,
        moduleNumber: moduleNumber,
        band: _activeBand,
        language: resolvedLanguage,
        previousModuleId: previousModuleId,
      );
      final moduleData = moduleResponse['module'];
      if (!mounted || moduleData is! Map) {
        if (mounted) {
          setState(() {
            _generatingModules.remove(moduleNumber);
          });

          _showModuleGenerationError(moduleNumber);
        }
        return;
      }

      setState(() {
        _applyGenerativeModuleData(
          moduleNumber,
          Map<String, dynamic>.from(moduleData),
        );
        _generatingModules.remove(moduleNumber);
        _hydratedModules.add(moduleNumber);
      });

      unawaited(_persistOutline());
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Failed to fetch module $moduleNumber: $error');

      setState(() {
        _generatingModules.remove(moduleNumber);
      });

      _showModuleGenerationError(moduleNumber);
    }
  }

  void _applyGenerativeModuleData(
    int moduleNumber,
    Map<String, dynamic> moduleData,
  ) {
    final outline = _outlineResponse?['outline'];
    if (outline is! List) return;

    final moduleIndex = moduleNumber - 1;
    if (moduleIndex < 0 || moduleIndex >= outline.length) {
      return;
    }

    final lessons = (moduleData['lessons'] as List?)
            ?.whereType<Map>()
            .toList(growable: false) ??
        const [];

    final mappedLessons = lessons.asMap().entries.map((entry) {
      final idx = entry.key;
      final lesson = Map<String, dynamic>.from(entry.value);
      final content = lesson['content']?.toString() ?? '';
      final estimated = lesson['estimatedTime'] is num
          ? (lesson['estimatedTime'] as num).toInt().clamp(1, 60)
          : 4;
      return <String, dynamic>{
        'id': lesson['id']?.toString() ?? 'gen-$moduleNumber-$idx',
        'title': lesson['title']?.toString() ?? 'Lesson ${idx + 1}',
        'summary': content,
        'content': content,
        'durationMinutes': estimated,
        'objective': lesson['objective'],
        'type': lesson['type'] ?? 'lesson',
      };
    }).toList(growable: false);

    final updatedModule = Map<String, dynamic>.from(
      (outline[moduleIndex] as Map?) ?? const <String, dynamic>{},
    )..addAll({
        'title': moduleData['title']?.toString() ??
            (outline[moduleIndex] as Map?)?['title'],
        'lessons': mappedLessons,
        'challenge': moduleData['challenge'],
        'test': moduleData['test'],
        'source': moduleData['source'] ?? 'openai',
      });

    final newOutline = List<Map<String, dynamic>>.from(
      outline.map((module) => Map<String, dynamic>.from(module as Map)),
    );
    newOutline[moduleIndex] = updatedModule;
    _outlineResponse = {
      ...?_outlineResponse,
      'outline': newOutline,
    };
  }

  Future<void> _persistOutline() async {
    final response = _outlineResponse;
    if (response == null) {
      return;
    }

    try {
      await LocalOutlineStorage.instance.save(
        topic: _courseId,
        payload: Map<String, dynamic>.from(response),
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[ModuleOutline] Failed to persist outline: $error\n$stackTrace',
      );
    }
  }

  Set<int> _detectGeneratedModules(dynamic outline) {
    if (outline is! List) {
      return <int>{};
    }

    final detected = <int>{};
    for (var i = 0; i < outline.length; i++) {
      final module = outline[i];
      if (module is! Map) continue;

      final source = module['source']?.toString().toLowerCase();
      if (source != null && source.contains('openai')) {
        detected.add(i + 1);
        continue;
      }

      final lessons = module['lessons'];
      if (lessons is List &&
          lessons.isNotEmpty &&
          lessons.every((lesson) {
            if (lesson is! Map) return false;
            final id = lesson['id']?.toString();
            return id != null && id.startsWith('gen-');
          })) {
        detected.add(i + 1);
      }
    }
    return detected;
  }

  String? _resolvePreviousModuleId(int moduleNumber) {
    if (moduleNumber <= 1) {
      return null;
    }

    final outline = _outlineResponse?['outline'];
    if (outline is! List) {
      return null;
    }

    final previousIndex = moduleNumber - 2;
    if (previousIndex < 0 || previousIndex >= outline.length) {
      return null;
    }

    final previousModule = outline[previousIndex];
    if (previousModule is! Map) {
      return null;
    }

    final candidates = <String?>[
      previousModule['id']?.toString(),
      previousModule['moduleId']?.toString(),
      'module-${moduleNumber - 1}',
    ];

    for (final candidate in candidates) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  String _resolveModuleLanguage(String? moduleLanguage) {
    final candidates = <String?>[
      moduleLanguage,
      _activeLanguage,
      widget.language,
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return Localizations.localeOf(context).languageCode;
  }

  void _showModuleGenerationError(int moduleNumber) {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final moduleLabel =
        l10n?.outlineModuleFallback(moduleNumber) ?? 'Module $moduleNumber';
    final generic =
        l10n?.outlineErrorGeneric ?? 'We could not load the outline.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$generic ($moduleLabel)')),
    );
  }

  void _applyCachedOutline(StoredOutline cached) {
    final response = Map<String, dynamic>.from(cached.rawResponse);

    response.putIfAbsent('outline', () => cached.outline);

    setState(() {
      _error = null;

      _outlineResponse = response;

      _outlineSource = cached.source;

      _lastSavedAt = cached.savedAt;

      _preferredBand = cached.band ?? _preferredBand;

      _activeBand = CourseApiService.tryPlacementBandFromString(cached.band);

      _activeDepth = cached.depth ?? _activeDepth;

      _activeLanguage = cached.lang ?? _activeLanguage;

      _isLoading = false;

      _generatingModules.clear();
      _hydratedModules
        ..clear()
        ..addAll(_detectGeneratedModules(response['outline']));
    });

    final language = cached.lang ?? _activeLanguage ?? 'en';

    final metadata = RecentOutlineMetadata(
      id: RecentOutlineMetadata.buildId(
        topic: cached.topic,
        language: language,
        band: cached.band,
        depth: cached.band == null ? cached.depth : null,
      ),
      topic: cached.topic,
      language: language,
      band: cached.band,
      depth: cached.depth,
      savedAt: DateTime.now(),
    );

    unawaited(RecentOutlinesStorage.instance.upsert(metadata));
  }

  void _notifyPlanReady({required bool fromCache}) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    final l10n = AppLocalizations.of(context)!;

    final message =
        fromCache ? l10n.outlineSnackCached : l10n.outlineSnackUpdated;

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startPlacementQuiz() async {
    final l10n = AppLocalizations.of(context)!;
    final auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid ?? 'anonymous';
    final localeLanguage = Localizations.localeOf(context).languageCode;
    final preferredLanguage = (_activeLanguage?.trim().isNotEmpty ?? false)
        ? _activeLanguage!.trim()
        : (widget.language?.trim().isNotEmpty ?? false)
            ? widget.language!.trim()
            : localeLanguage;
    final normalizedLanguage = preferredLanguage.toLowerCase();

    final lastStart = await QuizAttemptStorage.instance.lastStart(
      userId: userId,
      topic: _courseId,
      language: normalizedLanguage,
    );

    if (lastStart != null) {
      final elapsed = DateTime.now().difference(lastStart);
      const cooldown = Duration(minutes: 5);
      if (elapsed < cooldown) {
        final remaining = cooldown - elapsed;
        final minutesRemaining = remaining.inMinutes;
        final secondsRemaining = remaining.inSeconds % 60;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              minutesRemaining > 0
                  ? l10n.quizCooldownMinutes(
                      minutesRemaining + (secondsRemaining > 0 ? 1 : 0),
                    )
                  : l10n.quizCooldownSeconds,
            ),
          ),
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }

    final navigator = Navigator.of(context);
    final result = await navigator.pushNamed(
      QuizScreen.routeName,
      arguments: QuizScreenArgs(
        topic: _courseId,
        language: normalizedLanguage,
        autoOpenOutline: false,
        outlineGenerator: _outlineFetcher,
      ),
    );

    if (!mounted) {
      return;
    }

    if (result is! Map) {
      return;
    }

    final apply = result['apply'] != false;
    if (!apply) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.quizResultsNoChanges)),
      );
      return;
    }

    final scoreRaw = result['scorePct'];
    final scorePct = scoreRaw is num ? scoreRaw.toInt().clamp(0, 100) : 0;
    final bandRaw = result['band']?.toString();
    final suggestedDepthRaw = result['suggestedDepth']?.toString();
    final recommend = result['recommendRegenerate'] == true;

    final newBand = CourseApiService.tryPlacementBandFromString(bandRaw) ??
        CourseApiService.placementBandForScore(scorePct);
    final currentBand = _activeBand;
    final bandChanged = currentBand == null || newBand != currentBand;

    if (!bandChanged && !recommend) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.planAlreadyAligned)),
      );
      return;
    }

    final bandString = CourseApiService.placementBandToString(newBand);
    final depthSuggestion =
        suggestedDepthRaw ?? CourseApiService.depthForBand(newBand);

    await TopicBandCache.instance.setBand(
      userId: userId,
      topic: _courseId,
      language: normalizedLanguage,
      band: newBand,
    );

    _preferredBand = bandString;
    _activeBand = newBand;
    _activeDepth = depthSuggestion;
    _activeLanguage = normalizedLanguage;

    await _loadOutline(
      forceRefresh: true,
      showLoading: true,
      preferredBandOverride: bandString,
      depthOverride: depthSuggestion,
      notify: false,
      preferCache: false,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.planReady)),
    );
  }

  Future<void> _showRefineSheet() async {
    final l10n = AppLocalizations.of(context)!;

    final action = await showModalBottomSheet<RefineAction>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                key: const Key('refine-depth'),
                leading: const Icon(Icons.tune),
                title: Text(l10n.outlineRefineChangeDepthTitle),
                subtitle: Text(l10n.outlineRefineChangeDepthSubtitle),
                onTap: () => Navigator.of(context).pop(RefineAction.depth),
              ),
              ListTile(
                key: const Key('refine-quiz-option'),
                leading: const Icon(Icons.quiz_outlined),
                title: Text(l10n.takePlacementQuiz),
                subtitle: Text(l10n.outlineRefinePlacementQuizSubtitle),
                onTap: () => Navigator.of(context).pop(RefineAction.quiz),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (action == RefineAction.depth) {
      await _selectDepth();
    } else if (action == RefineAction.quiz) {
      await _startPlacementQuiz();
    }
  }

  Future<void> _selectDepth() async {
    final l10n = AppLocalizations.of(context)!;

    const options = ['intro', 'medium', 'deep'];

    final selection = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((depth) {
              final label = _depthLabelForSelection(l10n, depth);

              final isActive = depth == _activeDepth;

              return ListTile(
                key: ValueKey('depth-$depth'),
                leading: Icon(
                  isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(label),
                onTap: () => Navigator.of(context).pop(depth),
              );
            }).toList(),
          ),
        );
      },
    );

    if (!mounted || selection == null) {
      return;
    }

    await _loadOutline(
      forceRefresh: false,
      showLoading: true,
      preferredBandOverride: null,
      depthOverride: selection,
      notify: true,
      preferCache: true,
    );
  }

  String _depthLabelForSelection(AppLocalizations l10n, String depth) {
    switch (depth.toLowerCase()) {
      case 'intro':
        return l10n.depthIntro;

      case 'medium':
        return l10n.depthMedium;

      case 'deep':
        return l10n.depthDeep;

      default:
        return depth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildModuleOutlineView(context);
  }
}
