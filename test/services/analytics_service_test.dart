
import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
  });

  setUp(() async {
    final analytics = AnalyticsService();
    analytics.debugDisableAutoDrain(true);
    analytics.debugSetPosthogCaptureHandler((_, __) async {});
    analytics.debugSetTrackingConsentOverride(true);
    await analytics.debugDrainPosthogQueue();
  });

  test('track attaches schema_ver and app_version to GA4 payload', () async {
    final mockAnalytics = _MockFirebaseAnalytics();
    final analytics = AnalyticsService();
    analytics.debugConfigureForTests(
      firebaseAnalytics: mockAnalytics,
      appVersion: '2.0.0+5',
      platform: 'test',
      buildType: 'debug',
      language: 'en',
      country: 'us',
      installSource: 'test_store',
    );
    analytics.debugSetTrackingConsentOverride(true);
    analytics.debugSetPosthogCaptureHandler((_, __) async {});

    when(
      () => mockAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});

    await analytics.track(
      'sample_event',
      properties: const {'foo': 'bar'},
      targets: const {AnalyticsService.targetGa4},
    );

    final captured = verify(
      () => mockAnalytics.logEvent(
        name: 'sample_event',
        parameters: captureAny(named: 'parameters'),
      ),
    ).captured.single as Map<String, Object?>;

    expect(captured['schema_ver'], equals('v1'));
    expect(captured['app_version'], equals('2.0.0+5'));
    expect(captured['foo'], equals('bar'));
  });

  test('PostHog queue stays empty when tracking consent is false', () async {
    final analytics = AnalyticsService();
    analytics.debugConfigureForTests(
        firebaseAnalytics: _MockFirebaseAnalytics());
    analytics.debugSetTrackingConsentOverride(false);
    analytics.debugSetPosthogCaptureHandler((_, __) async {});

    await analytics.track(
      'ph_event',
      targets: const {AnalyticsService.targetPosthog},
    );

    expect(analytics.debugPosthogQueueLength(), equals(0));
  });

  test('PostHog throttling limits batch size to 10 events', () async {
    final analytics = AnalyticsService();
    analytics.debugConfigureForTests(
        firebaseAnalytics: _MockFirebaseAnalytics());
    analytics.debugSetTrackingConsentOverride(true);

    final captured = <String>[];
    analytics.debugSetPosthogCaptureHandler((event, _) async {
      captured.add(event);
    });

    for (var i = 0; i < 12; i++) {
      await analytics.track(
        'ph_event_$i',
        targets: const {AnalyticsService.targetPosthog},
      );
    }

    expect(analytics.debugPosthogQueueLength(), equals(12));

    await analytics.debugDrainPosthogQueue();

    expect(captured.length, equals(10));
    expect(analytics.debugPosthogQueueLength(), equals(2));
  });
}

