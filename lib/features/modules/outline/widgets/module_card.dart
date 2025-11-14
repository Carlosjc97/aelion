part of 'package:edaptia/features/modules/outline/module_outline_view.dart';

class ModuleCard extends StatefulWidget {
  const ModuleCard({
    super.key,
    required this.courseId,
    required this.courseTopic,
    required this.moduleIndex,
    required this.module,
    required this.l10n,
    this.courseLanguage,
    this.onExpansionChanged,
    this.isGenerating = false,
  });

  final String courseId;
  final String courseTopic; // Actual topic entered by user (e.g., "inglés", "SQL para Marketing")
  final int moduleIndex;
  final Map<String, dynamic> module;
  final AppLocalizations l10n;
  final String? courseLanguage;
  final ValueChanged<bool>? onExpansionChanged;
  final bool isGenerating;

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  late Future<_ModuleAccessState> _accessFuture;

  @override
  void initState() {
    super.initState();
    _accessFuture = _resolveAccess();
  }

  Future<_ModuleAccessState> _resolveAccess() async {
    final entitlements = EntitlementsService();
    await entitlements.ensureLoaded();

    final moduleNumber = widget.moduleIndex + 1;
    if (moduleNumber == 1) {
      return const _ModuleAccessState(
        unlocked: true,
        hasPremium: true,
        gatePassed: true,
      );
    }

    final hasPremium = entitlements.isPremium;
    if (!hasPremium) {
      return const _ModuleAccessState(
        unlocked: false,
        hasPremium: false,
        gatePassed: false,
      );
    }

    final gatePassed = await _hasPassedGate(widget.moduleIndex);
    return _ModuleAccessState(
      unlocked: gatePassed,
      hasPremium: hasPremium,
      gatePassed: gatePassed,
    );
  }

  Future<bool> _hasPassedGate(int gateModuleNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    if (gateModuleNumber <= 0) return true;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moduleGates')
        .doc('module-$gateModuleNumber')
        .get();

    final data = snapshot.data();
    return data != null && data['passed'] == true;
  }

