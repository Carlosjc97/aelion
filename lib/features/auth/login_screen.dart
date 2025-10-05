import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learning_ia/l10n/app_localizations.dart';
import 'package:learning_ia/services/google_sign_in_helper.dart';

const _googleServerClientId =
    '110324120650-b4ud5rpj6ckbh7ja0repab951mi45h8m.apps.googleusercontent.com';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    if (_loading) return;
    final l10n = AppLocalizations.of(context);

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()..addScope('email');
        await FirebaseAuth.instance.signInWithPopup(provider);
        return;
      }

      final googleSignIn = await GoogleSignInHelper.instance(
        serverClientId: _googleServerClientId,
      );
      final account = await googleSignIn.authenticate(
        scopeHint: const ['email'],
      );
      final authentication = account.authentication;
      final idToken = authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google ID token not returned',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        setState(() => _errorMessage =
            (l10n?.loginCancelled ?? 'Sign-in cancelled by the user'));
        return;
      }
      debugPrint('[LoginScreen] GoogleSignInException: ${e.code}');
      setState(() => _errorMessage = (l10n?.loginError ??
          'We could not complete the sign-in. Try again.'));
    } on FirebaseAuthException catch (e) {
      debugPrint('[LoginScreen] FirebaseAuthException: ${e.code}');
      setState(() => _errorMessage = (l10n?.loginError ??
          'We could not complete the sign-in. Try again.'));
    } catch (e, stack) {
      debugPrint('[LoginScreen] signInWithGoogle error: $e');
      debugPrint(stack.toString());
      setState(() => _errorMessage = (l10n?.loginError ??
          'We could not complete the sign-in. Try again.'));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2459F6);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: primary.withAlpha((0.08 * 255).round()),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Aelion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    (l10n?.loginTitle ?? 'Aprende m�s r�pido con IA'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _signInWithGoogle,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(_loading
                          ? (l10n?.loginLoading ?? 'Connecting...')
                          : (l10n?.loginButton ?? 'Sign in with Google')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
