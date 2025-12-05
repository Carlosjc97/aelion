# Google Play Billing Implementation - Complete Guide

## Context
Edaptia is an AI-powered adaptive learning platform built with Flutter + Firebase. Currently, we have a custom trial/entitlements system that violates Google Play Store policies. We MUST migrate to Google Play Billing before public launch.

## Current State Analysis

### Existing Payment System (TO BE REPLACED)
**Backend:** `functions/src/generative-endpoints.ts`
- `startTrial()` endpoint (line ~250): Creates 14-day trial in Firestore
- `getUserEntitlements()` (line 103): Reads `isPremium` and `trialEndsAt` from Firestore
- `ensurePremiumAccess()` (line 119): Validates premium access for modules 2+

**Frontend:** `lib/services/entitlements_service.dart`
- `startTrial()`: Calls backend to activate trial
- `isPremium()`: Checks Firestore for premium status
- Used in: `PaywallModal`, `AdaptiveJourneyScreen`, rate limiting

**Firestore Schema:**
```
users/{userId}/
  entitlements/
    isPremium: boolean
    trialEndsAt: Timestamp
```

### Premium Features (What Users Pay For)
1. **Unlimited Courses:** Free users limited to 3 courses (already implemented)
2. **Modules 2-6:** First module free, rest require premium
3. **No Daily AI Limits:** Premium users bypass DAILY_AI_CAP (30 ops/day)

### Revenue Model
- **Price:** $9.99/month USD (mentioned in paywall)
- **Free Tier:** 1 course (module 1 only) + 30 AI operations/day
- **Premium:** Unlimited everything

---

## TASK: Implement Google Play Billing

### ✅ Step 1: Define Subscription Product in Code

**File to create:** `lib/constants/subscription_products.dart`

```dart
class SubscriptionProducts {
  // Product ID - MUST match Google Play Console setup
  static const String premiumMonthly = 'edaptia_premium_monthly';

  // For testing
  static const List<String> testProductIds = [
    'android.test.purchased', // Always succeeds
  ];

  static bool isTestMode = false; // Toggle for development

  static List<String> get productIds =>
    isTestMode ? testProductIds : [premiumMonthly];
}
```

**Instructions:**
- Use exactly this product ID: `edaptia_premium_monthly`
- The user will create this in Google Play Console later
- Keep test mode toggle for sandbox testing

---

### ✅ Step 2: Create Google Play Billing Service

**File to create:** `lib/services/google_play_billing_service.dart`

**Requirements:**
1. **Initialize InAppPurchase:**
   - Check `InAppPurchase.instance.isAvailable()`
   - Listen to purchase stream in constructor
   - Query product details on init

2. **Purchase Flow:**
   - Method: `Future<bool> purchasePremiumSubscription()`
   - Call `InAppPurchase.instance.buyNonConsumable()` for monthly sub
   - Handle purchase states: pending, purchased, error, restored
   - Return true on success

3. **Verify Purchases:**
   - Method: `Future<bool> verifyPurchaseWithBackend(PurchaseDetails purchase)`
   - Send `purchase.verificationData.serverVerificationData` to new backend endpoint
   - Backend validates with Google's API
   - On success, backend sets `isPremium: true` in Firestore

4. **Restore Purchases:**
   - Method: `Future<void> restorePurchases()`
   - Call `InAppPurchase.instance.restorePurchases()`
   - Verify each restored purchase with backend
   - Update local entitlements cache

5. **Check Active Subscription:**
   - Method: `Future<bool> hasActiveSubscription()`
   - Query past purchases
   - Verify at least one is active and verified
   - Cache result for 1 hour to avoid excessive checks

6. **Stream for UI Updates:**
   - Expose `Stream<bool> get premiumStatusStream`
   - Emits true/false when subscription status changes
   - Use for reactive UI updates

**Error Handling:**
- Wrap all InAppPurchase calls in try-catch
- Log errors to Firebase Crashlytics
- Return meaningful error messages to UI
- Handle: network errors, canceled purchases, duplicate purchases

**Dependencies Already Added:**
- `in_app_purchase: ^3.2.2` (already in pubspec.yaml)

**Code Structure Template:**
```dart
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edaptia/constants/subscription_products.dart';
import 'package:edaptia/services/api_config.dart';
import 'package:http/http.dart' as http;

class GooglePlayBillingService {
  static final GooglePlayBillingService _instance = GooglePlayBillingService._internal();
  factory GooglePlayBillingService() => _instance;
  GooglePlayBillingService._internal() {
    _init();
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // TODO: Implement methods as specified above
}
```

---

### ✅ Step 3: Create Backend Verification Endpoint

