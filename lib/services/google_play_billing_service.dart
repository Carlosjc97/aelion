import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:edaptia/constants/subscription_products.dart';
import 'package:edaptia/services/api_config.dart';
import 'package:edaptia/services/course/course_api_client.dart';

typedef VerificationRequestFn = Future<VerificationResponse> Function(
  Map<String, dynamic> body,
  Set<int> additionalSuccessCodes,
);

class GooglePlayBillingService {
  GooglePlayBillingService._internal({
    InAppPurchase? inAppPurchase,
    VerificationRequestFn? verificationRequest,
    FirebaseAuth? firebaseAuth,
  })  : _iap = inAppPurchase ?? InAppPurchase.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance {
    _verificationRequest = verificationRequest ?? _callVerificationEndpoint;
    unawaited(_init());
  }

  GooglePlayBillingService._test({
    required InAppPurchase inAppPurchase,
    required VerificationRequestFn verificationRequest,
    FirebaseAuth? firebaseAuth,
  })  : _iap = inAppPurchase,
        _auth = firebaseAuth ?? FirebaseAuth.instance {
    _verificationRequest = verificationRequest;
    unawaited(_init());
  }

  static final GooglePlayBillingService _instance =
      GooglePlayBillingService._internal();
  factory GooglePlayBillingService() => _instance;

  @visibleForTesting
  factory GooglePlayBillingService.test({
    required InAppPurchase inAppPurchase,
    required VerificationRequestFn verificationRequest,
    FirebaseAuth? firebaseAuth,
  }) {
    return GooglePlayBillingService._test(
      inAppPurchase: inAppPurchase,
      verificationRequest: verificationRequest,
      firebaseAuth: firebaseAuth,
    );
  }

  static const String _androidPackageName = 'com.aelion.learning';

  final InAppPurchase _iap;
  final FirebaseAuth _auth;
  late final VerificationRequestFn _verificationRequest;
  final StreamController<bool> _premiumStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  List<ProductDetails> _products = <ProductDetails>[];
  bool _isAvailable = false;
  Future<void>? _initializationFuture;
  Completer<bool>? _activePurchaseCompleter;
  bool _hasActiveSubscription = false;
  DateTime? _lastStatusCheckAt;

  Future<void> _init() {
    _initializationFuture ??= _initialize();
    return _initializationFuture!;
  }

