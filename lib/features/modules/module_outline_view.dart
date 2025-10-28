import 'dart:async';



import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';



import 'package:aelion/l10n/app_localizations.dart';

import 'package:aelion/features/lesson/lesson_detail_page.dart';

import 'package:aelion/features/quiz/quiz_screen.dart';

import 'package:aelion/services/course_api_service.dart';

import 'package:aelion/widgets/skeleton.dart';

import 'package:aelion/services/local_outline_storage.dart';

import 'package:aelion/services/quiz_attempt_storage.dart';

import 'package:aelion/services/recent_outlines_storage.dart';

import 'package:aelion/services/topic_band_cache.dart';



enum _RefineAction { depth, quiz }



class ModuleOutlineArgs {

  const ModuleOutlineArgs({

    required this.topic,

    this.level,

    this.language,

    this.goal,

    this.depth,

    this.preferredBand,

    this.recommendRegenerate,

    this.initialOutline,

    this.initialResponse,

    this.initialSource,

    this.initialSavedAt,

    this.outlineFetcher,

  });



  final String topic;

  final String? level;

  final String? language;

  final String? goal;

  final String? depth;

  final String? preferredBand;

  final bool? recommendRegenerate;

  final List<Map<String, dynamic>>? initialOutline;

  final Map<String, dynamic>? initialResponse;

  final String? initialSource;

  final DateTime? initialSavedAt;

  final OutlineFetcher? outlineFetcher;

}



class ModuleOutlineView extends StatefulWidget {

  static const routeName = '/module';



  const ModuleOutlineView({

    super.key,

    this.topic,

    this.level,

    this.language,

    this.goal,

    this.depth,

    this.preferredBand,

    this.recommendRegenerate,

    this.initialOutline,

    this.initialResponse,

    this.initialSource,

    this.initialSavedAt,

    this.outlineFetcher,

  });



  final String? topic;

  final String? level;

  final String? language;

  final String? goal;

  final String? depth;

  final String? preferredBand;

  final bool? recommendRegenerate;

  final List<Map<String, dynamic>>? initialOutline;

  final Map<String, dynamic>? initialResponse;

  final String? initialSource;

  final DateTime? initialSavedAt;

  final OutlineFetcher? outlineFetcher;



  @override

  State<ModuleOutlineView> createState() => _ModuleOutlineViewState();

}



class _ModuleOutlineViewState extends State<ModuleOutlineView> {
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



  @override

