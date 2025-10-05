import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper to ensure the singleton [GoogleSignIn] instance is
/// initialised exactly once before use.
class GoogleSignInHelper {
  GoogleSignInHelper._();

  static Future<void>? _initialisation;

  /// Returns the shared [GoogleSignIn] instance, guaranteeing that
  /// [GoogleSignIn.initialize] has completed.
  static Future<GoogleSignIn> instance({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {
    _initialisation ??= GoogleSignIn.instance.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
      nonce: nonce,
      hostedDomain: hostedDomain,
    );

    await _initialisation;
    return GoogleSignIn.instance;
  }
}
