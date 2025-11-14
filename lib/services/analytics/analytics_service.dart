import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'package:edaptia/config/env.dart';
import 'package:edaptia/services/remote_config_service.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;

  static const _contextSchemaVersion = 'v1';
  static const _ga4TargetKey = 'ga4';
  static const _posthogTargetKey = 'ph';
  static const String targetGa4 = _ga4TargetKey;
  static const String targetPosthog = _posthogTargetKey;

  static const int _posthogMaxEventsPerWindow = 10;
  static const Duration _posthogWindow = Duration(seconds: 10);
  static const Duration _posthogRetryBackoff = Duration(seconds: 5);

  FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;
  final Queue<_PosthogEvent> _posthogQueue = Queue<_PosthogEvent>();
  final Queue<DateTime> _posthogEventTimestamps = Queue<DateTime>();
  final Map<String, _ModuleSession> _moduleSessions =
      <String, _ModuleSession>{};

  Timer? _posthogDrainTimer;
  Future<void>? _initFuture;
  bool _posthogConfigured = false;
  bool _posthogReady = false;
  bool _disableAutoDrainForTests = false;
  bool? _consentOverride;
  Future<void> Function(String eventName, Map<String, Object?> properties)?
      _posthogCaptureOverride;

  String _appVersion = '0.0.0';
  String _platform = 'unknown';
  String _buildType = 'debug';
  String _language = 'en';
  String _country = 'us';
  String _installSource = 'unknown';
  final Map<String, String> _experimentVariants = <String, String>{};

  String? _guestId;

  Future<void> init() {
    return _initFuture ??= _doInit();
  }

  Future<void> _doInit() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    _installSource = packageInfo.installerStore ?? 'unknown';

    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final locale = dispatcher.locale;
    _language = locale.languageCode;
    _country = locale.countryCode ?? 'unknown';

    _buildType = _resolveBuildType();
    _platform = await _resolvePlatform();

    await _firebaseAnalytics.setUserProperty(
      name: 'app_version',
      value: _appVersion,
    );

    await _setupPosthog();
  }

  Future<void> _setupPosthog() async {
    final apiKey = Env.posthogKey;
    final host = Env.posthogHost;
    if (_posthogCaptureOverride != null) {
      _posthogConfigured = true;
      _posthogReady = true;
      await _drainPosthogQueue();
      return;
    }
    _posthogConfigured = apiKey.isNotEmpty && host.isNotEmpty;
    if (!_posthogConfigured) {
      debugPrint('[AnalyticsService] PostHog not configured, skipping setup.');
      return;
    }

    try {
      final config = PostHogConfig(apiKey)
        ..host = host
        ..flushAt = 13
        ..sendFeatureFlagEvents = false
        ..preloadFeatureFlags = false
        ..captureApplicationLifecycleEvents = false
        ..sessionReplay = false
        ..debug = !kReleaseMode;

      await Posthog().setup(config);
      _posthogReady = true;
      await _drainPosthogQueue();
    } catch (error) {
      debugPrint('[AnalyticsService] PostHog setup failed: $error');
    }
  }

  Future<void> setExperimentVariant(String name, String variant) async {
    await init();
    final previous = _experimentVariants[name];
    if (previous == variant) return;
    _experimentVariants[name] = variant;
    await track(
      'experiment_exposure',
      properties: {'name': name, 'variant': variant},
    );
  }

  Future<void> trackModuleStarted({
    required String moduleId,
    required String topic,
    String? band,
    required int lessonCount,
  }) async {
    await init();
    final normalizedId = moduleId.trim().isEmpty ? topic : moduleId.trim();
    final normalizedBand =
        (band?.trim().isNotEmpty ?? false) ? band!.trim() : 'unknown';
    _moduleSessions[normalizedId] = _ModuleSession(
      moduleId: normalizedId,
      topic: topic,
      band: normalizedBand,
      lessonCount: lessonCount,
      startedAt: DateTime.now(),
    );
    await track(
      'module_started',
      properties: <String, Object?>{
        'module_id': normalizedId,
        'topic': topic,
        'band': normalizedBand,
        'lesson_count': lessonCount,
      },
      targets: const {targetPosthog},
    );
  }

  Future<void> trackModuleCompleted({
    required String moduleId,
    required String topic,
    String? band,
    required int lessonCount,
  }) async {
    await init();
    final normalizedId = moduleId.trim().isEmpty ? topic : moduleId.trim();
    final session = _moduleSessions.remove(normalizedId);
    final resolvedBand = (band?.trim().isNotEmpty ?? false)
        ? band!.trim()
        : session?.band ?? 'unknown';
    final resolvedLessonCount =
        lessonCount > 0 ? lessonCount : (session?.lessonCount ?? 0);
    final startedAt = session?.startedAt;
    final int durationSeconds = startedAt == null
        ? 0
        : (DateTime.now().difference(startedAt).inSeconds)
            .clamp(0, const Duration(hours: 8).inSeconds).toInt();
    await track(
      'module_completed',
      properties: <String, Object?>{
        'module_id': normalizedId,
        'topic': session?.topic ?? topic,
        'band': resolvedBand,
        'lesson_count': resolvedLessonCount,
        'duration_s': durationSeconds,
      },
      targets: const {targetPosthog},
    );
  }

  Future<void> trackNotificationOptIn(String status) {
    return track(
      'notification_opt_in',
      properties: <String, Object?>{'status': status},
      targets: const {targetGa4},
    );
  }

  Future<void> trackPaywallViewed(String placement) {
    return track(
      'paywall_viewed',
      properties: <String, Object?>{'placement': placement},
      targets: const {targetGa4},
    );
  }

  Future<void> trackTrialStarted(String trigger) {
    return track(
      'trial_start',
      properties: <String, Object?>{
        'trigger': trigger,
        'trial_days': 7,
      },
      targets: const {targetGa4},
    );
  }

  Future<void> trackPaywallDismissed(String trigger) {
    return track(
      'paywall_dismissed',
      properties: <String, Object?>{'trigger': trigger},
      targets: const {targetGa4},
    );
  }

  Future<void> trackPurchaseCompleted({
    required String plan,
    required double priceUsd,
  }) {
    return track(
      'purchase_completed',
      properties: <String, Object?>{
        'plan': plan,
        'price_usd': priceUsd,
      },
      targets: const {targetGa4},
    );
  }

  Future<void> identifyGuest(String guestId) async {
    await init();
    _guestId = guestId;
    if (!_shouldSendToPosthog()) return;
    await _callPosthogSafely(() => Posthog().identify(userId: guestId));
    await track(
      'user_identified',
      properties: <String, Object?>{
        'provider': 'guest',
        'lang': _language,
        'is_guest': true,
      },
    );
  }

  Future<void> aliasAndIdentify(String uid, String guestId) async {
    await init();
    _guestId ??= guestId;
    try {
      await _firebaseAnalytics.setUserId(id: uid);
    } catch (error) {
      debugPrint('[AnalyticsService] setUserId failed: $error');
    }

    if (!_shouldSendToPosthog()) return;
    await _callPosthogSafely(() async {
      await Posthog().alias(alias: uid);
      await Posthog().identify(userId: uid);
    });
    await track(
      'user_identified',
      properties: <String, Object?>{
        'provider': 'google',
        'lang': _language,
        'is_guest': false,
      },
    );
  }

  Future<void> track(
    String name, {
    Map<String, Object?> properties = const <String, Object?>{},
    Set<String> targets = const <String>{_ga4TargetKey, _posthogTargetKey},
  }) async {
    await init();
    final contextProps = _buildContextProperties();
    final mergedProps = <String, Object?>{
      ...contextProps,
      ...properties,
    };

    if (targets.contains(_ga4TargetKey)) {
      await _logGa4Event(name, mergedProps);
    }

    if (targets.contains(_posthogTargetKey) && _shouldSendToPosthog()) {
      _enqueuePosthogEvent(
          _PosthogEvent(name, _sanitizeForPosthog(mergedProps)));
    }
  }

  Map<String, Object?> _buildContextProperties() {
    return <String, Object?>{
      'schema_ver': _contextSchemaVersion,
      'app_version': _appVersion,
      'platform': _platform,
      'build_type': _buildType,
      'lang': _language,
      'country': _country,
      'install_source': _installSource,
      'experiment_variant': _experimentVariants.isEmpty
          ? 'none'
          : jsonEncode(_experimentVariants),
    };
  }

  Future<void> _logGa4Event(
      String name, Map<String, Object?> properties) async {
    final sanitized = _sanitizeForGa(properties);
    try {
      await _firebaseAnalytics.logEvent(name: name, parameters: sanitized);
    } catch (error) {
      debugPrint('[AnalyticsService] GA4 logEvent failed: $error');
    }
  }

  Future<void> _callPosthogSafely(Future<void> Function() action) async {
    if (!_posthogReady) {
      await _setupPosthog();
      if (!_posthogReady) return;
    }

    try {
      await action();
    } catch (error) {
      debugPrint('[AnalyticsService] PostHog call failed: $error');
    }
  }

  void _enqueuePosthogEvent(_PosthogEvent event) {
    _posthogQueue.add(event);
    _schedulePosthogDrain();
  }

  void _schedulePosthogDrain() {
    if (_disableAutoDrainForTests) {
      return;
    }
    if (_posthogDrainTimer != null) {
      return;
    }

    final delay = _nextPosthogDrainDelay();
    _posthogDrainTimer = Timer(delay, () async {
      _posthogDrainTimer = null;
      await _drainPosthogQueue();
      if (_posthogQueue.isNotEmpty) {
        _schedulePosthogDrain();
      }
    });
  }

  Duration _nextPosthogDrainDelay() {
    _prunePosthogTimestamps();
    if (_posthogEventTimestamps.length < _posthogMaxEventsPerWindow) {
      return Duration.zero;
    }
    final now = DateTime.now();
    final oldest = _posthogEventTimestamps.first;
    final waitUntil = oldest.add(_posthogWindow);
    final delay = waitUntil.difference(now);
    if (delay.isNegative) {
      return Duration.zero;
    }
    return delay;
  }

  Future<void> _drainPosthogQueue() async {
    if (!_shouldSendToPosthog()) {
      _posthogQueue.clear();
      return;
    }
    if (!_posthogReady) {
      await _setupPosthog();
      if (!_posthogReady) return;
    }

    _prunePosthogTimestamps();

    while (_posthogQueue.isNotEmpty &&
        _posthogEventTimestamps.length < _posthogMaxEventsPerWindow) {
      final event = _posthogQueue.removeFirst();
      try {
        if (_posthogCaptureOverride != null) {
          await _posthogCaptureOverride!(event.name, event.properties);
        } else {
          await Posthog()
              .capture(eventName: event.name, properties: event.properties);
        }
        _posthogEventTimestamps.addLast(DateTime.now());
        _prunePosthogTimestamps();
      } catch (error) {
        debugPrint('[AnalyticsService] PostHog capture failed: $error');
        _posthogQueue.addFirst(event);
        await Future<void>.delayed(_posthogRetryBackoff);
        break;
      }
    }
  }

  void _prunePosthogTimestamps() {
    final now = DateTime.now();
    while (_posthogEventTimestamps.isNotEmpty) {
      final oldest = _posthogEventTimestamps.first;
      if (now.difference(oldest) >= _posthogWindow) {
        _posthogEventTimestamps.removeFirst();
      } else {
        break;
      }
    }
  }

  @visibleForTesting
  void debugConfigureForTests({
    FirebaseAnalytics? firebaseAnalytics,
    String appVersion = 'test+1',
    String platform = 'test',
    String buildType = 'debug',
    String language = 'en',
    String country = 'us',
    String installSource = 'test',
  }) {
    _firebaseAnalytics = firebaseAnalytics ?? _firebaseAnalytics;
    _appVersion = appVersion;
    _platform = platform;
    _buildType = buildType;
    _language = language;
    _country = country;
    _installSource = installSource;
    _initFuture = Future<void>.value();
  }

  @visibleForTesting
  void debugSetTrackingConsentOverride(bool? value) {
    _consentOverride = value;
  }

  @visibleForTesting
  void debugSetPosthogCaptureHandler(
    Future<void> Function(String eventName, Map<String, Object?> properties)
        handler,
  ) {
    _posthogCaptureOverride = handler;
    _posthogConfigured = true;
    _posthogReady = true;
  }

  @visibleForTesting
  void debugDisableAutoDrain(bool value) {
    _disableAutoDrainForTests = value;
  }

  @visibleForTesting
  Future<void> debugDrainPosthogQueue() => _drainPosthogQueue();

  @visibleForTesting
  int debugPosthogQueueLength() => _posthogQueue.length;

  Map<String, Object> _sanitizeForGa(Map<String, Object?> properties) {
    final sanitized = <String, Object>{};
    properties.forEach((key, value) {
      if (value == null) return;
      if (value is num || value is bool || value is String) {
        sanitized[key] = value;
      } else {
        sanitized[key] = jsonEncode(value);
      }
    });
    return sanitized;
  }

  Map<String, Object> _sanitizeForPosthog(Map<String, Object?> properties) {
    final sanitized = <String, Object>{};
    properties.forEach((key, value) {
      if (value == null) return;
      if (value is DateTime) {
        sanitized[key] = value.toIso8601String();
      } else if (value is Duration) {
        sanitized[key] = value.inMilliseconds;
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  Future<String> _resolvePlatform() async {
    if (kIsWeb) {
      final info = await DeviceInfoPlugin().webBrowserInfo;
      final browser = info.browserName.name.toLowerCase();
      _installSource = 'browser:$browser';
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  String _resolveBuildType() {
    if (kReleaseMode) return 'release';
    if (kProfileMode) return 'profile';
    return 'debug';
  }

  bool _shouldSendToPosthog() {
    final consent = _consentOverride ?? RemoteConfigService().trackingConsent;
    return _posthogConfigured && consent;
  }

  String get appVersion => _appVersion;

  String get platform => _platform;

  String get buildType => _buildType;
}

class _PosthogEvent {
  _PosthogEvent(this.name, this.properties);

  final String name;
  final Map<String, Object> properties;
}

class _ModuleSession {
  _ModuleSession({
    required this.moduleId,
    required this.topic,
    required this.band,
    required this.lessonCount,
    required this.startedAt,
  });

  final String moduleId;
  final String topic;
  final String band;
  final int lessonCount;
  final DateTime startedAt;
}


