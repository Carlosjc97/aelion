import 'package:flutter/material.dart';
import 'package:edaptia/features/paywall/paywall_modal.dart';
import 'package:edaptia/services/entitlements_service.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';

class PaywallHelper {
  /// Show paywall if user tries to access locked content
  /// Returns true if user started trial or already has premium
  static Future<bool> checkAndShowPaywall(
    BuildContext context, {
    required String trigger,
    VoidCallback? onTrialStarted,
  }) async {
    final entitlements = EntitlementsService();

    // If already premium, allow access
    if (entitlements.isPremium) {
      return true;
    }

    // Track paywall viewed
    await AnalyticsService().trackPaywallViewed(trigger);

    // Show paywall
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaywallModal(
        trigger: trigger,
        onTrialStarted: onTrialStarted,
      ),
    );

    return result == true;
  }
}
