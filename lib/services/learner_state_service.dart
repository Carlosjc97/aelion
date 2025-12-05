import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:edaptia/services/course/models.dart';

/// Service that exposes helper utilities for learner state tracking.
class LearnerStateService {
  LearnerStateService._();

  static final LearnerStateService instance = LearnerStateService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Subscribe to real-time learner state updates.
  Stream<AdaptiveLearnerState?> watchLearnerState() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('[LearnerStateService] No authenticated user for watch');
      return Stream.value(null);
    }

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('adaptiveState')
        .doc('summary');

    return docRef.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      try {
        return AdaptiveLearnerState.fromJson(
          Map<String, dynamic>.from(data),
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[LearnerStateService] Failed to parse learner state: $error\n$stackTrace',
        );
        return null;
      }
    });
  }

  /// Whether a lesson has already been visited by the learner.
  bool isLessonVisited({
    required AdaptiveLearnerState? state,
    required String topic,
    required int moduleNumber,
    required int lessonIndex,
  }) {
    if (state == null) return false;
    final normalized = _normalizedTopic(topic);
    final lessonKey = '${normalized}_m${moduleNumber}_l$lessonIndex';
    return state.visitedLessons[lessonKey] == true;
  }

  /// Return module progress between 0 and 1.
  double getModuleProgress({
    required AdaptiveLearnerState? state,
    required String topic,
    required int moduleNumber,
    required int totalLessons,
  }) {
    if (state == null || totalLessons <= 0) return 0;
    var visitedCount = 0;
    for (var index = 0; index < totalLessons; index++) {
      if (isLessonVisited(
        state: state,
        topic: topic,
        moduleNumber: moduleNumber,
        lessonIndex: index,
      )) {
        visitedCount++;
      }
    }
    return visitedCount / totalLessons;
  }

  /// Whether all lessons in a module have been visited.
  bool isModuleComplete({
    required AdaptiveLearnerState? state,
    required String topic,
    required int moduleNumber,
    required int totalLessons,
  }) {
    if (state == null || totalLessons <= 0) return false;
    for (var index = 0; index < totalLessons; index++) {
      if (!isLessonVisited(
        state: state,
        topic: topic,
        moduleNumber: moduleNumber,
        lessonIndex: index,
      )) {
        return false;
      }
    }
    return true;
  }

  /// Count total lessons visited for a specific topic.
  int countVisitedLessons({
    required AdaptiveLearnerState? state,
    required String topic,
  }) {
    if (state == null) return 0;
    final normalized = _normalizedTopic(topic);
    return state.visitedLessons.entries
        .where((entry) => entry.key.startsWith('${normalized}_') && entry.value)
        .length;
  }

  String _normalizedTopic(String topic) {
    return topic.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }
}