  void initState() {
    super.initState();
    _outlineFetcher = widget.outlineFetcher ?? CourseApiService.generateOutline;
    _courseId = (widget.topic?.trim().isNotEmpty ?? false)

        ? widget.topic!.trim()

        : '';

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

      _activeBand =

          CourseApiService.tryPlacementBandFromString(_preferredBand);

      _activeDepth = widget.depth;

      _isLoading = false;

    } else {

      _activeBand =

          CourseApiService.tryPlacementBandFromString(_preferredBand);

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



      final cacheId = RecentOutlineMetadata.buildId(

        topic: _courseId,

        language: preferredLanguage,

        band: bandEnum != null

            ? CourseApiService.placementBandToString(bandEnum)

            : null,

        depth: bandEnum == null ? resolvedDepth : null,

      );



      if (!forceRefresh && preferCache) {

        final cached =

            await LocalOutlineStorage.instance.findById(cacheId);

        if (cached != null) {

          if (!mounted) return;

          _applyCachedOutline(cached);

          if (notify && mounted) {

            _notifyPlanReady(fromCache: true);

          }

          return;

        }

      }



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

    final action = await showModalBottomSheet<_RefineAction>(

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

                onTap: () => Navigator.of(context).pop(_RefineAction.depth),

              ),

              ListTile(

                key: const Key('refine-quiz-option'),

                leading: const Icon(Icons.quiz_outlined),

                title: Text(l10n.takePlacementQuiz),

                subtitle: Text(l10n.outlineRefinePlacementQuizSubtitle),

                onTap: () => Navigator.of(context).pop(_RefineAction.quiz),

              ),

            ],

          ),

        );

      },

    );



    if (!mounted) return;

    if (action == _RefineAction.depth) {

      await _selectDepth();

    } else if (action == _RefineAction.quiz) {

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

    final l10n = AppLocalizations.of(context)!;

    final title = widget.topic ?? l10n.outlineFallbackTitle;



    return Scaffold(

      appBar: AppBar(

        title: Text(title),

        actions: [

          IconButton(

            tooltip: l10n.outlineUpdatePlan,

            onPressed: _isLoading

                ? null

                : () => _loadOutline(

                      forceRefresh: true,

                      preferredBandOverride: _preferredBand,

                      depthOverride: _activeDepth,

                      notify: true,

                      preferCache: false,

                    ),

            icon: const Icon(Icons.sync),

          ),

        ],

      ),

      body: _buildBody(l10n),

      floatingActionButton: _isLoading || _error != null

          ? null

          : FloatingActionButton.extended(

              key: const Key('refine-plan'),

              onPressed: _showRefineSheet,

              icon: const Icon(Icons.tune),

              label: Text(l10n.refinePlan),

            ),

    );

  }



  Widget _buildBody(AppLocalizations l10n) {

    if (_isLoading) {

      return const _OutlineSkeleton();

    }

    if (_error != null) {

      final message = '${l10n.outlineErrorGeneric}\n${_error!}';

      return _ErrorState(

        message: message,

        retryLabel: l10n.commonRetry,

        onRetry: () => _loadOutline(

          showLoading: true,

          preferredBandOverride: _preferredBand,

          depthOverride: _activeDepth,

        ),

      );

    }

    final response = _outlineResponse;

    if (response == null) {

      return _ErrorState(

        message: l10n.outlineErrorEmpty,

        retryLabel: l10n.commonRetry,

        onRetry: () => _loadOutline(

          showLoading: true,

          preferredBandOverride: _preferredBand,

          depthOverride: _activeDepth,

        ),

      );

    }



    final modules = _parseOutline(response['outline']);

    if (modules.isEmpty) {

      return _ErrorState(

        message: l10n.outlineErrorNoContent,

        retryLabel: l10n.commonRetry,

        onRetry: () => _loadOutline(

          showLoading: true,

          preferredBandOverride: _preferredBand,

          depthOverride: _activeDepth,

        ),

      );

    }



    final savedAt = _resolveSavedAt(response);

    final source = _outlineSource ?? response['source']?.toString();



    return _OutlineContent(

      l10n: l10n,

      courseId: _courseId,

      response: response,

      modules: modules,

      source: source,

      savedAt: savedAt,

      band: _activeBand,

      depth: _activeDepth,

    );

  }



  List<Map<String, dynamic>> _parseOutline(dynamic raw) {

    if (raw is! List) return <Map<String, dynamic>>[];

    return raw

        .whereType<Map>()

        .map((module) => Map<String, dynamic>.from(module))

        .toList(growable: false);

  }



  DateTime? _resolveSavedAt(Map<String, dynamic> response) {

    if (_lastSavedAt != null) {

      return _lastSavedAt;

    }

    final raw = response['savedAt'] ?? response['lastSavedAt'];

    if (raw is String) {

      return DateTime.tryParse(raw);

    }

    if (raw is int) {

      return DateTime.fromMillisecondsSinceEpoch(raw).toLocal();

    }

    return null;

  }

}



class _OutlineContent extends StatelessWidget {

  const _OutlineContent({

    required this.l10n,

    required this.courseId,

    required this.response,

    required this.modules,

    this.source,

    this.savedAt,

    this.band,

    this.depth,

  });



  final AppLocalizations l10n;

  final String courseId;

  final Map<String, dynamic> response;

  final List<Map<String, dynamic>> modules;

  final String? source;

  final DateTime? savedAt;

  final PlacementBand? band;

  final String? depth;



  @override

  Widget build(BuildContext context) {

    final topic = response['topic']?.toString() ?? l10n.outlineFallbackTitle;

    final goal = response['goal']?.toString();

    final level = response['level']?.toString();

    final language = response['language']?.toString();

    final estimated = response['estimated_hours'];

    final estimatedLabel =

        estimated is num ? l10n.outlineMetaHours(estimated.round()) : null;

    final bandLabel = band != null ? _bandLabel(l10n, band!) : null;



    final updatedLabel =

        savedAt != null ? _formatUpdatedLabel(l10n, savedAt!) : null;



    final children = <Widget>[

      _OutlineHeader(

        l10n: l10n,

        topic: topic,

        goal: goal,

        level: level,

        bandLabel: bandLabel,

        estimated: estimatedLabel,

        language: language,

        depth: depth,

        updatedLabel: updatedLabel,

      ),

      ...modules.asMap().entries.map(

            (entry) => _ModuleCard(

              key: Key('module-${entry.key}'),

              courseId: courseId,

              moduleIndex: entry.key,

              module: entry.value,

              courseLanguage: language,

              l10n: l10n,

            ),

          ),

    ];



    return ListView(

      padding: const EdgeInsets.all(12),

      children: children,

    );

  }

}



