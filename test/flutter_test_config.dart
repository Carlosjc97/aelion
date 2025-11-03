import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aelion/firebase_options.dart';
import 'package:aelion/services/analytics/analytics_service.dart';

class _FakeFirebasePlatform extends FirebasePlatform {
  final Map<String, FirebaseAppPlatform> _apps = {};

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _apps[name] ??=
        FirebaseAppPlatform(name, DefaultFirebaseOptions.currentPlatform);
  }

  @override
  List<FirebaseAppPlatform> get apps => _apps.values.toList(growable: false);

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;
    final firebaseOptions = options ?? DefaultFirebaseOptions.currentPlatform;
    final app = FirebaseAppPlatform(appName, firebaseOptions);
    _apps[appName] = app;
    return app;
  }
}

class _TestFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = _FakeFirebasePlatform();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  registerFallbackValue(<String, Object?>{});
  final mockAnalytics = _TestFirebaseAnalytics();
  when(
    () => mockAnalytics.logEvent(
      name: any(named: 'name'),
      parameters: any(named: 'parameters'),
    ),
  ).thenAnswer((_) async {});
  when(
    () => mockAnalytics.setUserProperty(
      name: any(named: 'name'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((_) async {});

  final analytics = AnalyticsService();
  analytics.debugConfigureForTests(
    firebaseAnalytics: mockAnalytics,
    appVersion: 'test+1',
    platform: 'test',
    buildType: 'test',
    language: 'en',
    country: 'us',
    installSource: 'test_harness',
  );
  analytics.debugSetTrackingConsentOverride(true);
  analytics.debugDisableAutoDrain(true);
  analytics.debugSetPosthogCaptureHandler((_, __) async {});
  await testMain();
}
