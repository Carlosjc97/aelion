import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edaptia/core/app_colors.dart';
import 'package:edaptia/features/adaptive_journey/adaptive_journey_screen.dart';
import 'package:edaptia/features/home/home_controller.dart';
import 'package:edaptia/features/quiz/quiz_screen.dart';
import 'package:edaptia/features/settings/settings_view.dart';
import 'package:edaptia/features/support/help_support_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:edaptia/dataconnect_generated/courses.dart';
import 'package:edaptia/services/google_sign_in_helper.dart';
import 'package:edaptia/services/learner_state_service.dart';
import 'package:edaptia/widgets/skeleton.dart';
import 'package:edaptia/providers/streak_provider.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

enum _HomeMenuAction { settings, help, catalog }

class _HomeViewState extends ConsumerState<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  late final HomeController _controller;
  final LearnerStateService _learnerService = LearnerStateService.instance;
  AdaptiveLearnerState? _learnerState;
  StreamSubscription<AdaptiveLearnerState?>? _learnerSubscription;
  bool _loading = false;
  bool _initializedRecommendations = false;
  bool _englishWaitlistSubmitting = false;
  bool _englishWaitlistCompleted = false;

  FirebaseAuth? _safeAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (error, stackTrace) {
      debugPrint('[HomeView] FirebaseAuth unavailable: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.addListener(_onControllerChanged);
    unawaited(_controller.loadRecents());
    _hydrateStreak();
    _startLearnerStateListener();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _hydrateStreak() {
    final userId = _safeAuth()?.currentUser?.uid;
    if (userId == null) return;
    Future.microtask(() {
      if (!mounted) return;
      // Defer provider write until after build to avoid Riverpod init crash.
      unawaited(ref.read(streakProvider.notifier).refresh(userId));
    });
  }

  void _startLearnerStateListener() {
    _learnerSubscription?.cancel();
    final userId = _safeAuth()?.currentUser?.uid;
    if (userId == null) {
      setState(() => _learnerState = null);
      return;
    }
    _learnerSubscription = _learnerService.watchLearnerState().listen(
      (state) {
        if (!mounted) return;
        setState(() => _learnerState = state);
      },
      onError: (error) {
        debugPrint('[HomeView] learner state stream error: $error');
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedRecommendations) {
      _initializedRecommendations = true;
      final languageCode = Localizations.localeOf(context).languageCode;
      final userId = _safeAuth()?.currentUser?.uid ?? 'anonymous';
      unawaited(
        _controller.loadRecommendations(
          languageCode: languageCode,
          userId: userId,
        ),
      );
    }
  }

  void _handleMenuSelection(_HomeMenuAction action) {
    switch (action) {
      case _HomeMenuAction.settings:
        Navigator.of(context).pushNamed(SettingsView.routeName);
        break;
      case _HomeMenuAction.help:
        Navigator.of(context).pushNamed(HelpSupportScreen.routeName);
        break;
      case _HomeMenuAction.catalog:
        Navigator.of(context).pushNamed(LessonsPage.routeName);
        break;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _searchController.dispose();
    _learnerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startFlow({String? presetTopic}) async {
    final l10n = AppLocalizations.of(context)!;
    final rawTopic = (presetTopic ?? _searchController.text).trim();

    if (rawTopic.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeSnackMissingTopic)),
      );
      return;
    }

    if (_loading) return;

    setState(() => _loading = true);
    try {
      final auth = _safeAuth();
      final userId = auth?.currentUser?.uid ?? 'anonymous';
      final languageCode = Localizations.localeOf(context).languageCode;

      // NOTE: Re-enable when backend trackSearch endpoint is implemented
      // unawaited(
      //   CourseApiService.trackSearch(topic: rawTopic, language: languageCode)
      //       .catchError((error) {
      //     debugPrint('[HomeView] trackSearch failed: $error');
      //     return null;
      //   }),
      // );

      await _controller.recordSearch(
        userId: userId,
        topic: rawTopic,
        language: languageCode,
      );

      final cachedBand = await _controller.cachedBand(
        userId: userId,
        topic: rawTopic,
        language: languageCode,
      );

      if (!mounted) return;

      // ALWAYS go to adaptive journey flow (QuizScreen)
      // If cachedBand exists, QuizScreen will skip directly to AdaptiveJourneyScreen
      // This ensures we NEVER go to legacy ModuleOutlineView

      if (cachedBand == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.calibratingPlan)),
        );
      }

      unawaited(
        _controller.trackQuizOpen(
          topic: rawTopic,
          language: languageCode,
        ),
      );

      if (!mounted) return;

      assert(() {
        debugPrint('[HomeView] navigating to QuizScreen (adaptive flow)');
        return true;
      }());
      await Navigator.of(context).pushNamed(
        QuizScreen.routeName,
        arguments: QuizScreenArgs(
          topic: rawTopic,
          language: languageCode,
        ),
      );

      await _controller.loadRecents();
      await _controller.loadRecommendations(
        languageCode: languageCode,
        userId: userId,
      );
    } catch (error) {
      debugPrint('[HomeView] Failed to generate plan: $error');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.homeGenerateError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget? _buildStreakCard(
    StreakState state,
    ThemeData theme,
    bool isSpanish,
  ) {
    final userId = _safeAuth()?.currentUser?.uid;
    if (userId == null) return null;

    final title = isSpanish ? 'Racha diaria' : 'Daily streak';
    final subtitle = state.lastCheckIn == null
        ? (isSpanish
            ? 'Tu primera racha comienza hoy'
            : 'Start your first streak today')
        : (isSpanish
            ? 'Último check-in: ${_formatDate(state.lastCheckIn!)}'
            : 'Last check-in: ${_formatDate(state.lastCheckIn!)}');
    final helperText = isSpanish
        ? 'Tu racha se actualiza automáticamente al terminar una lección o módulo.'
        : 'Your streak updates automatically after finishing a lesson or module.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${state.days}',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.loading) const LinearProgressIndicator(minHeight: 4),
            if (state.loading) const SizedBox(height: 8),
            Text(
              helperText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  void _handleRecommendationTap(String topic) {
    final normalized = topic.trim();
    if (normalized.isEmpty) {
      return;
    }
    setState(() {
      _searchController.text = normalized;
    });
    unawaited(_startFlow(presetTopic: normalized));
  }

  Future<void> _notifyEnglishTechWaitlist() async {
    if (_englishWaitlistSubmitting || _englishWaitlistCompleted) {
      return;
    }

    setState(() => _englishWaitlistSubmitting = true);
    final user = _safeAuth()?.currentUser;
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context)!;

    try {
      final payload = <String, dynamic>{
        'userId': user?.uid,
        'email': user?.email,
        'displayName': user?.displayName,
        'language': locale.languageCode,
        'platform': defaultTargetPlatform.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
      payload.removeWhere((key, value) => value == null);

      await FirebaseFirestore.instance
          .collection('waitlist_english_tech')
          .add(payload);

      if (!mounted) return;
      setState(() => _englishWaitlistCompleted = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeEnglishNotifySuccess)),
      );
    } catch (error, stackTrace) {
      debugPrint('[HomeView] waitlist english tech failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeEnglishNotifyError)),
      );
    } finally {
      if (mounted) {
        setState(() => _englishWaitlistSubmitting = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final auth = _safeAuth();
      if (auth != null) {
        await auth.signOut();
      }
      if (!kIsWeb) {
        final helper = await GoogleSignInHelper.instance();
        await helper.signOut();
      }
    } catch (error) {
      debugPrint('[HomeView] signOut error: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.homeSignOutError)));
    }
  }

  String _buildGreeting(AppLocalizations l10n, User? user) {
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      final firstName = displayName.split(RegExp('\\s+')).first;
      return l10n.homeGreetingNamedShort(firstName);
    }
    return l10n.homeGreetingWave;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = _safeAuth()?.currentUser;

    final recommendations = _controller.buildRecommendationItems();
    final userId = user?.uid ?? 'anonymous';
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;
    final greeting = _buildGreeting(l10n, user);
    final motivation = l10n.homeMotivation;
    final streakState = ref.watch(streakProvider);
    final streakCard = _buildStreakCard(
      streakState,
      theme,
      locale.languageCode == 'es',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<_HomeMenuAction>(
            icon: const Icon(Icons.more_vert),
            tooltip: MaterialLocalizations.of(context).showMenuTooltip,
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.settings,
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined),
                    const SizedBox(width: 12),
                    Text(l10n.settingsTitle),
                  ],
                ),
              ),
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.catalog,
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_outlined),
                    const SizedBox(width: 12),
                    Text(l10n.homeShortcutCourse),
                  ],
                ),
              ),
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.help,
                child: Row(
                  children: [
                    const Icon(Icons.help_outline),
                    const SizedBox(width: 12),
                    Text(l10n.homeOverflowHelpSupport),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: l10n.homeLogoutTooltip,
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _GreetingCard(
                  greeting: greeting,
                  motivation: motivation,
                ),
                const SizedBox(height: 16),
                _PromptCard(
                  controller: _searchController,
                  generateLabel: l10n.homeGenerate,
                  loading: _loading,
                  onSubmit: () => _startFlow(),
                  hintText: l10n.homeInputHint,
                  title: l10n.homePromptTitle,
                ),
                if (streakCard != null) ...[
                  const SizedBox(height: 24),
                  streakCard,
                ],
                const SizedBox(height: 24),
                _RecommendationsSection(
                  l10n: l10n,
                  loading: _controller.loadingRecommendations,
                  error: _controller.recommendationsError,
                  recommendations: recommendations,
                  onRetry: () => _controller.loadRecommendations(
                    languageCode: languageCode,
                    userId: userId,
                  ),
                  onSelected: _handleRecommendationTap,
                ),
                const SizedBox(height: 24),
                _EnglishTechCard(
                  l10n: l10n,
                  loading: _englishWaitlistSubmitting,
                  completed: _englishWaitlistCompleted,
                  onNotify: _notifyEnglishTechWaitlist,
                ),
                const SizedBox(height: 24),
                if (_controller.recentOutlines.isNotEmpty) ...[
                  Text(l10n.homeRecentTitle,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  for (final entry
                      in _controller.recentOutlines.asMap().entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _AdaptivePlanCard(
                        key: ValueKey('recent-${entry.key}'),
                        item: entry.value,
                        l10n: l10n,
                        learnerState: _learnerState,
                        learnerService: _learnerService,
                        onContinue: () => _openCachedOutline(entry.value),
                      ),
                    ),
                ] else
                  _RecentEmptyCard(message: l10n.homeRecentEmpty),
              ],
            ),
            if (_loading) const _HomeLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Future<void> _openCachedOutline(HomeRecentOutline item) async {
    if (!mounted) return;
    final meta = item.metadata;

    // If we have a cached band, go directly to AdaptiveJourneyScreen
    // Otherwise, go to QuizScreen for placement quiz
    if (meta.band != null && meta.band!.isNotEmpty) {
      final band = CourseApiService.placementBandFromString(meta.band!);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AdaptiveJourneyScreen(
            topic: meta.topic,
            target: meta.topic,
            initialBand: band,
          ),
        ),
      );
    } else {
      // No band cached, do placement quiz first
      await Navigator.of(context).pushNamed(
        QuizScreen.routeName,
        arguments: QuizScreenArgs(
          topic: meta.topic,
          language: meta.language,
        ),
      );
    }
    await _controller.loadRecents();
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({
    required this.l10n,
    required this.loading,
    required this.error,
    required this.recommendations,
    required this.onRetry,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final bool loading;
  final bool error;
  final List<HomeRecommendation> recommendations;
  final Future<void> Function() onRetry;
  final void Function(String topic) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading) {
      return const _RecommendationSkeleton();
    }

    if (error) {
      return _RecommendationError(l10n: l10n, onRetry: onRetry);
    }

    if (recommendations.isEmpty) {
      return Text(l10n.homeRecommendationsEmpty);
    }

    final visible =
        recommendations.take(5).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.homeRecommendationsTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: visible.map((item) {
            return _RecommendationPill(
              label: item.label,
              icon: item.source == HomeRecommendationSource.trending
                  ? Icons.trending_up_outlined
                  : Icons.history_outlined,
              onTap: () => onSelected(item.label),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

class _RecommendationPill extends StatelessWidget {
  const _RecommendationPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationSkeleton extends StatelessWidget {
  const _RecommendationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        Skeleton(height: 32, width: 100),
        Skeleton(height: 32, width: 120),
        Skeleton(height: 32, width: 90),
      ],
    );
  }
}

class _RecommendationError extends StatelessWidget {
  const _RecommendationError({required this.l10n, required this.onRetry});

  final AppLocalizations l10n;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n.homeRecommendationsError,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        TextButton(
          onPressed: () {
            onRetry();
          },
          child: Text(l10n.commonRetry),
        ),
      ],
    );
  }
}

