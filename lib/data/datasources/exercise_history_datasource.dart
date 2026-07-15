import '../../core/utils/json_helpers.dart';
import '../../core/utils/profile_storage_keys.dart';
import '../models/measurement_models.dart';
import '../models/workout_log.dart';
import 'local_database.dart';

/// Hive-backed strength history scoped to one profile.
class ExerciseHistoryDatasource {
  ExerciseHistoryDatasource({
    required this.profileId,
    LocalDatabase? database,
  }) : _database = database ?? LocalDatabase.instance;

  final String profileId;
  final LocalDatabase _database;

  Future<ExerciseStrengthProfile?> getByExerciseId(String exerciseId) async {
    final raw = _database.exerciseHistoryBox.get(_keyFor(exerciseId));
    if (raw == null) return null;
    return ExerciseStrengthProfile.fromJson(deepJsonMap(raw));
  }

  Future<List<ExerciseStrengthProfile>> getAll() async {
    final box = _database.exerciseHistoryBox;
    final profiles = <ExerciseStrengthProfile>[];
    for (final key in box.keys) {
      final keyStr = key.toString();
      if (!ProfileStorageKeys.belongsToProfile(keyStr, profileId)) continue;
      final raw = box.get(key);
      if (raw == null) continue;
      profiles.add(ExerciseStrengthProfile.fromJson(deepJsonMap(raw)));
    }
    return profiles;
  }

  Future<void> save(ExerciseStrengthProfile profile) async {
    await _database.exerciseHistoryBox.put(
      _keyFor(profile.exerciseId),
      profile.toJson(),
    );
  }

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

  Future<void> appendFromWorkoutLog(WorkoutLog workoutLog) async {
    if (!workoutLog.isCompleted) return;
    for (final exercise in workoutLog.exercises) {
      await appendHistoryEntry(exercise: exercise, workoutLog: workoutLog);
    }
  }

  /// Replaces only this profile's strength profiles.
  Future<void> replaceAll(List<ExerciseStrengthProfile> profiles) async {
    final box = _database.exerciseHistoryBox;
    final profileKeys = box.keys
        .map((k) => k.toString())
        .where((k) => ProfileStorageKeys.belongsToProfile(k, profileId))
        .toList();
    final snapshot = <String, dynamic>{
      for (final key in profileKeys) key: box.get(key),
    };

    try {
      for (final key in profileKeys) {
        await box.delete(key);
      }
      if (profiles.isEmpty) return;
      await box.putAll({
        for (final p in profiles) _keyFor(p.exerciseId): p.toJson(),
      });
    } catch (_) {
      for (final key in profileKeys) {
        await box.delete(key);
      }
      if (snapshot.isNotEmpty) await box.putAll(snapshot);
      rethrow;
    }
  }

  String _keyFor(String exerciseId) =>
      ProfileStorageKeys.exercise(profileId, exerciseId);
}
