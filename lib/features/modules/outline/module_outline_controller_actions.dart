part of 'package:edaptia/features/modules/outline/module_outline_view.dart';

extension ModuleOutlineControllerActions on ModuleOutlineController {
  Widget buildModuleOutlineView(BuildContext context) {
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
      return const OutlineSkeleton();
    }

    if (_error != null) {
      final message = '${l10n.outlineErrorGeneric}\n${_error!}';

      return OutlineErrorView(
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
      return OutlineErrorView(
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
      return OutlineErrorView(
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

    return OutlineContent(
      l10n: l10n,
      courseId: _courseId,
      response: response,
      modules: modules,
      source: source,
      savedAt: savedAt,
      band: _activeBand,
      depth: _activeDepth,
      onModuleExpansion: _handleModuleExpansion,
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