class _OutlineHeader extends StatelessWidget {

  const _OutlineHeader({

    required this.l10n,

    required this.topic,

    this.goal,

    this.level,

    this.bandLabel,

    this.estimated,

    this.language,

    this.depth,

    this.updatedLabel,

  });



  final AppLocalizations l10n;

  final String topic;

  final String? goal;

  final String? level;

  final String? bandLabel;

  final String? estimated;

  final String? language;

  final String? depth;

  final String? updatedLabel;



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final chips = <Widget>[];



    if (bandLabel != null && bandLabel!.isNotEmpty) {

      chips.add(

        _OutlineMetaItem(

          icon: Icons.workspace_premium_outlined,

          label: l10n.outlineMetaBand(bandLabel!),

        ),

      );

    } else if (level != null && level!.isNotEmpty) {

      chips.add(

        _OutlineMetaItem(

          icon: Icons.school_outlined,

          label: l10n.outlineMetaLevel(level!),

        ),

      );

    }



    if (estimated != null && estimated!.isNotEmpty) {

      chips.add(

        _OutlineMetaItem(

          icon: Icons.schedule_outlined,

          label: estimated!,

        ),

      );

    }



    if (language != null && language!.isNotEmpty) {

      chips.add(

        _OutlineMetaItem(

          icon: Icons.translate,

          label: l10n.outlineMetaLanguage(language!),

        ),

      );

    }



    if (depth != null && depth!.isNotEmpty) {

      chips.add(

        _OutlineMetaItem(

          icon: Icons.assessment_outlined,

          label: l10n.outlineMetaDepth(depth!),

        ),

      );

    }



    return Card(

      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(topic, style: theme.textTheme.headlineSmall),

            if (updatedLabel != null && updatedLabel!.isNotEmpty) ...[

              const SizedBox(height: 4),

              Text(

                updatedLabel!,

                style: theme.textTheme.bodySmall,

              ),

            ],

            if (goal != null && goal!.isNotEmpty) ...[

              const SizedBox(height: 8),

              Text(goal!, style: theme.textTheme.bodyMedium),

            ],

            if (chips.isNotEmpty) ...[

              const SizedBox(height: 12),

              Wrap(

                spacing: 12,

                runSpacing: 8,

                children: chips,

              ),

            ],

          ],

        ),

      ),

    );

  }

}



class _OutlineMetaItem extends StatelessWidget {

  const _OutlineMetaItem({

    required this.icon,

    required this.label,

  });



  final IconData icon;

  final String label;



  @override

  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(

        color: colorScheme.secondaryContainer,

        borderRadius: BorderRadius.circular(24),

      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(icon, size: 18, color: colorScheme.onSecondaryContainer),

          const SizedBox(width: 6),

          Text(

            label,

            style: TextStyle(color: colorScheme.onSecondaryContainer),

          ),

        ],

      ),

    );

  }

}



class _ModuleCard extends StatelessWidget {

  const _ModuleCard({

    super.key,

    required this.courseId,

    required this.moduleIndex,

    required this.module,

    required this.l10n,

    this.courseLanguage,

  });



  final String courseId;

  final int moduleIndex;

  final Map<String, dynamic> module;

  final AppLocalizations l10n;

  final String? courseLanguage;



  @override