**File to modify:** `functions/src/generative-endpoints.ts`

**New Endpoint:** `verifyGooglePlayPurchase`

**Location:** Add after `startTrial` endpoint (around line 300)

**Functionality:**
1. **Input Validation:**
   ```typescript
   {
     purchaseToken: string,
     productId: string,
     packageName: string
   }
   ```

2. **Verify with Google Play Developer API:**
   - Use `@googleapis/androidpublisher` package (add to package.json)
   - Service account credentials from Firebase project
   - Endpoint: `androidpublisher.purchases.subscriptions.get()`
   - Validate: `expiryTimeMillis > Date.now()` and `paymentState === 1`

3. **Update Firestore on Success:**
   ```typescript
   await firestore.collection("users").doc(userId).set({
     entitlements: {
       isPremium: true,
       googlePlayPurchaseToken: purchaseToken,
       googlePlayProductId: productId,
       subscriptionExpiresAt: new Date(subscription.expiryTimeMillis),
       verifiedAt: FieldValue.serverTimestamp()
     }
   }, { merge: true });
   ```

4. **Return Response:**
   ```typescript
   res.status(200).json({
     verified: true,
     expiresAt: subscription.expiryTimeMillis,
     autoRenewing: subscription.autoRenewing
   });
   ```

**Error Handling:**
- Invalid token: 400
- Expired subscription: 403
- Google API error: 502
- Log all verification attempts to Firestore for audit

**Security:**
- Require authentication (existing `authenticateRequest`)
- Rate limit: 20 requests per 5 minutes per user
- Validate userId matches Firebase Auth

**Dependencies to Add:**
```json
{
  "@googleapis/androidpublisher": "^15.0.0"
}
```

**Code Template:**
```typescript
export const verifyGooglePlayPurchase = onRequest(
  { cors: true, timeoutSeconds: 30, memory: "256MiB" },
  async (req, res) => {
    // 1. Authenticate
    const authContext = await authenticateRequest(req, authClient);

    // 2. Extract purchase data
    const { purchaseToken, productId, packageName } = req.body;

    // 3. Verify with Google
    const androidpublisher = google.androidpublisher('v3');
    const subscription = await androidpublisher.purchases.subscriptions.get({
      packageName,
      subscriptionId: productId,
      token: purchaseToken
    });

    // 4. Update Firestore
    // 5. Return response
  }
);
```

---

### ✅ Step 4: Update EntitlementsService

**File to modify:** `lib/services/entitlements_service.dart`

**Changes Required:**

1. **Inject GooglePlayBillingService:**
   ```dart
   final GooglePlayBillingService _billingService = GooglePlayBillingService();
   ```

2. **Update `isPremium()` method:**
   ```dart
   Future<bool> isPremium() async {
     // First check Firestore (fast)
     final firestoreStatus = await _checkFirestorePremium();
     if (firestoreStatus) return true;

     // Fallback: check Google Play (slower but authoritative)
     return await _billingService.hasActiveSubscription();
   }
   ```

3. **Deprecate `startTrial()` method:**
   - Add `@Deprecated('Use GooglePlayBillingService.purchasePremiumSubscription()')`
   - Keep for backward compatibility during migration
   - Log warning when called

4. **Add Purchase Method:**
   ```dart
   Future<bool> purchasePremium() async {
     return await _billingService.purchasePremiumSubscription();
   }
   ```

5. **Add Restore Method:**
   ```dart
   Future<void> restorePurchases() async {
     await _billingService.restorePurchases();
     notifyListeners(); // If using ChangeNotifier
   }
   ```

**Backward Compatibility:**
- Keep reading `isPremium` from Firestore
- Google Play becomes the source of truth
- Firestore acts as cache

---

### ✅ Step 5: Update PaywallModal UI

**File to modify:** `lib/features/paywall/paywall_modal.dart`

**Changes:**

1. **Replace Trial Button with Purchase Button:**

   **Old code (around line 80):**
   ```dart
   ElevatedButton(
     onPressed: () async {
       await EntitlementsService().startTrial();
       widget.onTrialStarted?.call();
     },
     child: Text('Iniciar prueba gratuita (14 días)')
   )
   ```

   **New code:**
   ```dart
   ElevatedButton(
     onPressed: _isProcessing ? null : () async {
       setState(() => _isProcessing = true);
       try {
         final success = await EntitlementsService().purchasePremium();
         if (success && mounted) {
           widget.onTrialStarted?.call(); // Rename to onPurchaseCompleted
           Navigator.pop(context);
         }
       } catch (error) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: ${error.toString()}')),
           );
         }
       } finally {
         if (mounted) setState(() => _isProcessing = false);
       }
     },
     child: _isProcessing
       ? CircularProgressIndicator()
       : Text('Suscribirse por \$9.99/mes')
   )
   ```

