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

    final String rawId = module['id']?.toString() ?? '';

    final String moduleId =
        rawId.trim().isNotEmpty ? rawId.trim() : 'module-$moduleIndex';

    if (!_reportedModuleStarts.add(moduleId)) {
      return;
    }

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
      });

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
