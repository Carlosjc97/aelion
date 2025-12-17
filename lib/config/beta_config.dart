// Beta Configuration
//
// This file contains feature flags and configuration for beta testing.
// Update these values when transitioning from beta to production.

/// Master beta mode flag - controls all beta features.
/// Set to false when ready for production launch.
const bool isBetaMode = true;

/// Beta-specific feature flags
class BetaConfig {
  /// Show simplified onboarding flow during beta
  /// - Micro-lesson BEFORE quiz (demo value first)
  /// - Quiz becomes optional "unlock advanced mode"
  /// - Reduces friction for first-time users
  static const bool simplifiedFlow = true;

  /// Default topic for beta testers (focused testing)
  /// Production will allow free topic selection
  static const String defaultTopic = "SQL";

  /// Allow topic customization in beta
  /// false = SQL only, true = any topic
  static const bool allowTopicSelection = false;

  /// Make quiz optional during beta
  /// Shows "Skip to lesson" option for reduced friction
  static const bool optionalQuiz = true;

  /// Enhanced analytics during beta
  /// Track detailed user journey for Google Play metrics
  static const bool enhancedAnalytics = true;
}

/// Production Checklist (when disabling beta):
///
/// 1. Set isBetaMode = false in this file
/// 2. Set _isBetaMode = false in lib/services/entitlements_service.dart
/// 3. Update BetaConfig.simplifiedFlow = false (or remove conditional logic)
/// 4. Update BetaConfig.allowTopicSelection = true
/// 5. Update BetaConfig.optionalQuiz = false
/// 6. Run flutter analyze && flutter test
/// 7. Test premium paywall appears correctly
/// 8. Create new version tag: git tag -a v1.0.0+6-production
