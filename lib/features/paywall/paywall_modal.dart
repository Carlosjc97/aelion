import 'package:flutter/material.dart';

import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/entitlements_service.dart';
import 'package:edaptia/services/google_play_billing_service.dart';

class PaywallModal extends StatefulWidget {
  final String trigger;
  final VoidCallback? onTrialStarted;
  final VoidCallback? onDismissed;

  const PaywallModal({
    super.key,
    required this.trigger,
    this.onTrialStarted,
    this.onDismissed,
  });

  @override
  State<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends State<PaywallModal> {
  static const double _priceUsd = 9.99;
  final EntitlementsService _entitlements = EntitlementsService();

  bool _isProcessingPurchase = false;
  bool _isRestoringPurchases = false;

  String get _title {
    switch (widget.trigger) {
      case 'post_calibration':
        return 'Desbloquea tu plan completo';
      case 'module_locked':
        return 'Accede a todos los modulos';
      case 'course_limit_reached':
        return 'Cursos ilimitados con Premium';
      default:
        return 'Suscripcion Premium';
    }
  }

  String get _subtitle {
    switch (widget.trigger) {
      case 'post_calibration':
        return 'Obtiene los 6 modulos personalizados y seguimiento en tiempo real.';
      case 'module_locked':
        return 'Activa los modulos 2 al 6 y avanza sin bloqueos.';
      case 'course_limit_reached':
        return 'Tu biblioteca no tiene limites con Premium por solo \$9.99 USD/mes.';
      default:
        return 'Todo el contenido avanzado, sin limites diarios de IA.';
    }
  }

  List<String> get _benefits => const <String>[
        'Cursos ilimitados y modulos avanzados',
        'Sin limite diario de IA ni colas',
        'Actualizaciones semanales y retos exclusivos',
        'Soporte prioritario y progreso sincronizado',
      ];

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_outlined, size: 64, color: theme.primaryColor),
            const SizedBox(height: 16),
            Text(
              _title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              style: TextStyle(fontSize: 16, color: theme.textTheme.bodySmall?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Suscripcion mensual auto-renovable por \$${_priceUsd.toStringAsFixed(2)} USD',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            for (final benefit in _benefits) _buildBenefit(benefit),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessingPurchase ? null : _handlePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isProcessingPurchase
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Suscribirse por \$9.99/mes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: (_isProcessingPurchase || _isRestoringPurchases) ? null : _handleRestore,
              child: _isRestoringPurchases
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Restaurar compras'),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                widget.onDismissed?.call();
                navigator.pop(false);
              },
              child: const Text('Tal vez despues'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Los pagos se procesan a traves de Google Play. Cancela cuando quieras en la app de Google Play.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() => _isProcessingPurchase = true);
    try {
      final success = await _entitlements.purchasePremium();
      if (!mounted) return;
      final navigator = Navigator.of(context);
      if (success) {
        await AnalyticsService().trackPurchaseCompleted(
          plan: 'edaptia_premium_monthly',
          priceUsd: _priceUsd,
        );
        widget.onTrialStarted?.call();
        navigator.pop(true);
      } else {
        _showMessage('Compra cancelada.');
      }
    } on PurchaseException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (error) {
      _showMessage('Error al procesar la compra: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessingPurchase = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isRestoringPurchases = true);
    try {
      await _entitlements.restorePurchases();
      if (!mounted) return;
      _showMessage('Compras restauradas correctamente.');
    } on PurchaseException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (error) {
      _showMessage('Error al restaurar compras: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isRestoringPurchases = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
