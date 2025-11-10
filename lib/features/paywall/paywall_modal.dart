import 'package:flutter/material.dart';
import 'package:edaptia/services/entitlements_service.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';

class PaywallModal extends StatelessWidget {
  final String trigger; // 'post_calibration', 'module_locked', 'mock_locked'
  final VoidCallback? onTrialStarted;
  final VoidCallback? onDismissed;

  const PaywallModal({
    super.key,
    required this.trigger,
    this.onTrialStarted,
    this.onDismissed,
  });

  String get _title {
    switch (trigger) {
      case 'post_calibration':
        return 'Desbloquear plan completo';
      case 'module_locked':
        return 'Continuar con Premium';
      case 'mock_locked':
        return 'Acceder a examen de práctica';
      default:
        return 'Acceder a Premium';
    }
  }

  String get _subtitle {
    switch (trigger) {
      case 'post_calibration':
        return 'Completa los 6 módulos y domina tu nueva habilidad.';
      case 'module_locked':
        return 'Desbloquea M2-M6 generados para tu plan personalizado.';
      case 'mock_locked':
        return 'Practica con casos reales antes de tu entrevista.';
      default:
        return 'Accede a todo el contenido premium.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final entitlements = EntitlementsService();
    final navigator = Navigator.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock icon
            Icon(Icons.lock_outline, size: 64, color: Colors.purple),
            SizedBox(height: 16),

            // Title
            Text(
              _title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),

            // Subtitle
            Text(
              _subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),

            // Benefits
            _buildBenefit('Acceso a los 6 módulos completos'),
            _buildBenefit('Mock exam de práctica'),
            _buildBenefit('Cheat sheet PDF descargable'),
            _buildBenefit('Progreso guardado automáticamente'),
            SizedBox(height: 24),

            // Trial CTA
            ElevatedButton(
              onPressed: () async {
                await entitlements.startTrial();

                // Track trial start event
                await AnalyticsService().trackTrialStarted(trigger);

                onTrialStarted?.call();
                navigator.pop(true); // Return true = trial started
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Empezar prueba gratis (7 días)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),

            // Cancel
            TextButton(
              onPressed: () {
                onDismissed?.call();
                navigator.pop(false);
              },
              child: const Text('Tal vez después'),
            ),
            SizedBox(height: 8),

            // Fine print
            Text(
              'Sin tarjeta requerida • Cancela cuando quieras',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