  Future<void> _initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _initializationFuture = null;
      return;
    }

    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        return;
      }

      _purchaseSubscription ??= _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _purchaseSubscription = null,
        onError: (Object error, StackTrace stackTrace) {
          _logError(error, stackTrace, reason: 'purchase_stream');
          _completePurchaseWithError(const PurchaseException(
            'billing',
            'Error inesperado con Google Play Billing.',
          ));
        },
      );

      await _queryProductDetails();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, reason: 'initialize_billing');
    } finally {
      _initializationFuture = null;
    }
  }

  Future<void> _queryProductDetails() async {
    final ids = SubscriptionProducts.productIds;
    if (ids.isEmpty) {
      return;
    }

    final response = await _iap.queryProductDetails(ids.toSet());
    if (response.error != null) {
      _logError(
        response.error!,
        StackTrace.current,
        reason: 'query_product_details',
        data: {'message': response.error!.message},
      );
    }

    if (response.productDetails.isNotEmpty) {
      _products = response.productDetails;
    }
  }

  Future<ProductDetails?> _loadPremiumProduct() async {
    if (_products.isEmpty) {
      await _queryProductDetails();
    }

    final ids = SubscriptionProducts.productIds;
    for (final id in ids) {
      try {
        return _products.firstWhere((product) => product.id == id);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<bool> purchasePremiumSubscription() async {
    await _init();
    if (!_isAvailable) {
      throw const PurchaseException(
        'billing_unavailable',
        'Google Play Billing no est? disponible en este dispositivo.',
      );
    }

    final product = await _loadPremiumProduct();
    if (product == null) {
      throw const PurchaseException(
        'product_unavailable',
        'No encontramos la suscripci?n premium. Intenta m?s tarde.',
      );
    }

    if (_activePurchaseCompleter != null &&
        !(_activePurchaseCompleter!.isCompleted)) {
      throw const PurchaseException(
        'purchase_in_progress',
        'Ya hay una compra en progreso.',
      );
    }

    final completer = Completer<bool>();
    _activePurchaseCompleter = completer;

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (error, stackTrace) {
      _logError(error, stackTrace, reason: 'start_purchase');
      _completePurchaseWithError(PurchaseException(
        'purchase_failed',
        error.toString(),
      ));
      rethrow;
    }

    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        _activePurchaseCompleter = null;
        throw const PurchaseException(
          'timeout',
          'No recibimos confirmaci?n de Google Play. Intenta nuevamente.',
        );
      },
    );
  }

  Future<void> restorePurchases() async {
    await _init();
    if (!_isAvailable) {
      throw const PurchaseException(
        'billing_unavailable',
        'Google Play Billing no est? disponible en este dispositivo.',
      );
    }

    try {
      await _iap.restorePurchases();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, reason: 'restore_purchases');
      throw const PurchaseException(
        'restore_failed',
        'No pudimos restaurar tus compras en este momento.',
      );
    }
  }

  Future<bool> hasActiveSubscription({bool forceRefresh = false}) async {
    await _init();
    if (!_isAvailable) {
      return _hasActiveSubscription;
    }

    if (!forceRefresh && _lastStatusCheckAt != null) {
      final elapsed = DateTime.now().difference(_lastStatusCheckAt!);
      if (elapsed < const Duration(hours: 1)) {
        return _hasActiveSubscription;
      }
    }

    try {
      await _iap.restorePurchases();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, reason: 'has_active_subscription');
    } finally {
      _lastStatusCheckAt = DateTime.now();
    }

    return _hasActiveSubscription;
  }

  Future<bool> verifyPurchaseWithBackend(PurchaseDetails purchase) async {
    await _requireUser();
    final token = _extractPurchaseToken(
      purchase.verificationData.serverVerificationData,
    );
    if (token.isEmpty) {
      throw const PurchaseException(
        'invalid_token',
        'No pudimos leer los datos de la compra.',
      );
    }

    try {
      final verification = await _verificationRequest(
        <String, dynamic>{
          'purchaseToken': token,
          'productId': purchase.productID,
          'packageName': _androidPackageName,
        },
        const {403},
      );

      final payload = verification.payload;
      final statusCode = verification.statusCode;
      if (statusCode == 200 && payload['verified'] == true) {
        _emitPremiumStatus(true);
        return true;
      }

      if (statusCode == 403) {
        throw const PurchaseException(
          'expired',
          'Tu suscripci?n de Google Play est? vencida.',
        );
      }

      final errorCode = payload['error']?.toString();
      if (errorCode == 'PURCHASE_PENDING') {
        throw const PurchaseException(
          'pending',
          'Tu compra est? pendiente de confirmaci?n por Google Play.',
        );
      }

      throw PurchaseException(
        'verification_failed',
        errorCode ?? 'No pudimos verificar tu compra.',
      );
    } on PurchaseException {
      rethrow;
    } catch (error, stackTrace) {
      _logError(error, stackTrace, reason: 'verify_purchase');
      throw const PurchaseException(
        'network',
        'No pudimos contactar a Google Play. Intenta de nuevo.',
      );
    }
  }

  Future<User> _requireUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const PurchaseException(
        'auth',
        'Debes iniciar sesi?n para usar Google Play Billing.',
      );
    }
    await user.getIdToken();
    return user;
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    if (purchases.isEmpty) return;

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        final error = purchase.error;
        final code = error == null ? '' : error.code.toLowerCase();
        if (code.contains('cancel')) {
          _completePurchase(false);
        } else {
          _logError(error ?? 'unknown', StackTrace.current,
              reason: 'purchase_error');
          _completePurchaseWithError(PurchaseException(
            error?.code ?? 'purchase_error',
            error?.message ?? 'Error al procesar la compra.',
          ));
        }
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        try {
          final verified = await verifyPurchaseWithBackend(purchase);
          if (verified) {
            _completePurchase(true);
          }
        } on PurchaseException catch (error) {
          if (purchase.status == PurchaseStatus.restored &&
              (error.code == 'expired' || error.code == 'invalid_token')) {
            _emitPremiumStatus(false);
          } else {
            _completePurchaseWithError(error);
          }
        }
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<VerificationResponse> _callVerificationEndpoint(
    Map<String, dynamic> body,
    Set<int> additionalSuccessCodes,
  ) async {
    final response = await CourseApiClient.postJson(
      uri: Uri.parse(ApiConfig.verifyGooglePlayPurchase()),
      body: body,
      timeout: const Duration(seconds: 30),
      additionalSuccessCodes: additionalSuccessCodes,
    );

    return VerificationResponse(
      statusCode: response.statusCode,
      payload: _decodeBody(response.body),
    );
  }

  void _emitPremiumStatus(bool isPremium) {
    _hasActiveSubscription = isPremium;
    _lastStatusCheckAt = DateTime.now();
    _premiumStatusController.add(isPremium);
  }

  void _completePurchase(bool success) {
    if (_activePurchaseCompleter != null &&
        !(_activePurchaseCompleter!.isCompleted)) {
      _activePurchaseCompleter!.complete(success);
    }
    _activePurchaseCompleter = null;
  }

  void _completePurchaseWithError(PurchaseException exception) {
    if (_activePurchaseCompleter != null &&
        !(_activePurchaseCompleter!.isCompleted)) {
      _activePurchaseCompleter!.completeError(exception);
    }
    _activePurchaseCompleter = null;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _extractPurchaseToken(String raw) {
    if (raw.isEmpty) return raw;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final token = decoded['purchaseToken'] ?? decoded['token'];
        if (token is String) {
          return token;
        }
      }
    } catch (_) {
      // raw string already token
    }
    return raw;
  }

  void _logError(Object error, StackTrace stackTrace,
      {String? reason, Map<String, Object?>? data}) {
    debugPrint(
        '[GooglePlayBillingService] ${reason ?? 'error'}: $error');
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        information: (data?.entries
                .map<Object>((entry) => '${entry.key}: ${entry.value}')
                .toList()) ?? const <Object>[],
      );
    } catch (_) {
      // ignore
    }
  }
}

class VerificationResponse {
  const VerificationResponse({
    required this.statusCode,
    required this.payload,
  });

  final int statusCode;
  final Map<String, dynamic> payload;
}

class PurchaseException implements Exception {
  const PurchaseException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'PurchaseException(code: $code, message: $message)';
}
