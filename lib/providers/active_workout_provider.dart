import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../data/models/program_models.dart';
import '../data/models/workout_log.dart';
import '../data/repositories/workout_repository.dart';
import 'program_provider.dart';
import 'repository_providers.dart';
import 'settings_provider.dart';
import 'workout_logs_provider.dart';

final activeWorkoutProvider =
    NotifierProvider<ActiveWorkoutNotifier, WorkoutLog?>(
  ActiveWorkoutNotifier.new,
);

class ActiveWorkoutNotifier extends Notifier<WorkoutLog?> {
  WorkoutRepository get _repo => ref.read(workoutRepositoryProvider);

  @override
  WorkoutLog? build() {
    ref.listen(activeSessionProvider, (_, next) {
      if (next != null && state == null) {
        state = next;
      }
    });
    return ref.read(activeSessionProvider);
  }

  /// Starts (or resumes) the session for [day].
  ///
  /// Only one incomplete session may ever exist:
  /// - An incomplete log for the SAME day is resumed as-is.
  /// - An incomplete log for a DIFFERENT day is an orphan and is always
  ///   deleted before starting the new one, regardless of [forceNew].
  /// - [forceNew] forces a brand new session even if an incomplete log for
  ///   the same day already exists (discarding its progress).
  Future<void> startFromDay(
    WorkoutDayTemplate day,
    int weekNumber, {
    bool forceNew = false,
  }) async {
    final existing = ref.read(activeSessionProvider);

    if (existing != null) {
      if (existing.dayId == day.id && !forceNew) {
        state = existing;
        return;
      }
      // Either an orphaned session for another day, or an explicit restart
      // of the same day — either way there must only ever be one active
      // session, so remove the stale one first.
      await ref.read(workoutLogsProvider.notifier).delete(existing.id);
    }

    final log = await _repo.startWorkout(day: day, weekNumber: weekNumber);
    state = log;
    ref.invalidate(workoutLogsProvider);
  }

  Future<void> resumeSession(WorkoutLog log) async {
    state = log;
  }

  /// Toggles the completion of a set, identified by [exerciseId] (not
  /// index, so reordering/filtering never causes cross-exercise mistakes).
  ///
  /// Returns the rest duration (seconds) that the caller should start a
  /// rest timer for when the set has just become completed, or `null` when
  /// the set was un-completed (or nothing changed). This notifier never
  /// starts the rest timer itself — the UI owns that decision.
  Future<int?> toggleSetComplete(String exerciseId, int setIndex) async {
    final log = state;
    if (log == null) return null;

    final exerciseIndex =
        log.exercises.indexWhere((e) => e.exerciseId == exerciseId);
    if (exerciseIndex == -1) return null;

    final exercise = log.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return null;

    final set = exercise.sets[setIndex];
    final nowCompleted = !set.completed;

    final updatedSets = [...exercise.sets];
    updatedSets[setIndex] = set.copyWith(completed: nowCompleted);

    final updatedExercises = [...log.exercises];
    updatedExercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);

    final updated = log.copyWith(exercises: updatedExercises);
    state = updated;
    await _repo.saveLog(updated);
    ref.read(workoutLogsProvider.notifier).patchLog(updated);

    if (!nowCompleted) return null;

    return _restSecondsFor(log: log, exerciseId: exerciseId);
  }

  Future<void> updateWeight(String exerciseId, int setIndex, double weight) =>
      _updateSet(exerciseId, setIndex, (set) => set.copyWith(weight: weight));

  Future<void> updateReps(String exerciseId, int setIndex, int reps) =>
      _updateSet(exerciseId, setIndex, (set) => set.copyWith(reps: reps));

  Future<void> updateNotes(String exerciseId, String notes) async {
    final log = state;
    if (log == null) return;

    final exerciseIndex =
        log.exercises.indexWhere((e) => e.exerciseId == exerciseId);
    if (exerciseIndex == -1) return;

    final updatedExercises = [...log.exercises];
    updatedExercises[exerciseIndex] =
        log.exercises[exerciseIndex].copyWith(notes: notes);

    final updated = log.copyWith(exercises: updatedExercises);
    state = updated;
    await _repo.saveLog(updated);
    ref.read(workoutLogsProvider.notifier).patchLog(updated);
  }

  /// Completes the workout and clears session state. Does NOT navigate —
  /// the caller is responsible for pushing the summary screen with the
  /// returned log's id.
  Future<WorkoutLog?> finishWorkout(String notes) async {
    final log = state;
    if (log == null) return null;

    ref.read(restTimerServiceProvider).cancel();

    final withNotes = log.copyWith(
      notes: notes,
      prCount: _countPersonalRecords(log),
      endedAt: DateTime.now(),
    );
    final completed =
        await ref.read(workoutLogsProvider.notifier).complete(withNotes);
    state = null;
    return completed;
  }

  /// Deletes the in-progress session entirely and clears local state.
  Future<void> discardSession() async {
    final log = state;
    if (log == null) return;

    ref.read(restTimerServiceProvider).cancel();
    await ref.read(workoutLogsProvider.notifier).delete(log.id);
    state = null;
  }

  void clearSession() => state = null;

  int _countPersonalRecords(WorkoutLog log) {
    var prs = 0;
    for (final exercise in log.exercises) {
      final prev = exercise.previousBestWeight;
      final threshold = (prev == null || prev <= 0) ? 0.0 : prev;
      final isPr = exercise.sets.any(
        (set) => set.completed && set.weight > threshold,
      );
      if (isPr) prs++;
    }
    return prs;
  }

  Future<void> _updateSet(
    String exerciseId,
    int setIndex,
    LoggedSet Function(LoggedSet) transform,
  ) async {
    final log = state;
    if (log == null) return;

    final exerciseIndex =
        log.exercises.indexWhere((e) => e.exerciseId == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = log.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;

    final updatedSets = [...exercise.sets];
    updatedSets[setIndex] = transform(exercise.sets[setIndex]);

    final updatedExercises = [...log.exercises];
    updatedExercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);

    final updated = log.copyWith(exercises: updatedExercises);
    state = updated;
    await _repo.saveLog(updated);
    ref.read(workoutLogsProvider.notifier).patchLog(updated);
  }

  /// Resolves the rest duration for [exerciseId] from the day template,
  /// falling back to the user's default rest setting.
  Future<int> _restSecondsFor({
    required WorkoutLog log,
    required String exerciseId,
  }) async {
    var restSeconds = ref.read(settingsProvider).value?.restSeconds ??
        AppConstants.defaultRestSeconds;

    try {
      final program = await ref.read(workoutProgramProvider.future);
      final day = program.findDay(log.dayId);
      if (day != null) {
        ExerciseTemplate? template;
        for (final e in day.exercises) {
          if (e.id == exerciseId) {
            template = e;
            break;
          }
        }
        if (template != null) {
          restSeconds = template.restSeconds;
        }
      }
    } catch (_) {
      // Fall back to global rest setting.
    }

    return restSeconds;
  }
}