class _EnglishTechCard extends StatelessWidget {
  const _EnglishTechCard({
    required this.l10n,
    required this.loading,
    required this.completed,
    required this.onNotify,
  });

  final AppLocalizations l10n;
  final bool loading;
  final bool completed;
  final VoidCallback onNotify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium;
    final subtitleStyle = theme.textTheme.bodySmall;
    final buttonLabel =
        completed ? l10n.homeEnglishNotifyDone : l10n.homeEnglishNotifyCta;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.language, size: 40),
        title: Text(l10n.homeEnglishComingTitle, style: titleStyle),
        subtitle: Text(
          l10n.homeEnglishComingSubtitle,
          style: subtitleStyle,
        ),
        isThreeLine: true,
        trailing: SizedBox(
          width: 140,
          child: FilledButton(
            onPressed: (loading || completed) ? null : onNotify,
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(buttonLabel),
          ),
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({
    required this.greeting,
    required this.motivation,
  });

  final String greeting;
  final String motivation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(motivation, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.controller,
    required this.generateLabel,
    required this.loading,
    required this.onSubmit,
    required this.hintText,
    required this.title,
  });

  final TextEditingController controller;
  final String generateLabel;
  final bool loading;
  final VoidCallback onSubmit;
  final String hintText;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.neutral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : onSubmit,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(generateLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptivePlanCard extends StatelessWidget {
  const _AdaptivePlanCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.learnerState,
    required this.learnerService,
    required this.onContinue,
  });

  final HomeRecentOutline item;
  final AppLocalizations l10n;
  final AdaptiveLearnerState? learnerState;
  final LearnerStateService learnerService;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = item.metadata;
    final outline = item.cached?.outline ?? const <Map<String, dynamic>>[];
    final modules = outline.isEmpty
        ? [
            <String, dynamic>{
              'moduleNumber': 1,
              'title': l10n.outlineModuleFallback(1),
              'lessons': const <Map<String, dynamic>>[],
            }
          ]
        : outline;

    final moduleSnapshots = modules.asMap().entries.map((entry) {
      final moduleMap = Map<String, dynamic>.from(entry.value);
      final moduleNumber = moduleMap['moduleNumber'] is num
          ? (moduleMap['moduleNumber'] as num).toInt()
          : entry.key + 1;
      final moduleTitle = (moduleMap['title']?.toString().trim().isNotEmpty ??
              false)
          ? moduleMap['title'].toString()
          : l10n.outlineModuleFallback(moduleNumber);
      final lessonsRaw = moduleMap['lessons'];
      final lessonsList = lessonsRaw is List ? lessonsRaw : const [];
      final lessons = lessonsList.asMap().entries.map((lessonEntry) {
        final raw = lessonEntry.value is Map
            ? Map<String, dynamic>.from(lessonEntry.value as Map)
            : <String, dynamic>{};
        final title =
            (raw['title']?.toString().trim().isNotEmpty ?? false)
                ? raw['title'].toString()
                : 'Lección ${lessonEntry.key + 1}';
        final visited = learnerService.isLessonVisited(
          state: learnerState,
          topic: metadata.topic,
          moduleNumber: moduleNumber,
          lessonIndex: lessonEntry.key,
        );
        return _HomeLessonSnapshot(
          index: lessonEntry.key,
          title: title,
          visited: visited,
        );
      }).toList(growable: false);

      return _HomeModuleSnapshot(
        number: moduleNumber,
        title: moduleTitle,
        lessons: lessons,
      );
    }).toList(growable: false)
      ..sort((a, b) => a.number.compareTo(b.number));

    final activeModule = moduleSnapshots.firstWhere(
      (module) => !module.completed,
      orElse: () => moduleSnapshots.last,
    );

    final totalLessons = moduleSnapshots.fold<int>(
      0,
      (currentTotal, module) => currentTotal + module.totalLessons,
    );
    final visitedLessons = moduleSnapshots.fold<int>(
      0,
      (currentVisited, module) => currentVisited + module.visitedLessons,
    );
    final overallProgress =
        totalLessons == 0 ? 0.0 : visitedLessons / totalLessons;
    final bandEnum =
        CourseApiService.tryPlacementBandFromString(metadata.band);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metadata.topic,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatUpdatedLabel(l10n, metadata.savedAt),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (bandEnum != null)
                _MiniTag(
                  icon: Icons.school_outlined,
                  label: _bandLabel(l10n, bandEnum),
                ),
              _MiniTag(
                icon: Icons.language,
                label: metadata.language.toUpperCase(),
              ),
              _MiniTag(
                icon: Icons.check_circle_outline,
                label: '$visitedLessons/$totalLessons lecciones',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'M${activeModule.number} · ${activeModule.title}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _PlanProgressBar(
            value: activeModule.progress,
            label: 'Módulo activo ${(activeModule.progress * 100).round()}%',
          ),
          const SizedBox(height: 4),
          Text(
            'Avance total ${(overallProgress * 100).round()}% · '
            '$visitedLessons/$totalLessons lecciones',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ...activeModule.lessons
              .take(4)
              .map((lesson) => _LessonStatusRow(lesson: lesson)),
          if (activeModule.totalLessons > 4)
            Text(
              '+${activeModule.totalLessons - 4} lecciones más en este módulo',
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.play_circle_outline),
            label: Text(activeModule.completed
                ? l10n.homeRecentView
                : 'Continuar módulo ${activeModule.number}'),
          ),
        ],
      ),
    );
  }
}

