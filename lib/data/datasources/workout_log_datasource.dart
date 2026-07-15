import '../../core/utils/json_helpers.dart';
import '../models/workout_log.dart';
import 'local_database.dart';

/// Hive-backed CRUD for [WorkoutLog] records stored as JSON maps.
class WorkoutLogDatasource {
  WorkoutLogDatasource({LocalDatabase? database})
      : _database = database ?? LocalDatabase.instance;

  final LocalDatabase _database;

  static const String _recordKeyPrefix = 'log_';

  /// Returns every stored workout log, newest first.
  Future<List<WorkoutLog>> getAll() async {
    final box = _database.workoutLogsBox;
    final logs = box.values
        .map((raw) => WorkoutLog.fromJson(deepJsonMap(raw)))
        .toList();
    logs.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return logs;
  }

  /// Returns a single log by id, or null if missing.
  Future<WorkoutLog?> getById(String id) async {
    final box = _database.workoutLogsBox;
    final raw = box.get(_keyFor(id));
    if (raw == null) return null;
    return WorkoutLog.fromJson(deepJsonMap(raw));
  }

  /// Returns only completed workout logs, newest first.
  Future<List<WorkoutLog>> getCompleted() async {
    final all = await getAll();
    return all.where((log) => log.isCompleted).toList();
  }

  /// Returns logs for a specific program day id, newest first.
  Future<List<WorkoutLog>> getByDayId(String dayId) async {
    final all = await getAll();
    return all.where((log) => log.dayId == dayId).toList();
  }

  /// Persists a workout log (insert or update).
  Future<void> save(WorkoutLog log) async {
    final box = _database.workoutLogsBox;
    await box.put(_keyFor(log.id), log.toJson());
  }

  /// Deletes a workout log by id.
  Future<void> delete(String id) async {
    final box = _database.workoutLogsBox;
    await box.delete(_keyFor(id));
  }

  /// Returns the most recent completed weight used for [exerciseId].
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

  /// Replaces all stored logs with [logs] using a snapshot rollback on failure.
  Future<void> replaceAll(List<WorkoutLog> logs) async {
    final box = _database.workoutLogsBox;
    final snapshot = Map<dynamic, dynamic>.from(box.toMap());
    try {
      final next = <String, Map<String, dynamic>>{
        for (final log in logs) _keyFor(log.id): log.toJson(),
      };
      await box.clear();
      if (next.isNotEmpty) await box.putAll(next);
    } catch (_) {
      await box.clear();
      if (snapshot.isNotEmpty) await box.putAll(snapshot);
      rethrow;
    }
  }

  String _keyFor(String id) => '$_recordKeyPrefix$id';
}
