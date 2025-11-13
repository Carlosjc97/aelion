import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edaptia/services/analytics/analytics_service.dart';

class OnboardingAnswers {
  OnboardingAnswers({
    this.ageRange,
    List<String> interests = const <String>[],
    this.education,
    this.isFirstTimeSql,
    this.wantsBetaTester = false,
    this.skipped = false,
  }) : interests = List.unmodifiable(interests);

  final String? ageRange;
  final List<String> interests;
  final String? education;
  final bool? isFirstTimeSql;
  final bool wantsBetaTester;
  final bool skipped;

  OnboardingAnswers copyWith({
    String? ageRange,
    List<String>? interests,
    String? education,
    bool? isFirstTimeSql,
    bool? wantsBetaTester,
    bool? skipped,
  }) {
    return OnboardingAnswers(
      ageRange: ageRange ?? this.ageRange,
      interests: interests ?? this.interests,
      education: education ?? this.education,
      isFirstTimeSql: isFirstTimeSql ?? this.isFirstTimeSql,
      wantsBetaTester: wantsBetaTester ?? this.wantsBetaTester,
      skipped: skipped ?? this.skipped,
    );
  }

  factory OnboardingAnswers.skipped({
    List<String> interests = const <String>[],
    bool wantsBetaTester = false,
  }) {
    return OnboardingAnswers(
      interests: interests,
      wantsBetaTester: wantsBetaTester,
      skipped: true,
    );
  }

  Map<String, dynamic> toDocumentPayload() {
    final payload = <String, dynamic>{
      'skipped': skipped,
      'betaTester': wantsBetaTester,
    };

    if (ageRange != null) {
      payload['ageRange'] = ageRange;
    }
    if (education != null) {
      payload['education'] = education;
    }
    if (isFirstTimeSql != null) {
      payload['firstTimeSql'] = isFirstTimeSql;
    }
    if (interests.isNotEmpty) {
      payload['interests'] = interests;
    }

    return payload;
  }

  Map<String, Object?> toAnalyticsProperties() {
    return <String, Object?>{
      'age_range': ageRange,
      'education': education,
      'first_time_sql': isFirstTimeSql,
      'interests': interests,
      'beta_tester': wantsBetaTester,
      'skipped': skipped,
    };
  }
}

class OnboardingService {
  OnboardingService._({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static final OnboardingService _instance = OnboardingService._();
  factory OnboardingService() => _instance;

  static const String _prefsKey = 'hasCompletedOnboarding';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<bool> hasCompletedLocally() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> setLocalCompleted([bool value = true]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  Future<bool> needsOnboarding() async {
    if (await hasCompletedLocally()) {
      return false;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return false;
    }

    final hasRemote = await _hasRemoteRecord(uid);
    if (hasRemote) {
      await setLocalCompleted(true);
      return false;
    }

    return true;
  }

  Future<void> submit(OnboardingAnswers answers) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError(
          'Cannot submit onboarding without an authenticated user.');
    }

    final payload = answers.toDocumentPayload();
    final timestamp = FieldValue.serverTimestamp();
    payload['updatedAt'] = timestamp;
    if (answers.skipped) {
      payload['skippedAt'] = timestamp;
    } else {
      payload['completedAt'] = timestamp;
    }

    try {
      await _firestore.collection('users').doc(uid).set(
        <String, dynamic>{'onboarding': payload},
        SetOptions(merge: true),
      );
      await setLocalCompleted(true);
      await AnalyticsService().track('onboarding_completed',
          properties: answers.toAnalyticsProperties());
    } catch (error, stackTrace) {
      debugPrint('[OnboardingService] Failed to submit onboarding: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> skip({OnboardingAnswers? partial}) {
    final answers = (partial ?? OnboardingAnswers()).copyWith(skipped: true);
    return submit(answers);
  }

  Future<bool> _hasRemoteRecord(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      final data = snapshot.data();
      if (data == null) return false;
      final onboarding = data['onboarding'];
      if (onboarding is Map<String, dynamic>) {
        if (onboarding.isEmpty) return false;
        if (onboarding['skipped'] == true) return true;
        if (onboarding['completedAt'] != null) return true;
        if (onboarding['interests'] != null) return true;
        return onboarding.keys.isNotEmpty;
      }
      return false;
    } catch (error, stackTrace) {
      debugPrint('[OnboardingService] Remote onboarding lookup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}
