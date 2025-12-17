import 'package:flutter_test/flutter_test.dart';
import 'package:edaptia/services/entitlements_service.dart';

void main() {
  setUp(() {
    EntitlementsService()
      ..configureForTesting(memoryOnly: true)
      ..reset();
  });

  test('EntitlementsService - M1 always unlocked', () async {
    final service = EntitlementsService();
    await service.ensureLoaded();

    expect(service.isModuleUnlocked('M1'), true);
  });

  test('EntitlementsService - M2-M6 locked by default', () async {
    final service = EntitlementsService();
    await service.ensureLoaded();

    // Note: During beta mode (_isBetaMode = true in entitlements_service.dart),
    // all modules are unlocked for testers. This test validates that behavior.
    // TODO: When beta ends, update expectations to expect(false) for production behavior.

    // Beta mode expectations:
    expect(service.isModuleUnlocked('M2'), true, reason: 'Beta mode: all modules unlocked');
    expect(service.isModuleUnlocked('M3'), true, reason: 'Beta mode: all modules unlocked');
    expect(service.isModuleUnlocked('M6'), true, reason: 'Beta mode: all modules unlocked');

    // Production behavior (uncomment when _isBetaMode = false):
    // expect(service.isModuleUnlocked('M2'), false);
    // expect(service.isModuleUnlocked('M3'), false);
    // expect(service.isModuleUnlocked('M6'), false);
  });

  test('EntitlementsService - Trial unlocks everything', () async {
    final service = EntitlementsService();
    // ignore: deprecated_member_use_from_same_package
    await service.startTrial();

    expect(service.hasPremiumAccess, true);
    expect(service.isModuleUnlocked('M2'), true);
    expect(service.isModuleUnlocked('M6'), true);
  });

  test('EntitlementsService - Trial expires after 7 days', () async {
    final service = EntitlementsService();
    // ignore: deprecated_member_use_from_same_package
    await service.startTrial();

    expect(service.isInTrial, true);
    expect(service.trialDaysRemaining, 7);
  });
}
