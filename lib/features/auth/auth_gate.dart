import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:aelion/l10n/app_localizations.dart';
import 'package:aelion/features/auth/sign_in_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _AuthStatusScaffold(
            title: l10n?.appTitle ?? 'Aelion',
            message: l10n?.authCheckingSession ?? 'Checking your session...',
            child: const CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _AuthStatusScaffold(
            title: l10n?.appTitle ?? 'Aelion',
            message: l10n?.authError ?? 'We could not verify your session',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${snapshot.error}'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: FirebaseAuth.instance.signOut,
                  child: Text(l10n?.authRetry ?? 'Try again'),
                ),
              ],
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const SignInScreen();
        }

        return child;
      },
    );
  }
}

class _AuthStatusScaffold extends StatelessWidget {
  const _AuthStatusScaffold({
    required this.title,
    required this.message,
    required this.child,
  });

  final String title;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
