import '../../core/utils/json_helpers.dart';
import '../models/measurement_models.dart';
import '../models/workout_log.dart';
import 'local_database.dart';

/// Hive-backed storage for per-exercise strength history profiles.
class ExerciseHistoryDatasource {
  ExerciseHistoryDatasource({LocalDatabase? database})
      : _database = database ?? LocalDatabase.instance;

  final LocalDatabase _database;

  static const String _recordKeyPrefix = 'exercise_';

  /// Returns the strength profile for [exerciseId], or null if none exists.
  Future<ExerciseStrengthProfile?> getByExerciseId(String exerciseId) async {
    final box = _database.exerciseHistoryBox;
    final raw = box.get(_keyFor(exerciseId));
    if (raw == null) return null;
    return ExerciseStrengthProfile.fromJson(deepJsonMap(raw));
  }

  /// Returns all stored exercise strength profiles.
  Future<List<ExerciseStrengthProfile>> getAll() async {
    final box = _database.exerciseHistoryBox;
    return box.values
        .map((raw) => ExerciseStrengthProfile.fromJson(deepJsonMap(raw)))
        .toList();
  }

  /// Persists a full strength profile (insert or replace).
  Future<void> save(ExerciseStrengthProfile profile) async {
    final box = _database.exerciseHistoryBox;
    await box.put(_keyFor(profile.exerciseId), profile.toJson());
  }

  /// Appends a history entry when a workout completes.
  Future<void> appendHistoryEntry({
    required LoggedExercise exercise,
    required WorkoutLog workoutLog,
  }) async {
    final completedSets = exercise.sets.where((s) => s.completed).toList();
    if (completedSets.isEmpty) return;

    final bestWeight = completedSets
        .map((s) => s.weight)
        .reduce((a, b) => a > b ? a : b);
    final bestReps = completedSets
        .map((s) => s.reps)
        .reduce((a, b) => a > b ? a : b);
    final bestVolume = completedSets
        .map((s) => s.volume)
        .reduce((a, b) => a > b ? a : b);

    final entry = ExerciseHistoryEntry(
      date: workoutLog.endedAt ?? workoutLog.startedAt,
      bestWeight: bestWeight,
      bestReps: bestReps,
      bestVolume: bestVolume,
      workoutLogId: workoutLog.id,
    );

    final existing = await getByExerciseId(exercise.exerciseId);
    final history = existing?.history ?? <ExerciseHistoryEntry>[];

    final updated = ExerciseStrengthProfile(
      exerciseId: exercise.exerciseId,
      name: exercise.name,
      muscleGroup: exercise.muscleGroup,
      history: [...history, entry],
    );

    await save(updated);
  }

  /// Records history for every exercise in a completed workout.
  Future<void> appendFromWorkoutLog(WorkoutLog workoutLog) async {
    if (!workoutLog.isCompleted) return;
    for (final exercise in workoutLog.exercises) {
      await appendHistoryEntry(exercise: exercise, workoutLog: workoutLog);
    }
  }

  /// Replaces all stored profiles with a snapshot rollback on failure.
  Future<void> replaceAll(List<ExerciseStrengthProfile> profiles) async {
    final box = _database.exerciseHistoryBox;
    final snapshot = Map<dynamic, dynamic>.from(box.toMap());
    try {
      final next = <String, Map<String, dynamic>>{
        for (final p in profiles) _keyFor(p.exerciseId): p.toJson(),
      };
      await box.clear();
      if (next.isNotEmpty) await box.putAll(next);
    } catch (_) {
      await box.clear();
      if (snapshot.isNotEmpty) await box.putAll(snapshot);
      rethrow;
    }
  }

  String _keyFor(String exerciseId) => '$_recordKeyPrefix$exerciseId';
}