class _PlanProgressBar extends StatelessWidget {
  const _PlanProgressBar({
    required this.value,
    required this.label,
  });

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso del módulo',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _LessonStatusRow extends StatelessWidget {
  const _LessonStatusRow({required this.lesson});

  final _HomeLessonSnapshot lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool visited = lesson.visited;
    final Color color = visited
        ? Colors.green
        : theme.colorScheme.outlineVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: visited
              ? color.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.4),
        ),
        color: visited
            ? color.withValues(alpha: 0.06)
            : theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Icon(
            visited ? Icons.check_circle : Icons.radio_button_unchecked,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              lesson.title,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _HomeLessonSnapshot {
  const _HomeLessonSnapshot({
    required this.index,
    required this.title,
    required this.visited,
  });

  final int index;
  final String title;
  final bool visited;
}

class _HomeModuleSnapshot {
  const _HomeModuleSnapshot({
    required this.number,
    required this.title,
    required this.lessons,
  });

  final int number;
  final String title;
  final List<_HomeLessonSnapshot> lessons;

  int get totalLessons => lessons.length;
  int get visitedLessons =>
      lessons.where((lesson) => lesson.visited).length;
  double get progress =>
      totalLessons == 0 ? 0 : visitedLessons / totalLessons;
  bool get completed => totalLessons > 0 && visitedLessons == totalLessons;
}

String _formatUpdatedLabel(AppLocalizations l10n, DateTime savedAt) {
  final now = DateTime.now();
  final difference = now.difference(savedAt.toLocal());
  final safeDifference = difference.isNegative ? Duration.zero : difference;

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

String _bandLabel(AppLocalizations l10n, PlacementBand band) {
  switch (band) {
    case PlacementBand.basic:
      return l10n.quizBandBasic;
    case PlacementBand.intermediate:
      return l10n.quizBandIntermediate;
    case PlacementBand.advanced:
      return l10n.quizBandAdvanced;
  }
}

class _RecentEmptyCard extends StatelessWidget {
  const _RecentEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadingOverlay extends StatelessWidget {
  const _HomeLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.92),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Skeleton(height: 20, width: 220),
              SizedBox(height: 16),
              Skeleton(height: 56, width: 200),
            ],
          ),
        ),
      ),
    );
  }
}

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  static const routeName = '/lessons';

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  bool _initialized = false;
  bool _loading = false;
  String? _errorMessage;
  GetCourseOutlineCourses? _course;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final languageCode = Localizations.localeOf(context).languageCode;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final catalogResult = await CoursesConnector.instance
          .getCourseCatalog(language: languageCode)
          .limit(10)
          .execute();

      final catalog = catalogResult.data.courses;
      if (catalog.isEmpty) {
        setState(() {
          _course = null;
          _errorMessage = 'No hay cursos publicados todavia.';
        });
        return;
      }

      final selectedSlug = catalog.first.slug;
      final outlineResult = await CoursesConnector.instance
          .getCourseOutline(slug: selectedSlug)
          .execute();

      final outlineCourses = outlineResult.data.courses;
      setState(() {
        _course = outlineCourses.isNotEmpty ? outlineCourses.first : null;
        _errorMessage = outlineCourses.isEmpty
            ? 'No se encontro el detalle del curso seleccionado.'
            : null;
      });
    } catch (error, stackTrace) {
      debugPrint('[LessonsPage] Failed to load courses: $error\n$stackTrace');
      setState(() {
        _errorMessage = 'No se pudo cargar el catalogo.';
        _course = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo de cursos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading && _course == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _ErrorView(message: _errorMessage!, onRetry: _loadData);
    }

    final course = _course;
    if (course == null) {
      return const Center(child: Text('Sin contenido disponible.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Text(course.title, style: theme.textTheme.headlineSmall),
          if (course.subtitle?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(course.subtitle!, style: theme.textTheme.titleMedium),
          ],
          if (course.summary?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(course.summary!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 20),
          for (final module in course.modules) _ModuleTile(module: module),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module});

  final GetCourseOutlineCoursesModules module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        key: PageStorageKey(module.id),
        title: Text(module.title, style: theme.textTheme.titleMedium),
        subtitle: module.summary?.isNotEmpty == true
            ? Text(module.summary!, style: theme.textTheme.bodySmall)
            : null,
        children: [
          for (final lesson in module.lessons)
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(lesson.title),
              subtitle: lesson.summary?.isNotEmpty == true
                  ? Text(
                      lesson.summary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: lesson.durationMinutes != null
                  ? Text('${lesson.durationMinutes} min')
                  : null,
            ),
        ],
      ),
    );
  }
}
