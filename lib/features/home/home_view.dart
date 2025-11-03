import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:aelion/core/app_colors.dart';
import 'package:aelion/features/modules/module_outline_view.dart';
import 'package:aelion/features/settings/settings_view.dart';
import 'package:aelion/features/support/help_support_screen.dart';
import 'package:aelion/features/quiz/quiz_screen.dart';
import 'package:aelion/l10n/app_localizations.dart';
import 'package:aelion/services/analytics/analytics_service.dart';
import 'package:aelion/services/course_api_service.dart';
import 'package:aelion/services/google_sign_in_helper.dart';
import 'package:aelion/services/local_outline_storage.dart';
import 'package:aelion/services/recent_outlines_storage.dart';
import 'package:aelion/services/recent_search_storage.dart';
import 'package:aelion/services/topic_band_cache.dart';
import 'package:aelion/widgets/skeleton.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  State<HomeView> createState() => _HomeViewState();
}

enum _HomeMenuAction { settings, help }

class _HomeViewState extends State<HomeView> {
  static const _maxRecommendationItems = 35;
  static const _maxRecentOutlineItems = 5;

  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  bool _loadingRecommendations = false;
  bool _recommendationsError = false;
  bool _initializedRecommendations = false;

  List<_RecentOutlineItem> _recentOutlines = const [];
  List<TrendingTopic> _trendingTopics = const [];
  List<RecentSearchEntry> _recentSearches = const [];

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedRecommendations) {
      _initializedRecommendations = true;
      unawaited(_loadRecommendations());
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
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecents() async {
    final metadata = await RecentOutlinesStorage.instance.readAll();
    if (metadata.isEmpty) {
      if (!mounted) return;
      setState(() {
        _recentOutlines = const [];
      });
      return;
    }

    final sorted =
        metadata.where((entry) => entry.id.trim().isNotEmpty).toList()
          ..sort(
            (a, b) => b.savedAt.compareTo(a.savedAt),
          );

    final seen = <String>{};
    final limited = <RecentOutlineMetadata>[];
    for (final entry in sorted) {
      final key = entry.id.trim();
      if (key.isEmpty || !seen.add(key)) {
        continue;
      }
      limited.add(entry);
      if (limited.length >= _maxRecentOutlineItems) {
        break;
      }
    }

    final items = await Future.wait(
      limited.map(
        (entry) async {
          final cached = await LocalOutlineStorage.instance.findById(entry.id);
          return _RecentOutlineItem(metadata: entry, cached: cached);
        },
      ),
    );

    if (!mounted) return;
    setState(() {
      _recentOutlines = items;
    });
  }

  Future<void> _loadRecommendations() async {
    if (!mounted) return;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final languageCode = Localizations.localeOf(context).languageCode;

    setState(() {
      _loadingRecommendations = true;
      _recommendationsError = false;
    });

    try {
      final results = await Future.wait<dynamic>([
        CourseApiService.fetchTrending(language: languageCode),
        RecentSearchStorage.instance.readForUser(userId),
      ]);

      if (!mounted) return;
      final trending =
          (results.first as List<TrendingTopic>).toList(growable: false)
            ..sort((a, b) {
              final countComparison = b.count.compareTo(a.count);
              if (countComparison != 0) {
                return countComparison;
              }
              return a.topic.toLowerCase().compareTo(b.topic.toLowerCase());
            });

      final recent = (results.last as List<RecentSearchEntry>)
          .toList(growable: false)
        ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

      setState(() {
        _trendingTopics =
            trending.take(_maxRecommendationItems).toList(growable: false);
        _recentSearches =
            recent.take(_maxRecommendationItems).toList(growable: false);
        _recommendationsError = false;
      });
    } catch (error) {
      debugPrint('[HomeView] Failed to load recommendations: $error');
      if (!mounted) return;
      setState(() {
        _recommendationsError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingRecommendations = false;
        });
      }
    }
  }

  List<_RecommendationItem> _buildRecommendationItems() {
    const replacements = <String, String>{
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'ã': 'a',
      'å': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ñ': 'n',
      'ç': 'c',
    };

    final allowedAlphaNumeric = RegExp(r'[a-z0-9]');

    String normalizeKey({String? label, String? topicKey}) {
      final preferred = topicKey?.trim();
      if (preferred != null && preferred.isNotEmpty) {
        return preferred.toLowerCase();
      }

      final raw = label?.toLowerCase().trim() ?? '';
      if (raw.isEmpty) {
        return '';
      }

      final buffer = StringBuffer();
      for (final rune in raw.runes) {
        final char = String.fromCharCode(rune);
        final replacement = replacements[char];
        if (replacement != null) {
          buffer.write(replacement);
          continue;
        }
        if (allowedAlphaNumeric.hasMatch(char)) {
          buffer.write(char);
        } else if (char.trim().isEmpty) {
          buffer.write(' ');
        }
      }

      final normalized =
          buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
      return normalized;
    }

    final seen = <String>{};
    final items = <_RecommendationItem>[];

    for (final topic in _trendingTopics) {
      final label = topic.topic.trim();
      if (label.isEmpty) continue;
      final key = normalizeKey(label: label, topicKey: topic.topicKey);
      if (key.isEmpty || !seen.add(key)) {
        continue;
      }
      items.add(_RecommendationItem(
        label: label,
        source: _RecommendationSource.trending,
      ));
      if (items.length >= _maxRecommendationItems) {
        return items;
      }
    }

    for (final recent in _recentSearches) {
      if (items.length >= _maxRecommendationItems) {
        break;
      }
      final label = recent.topic.trim();
      if (label.isEmpty) continue;
      final key = normalizeKey(label: label);
      if (key.isEmpty || !seen.add(key)) {
        continue;
      }
      items.add(_RecommendationItem(
        label: label,
        source: _RecommendationSource.recent,
      ));
    }

    if (items.length <= _maxRecommendationItems) {
      return items;
    }

    return items.take(_maxRecommendationItems).toList(growable: false);
  }

  Future<void> _startFlow({String? presetTopic}) async {
    final l10n = AppLocalizations.of(context)!;
    final rawTopic = (presetTopic ?? _controller.text).trim();

    if (rawTopic.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeSnackMissingTopic)),
      );
      return;
    }

    if (_loading) return;

    setState(() => _loading = true);
    try {
      final auth = FirebaseAuth.instance;
      final userId = auth.currentUser?.uid ?? 'anonymous';
      final languageCode = Localizations.localeOf(context).languageCode;
      final analytics = AnalyticsService();

      unawaited(
        CourseApiService.trackSearch(topic: rawTopic, language: languageCode)
            .catchError((error) {
          debugPrint('[HomeView] trackSearch failed: $error');
          return null;
        }),
      );

      await RecentSearchStorage.instance.add(
        userId: userId,
        topic: rawTopic,
        language: languageCode,
      );

      final cachedBand = await TopicBandCache.instance.getBand(
        userId: userId,
        topic: rawTopic,
        language: languageCode,
      );

      if (!mounted) return;

      if (cachedBand == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.calibratingPlan)),
        );

        await Navigator.of(context).pushNamed(
          QuizScreen.routeName,
          arguments: QuizScreenArgs(
            topic: rawTopic,
            language: languageCode,
          ),
        );
      } else {
        final outlineResponse = await CourseApiService.generateOutline(
          topic: rawTopic,
          language: languageCode,
          band: cachedBand,
        );

        final now = DateTime.now();
        await LocalOutlineStorage.instance.save(
          topic: rawTopic,
          payload: outlineResponse,
        );

        final responseBand = outlineResponse['band']?.toString();
        final responseDepth = outlineResponse['depth']?.toString() ??
            CourseApiService.depthForBand(cachedBand);
        final responseLanguage =
            outlineResponse['language']?.toString() ?? languageCode;
        final outlineList = _extractOutlineList(outlineResponse['outline']);

        final metadata = RecentOutlineMetadata(
          id: RecentOutlineMetadata.buildId(
            topic: rawTopic,
            language: responseLanguage,
            band: responseBand,
            depth: responseBand == null || responseBand.isEmpty
                ? responseDepth
                : null,
          ),
          topic: rawTopic,
          language: responseLanguage,
          band: responseBand?.isNotEmpty == true ? responseBand : null,
          depth: responseDepth,
          savedAt: now,
        );
        await RecentOutlinesStorage.instance.upsert(metadata);

        if (!mounted) return;
        await Navigator.of(context).pushNamed(
          ModuleOutlineView.routeName,
          arguments: ModuleOutlineArgs(
            topic: rawTopic,
            language: responseLanguage,
            depth: responseDepth,
            preferredBand: responseBand,
            initialOutline: outlineList,
            initialResponse: outlineResponse,
            initialSource: outlineResponse['source']?.toString(),
            initialSavedAt: now,
          ),
        );
      }

      await _loadRecents();
      await _loadRecommendations();
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

  void _handleRecommendationTap(String topic) {
    final normalized = topic.trim();
    if (normalized.isEmpty) {
      return;
    }
    setState(() {
      _controller.text = normalized;
    });
    unawaited(_startFlow(presetTopic: normalized));
  }

  Future<void> _handleSignOut() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await FirebaseAuth.instance.signOut();
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
    final user = FirebaseAuth.instance.currentUser;

    final greeting = _buildGreeting(l10n, user);
    final motivation = l10n.homeMotivation;

    final recommendations = _buildRecommendationItems();

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
                  controller: _controller,
                  generateLabel: l10n.homeGenerate,
                  loading: _loading,
                  onSubmit: () => _startFlow(),
                  hintText: l10n.homeInputHint,
                  title: l10n.homePromptTitle,
                ),
                const SizedBox(height: 24),
                _RecommendationsSection(
                  l10n: l10n,
                  loading: _loadingRecommendations,
                  error: _recommendationsError,
                  recommendations: recommendations,
                  onRetry: _loadRecommendations,
                  onSelected: _handleRecommendationTap,
                ),
                const SizedBox(height: 24),
                if (_recentOutlines.isNotEmpty) ...[
                  Text(l10n.homeRecentTitle,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  for (final entry in _recentOutlines.asMap().entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _RecentOutlineCard(
                        key: ValueKey('recent-${entry.key}'),
                        item: entry.value,
                        l10n: l10n,
                        onViewPressed: () => _openCachedOutline(entry.value),
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

  Future<void> _openCachedOutline(_RecentOutlineItem item) async {
    if (!mounted) return;
    final meta = item.metadata;
    final cached =
        item.cached ?? await LocalOutlineStorage.instance.findById(meta.id);
    if (!mounted) return;

    final args = ModuleOutlineArgs(
      topic: meta.topic,
      language: cached?.lang ?? meta.language,
      depth: cached?.depth ?? meta.depth,
      preferredBand: cached?.band ?? meta.band,
      recommendRegenerate: false,
      initialOutline: cached?.outline,
      initialResponse: cached?.rawResponse,
      initialSource: cached?.source,
      initialSavedAt: cached?.savedAt,
    );

    await Navigator.of(context).pushNamed(
      ModuleOutlineView.routeName,
      arguments: args,
    );
    await _loadRecents();
  }

  static List<Map<String, dynamic>> _extractOutlineList(dynamic raw) {
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((module) => Map<String, dynamic>.from(module))
        .toList(growable: false);
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
  final List<_RecommendationItem> recommendations;
  final Future<void> Function() onRetry;
  final void Function(String topic) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.homeRecommendationsTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (loading)
          const _RecommendationSkeleton()
        else if (error)
          _RecommendationError(l10n: l10n, onRetry: onRetry)
        else if (recommendations.isEmpty)
          Text(l10n.homeRecommendationsEmpty)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recommendations
                .map(
                  (item) => ActionChip(
                    label: Text(item.label),
                    avatar: Icon(
                      item.source == _RecommendationSource.trending
                          ? Icons.trending_up_outlined
                          : Icons.history_outlined,
                      size: 16,
                    ),
                    onPressed: () => onSelected(item.label),
                  ),
                )
                .toList(growable: false),
          ),
      ],
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

class _RecommendationItem {
  const _RecommendationItem({
    required this.label,
    required this.source,
  });

  final String label;
  final _RecommendationSource source;
}

enum _RecommendationSource { trending, recent }

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

class _RecentOutlineCard extends StatelessWidget {
  const _RecentOutlineCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.onViewPressed,
  });

  final _RecentOutlineItem item;
  final AppLocalizations l10n;
  final VoidCallback onViewPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = item.metadata;
    final cached = item.cached;

    final chips = <Widget>[];
    final bandEnum = CourseApiService.tryPlacementBandFromString(metadata.band);
    if (bandEnum != null) {
      chips.add(_InfoChip(
        icon: Icons.school_outlined,
        label: _bandLabel(l10n, bandEnum),
      ));
    } else if (metadata.depth?.isNotEmpty == true) {
      chips.add(_InfoChip(
        icon: Icons.layers_outlined,
        label: _depthLabel(l10n, metadata.depth!),
      ));
    }
    chips.add(
      _InfoChip(
        icon: Icons.language_outlined,
        label: metadata.language.toUpperCase(),
      ),
    );

    final outline = cached?.outline ?? const <Map<String, dynamic>>[];
    final previewModules = outline.length > 2 ? outline.sublist(0, 2) : outline;
    final remaining = outline.length - previewModules.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: chips,
              ),
            ],
            if (previewModules.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...previewModules.asMap().entries.map((entry) {
                final index = entry.key;
                final module = entry.value;
                final rawTitle = module['title']?.toString();
                final resolvedTitle = (rawTitle?.isNotEmpty ?? false)
                    ? rawTitle!
                    : l10n.outlineModuleFallback(index + 1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '- $resolvedTitle',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }),
              if (remaining > 0)
                Text(
                  l10n.homeRecentMoreCount(remaining),
                  style: theme.textTheme.bodySmall,
                ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onViewPressed,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l10n.homeRecentView),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _RecentOutlineItem {
  const _RecentOutlineItem({
    required this.metadata,
    this.cached,
  });

  final RecentOutlineMetadata metadata;
  final StoredOutline? cached;
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

String _depthLabel(AppLocalizations l10n, String depth) {
  switch (depth.trim().toLowerCase()) {
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

class _RecentEmptyCard extends StatelessWidget {
  const _RecentEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
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
