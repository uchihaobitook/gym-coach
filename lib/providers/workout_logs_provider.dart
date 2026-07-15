import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/stats_calculator.dart';
import '../data/models/workout_log.dart';
import '../data/repositories/workout_repository.dart';
import 'exercise_strength_provider.dart';
import 'active_profile_provider.dart';
import 'repository_providers.dart';

final workoutLogsProvider =
    AsyncNotifierProvider<WorkoutLogsNotifier, List<WorkoutLog>>(
  WorkoutLogsNotifier.new,
);

/// Aggregated statistics derived from all stored logs.
final statsProvider = Provider<WorkoutStats>((ref) {
  final logs = ref.watch(workoutLogsProvider).value ?? const [];
  return StatsCalculator.calculate(logs);
});

/// Whether the latest log for [dayId] is a completed session.
final isDayCompletedProvider = Provider.family<bool, String>((ref, dayId) {
  final logs = ref.watch(workoutLogsProvider).value ?? const <WorkoutLog>[];
  return logs.any((l) => l.dayId == dayId && l.isCompleted);
});

/// Completion percent for the most recent log of a program [dayId].
final dayCompletionPercentProvider = Provider.family<double, String>(
  (ref, dayId) {
    final logs = ref.watch(workoutLogsProvider).value ?? const <WorkoutLog>[];
    final dayLogs = logs.where((l) => l.dayId == dayId).toList();
    if (dayLogs.isEmpty) return 0;
    final latest = dayLogs.first;
    return latest.isCompleted ? 100.0 : latest.completionPercent;
  },
);

/// The in-progress workout session persisted in storage, if any.
final activeSessionProvider = Provider<WorkoutLog?>((ref) {
  final logs = ref.watch(workoutLogsProvider).value;
  if (logs == null) return null;
  for (final log in logs) {
    if (!log.isCompleted) return log;
  }
  return null;
});

class WorkoutLogsNotifier extends AsyncNotifier<List<WorkoutLog>> {
  WorkoutRepository get _repo => ref.read(workoutRepositoryProvider);

  @override
  Future<List<WorkoutLog>> build() async {
    await ref.watch(profileBootstrapProvider.future);
    return _repo.getAllLogs();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.getAllLogs);
  }

  Future<void> save(WorkoutLog log) async {
    await _repo.saveLog(log);
    await refresh();
  }

  /// Updates [log] within the in-memory list without a full disk reload.
  /// Used for high-frequency edits (weight/reps/notes keystrokes) where a
  /// full [refresh] would be wasteful.
  void patchLog(WorkoutLog log) {
    final logs = state.value;
    if (logs == null) return;
    final index = logs.indexWhere((l) => l.id == log.id);
    if (index == -1) return;
    final updated = [...logs];
    updated[index] = log;
    state = AsyncValue.data(updated);
  }

  Future<void> delete(String id) async {
    await _repo.deleteLog(id);
    await refresh();
  }

  Future<WorkoutLog> complete(WorkoutLog log) async {
    final completed = await _repo.completeWorkout(log);
    await refresh();
    ref.invalidate(allExerciseStrengthProfilesProvider);
    return completed;
  }

  /// Returns completion percent for [dayId] from the latest log.
  double dayCompletionPercent(String dayId) {
    final logs = state.value ?? const [];
    final dayLogs = logs.where((l) => l.dayId == dayId).toList();
    if (dayLogs.isEmpty) return 0;
    return dayLogs.first.completionPercent;
  }

  bool isDayCompleted(String dayId) {
    final logs = state.value ?? const [];
    return logs.any((l) => l.dayId == dayId && l.isCompleted);
  }

  WorkoutLog? latestLogForDay(String dayId) {
    final logs = state.value ?? const [];
    final filtered = logs.where((l) => l.dayId == dayId).toList();
    if (filtered.isEmpty) return null;
    return filtered.first;
  }
}
