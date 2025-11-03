import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService _instance = RemoteConfigService._();

  factory RemoteConfigService() => _instance;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _initialized = false;

  static const _defaults = <String, Object>{
    'tracking_consent': false,
    'ftue_login_gate': false,
    'naming_outline': false,
    'naming_quiz': false,
    'habit_variant': 'control',
  };

  Future<void> fetchAndActivate() async {
    if (!_initialized) {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kReleaseMode ? const Duration(hours: 1) : const Duration(minutes: 5),
      ));
      await _remoteConfig.setDefaults(_defaults);
      _initialized = true;
    }

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (error) {
      debugPrint('[RemoteConfigService] fetchAndActivate failed: $error');
    }
  }

  bool get trackingConsent => _remoteConfig.getBool('tracking_consent');
  bool get ftueLoginGate => _remoteConfig.getBool('ftue_login_gate');
  bool get namingOutline => _remoteConfig.getBool('naming_outline');
  bool get namingQuiz => _remoteConfig.getBool('naming_quiz');
  String get habitVariant => _remoteConfig.getString('habit_variant');
}
