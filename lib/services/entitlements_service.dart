import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:edaptia/services/api_config.dart';
import 'package:edaptia/services/course/course_api_client.dart';
import 'package:edaptia/services/google_play_billing_service.dart';

class EntitlementsService {
  EntitlementsService._internal() {
    _billingService.premiumStatusStream.listen((isPremium) {
      _isPremium = isPremium;
      if (isPremium) {
        _lastFetchedAt = DateTime.now();
      }
    });
  }
  static final EntitlementsService _instance = EntitlementsService._internal();
  factory EntitlementsService() => _instance;

  bool _isPremium = false;
  DateTime? _trialEndsAt;
  bool _loaded = false;
  DateTime? _lastFetchedAt;
  Future<void>? _loadFuture;
  bool _testingMode = false;
  DateTime? _subscriptionExpiresAt;
  final GooglePlayBillingService _billingService = GooglePlayBillingService();

  bool get hasPremiumAccess => _isPremium || isInTrial;

  Future<bool> isPremium() async {
    final firestoreStatus = await _checkFirestorePremium();
    if (firestoreStatus) {
      return true;
    }

    final billingStatus =
        await _billingService.hasActiveSubscription(forceRefresh: true);
    _isPremium = billingStatus;
    if (billingStatus) {
      _lastFetchedAt = DateTime.now();
    }
    return billingStatus || isInTrial;
  }

  bool get isInTrial {
    if (_trialEndsAt == null) return false;
    return DateTime.now().isBefore(_trialEndsAt!);
  }

  int get trialDaysRemaining {
    if (_trialEndsAt == null) return 0;
    final remaining = _trialEndsAt!.difference(DateTime.now());
    final days = remaining.inDays +
        (remaining.inSeconds % Duration.secondsPerDay == 0 ? 0 : 1);
    return days.clamp(0, 7);
  }

  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    if (!forceRefresh && _loaded && _lastFetchedAt != null) {
      final elapsed = DateTime.now().difference(_lastFetchedAt!);
      if (elapsed < const Duration(minutes: 5)) {
        return;
      }
    }
    _loadFuture ??= _fetchEntitlements();
    try {
      await _loadFuture;
    } finally {
      _loadFuture = null;
    }
  }

  Future<void> _fetchEntitlements() async {
    if (_testingMode) {
      _loaded = true;
      _lastFetchedAt = DateTime.now();
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _resetLocal();
      _loaded = true;
      _lastFetchedAt = DateTime.now();
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = snapshot.data();
      final entitlements = data?['entitlements'];
      final dynamic premiumFlag = entitlements is Map
          ? entitlements['isPremium']
          : data?['isPremium'];
      _isPremium = premiumFlag == true;

      final dynamic trialSource = entitlements is Map && entitlements['trialEndsAt'] != null
          ? entitlements['trialEndsAt']
          : data?['trialEndsAt'];
      _trialEndsAt = _parseTimestamp(trialSource);

      final dynamic subscriptionSource =
          entitlements is Map && entitlements['subscriptionExpiresAt'] != null
              ? entitlements['subscriptionExpiresAt']
              : data?['subscriptionExpiresAt'];
      _subscriptionExpiresAt = _parseTimestamp(subscriptionSource);

      if (!_isPremium &&
          _subscriptionExpiresAt != null &&
          DateTime.now().isBefore(_subscriptionExpiresAt!)) {
        _isPremium = true;
      }

      _loaded = true;
      _lastFetchedAt = DateTime.now();
    } catch (error, stackTrace) {
      debugPrint('[EntitlementsService] Failed to load entitlements: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> _checkFirestorePremium({bool forceRefresh = false}) async {
    await ensureLoaded(forceRefresh: forceRefresh);
    if (_isPremium) {
      return true;
    }
    if (_subscriptionExpiresAt != null &&
        DateTime.now().isBefore(_subscriptionExpiresAt!)) {
      _isPremium = true;
      return true;
    }
    return false;
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @Deprecated('Use GooglePlayBillingService.purchasePremiumSubscription()')
  Future<void> startTrial() async {
    debugPrint('[EntitlementsService] startTrial() is deprecated.');
    final trialEnds = DateTime.now().add(const Duration(days: 7));

    if (_testingMode) {
      _trialEndsAt = trialEnds;
      _loaded = true;
      _lastFetchedAt = DateTime.now();
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final response = await CourseApiClient.postJson(
        uri: Uri.parse(ApiConfig.startTrial()),
        body: const <String, dynamic>{},
        timeout: const Duration(seconds: 30),
      );
      final decoded = jsonDecode(response.body);
      DateTime? remoteTrialEnds;
      if (decoded is Map) {
        final raw = decoded['trialEndsAt'];
        if (raw is num) {
          remoteTrialEnds = DateTime.fromMillisecondsSinceEpoch(
            raw.toInt(),
            isUtc: true,
          ).toLocal();
        } else if (raw is String) {
          remoteTrialEnds = DateTime.tryParse(raw);
        }
      }
      _trialEndsAt = remoteTrialEnds ?? trialEnds;
      _loaded = true;
      _lastFetchedAt = DateTime.now();
    } catch (error, stackTrace) {
      debugPrint('[EntitlementsService] Failed to start trial: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> purchasePremium() async {
    if (_testingMode) {
      _isPremium = true;
      _lastFetchedAt = DateTime.now();
      return true;
    }

    final success = await _billingService.purchasePremiumSubscription();
    if (success) {
      await ensureLoaded(forceRefresh: true);
    }
    return success;
  }

  Future<void> restorePurchases() async {
    if (_testingMode) {
      return;
    }

    await _billingService.restorePurchases();
    await _billingService.hasActiveSubscription(forceRefresh: true);
    await ensureLoaded(forceRefresh: true);
  }

  void configureForTesting({bool memoryOnly = true}) {
    _testingMode = true;
    reset();
  }

  void grantPremium() {
    _isPremium = true;
    _lastFetchedAt = DateTime.now();
  }

  bool isModuleUnlocked(String moduleId) {
    final normalized = moduleId.trim().toUpperCase();
    if (normalized == 'M1' || normalized == 'MODULE1') {
      return true;
    }
    return hasPremiumAccess;
  }

  void reset() {
    _resetLocal();
    _loaded = false;
    _lastFetchedAt = null;
  }

  void _resetLocal() {
    _isPremium = false;
    _trialEndsAt = null;
    _subscriptionExpiresAt = null;
  }

  void exitTestingMode() {
    _testingMode = false;
    reset();
  }
}
