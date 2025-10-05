import 'dart:async';
import 'package:flutter/material.dart';

import 'package:aelion/services/course_api_service.dart';
import 'package:aelion/widgets/skeleton.dart';

class ModuleOutlineView extends StatefulWidget {
  static const routeName = '/module';
  final String? topic;

  const ModuleOutlineView({super.key, this.topic});

  @override
  State<ModuleOutlineView> createState() => _ModuleOutlineViewState();
}

class _ModuleOutlineViewState extends State<ModuleOutlineView> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _outlineResponse; // Contains source and outline
  late String _courseId;

  @override
  void initState() {
    super.initState();
    _courseId = (widget.topic?.trim().isNotEmpty ?? false)
        ? widget.topic!.trim()
        : 'Default Topic';
    _loadOutline();
  }

  Future<void> _loadOutline({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      setState(() => _isLoading = true);
    }
    setState(() => _error = null);

    try {
      final response = await CourseApiService.generateOutline(topic: _courseId);
      if (!mounted) return;
      setState(() {
        _outlineResponse = response;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading content: ${e.toString()}';
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
    final outlineList = _outlineResponse?['outline'] as List?;
    if (outlineList == null || outlineList.isEmpty) {
      return _ErrorState(
          errorMessage: 'No content available for this topic.',
          onRetry: _loadOutline);
    }
    return _OutlineContent(response: _outlineResponse!);
  }
}

// --- UI Widgets ---

class _OutlineContent extends StatelessWidget {
  final Map<String, dynamic> response;
  const _OutlineContent({required this.response});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> outline = response['outline'] ?? [];
    final String source = response['source'] ?? 'unknown';

    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        if (source == 'cache') const _FallbackBanner(),
        ...outline.map((item) {
          final section = Map<String, dynamic>.from(item);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.article_outlined, size: 28),
              title: Text(section['title'] ?? 'Untitled Section'),
              subtitle: Text(section['description'] ?? 'No description.'),
              trailing: Text('${section['duration_minutes'] ?? '?'} min'),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
          );
        }),
      ],
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Showing cached content. Tap Regenerate for the latest version.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineSkeleton extends StatelessWidget {
  const _OutlineSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: const ListTile(
            leading: Skeleton(height: 28, width: 28, cornerRadius: 14),
            title: Skeleton(height: 16, width: 200),
            subtitle: Skeleton(height: 14, width: double.infinity),
            trailing: Skeleton(height: 16, width: 40),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorState({required this.errorMessage, required this.onRetry});

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
