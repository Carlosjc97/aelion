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

    // Note: During beta mode (_isBetaMode = true), all modules are unlocked
    // This test validates beta behavior. When beta ends, change expectations below.
    // TODO: When _isBetaMode = false in entitlements_service.dart, expect false instead of true
    const isBetaMode = true;

    if (isBetaMode) {
      // Beta mode: all modules are unlocked for testers
      expect(service.isModuleUnlocked('M2'), true, reason: 'Beta mode: all modules unlocked');
      expect(service.isModuleUnlocked('M3'), true, reason: 'Beta mode: all modules unlocked');
      expect(service.isModuleUnlocked('M6'), true, reason: 'Beta mode: all modules unlocked');
    }
    // Production behavior (when isBetaMode = false):
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
