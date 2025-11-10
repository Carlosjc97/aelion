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
    VoidCallback? onModalClosed,
  }) async {
    final navigator = Navigator.of(context);
    final entitlements = EntitlementsService();
    try {
      await entitlements.ensureLoaded();
    } catch (error, stackTrace) {
      debugPrint('[PaywallHelper] Failed to load entitlements: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!navigator.mounted) return false;
      await showDialog<void>(
        context: navigator.context,
        builder: (context) => AlertDialog(
          title: const Text('Modo sin conexión'),
          content: const Text(
            'No pudimos verificar tus beneficios premium. Intenta nuevamente cuando tengas conexión.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return false;
    }
    if (!navigator.mounted) return false;

    // If already premium, allow access
    if (entitlements.isPremium) {
      return true;
    }

    // Track paywall viewed
    await AnalyticsService().trackPaywallViewed(trigger);
    if (!navigator.mounted) return false;

    // Show paywall
    final result = await showDialog<bool>(
      context: navigator.context,
      barrierDismissible: false,
      builder: (context) => PaywallModal(
        trigger: trigger,
        onTrialStarted: onTrialStarted,
        onDismissed: () async {
          await AnalyticsService().trackPaywallDismissed(trigger);
          onModalClosed?.call();
        },
      ),
    );

    if (result == true) {
      return true;
    }

    await AnalyticsService().trackPaywallDismissed(trigger);
    onModalClosed?.call();
    return false;
  }
}