2. **Add "Restore Purchases" Button:**
   ```dart
   TextButton(
     onPressed: () async {
       await EntitlementsService().restorePurchases();
       // Show success message
     },
     child: Text('Restaurar compras'),
   )
   ```

3. **Update Copy:**
   - Remove all "prueba gratuita" mentions
   - Change to "Suscripción mensual"
   - Add "Cancela cuando quieras" disclaimer
   - Include "Los pagos se procesan a través de Google Play"

4. **Add Loading State:**
   - Show spinner while purchase is processing
   - Prevent double-taps
   - Handle user cancellation gracefully

**Specific triggers to update:**
- `course_limit_reached`: "Desbloquea cursos ilimitados por $9.99/mes"
- `module_locked`: "Accede a todos los módulos con Premium"
- `post_calibration`: Keep existing but change CTA

---

### ✅ Step 6: Update Rate Limiting Logic

**File to modify:** `functions/src/generative-endpoints.ts`

**Function to update:** `enforceRateLimit()` (around line 200)

**Change:**
```typescript
async function enforceRateLimit(params: {
  key: string;
  limit: number;
  windowSeconds: number;
  userId?: string;
  userDailyCap?: number;
}): Promise<void> {
  // ... existing rate limit logic ...

  // NEW: Check premium status
  if (params.userId && params.userDailyCap) {
    const entitlements = await getUserEntitlements(params.userId);

    // Premium users bypass daily cap
    if (entitlements.isPremium) {
      return; // No daily limit for premium
    }

    // Check if subscription is expired
    if (entitlements.subscriptionExpiresAt) {
      const expiresAt = entitlements.subscriptionExpiresAt instanceof Timestamp
        ? entitlements.subscriptionExpiresAt.toMillis()
        : new Date(entitlements.subscriptionExpiresAt).getTime();

      if (Date.now() > expiresAt) {
        // Subscription expired - enforce limits
        // Consider: trigger background job to update isPremium to false
      }
    }

    // ... rest of daily cap logic ...
  }
}
```

**Update `getUserEntitlements()` interface:**
```typescript
interface UserEntitlements {
  isPremium: boolean;
  trialEndsAt?: Timestamp | Date;
  subscriptionExpiresAt?: Timestamp | Date; // NEW
  googlePlayPurchaseToken?: string; // NEW
}
```

---

### ✅ Step 7: Add Settings UI for Subscription Management

**File to modify:** `lib/features/settings/settings_view.dart`

**New Section to Add (after line 100):**

```dart
ListTile(
  leading: Icon(Icons.card_membership),
  title: Text('Suscripción Premium'),
  subtitle: FutureBuilder<bool>(
    future: EntitlementsService().isPremium(),
    builder: (context, snapshot) {
      if (snapshot.data == true) {
        return Text('Activa - Administrar en Google Play');
      }
      return Text('No activa - Toca para suscribirte');
    },
  ),
  trailing: Icon(Icons.chevron_right),
  onTap: () async {
    final isPremium = await EntitlementsService().isPremium();
    if (!isPremium && mounted) {
      // Show paywall
      showDialog(
        context: context,
        builder: (_) => PaywallModal(trigger: 'settings'),
      );
    } else {
      // Open Google Play subscriptions
      final url = 'https://play.google.com/store/account/subscriptions';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  },
),
```

**Add "Restore Purchases" Option:**
```dart
ListTile(
  leading: Icon(Icons.restore),
  title: Text('Restaurar compras'),
  subtitle: Text('Si ya compraste Premium en otro dispositivo'),
  onTap: () async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      await EntitlementsService().restorePurchases();
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compras restauradas exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al restaurar: ${e.toString()}')),
        );
      }
    }
  },
),
```

---

### ✅ Step 8: Testing Strategy

**Create test file:** `test/services/google_play_billing_service_test.dart`

**Test Cases:**
1. ✅ Service initializes correctly
2. ✅ Handles purchase cancellation gracefully
3. ✅ Verifies successful purchase with backend
4. ✅ Restores previous purchases
5. ✅ Handles network errors during verification
6. ✅ Caches subscription status correctly
7. ✅ Updates Firestore after successful purchase

**Manual Testing Checklist:**
- [ ] Purchase flow works in sandbox mode
- [ ] Paywall shows correct pricing
- [ ] "Restore Purchases" works on second device
- [ ] Premium features unlock after purchase
- [ ] Free users see paywall at correct triggers
- [ ] Subscription expiration handled correctly
- [ ] Canceled subscription reverts to free tier

