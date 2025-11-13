import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class EntitlementsService {
  EntitlementsService._internal();
  static final EntitlementsService _instance = EntitlementsService._internal();
  factory EntitlementsService() => _instance;

  bool _isPremium = false;
  DateTime? _trialEndsAt;
  bool _loaded = false;
  DateTime? _lastFetchedAt;
  Future<void>? _loadFuture;

  bool get isPremium => _isPremium || isInTrial;

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
      _isPremium = entitlements is Map && entitlements['isPremium'] == true;
      _trialEndsAt = _parseTimestamp(
          entitlements is Map ? entitlements['trialEndsAt'] : null);
      _loaded = true;
      _lastFetchedAt = DateTime.now();
    } catch (error, stackTrace) {
      debugPrint('[EntitlementsService] Failed to load entitlements: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
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

  Future<void> startTrial() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final trialEnds = DateTime.now().add(const Duration(days: 7));
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'entitlements': {
          'trialEndsAt': Timestamp.fromDate(trialEnds),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
      _trialEndsAt = trialEnds;
      _loaded = true;
      _lastFetchedAt = DateTime.now();
    } catch (error, stackTrace) {
      debugPrint('[EntitlementsService] Failed to start trial: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  void configureForTesting({bool memoryOnly = true}) {
    reset();
  }

  void grantPremium() {
    _isPremium = true;
  }

  bool isModuleUnlocked(String moduleId) {
    final normalized = moduleId.trim().toUpperCase();
    if (normalized == 'M1' || normalized == 'MODULE1') {
      return true;
    }
    return isPremium;
  }

  void reset() {
    _resetLocal();
    _loaded = false;
    _lastFetchedAt = null;
  }

  void _resetLocal() {
    _isPremium = false;
    _trialEndsAt = null;
  }
}
