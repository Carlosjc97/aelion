/// Mock service for premium entitlements (MVP - no RevenueCat yet)
///
/// Manages premium access and trial state for the app.
/// In MVP phase, this is a simple in-memory mock without backend persistence.
class EntitlementsService {
  static final EntitlementsService _instance = EntitlementsService._internal();
  factory EntitlementsService() => _instance;
  EntitlementsService._internal();

  bool _isPremium = false;
  DateTime? _trialStartedAt;

  /// Check if user has premium access
  bool get isPremium => _isPremium || isInTrial;

  /// Check if user is in trial period (7 days)
  bool get isInTrial {
    if (_trialStartedAt == null) return false;
    final daysSinceTrial = DateTime.now().difference(_trialStartedAt!).inDays;
    return daysSinceTrial < 7;
  }

  /// Get days remaining in trial
  int get trialDaysRemaining {
    if (_trialStartedAt == null) return 0;
    final daysSinceTrial = DateTime.now().difference(_trialStartedAt!).inDays;
    return (7 - daysSinceTrial).clamp(0, 7);
  }

  /// Start trial (mock)
  void startTrial() {
    _trialStartedAt = DateTime.now();
    print('[EntitlementsService] Trial started: $_trialStartedAt');
  }

  /// Grant premium (mock for testing)
  void grantPremium() {
    _isPremium = true;
    print('[EntitlementsService] Premium granted');
  }

  /// Check if specific module is unlocked
  /// M1 is always free, M2-M6 require premium
  bool isModuleUnlocked(String moduleId) {
    final normalized = moduleId.trim().toUpperCase();

    // M1 always free
    if (normalized == 'M1' || normalized == 'MODULE1' || normalized.contains('FUNDAMENTOS') || normalized.contains('FUNDAMENTALS')) {
      return true;
    }

    // M2-M6 require premium
    return isPremium;
  }

  /// Reset (for testing)
  void reset() {
    _isPremium = false;
    _trialStartedAt = null;
  }
}