**Use Test Products:**
```dart
// In subscription_products.dart
static const List<String> testProductIds = [
  'android.test.purchased',  // Always succeeds
  'android.test.canceled',   // Always canceled
  'android.test.item_unavailable', // Product not available
];
```

---

### ✅ Step 9: Migration Path

**For Existing Trial Users:**

**Backend migration script:** `functions/src/migrate-trials.ts`

```typescript
// One-time script to grant existing trial users a free month
async function migrateExistingTrialUsers() {
  const usersSnapshot = await firestore.collection('users')
    .where('entitlements.trialEndsAt', '>', new Date())
    .get();

  for (const doc of usersSnapshot.docs) {
    const userId = doc.id;
    const trialEndsAt = doc.data().entitlements.trialEndsAt;

    // Grant them premium until trial would have ended
    await doc.ref.update({
      'entitlements.isPremium': true,
      'entitlements.migrated': true,
      'entitlements.migratedAt': FieldValue.serverTimestamp(),
      'entitlements.subscriptionExpiresAt': trialEndsAt,
      'entitlements.migrationType': 'trial_to_premium_grace'
    });

    console.log(`Migrated user ${userId}`);
  }
}
```

**Run once before launch:**
```bash
cd functions
node -e "require('./lib/migrate-trials').migrateExistingTrialUsers()"
```

---

### ✅ Step 10: Documentation

**Create file:** `docs/SUBSCRIPTION_MANAGEMENT.md`

**Contents:**
1. How to set up products in Google Play Console
2. How to test with sandbox accounts
3. How to handle refunds (Google manages this)
4. How to track subscription metrics
5. Troubleshooting common issues

---

## 🎯 Success Criteria

**Frontend:**
- ✅ Users can purchase subscription from PaywallModal
- ✅ Subscription status syncs across devices
- ✅ "Restore Purchases" works correctly
- ✅ Premium features unlock immediately after purchase
- ✅ Settings shows subscription status

**Backend:**
- ✅ Verifies purchases with Google Play API
- ✅ Updates Firestore with subscription data
- ✅ Rate limiting respects premium status
- ✅ Handles subscription expiration

**Compliance:**
- ✅ No direct payment methods (Stripe, PayPal, etc.)
- ✅ All purchases go through Google Play
- ✅ Follows Google Play Billing Library 5.0+ standards
- ✅ Implements required "Restore Purchases" functionality

---

## 🔧 Implementation Order

1. **Backend first:** Create verification endpoint (Step 3)
2. **Service layer:** Implement billing service (Step 2)
3. **Constants:** Define products (Step 1)
4. **Integration:** Update EntitlementsService (Step 4)
5. **UI:** Update PaywallModal (Step 5)
6. **Rate limits:** Update backend logic (Step 6)
7. **Settings:** Add subscription management (Step 7)
8. **Testing:** Full test coverage (Step 8)
9. **Migration:** Handle existing users (Step 9)

**Total Estimated Time:** 6-8 hours for experienced developer

---

## 📝 Notes for Implementation

- **Do NOT remove** existing `startTrial()` functionality until migration is complete
- **Keep Firestore** as cache for performance - Google Play as source of truth
- **Test thoroughly** with sandbox before production
- **Monitor Crashlytics** for purchase-related errors
- **Track conversion** with Firebase Analytics: `purchase_initiated`, `purchase_completed`, `purchase_failed`

---

## 🚨 Critical Reminders

1. **Product ID must match Google Play Console exactly**
2. **Never store real payment data in Firestore** (only tokens/references)
3. **Always verify purchases server-side** (never trust client)
4. **Handle subscription lifecycle events** (renewal, cancellation, expiration)
5. **Provide clear refund policy** (Google handles refunds, but communicate this)

---

## Files to Create/Modify

**New Files:**
- `lib/constants/subscription_products.dart`
- `lib/services/google_play_billing_service.dart`
- `test/services/google_play_billing_service_test.dart`
- `docs/SUBSCRIPTION_MANAGEMENT.md`
- `functions/src/migrate-trials.ts`

**Modified Files:**
- `functions/src/generative-endpoints.ts` (add verification endpoint)
- `lib/services/entitlements_service.dart` (integrate billing)
- `lib/features/paywall/paywall_modal.dart` (update UI)
- `lib/features/settings/settings_view.dart` (add subscription management)
- `functions/package.json` (add androidpublisher dependency)

---

**END OF SPECIFICATION**

This spec is complete and ready for implementation. Review after completion to ensure all Google Play Store requirements are met.
