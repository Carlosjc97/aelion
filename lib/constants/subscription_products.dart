class SubscriptionProducts {
  static const String premiumMonthly = 'edaptia_premium_monthly';

  static const List<String> testProductIds = [
    'android.test.purchased',
    'android.test.canceled',
    'android.test.item_unavailable',
  ];

  static bool isTestMode = false;

  static List<String> get productIds =>
      isTestMode ? testProductIds : <String>[premiumMonthly];
}
