import '../../core/utils/json_helpers.dart';
import '../../core/utils/profile_storage_keys.dart';
import '../models/workout_log.dart';
import 'local_database.dart';

/// Hive-backed CRUD for [WorkoutLog] records scoped to one profile.
class WorkoutLogDatasource {
  WorkoutLogDatasource({
    required this.profileId,
    LocalDatabase? database,
  }) : _database = database ?? LocalDatabase.instance;

  final String profileId;
  final LocalDatabase _database;

  /// Returns every stored workout log for this profile, newest first.
  Future<List<WorkoutLog>> getAll() async {
    final box = _database.workoutLogsBox;
    final logs = <WorkoutLog>[];
    for (final key in box.keys) {
      final keyStr = key.toString();
      if (!ProfileStorageKeys.belongsToProfile(keyStr, profileId)) continue;
      final raw = box.get(key);
      if (raw == null) continue;
      logs.add(WorkoutLog.fromJson(deepJsonMap(raw)));
    }
    logs.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return logs;
  }

  Future<WorkoutLog?> getById(String id) async {
    final raw = _database.workoutLogsBox.get(_keyFor(id));
    if (raw == null) return null;
    return WorkoutLog.fromJson(deepJsonMap(raw));
  }

  Future<List<WorkoutLog>> getCompleted() async {
    final all = await getAll();
    return all.where((log) => log.isCompleted).toList();
  }

  Future<List<WorkoutLog>> getByDayId(String dayId) async {
    final all = await getAll();
    return all.where((log) => log.dayId == dayId).toList();
  }

  Future<void> save(WorkoutLog log) async {
    await _database.workoutLogsBox.put(_keyFor(log.id), log.toJson());
  }

  Future<void> delete(String id) async {
    await _database.workoutLogsBox.delete(_keyFor(id));
  }

  Future<double?> getLatestForExercise(String exerciseId) async {
    final completed = await getCompleted();
    for (final log in completed) {
      for (final exercise in log.exercises) {
        if (exercise.exerciseId != exerciseId) continue;
        final completedSets =
            exercise.sets.where((s) => s.completed).toList();
        if (completedSets.isEmpty) continue;
        return completedSets
            .map((s) => s.weight)
            .reduce((a, b) => a > b ? a : b);
      }
    }
    return null;
  }

  /// Replaces only this profile's logs (does not touch other profiles).
  Future<void> replaceAll(List<WorkoutLog> logs) async {
    final box = _database.workoutLogsBox;
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
      if (logs.isEmpty) return;
      await box.putAll({
        for (final log in logs) _keyFor(log.id): log.toJson(),
      });
    } catch (_) {
      for (final key in profileKeys) {
        await box.delete(key);
      }
      if (snapshot.isNotEmpty) await box.putAll(snapshot);
      rethrow;
    }
  }

  String _keyFor(String id) => ProfileStorageKeys.log(profileId, id);
}
