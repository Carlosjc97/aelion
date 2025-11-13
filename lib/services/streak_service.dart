import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class StreakSnapshot {
  const StreakSnapshot({
    required this.streakDays,
    required this.lastCheckIn,
    required this.incremented,
  });

  final int streakDays;
  final DateTime? lastCheckIn;
  final bool incremented;
}

class StreakService {
  StreakService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<StreakSnapshot> fetch(String userId) async {
    // Verify auth state before attempting Firestore read
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != userId) {
      // Return default if auth mismatch or not logged in
      return const StreakSnapshot(streakDays: 0, lastCheckIn: null, incremented: false);
    }

    try {
      final doc = await _firestore.collection('user_streaks').doc(userId).get();
      if (!doc.exists) {
        return const StreakSnapshot(streakDays: 0, lastCheckIn: null, incremented: false);
      }
      final data = doc.data() ?? <String, dynamic>{};
      final streak = data['currentStreak'] is num ? (data['currentStreak'] as num).toInt() : 0;
      final timestamp = data['lastCheckIn'];
      final lastCheckIn = timestamp is Timestamp ? timestamp.toDate() : null;
      return StreakSnapshot(
        streakDays: streak,
        lastCheckIn: lastCheckIn,
        incremented: false,
      );
    } on FirebaseException catch (e) {
      // Handle permission-denied gracefully by returning default
      if (e.code == 'permission-denied') {
        return const StreakSnapshot(streakDays: 0, lastCheckIn: null, incremented: false);
      }
      rethrow;
    }
  }

  Future<StreakSnapshot> checkIn(String userId) async {
    final docRef = _firestore.collection('user_streaks').doc(userId);
    final now = DateTime.now();
    final nowDay = DateTime(now.year, now.month, now.day);

    final snapshot = await _firestore.runTransaction<StreakSnapshot>((transaction) async {
      final doc = await transaction.get(docRef);
      final data = doc.data() ?? <String, dynamic>{};
      final previousStreak = data['currentStreak'] is num ? (data['currentStreak'] as num).toInt() : 0;
      final lastTimestamp = data['lastCheckIn'];
      final lastDate = lastTimestamp is Timestamp ? lastTimestamp.toDate() : null;
      int nextStreak = previousStreak;
      bool incremented = false;

      if (lastDate == null) {
        nextStreak = 1;
        incremented = true;
      } else {
        final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final diffDays = nowDay.difference(lastDay).inDays;
        if (diffDays == 1) {
          nextStreak = previousStreak + 1;
          incremented = true;
        } else if (diffDays > 1) {
          nextStreak = 1;
          incremented = true;
        }
      }

      transaction.set(docRef, {
        'currentStreak': nextStreak,
        'lastCheckIn': Timestamp.fromDate(now),
      });

      return StreakSnapshot(
        streakDays: nextStreak,
        lastCheckIn: now,
        incremented: incremented,
      );
    });

    await _ensureReminderSubscription();
    return snapshot;
  }

  Future<void> _ensureReminderSubscription() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await messaging.subscribeToTopic('streak_reminders');
    }
  }
}
