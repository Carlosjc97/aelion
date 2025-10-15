import 'dart:async';

import 'package:flutter/material.dart';

import 'package:aelion/services/course_api_service.dart';
import 'package:aelion/widgets/skeleton.dart';

class ModuleOutlineArgs {
  const ModuleOutlineArgs({
    required this.topic,
    this.level,
    this.language,
    this.goal,
  });

  final String topic;
  final String? level;
  final String? language;
  final String? goal;
}

class ModuleOutlineView extends StatefulWidget {
  static const routeName = '/module';

  const ModuleOutlineView({
    super.key,
    this.topic,
    this.level,
    this.language,
    this.goal,
  });

  final String? topic;
  final String? level;
  final String? language;
  final String? goal;

  @override
  State<ModuleOutlineView> createState() => _ModuleOutlineViewState();
}

class _ModuleOutlineViewState extends State<ModuleOutlineView> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _outlineResponse;
  late String _courseId;
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _courseId = (widget.topic?.trim().isNotEmpty ?? false)
        ? widget.topic!.trim()
        : 'Default Topic';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialLoad) {
      _didInitialLoad = true;
      unawaited(_loadOutline());
    }
  }

  Future<void> _loadOutline({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      setState(() => _isLoading = true);
    }
    setState(() => _error = null);

    try {
      final localeLanguage = Localizations.localeOf(context).languageCode;
      final preferredLanguage = (widget.language?.trim().isNotEmpty ?? false)
          ? widget.language!.trim()
          : localeLanguage;

      final response = await CourseApiService.generateOutline(
        topic: _courseId,
        goal: widget.goal,
        level: widget.level,
        language: preferredLanguage,
      );

      if (!mounted) return;
      setState(() {
        _outlineResponse = response;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading content: ${error.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.topic ?? 'Outline';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: _isLoading || _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _loadOutline(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate'),
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const _OutlineSkeleton();
    }
    if (_error != null) {
      return _ErrorState(errorMessage: _error!, onRetry: _loadOutline);
    }
    final response = _outlineResponse;
    if (response == null) {
      return _ErrorState(
        errorMessage: 'No outline available for this topic.',
        onRetry: _loadOutline,
      );
    }

    final modules = _parseModules(response['modules']);
    if (modules.isEmpty) {
      return _ErrorState(
        errorMessage: 'No content available for this topic.',
        onRetry: _loadOutline,
      );
    }

    return _OutlineContent(response: response, modules: modules);
  }

  List<Map<String, dynamic>> _parseModules(dynamic raw) {
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((module) => Map<String, dynamic>.from(module))
        .toList(growable: false);
  }
}

class _OutlineContent extends StatelessWidget {
  const _OutlineContent({
    required this.response,
    required this.modules,
  });

  final Map<String, dynamic> response;
  final List<Map<String, dynamic>> modules;

  @override
  Widget build(BuildContext context) {
    final topic = response['topic']?.toString() ?? 'Course outline';
    final goal = response['goal']?.toString();
    final level = response['level']?.toString();
    final language = response['language']?.toString();
    final estimated = response['estimated_hours'];
    final estimatedLabel =
        estimated is num ? '${estimated.round()} hours' : null;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _OutlineHeader(
          topic: topic,
          goal: goal,
          level: level,
          estimated: estimatedLabel,
          language: language,
        ),
        ...modules.map(
          (module) => _ModuleCard(
            module: module,
            courseLanguage: language,
          ),
        ),
      ],
    );
  }
}

class _OutlineHeader extends StatelessWidget {
  const _OutlineHeader({
    required this.topic,
    this.goal,
    this.level,
    this.estimated,
    this.language,
  });

  final String topic;
  final String? goal;
  final String? level;
  final String? estimated;
  final String? language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <Widget>[
      if (level != null && level!.isNotEmpty)
        _OutlineMetaItem(
          icon: Icons.school_outlined,
          label: 'Level: ${level!}',
        ),
      if (estimated != null && estimated!.isNotEmpty)
        _OutlineMetaItem(
          icon: Icons.schedule_outlined,
          label: estimated!,
        ),
      if (language != null && language!.isNotEmpty)
        _OutlineMetaItem(
          icon: Icons.translate,
          label: language!,
        ),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topic, style: theme.textTheme.headlineSmall),
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
    required this.module,
    this.courseLanguage,
  });

  final Map<String, dynamic> module;
  final String? courseLanguage;

  @override
  Widget build(BuildContext context) {
    final title = module['title']?.toString() ?? 'Module';
    final locked = module['locked'] == true;
    final lessons = _parseLessons(module['lessons']);
    final languageLabel = courseLanguage ?? '';

    final leadingIcon =
        locked ? Icons.lock_outline : Icons.check_circle_outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: !locked,
        leading: Icon(leadingIcon),
        title: Text(title),
        subtitle: Text('${lessons.length} lessons'),
        children: lessons.map((lesson) {
          final lessonTitle = lesson['title']?.toString() ?? 'Lesson';
          final lessonLanguage =
              lesson['language']?.toString() ?? languageLabel;
          return ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(lessonTitle),
            subtitle: lessonLanguage.isEmpty
                ? null
                : Text('Language: $lessonLanguage'),
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
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
