import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/components/edaptia_card.dart';
import 'package:edaptia/core/design_system/typography.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/analytics/guest_id.dart';
import 'package:edaptia/services/google_sign_in_helper.dart';
import 'package:edaptia/widgets/a11y_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const routeName = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  Future<void> _onSignInPressed() async {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters(<String, String>{'prompt': 'select_account'});
        final credential = await FirebaseAuth.instance.signInWithPopup(provider);
        await _handleLoginSuccess(credential);
        return;
      }

      final GoogleSignIn googleSignIn = await GoogleSignInHelper.instance();
      GoogleSignInAccount account;
      try {
        account = await googleSignIn.authenticate();
      } on GoogleSignInException catch (error) {
        if (error.code == GoogleSignInExceptionCode.canceled) {
          _showSnackBar(
              l10n?.loginCancelled ?? 'Sign-in cancelled by the user');
          return;
        }
        rethrow;
      }

      GoogleSignInClientAuthorization authorization;
      try {
        authorization = await account.authorizationClient
            .authorizeScopes(const <String>['email', 'profile']);
      } on GoogleSignInException catch (error) {
        if (error.code == GoogleSignInExceptionCode.canceled) {
          _showSnackBar(
              l10n?.loginCancelled ?? 'Sign-in cancelled by the user');
          return;
        }
        rethrow;
      }

      final GoogleSignInAuthentication auth = account.authentication;
      if (auth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message: 'Google Sign-In did not return an ID token.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: authorization.accessToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      await _handleLoginSuccess(userCredential);
    } on GoogleSignInException catch (error) {
      debugPrint(
          '[SignInScreen] GoogleSignInException: ${error.code} ${error.description}');
      _showSnackBar(
          l10n?.loginError ?? 'We could not complete the sign-in. Try again.');
    } on FirebaseAuthException catch (error) {
      debugPrint('[SignInScreen] FirebaseAuthException: ${error.code}');
      _showSnackBar(_describeAuthError(error, l10n));
    } catch (error, stackTrace) {
      debugPrint('[SignInScreen] Unexpected sign-in error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showSnackBar(
          l10n?.loginError ?? 'We could not complete the sign-in. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLoginSuccess(UserCredential credential) async {
    final uid = credential.user?.uid;
    if (uid == null) return;
    try {
      final guestId = await GuestIdStore().getOrCreate();
      await AnalyticsService().aliasAndIdentify(uid, guestId);
    } catch (error, stackTrace) {
      debugPrint('[SignInScreen] Analytics identify failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _describeAuthError(
      FirebaseAuthException error, AppLocalizations? l10n) {
    switch (error.code) {
      case 'network-request-failed':
      case 'user-disabled':
      case 'account-exists-with-different-credential':
      case 'missing-id-token':
        return l10n?.loginError ??
            'We could not complete the sign-in. Try again.';
      default:
        return l10n?.loginError ??
            'We could not complete the sign-in. Try again.';
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headlineStyle =
        EdaptiaTypography.largeTitle.copyWith(color: EdaptiaColors.textPrimary);
    final subtitleStyle = EdaptiaTypography.title2
        .copyWith(color: EdaptiaColors.textSecondary);
    final statusStyle = EdaptiaTypography.subheadline
        .copyWith(color: EdaptiaColors.textTertiary);
    final buttonLabel = l10n?.loginButton ?? 'Sign in with Google';

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 640;
            final column = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n?.appTitle ?? 'Edaptia',
                  style: headlineStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.loginTitle ?? 'Learn faster with AI',
                  style: subtitleStyle,
                ),
                const SizedBox(height: 32),
                A11yButton(
                  onPressed: _isLoading ? null : _onSignInPressed,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: buttonLabel,
                  semanticsLabel: buttonLabel,
                  onTapHint: buttonLabel,
                ),
                const SizedBox(height: 16),
                Text(
                  _isLoading
                      ? (l10n?.loginLoading ?? 'Connecting...')
                      : (l10n?.loginSubtitle ??
                          'Your learning path in a few taps'),
                  style: statusStyle,
                ),
              ],
            );

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: isWide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: column),
                            const SizedBox(width: 40),
                            const Expanded(
                              child: _HighlightsCard(),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            column,
                            const SizedBox(height: 32),
                            const _HighlightsCard(),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HighlightsCard extends StatelessWidget {
  const _HighlightsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleStyle =
        EdaptiaTypography.title3.copyWith(color: Colors.white);
    final bulletStyle =
        EdaptiaTypography.body.copyWith(color: Colors.white70);

    final highlights = <String>[
      l10n?.loginHighlightPersonalized ?? 'Personalized outlines in minutes',
      l10n?.loginHighlightStreak ?? 'Daily streaks keep you motivated',
      l10n?.loginHighlightSync ??
          'Sync across devices with your Google account',
    ];

    return EdaptiaCard(
      gradient: EdaptiaColors.hookGradient,
      borderRadius: 24,
      elevation: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.loginTitle ?? 'Learn faster with AI',
            style: titleStyle,
          ),
          const SizedBox(height: 12),
          for (final item in highlights) ...[
            Text(item, style: bulletStyle),
            if (item != highlights.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}


