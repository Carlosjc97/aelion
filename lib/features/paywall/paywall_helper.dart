import 'package:flutter/material.dart';

import 'package:edaptia/features/paywall/paywall_modal.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/entitlements_service.dart';

class PaywallHelper {
  /// Show paywall if user tries to access locked content.
  /// Returns true if user started trial or already has premium.
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
      await _showFallbackPaywallDialog(
        navigator.context,
        trigger: trigger,
        onModalClosed: onModalClosed,
      );
      return false;
    }
    if (!navigator.mounted) return false;

    if (entitlements.isPremium) {
      return true;
    }

    await AnalyticsService().trackPaywallViewed(trigger);
    if (!navigator.mounted) return false;

    var dismissedFromModal = false;
    Future<void> handleDismiss() async {
      if (dismissedFromModal) return;
      dismissedFromModal = true;
      await AnalyticsService().trackPaywallDismissed(trigger);
      onModalClosed?.call();
    }

    final result = await showDialog<bool>(
      context: navigator.context,
      barrierDismissible: false,
      builder: (context) => PaywallModal(
        trigger: trigger,
        onTrialStarted: onTrialStarted,
        onDismissed: handleDismiss,
      ),
    );

    if (result == true) {
      return true;
    }

    await handleDismiss();
    return false;
  }

  static Future<void> _showFallbackPaywallDialog(
    BuildContext context, {
    required String trigger,
    VoidCallback? onModalClosed,
  }) async {
    final locale = Localizations.localeOf(context);
    final isSpanish = locale.languageCode == 'es';
    final title = isSpanish ? 'Contenido premium' : 'Premium content';
    final message = isSpanish
        ? 'No pudimos verificar tus beneficios premium. Intenta nuevamente cuando tengas conexion.'
        : 'We could not verify your premium benefits. Try again when you are back online.';
    final buttonLabel = isSpanish ? 'Entendido' : 'Got it';

    await AnalyticsService().track(
      'paywall_fallback_shown',
      properties: <String, Object?>{
        'trigger': trigger,
        'locale': locale.languageCode,
      },
    );

    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
    onModalClosed?.call();
  }
}
