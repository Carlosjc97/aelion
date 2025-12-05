import 'dart:async';

import 'package:edaptia/constants/subscription_products.dart';
import 'package:edaptia/services/google_play_billing_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';

class _MockInAppPurchase extends Mock implements InAppPurchase {}

class _MockVerificationHandler extends Mock {
  Future<VerificationResponse> call(
    Map<String, dynamic> body,
    Set<int> additionalSuccessCodes,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockInAppPurchase mockIap;
  late _MockVerificationHandler verificationHandler;
  late StreamController<List<PurchaseDetails>> purchaseController;
  late GooglePlayBillingService service;
  late ProductDetails testProduct;
  late MockFirebaseAuth mockFirebaseAuth;

  setUpAll(() {
    testProduct = _buildProduct();
    registerFallbackValue(PurchaseParam(productDetails: testProduct));
    registerFallbackValue(_buildPurchase());
  });

  setUp(() async {
    purchaseController = StreamController<List<PurchaseDetails>>.broadcast();
    mockIap = _MockInAppPurchase();
    verificationHandler = _MockVerificationHandler();
    mockFirebaseAuth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'tester', isAnonymous: true),
    );
    await mockFirebaseAuth.signInAnonymously();

    when(() => mockIap.purchaseStream).thenAnswer((_) => purchaseController.stream);
    when(() => mockIap.isAvailable()).thenAnswer((_) async => true);
    when(() => mockIap.queryProductDetails(any())).thenAnswer((invocation) async {
      final ids = invocation.positionalArguments.first as Set<String>;
      final products = ids
          .map((id) => _buildProduct(id: id))
          .toList(growable: false);
      return ProductDetailsResponse(
        productDetails: products,
        notFoundIDs: const <String>[],
      );
    });
    when(() => mockIap.buyNonConsumable(purchaseParam: any(named: 'purchaseParam')))
        .thenAnswer((_) async => true);
    when(() => mockIap.completePurchase(any())).thenAnswer((_) async {});
    when(() => mockIap.restorePurchases()).thenAnswer((_) async {});
    when(() => verificationHandler.call(any(), any())).thenAnswer((_) async =>
        VerificationResponse(statusCode: 200, payload: <String, dynamic>{'verified': true}));

    service = GooglePlayBillingService.test(
      inAppPurchase: mockIap,
      verificationRequest: verificationHandler.call,
      firebaseAuth: mockFirebaseAuth,
    );

    await service.hasActiveSubscription(forceRefresh: true);
  });

  tearDown(() async {
    await purchaseController.close();
  });

  test('completes purchase when verification succeeds', () async {
    final statusEvents = <bool>[];
    final sub = service.premiumStatusStream.listen(statusEvents.add);

    final purchaseFuture = service.purchasePremiumSubscription();
    final purchase = _buildPurchase();
    purchase.pendingCompletePurchase = true;
    await _emitPurchase(purchaseController, purchase);

    final result = await purchaseFuture;

    expect(result, isTrue);
    verify(() => mockIap.buyNonConsumable(purchaseParam: any(named: 'purchaseParam'))).called(1);
    verify(() => verificationHandler.call(any(), any())).called(1);
    verify(() => mockIap.completePurchase(purchase)).called(1);
    await Future<void>.delayed(Duration.zero);
    expect(statusEvents.contains(true), isTrue);
    await sub.cancel();
  });

  test('returns false when purchase is cancelled by the user', () async {
    final purchaseFuture = service.purchasePremiumSubscription();
    final purchase = _buildPurchase(status: PurchaseStatus.error);
    purchase.error = IAPError(
      source: 'test',
      code: 'purchase_cancelled',
      message: 'cancelled',
    );
    await _emitPurchase(purchaseController, purchase);

    final result = await purchaseFuture;

    expect(result, isFalse);
    verifyNever(() => verificationHandler.call(any(), any()));
  });

  test('restorePurchases triggers verification for restored items', () async {
    final restored = _buildPurchase(status: PurchaseStatus.restored);
    restored.pendingCompletePurchase = true;
    var restoreCalls = 0;
    when(() => mockIap.restorePurchases()).thenAnswer((_) async {
      restoreCalls++;
      await _emitPurchase(purchaseController, restored);
    });

    await service.restorePurchases();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(restoreCalls, 1);
    verify(() => verificationHandler.call(any(), any())).called(greaterThanOrEqualTo(1));
  });

  test('hasActiveSubscription skips restore call when cached recently', () async {
    var restoreCalls = 0;
    when(() => mockIap.restorePurchases()).thenAnswer((_) async {
      restoreCalls++;
    });

    final first = await service.hasActiveSubscription(forceRefresh: true);
    final second = await service.hasActiveSubscription();

    expect(first, isFalse);
    expect(second, isFalse);
    expect(restoreCalls, 1);
  });

  test('verifyPurchaseWithBackend throws when backend marks purchase pending', () async {
    when(() => verificationHandler.call(any(), any())).thenAnswer((_) async =>
        VerificationResponse(statusCode: 202, payload: <String, dynamic>{'error': 'PURCHASE_PENDING'}));

    final purchase = _buildPurchase();

    expect(
      () => service.verifyPurchaseWithBackend(purchase),
      throwsA(isA<PurchaseException>().having((e) => e.code, 'code', 'pending')),
    );
  });
}

Future<void> _emitPurchase(
  StreamController<List<PurchaseDetails>> controller,
  PurchaseDetails purchase,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
  controller.add(<PurchaseDetails>[purchase]);
}

ProductDetails _buildProduct({String id = SubscriptionProducts.premiumMonthly}) {
  return ProductDetails(
    id: id,
    title: 'Premium',
    description: 'Full access',
    price: '\$9.99',
    rawPrice: 9.99,
    currencyCode: 'USD',
  );
}

PurchaseDetails _buildPurchase({
  PurchaseStatus status = PurchaseStatus.purchased,
}) {
  return PurchaseDetails(
    purchaseID: 'order-123',
    productID: SubscriptionProducts.premiumMonthly,
    verificationData: PurchaseVerificationData(
      localVerificationData: '{}',
      serverVerificationData: 'token',
      source: 'test',
    ),
    transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
    status: status,
  );
}