  Widget build(BuildContext context) {

    final rawTitle = module['title']?.toString().trim();

    final title =

        (rawTitle?.isNotEmpty ?? false) ? rawTitle! : l10n.outlineModuleFallback(moduleIndex + 1);

    final locked = module['locked'] == true;

    final lessons = _parseLessons(module['lessons']);

    final lessonCountLabel = l10n.outlineLessonCount(lessons.length);

    final languageLabel = courseLanguage ?? '';



    final leadingIcon =

        locked ? Icons.lock_outline : Icons.check_circle_outline;



    return Card(

      margin: const EdgeInsets.only(bottom: 12),

      child: ExpansionTile(

        key: Key('module-$moduleIndex-tile'),

        initiallyExpanded: !locked,

        leading: Icon(leadingIcon),

        title: Text(title),

        subtitle: Text(lessonCountLabel),

        children: lessons.asMap().entries.map((entry) {

          final lessonIndex = entry.key;

          final lesson = entry.value;

          final rawLessonTitle = lesson['title']?.toString().trim();

          final lessonTitle = (rawLessonTitle?.isNotEmpty ?? false)

              ? rawLessonTitle!

              : l10n.outlineLessonFallback(lessonIndex + 1);

          final lessonLanguage =

              lesson['language']?.toString() ?? languageLabel;

          return ListTile(

            key: Key('lesson-tile-$moduleIndex-$lessonIndex'),

            leading: const Icon(Icons.menu_book_outlined),

            title: Text(lessonTitle),

            subtitle: lessonLanguage.isEmpty

                ? null

                : Text(l10n.outlineLessonLanguage(lessonLanguage)),

            trailing: const Icon(Icons.chevron_right),

            onTap: () {

              Navigator.of(context).pushNamed(

                LessonDetailPage.routeName,

                arguments: LessonDetailArgs(

                  courseId: courseId,

                  moduleTitle: title,

                  lessonTitle: lessonTitle,

                  content: lesson['content']?.toString(),

                ),

              );

            },

          );

        }).toList(),

      ),

    );

  }



  List<Map<String, dynamic>> _parseLessons(dynamic raw) {

    if (raw is! List) return <Map<String, dynamic>>[];

    return raw

        .whereType<Map>()

        .map((lesson) => Map<String, dynamic>.from(lesson))

        .toList(growable: false);

  }

}



class _OutlineSkeleton extends StatelessWidget {

  const _OutlineSkeleton();



  @override

  Widget build(BuildContext context) {

    return ListView.builder(

      padding: const EdgeInsets.all(12.0),

      itemCount: 4,

      itemBuilder: (context, index) {

        return Card(

          margin: const EdgeInsets.only(bottom: 12),

          child: const Padding(

            padding: EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Skeleton(height: 20, width: 200),

                SizedBox(height: 12),

                Skeleton(height: 16, width: 160),

                SizedBox(height: 8),

                Skeleton(height: 16, width: double.infinity),

                SizedBox(height: 8),

                Skeleton(height: 16, width: double.infinity),

              ],

            ),

          ),

        );

      },

    );

  }

}



class _ErrorState extends StatelessWidget {

  const _ErrorState({

    required this.message,

    required this.onRetry,

    required this.retryLabel,

  });



  final String message;

  final VoidCallback onRetry;

  final String retryLabel;



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(16.0),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            const Icon(Icons.error_outline, color: Colors.red, size: 48),

            const SizedBox(height: 16),

            Text(

              message,

              textAlign: TextAlign.center,

              style: theme.textTheme.bodyLarge,

            ),

            const SizedBox(height: 16),

            FilledButton.icon(

              onPressed: onRetry,

              icon: const Icon(Icons.refresh),

              label: Text(retryLabel),

            ),

          ],

        ),

      ),

    );

  }





}

String _bandLabel(AppLocalizations l10n, PlacementBand band) {

  switch (band) {

    case PlacementBand.beginner:

      return l10n.quizBandBeginner;

    case PlacementBand.intermediate:

      return l10n.quizBandIntermediate;

    case PlacementBand.advanced:

      return l10n.quizBandAdvanced;

  }

}



String _formatUpdatedLabel(AppLocalizations l10n, DateTime savedAt) {

  final difference = DateTime.now().difference(savedAt.toLocal());

  final safeDifference =

      difference.isNegative ? Duration.zero : difference;

  if (safeDifference.inMinutes < 1) {

    return l10n.homeUpdatedJustNow;

  }

  if (safeDifference.inHours < 1) {

    return l10n.homeUpdatedMinutes(safeDifference.inMinutes);

  }

  if (safeDifference.inDays < 1) {

    return l10n.homeUpdatedHours(safeDifference.inHours);

  }

  return l10n.homeUpdatedDays(safeDifference.inDays);

}

