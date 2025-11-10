import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edaptia/services/course/models.dart';
import 'package:edaptia/services/course_api_service.dart';

final usageMetricsProvider =
    FutureProvider.autoDispose<UsageMetrics>((ref) async {
  return CourseApiService.fetchOpenAiUsageMetrics();
});

class UsageDashboardPage extends ConsumerWidget {
  const UsageDashboardPage({super.key});

  static const routeName = '/usage-dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(usageMetricsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenAI usage'),
      ),
      body: metricsAsync.when(
        data: (metrics) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(usageMetricsProvider);
            await ref.read(usageMetricsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _UsageSummary(metrics: metrics),
              const SizedBox(height: 16),
              _UsageChart(metrics: metrics),
              const SizedBox(height: 16),
              _UsageEntries(metrics: metrics),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _UsageError(
          message: error.toString(),
          onRetry: () => ref.invalidate(usageMetricsProvider),
        ),
      ),
    );
  }
}

class _UsageSummary extends StatelessWidget {
  const _UsageSummary({required this.metrics});

  final UsageMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Últimos llamados', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${metrics.totalTokens} tokens',
              style: theme.textTheme.headlineMedium,
            ),
            Text(
              '\$${metrics.totalCost.toStringAsFixed(4)} USD',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageChart extends StatelessWidget {
  const _UsageChart({required this.metrics});

  final UsageMetrics metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.byEndpoint.isEmpty) {
      return const SizedBox.shrink();
    }

    final data = metrics.byEndpoint.entries
        .map(
          (entry) => _UsageBarData(
            endpoint: entry.key,
            tokens: entry.value,
          ),
        )
        .toList();

    final groups = data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.tokens.toDouble(),
            color: Theme.of(context).colorScheme.primary,
            width: 18,
          ),
        ],
      );
    }).toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              barGroups: groups,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      final label = data[index].endpoint;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UsageEntries extends StatelessWidget {
  const _UsageEntries({required this.metrics});

  final UsageMetrics metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.entries.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Historial reciente', style: theme.textTheme.titleMedium),
          ),
          const Divider(height: 0),
          for (final entry in metrics.entries.take(20))
            ListTile(
              title: Text(entry.endpoint),
              subtitle: Text(
                entry.timestamp.toLocal().toString(),
                style: theme.textTheme.bodySmall,
              ),
              trailing: Text('${entry.tokens} tks'),
            ),
        ],
      ),
    );
  }
}

class _UsageError extends StatelessWidget {
  const _UsageError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageBarData {
  _UsageBarData({required this.endpoint, required this.tokens});

  final String endpoint;
  final int tokens;
}
