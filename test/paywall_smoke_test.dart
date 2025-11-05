import 'package:flutter_test/flutter_test.dart';
import 'package:edaptia/services/entitlements_service.dart';

void main() {
  test('EntitlementsService - M1 always unlocked', () {
    final service = EntitlementsService();
    service.reset();

    expect(service.isModuleUnlocked('M1'), true);
  });

  test('EntitlementsService - M2-M6 locked by default', () {
    final service = EntitlementsService();
    service.reset();

    expect(service.isModuleUnlocked('M2'), false);
    expect(service.isModuleUnlocked('M3'), false);
    expect(service.isModuleUnlocked('M6'), false);
  });

  test('EntitlementsService - Trial unlocks everything', () {
    final service = EntitlementsService();
    service.reset();
    service.startTrial();

    expect(service.isPremium, true);
    expect(service.isModuleUnlocked('M2'), true);
    expect(service.isModuleUnlocked('M6'), true);
  });

  test('EntitlementsService - Trial expires after 7 days', () {
    final service = EntitlementsService();
    service.reset();
    service.startTrial();

    expect(service.isInTrial, true);
    expect(service.trialDaysRemaining, 7);
  });
}
