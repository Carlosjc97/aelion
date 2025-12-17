import 'package:flutter_riverpod/legacy.dart';

import 'package:edaptia/services/progress_service.dart';
import 'package:edaptia/services/streak_service.dart';

class StreakState {
  const StreakState({
    this.loading = false,
    this.days = 0,
    this.lastCheckIn,
    this.error,
  });

  final bool loading;
  final int days;
  final DateTime? lastCheckIn;
  final String? error;

  StreakState copyWith({
    bool? loading,
    int? days,
    DateTime? lastCheckIn,
    String? error,
  }) {
    return StreakState(
      loading: loading ?? this.loading,
      days: days ?? this.days,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      error: error,
    );
  }
}

class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier(this._service) : super(const StreakState());

  final StreakService _service;
  final ProgressService _progress = ProgressService();

  Future<StreakSnapshot?> _localSnapshot({required bool increment}) async {
    await _progress.init();
    if (increment) {
      final update = await _progress.tickDailyStreak();
      final now = DateTime.now();
      return StreakSnapshot(
        streakDays: update.streakLength,
        lastCheckIn: now,
        incremented: update.incremented,
      );
    }
    final localDays = _progress.streakCount;
    if (localDays <= 0) return null;
    return StreakSnapshot(
      streakDays: localDays,
      lastCheckIn: _progress.lastStreakCheckIn,
      incremented: false,
    );
  }

  Future<void> refresh(String userId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final snapshot = await _service.fetch(userId);
      if (snapshot.streakDays == 0 && snapshot.lastCheckIn == null) {
        final fallback = await _localSnapshot(increment: false);
        if (fallback != null) {
          state = state.copyWith(
            loading: false,
            days: fallback.streakDays,
            lastCheckIn: fallback.lastCheckIn,
            error: null,
          );
          return;
        }
      }
      state = state.copyWith(
        loading: false,
        days: snapshot.streakDays,
        lastCheckIn: snapshot.lastCheckIn,
        error: null,
      );
    } catch (error) {
      final fallback = await _localSnapshot(increment: false);
      if (fallback != null) {
        state = state.copyWith(
          loading: false,
          days: fallback.streakDays,
          lastCheckIn: fallback.lastCheckIn,
          error: null,
        );
      } else {
        state = state.copyWith(
          loading: false,
          error: error.toString(),
        );
      }
    }
  }

  Future<StreakSnapshot?> checkIn(
    String userId, {
    bool silent = false,
  }) async {
    if (!silent) {
      state = state.copyWith(loading: true, error: null);
    } else {
      state = state.copyWith(error: null);
    }
    try {
      final snapshot = await _service.checkIn(userId);
      state = state.copyWith(
        loading: false,
        days: snapshot.streakDays,
        lastCheckIn: snapshot.lastCheckIn,
        error: null,
      );
      return snapshot;
    } catch (error) {
      final fallback = await _localSnapshot(increment: true);
      if (fallback != null) {
        state = state.copyWith(
          loading: false,
          days: fallback.streakDays,
          lastCheckIn: fallback.lastCheckIn,
          error: null,
        );
        return fallback;
      }
      state = state.copyWith(
        loading: false,
        error: error.toString(),
      );
      return null;
    }
  }
}

final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier(StreakService());
});