  Future<void> _refreshAccess() async {
    setState(() {
      _accessFuture = _resolveAccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ModuleAccessState>(
      future: _accessFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Skeleton(height: 24, width: double.infinity),
            ),
          );
        }

        final access = snapshot.data!;
        final module = widget.module;
        final l10n = widget.l10n;

        final rawTitle = module['title']?.toString().trim();
        final title = (rawTitle?.isNotEmpty ?? false)
            ? rawTitle!
            : l10n.outlineModuleFallback(widget.moduleIndex + 1);

        final lessons = _parseLessons(module['lessons']);
        final languageLabel = widget.courseLanguage ?? '';
        final progress =
            _buildProgressStatus(module['progress'], lessons.length);
        final locked = !access.unlocked;
        final isGenerating = widget.isGenerating;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            key: Key('module-${widget.moduleIndex}-tile'),
            initiallyExpanded: !locked,
            leading:
                Icon(locked ? Icons.lock_outline : Icons.check_circle_outline),
            title: Text(title),
            subtitle: Text(l10n.outlineLessonCount(lessons.length)),
            onExpansionChanged: (expanded) {
              if (locked && expanded) {
                unawaited(_handleLockedTap(access));
                return;
              }
              widget.onExpansionChanged?.call(expanded);
            },
            children: [
              if (progress != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ModuleProgressIndicator(status: progress),
                ),
              if (locked)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _LockedModuleNotice(
                    moduleIndex: widget.moduleIndex,
                    access: access,
                    onUnlocked: _refreshAccess,
                    courseId: widget.courseId,
                    courseTopic: widget.courseTopic,
                    language: languageLabel.isEmpty ? 'en' : languageLabel,
                    l10n: l10n,
                  ),
                )
              else if (isGenerating)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ...lessons.asMap().entries.map(
                  (entry) {
                    final lessonIndex = entry.key;
                    final lesson = entry.value;
                    return LessonCard(
                      key: Key(
                          'lesson-card-${widget.moduleIndex}-$lessonIndex'),
                      moduleIndex: widget.moduleIndex,
                      lessonIndex: lessonIndex,
                      lesson: lesson,
                      courseId: widget.courseId,
                      moduleTitle: title,
                      l10n: l10n,
                      courseLanguage: languageLabel,
                      isLocked: locked,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLockedTap(_ModuleAccessState access) async {
    if (!access.hasPremium) {
      final granted = await PaywallHelper.checkAndShowPaywall(
        context,
        trigger: 'module_locked',
        onTrialStarted: _refreshAccess,
      );
      if (granted) {
        await _refreshAccess();
      }
    } else if (!access.gatePassed) {
      await _launchGateQuiz();
    }
  }

  Future<void> _launchGateQuiz() async {
    final previousModuleNumber = widget.moduleIndex;
    if (previousModuleNumber <= 0) return;

    final result = await Navigator.of(context).pushNamed(
      ModuleGateQuizScreen.routeName,
      arguments: ModuleGateQuizArgs(
        moduleNumber: previousModuleNumber,
        topic: widget.courseTopic, // Use actual topic, not courseId
        language: widget.courseLanguage ?? 'en',
      ),
    );

    if (result == true) {
      await _refreshAccess();
    }
  }

  List<Map<String, dynamic>> _parseLessons(dynamic raw) {
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((lesson) => Map<String, dynamic>.from(lesson))
        .toList(growable: false);
  }

  ModuleProgressStatus? _buildProgressStatus(dynamic raw, int totalLessons) {
    if (raw == null) return null;
    if (raw is num) {
      final fraction = raw.toDouble().clamp(0, 1);
      return ModuleProgressStatus(
        completed: (fraction * totalLessons).round().clamp(0, totalLessons),
        total: totalLessons,
      );
    }
    if (raw is Map<String, dynamic>) {
      final completed = (raw['completed'] as num?)?.toInt();
      final total = (raw['total'] as num?)?.toInt() ?? totalLessons;
      if (completed == null || total <= 0) {
        return null;
      }
      return ModuleProgressStatus(
        completed: completed.clamp(0, total),
        total: total,
      );
    }
    return null;
  }
}

class _ModuleAccessState {
  const _ModuleAccessState({
    required this.unlocked,
    required this.hasPremium,
    required this.gatePassed,
  });

  final bool unlocked;
  final bool hasPremium;
  final bool gatePassed;
}

class _LockedModuleNotice extends StatelessWidget {
  const _LockedModuleNotice({
    required this.moduleIndex,
    required this.access,
    required this.onUnlocked,
    required this.courseId,
    required this.courseTopic,
    required this.language,
    required this.l10n,
  });

  final int moduleIndex;
  final _ModuleAccessState access;
  final VoidCallback onUnlocked;
  final String courseId;
  final String courseTopic; // Actual user topic
  final String language;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextModule = moduleIndex + 1;
    final gateModule = moduleIndex;

    if (!access.hasPremium) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.modulePremiumContent,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.modulePremiumUnlock(nextModule),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final granted = await PaywallHelper.checkAndShowPaywall(
                context,
                trigger: 'module_locked',
              );
              if (granted) {
                onUnlocked();
              }
            },
            child: Text(l10n.modulePremiumButton),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.moduleGatePending,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.moduleGateRequired(gateModule),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
          onPressed: () async {
            final result = await Navigator.of(context).pushNamed(
              ModuleGateQuizScreen.routeName,
              arguments: ModuleGateQuizArgs(
                moduleNumber: gateModule,
                topic: courseTopic, // Use actual topic
                language: language,
              ),
            );
            if (result == true) {
              onUnlocked();
            }
          },
          icon: const Icon(Icons.quiz_outlined),
          label: Text(l10n.moduleGateTake),
        ),
      ],
    );
  }
}
