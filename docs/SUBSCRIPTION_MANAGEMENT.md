# Subscription Management Guide

## Google Play Console Setup
- Create the `edaptia_premium_monthly` subscription under **Monetize > Products > Subscriptions**.
- Enable auto-renewal, set the base price to USD 9.99, and add equivalent prices for your launch markets.
- Upload a localized title/description that matches the paywall copy and mentions that billing is handled by Google Play.
- Add license testers (Google Play Console > Setup > License testing) so the QA team can purchase without charges.
- Confirm that the Play Billing library is set to the latest version and that the Play integrity settings allow server-side verification.

## Sandbox & QA Testing
- Use tester accounts from the **License testing** list. Testers must be on a release-signed build uploaded to the internal test track.
- To force sandbox mode, toggle `SubscriptionProducts.isTestMode = true` and install the debug build.
- Validate the following flows: paywall purchase, pending purchase, cancellation, upgrade/downgrade, and restore on a second device.
- Use the static product IDs (`android.test.purchased`, etc.) only for local smoke tests; always run a full regression with the real subscription in the internal track.

## Handling Refunds & Support
- Refunds are issued exclusively through Google Play Console (Transactions > Order management). Refunds automatically revoke premium status after the Play hook propagates.
- Support requests should capture the Google Play order ID. Compare it to `googlePlayPurchaseToken` stored in Firestore for diagnostics.
- Never process manual refunds or prorations in Firestore; always go through Google Play to keep compliance.

## Monitoring & Metrics
- Track paywall funnel events in Firebase Analytics / PostHog: `paywall_viewed`, `purchase_completed`, and `purchase_failed`.
- Monitor Crashlytics for any logs tagged `GooglePlayBillingService`. Peaks usually indicate configuration or network issues.
- Use BigQuery exports from Google Play Billing for revenue analytics, and reconcile with the `entitlements` collection for unlocked users.
- Set up alerts for verification failures (HTTP 4xx/5xx) to catch token or service account issues early.

## Troubleshooting
- **Purchase pending**: usually caused by the `android.test.purchased` account or parental approvals. Inform the user and the listener will resume automatically.
- **INVALID_TOKEN** errors: ensure the client sends the latest `serverVerificationData` and that the backend service account matches the Play Console project.
- **Users still limited after purchase**: check `entitlements.subscriptionExpiresAt` in Firestore; if missing, rerun `restorePurchases()` to resync.
- **Restore fails**: ensure the tester/device uses the same Google account that originally purchased the subscription, and confirm Play Store app is updated.
- **Rate limiting despite premium**: run the migration script `functions/src/migrate-trials.ts` to normalize data for legacy trial users and confirm the `subscriptionExpiresAt` timestamp is in the future.
