import 'package:flutter/material.dart';

import 'package:aelion/l10n/app_localizations.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key, this.routeName, this.reason});

  final String? routeName;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final message = l10n?.notFoundRoute ?? 'Route not found';
    final displayRoute = routeName ?? 'unknown';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                displayRoute,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (reason != null) ...[
                const SizedBox(height: 8),
                Text(
                  reason!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false),
                child: Text(l10n?.authRetry ?? 'Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
