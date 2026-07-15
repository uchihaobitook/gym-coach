import 'package:uuid/uuid.dart';

import '../../core/utils/calorie_estimator.dart';
import '../datasources/exercise_history_datasource.dart';
import '../datasources/workout_log_datasource.dart';
import '../models/program_models.dart';
import '../models/workout_log.dart';
import 'program_repository.dart';

/// Repository orchestrating workout session persistence and history.
class WorkoutRepository {
  WorkoutRepository({
    WorkoutLogDatasource? logDatasource,
    ExerciseHistoryDatasource? historyDatasource,
    ProgramRepository? programRepository,
    Uuid? uuid,
  })  : _logDatasource = logDatasource ?? WorkoutLogDatasource(),
        _historyDatasource = historyDatasource ?? ExerciseHistoryDatasource(),
        _programRepository = programRepository ?? ProgramRepository(),
        _uuid = uuid ?? const Uuid();

  final WorkoutLogDatasource _logDatasource;
  final ExerciseHistoryDatasource _historyDatasource;
  final ProgramRepository _programRepository;
  final Uuid _uuid;

  Future<List<WorkoutLog>> getAllLogs() => _logDatasource.getAll();

  Future<WorkoutLog?> getLogById(String id) => _logDatasource.getById(id);

  Future<List<WorkoutLog>> getCompletedLogs() => _logDatasource.getCompleted();

  Future<List<WorkoutLog>> getLogsByDayId(String dayId) =>
      _logDatasource.getByDayId(dayId);

  Future<double?> getPreviousWeight(String exerciseId) =>
      _logDatasource.getLatestForExercise(exerciseId);

  /// Starts a new in-progress workout for the given day template.
  Future<WorkoutLog> startWorkout({
    required WorkoutDayTemplate day,
    required int weekNumber,
  }) async {
    final exercises = <LoggedExercise>[];
    for (final template in day.exercises) {
      final previousWeight =
          await _logDatasource.getLatestForExercise(template.id);
      exercises.add(
        LoggedExercise(
          exerciseId: template.id,
          name: template.name,
          muscleGroup: template.muscleGroup,
          isDropSet: template.isDropSet,
          isFail: template.isFail,
          previousBestWeight: previousWeight,
          sets: List.generate(
            template.sets,
            (index) => LoggedSet(
              setNumber: index + 1,
              reps: 0,
              weight: previousWeight ?? 0,
              completed: false,
              isDropSet: template.isDropSet,
              isFail: template.isFail,
            ),
          ),
        ),
      );
    }

    final log = WorkoutLog(
      id: _uuid.v4(),
      dayId: day.id,
      dayName: day.name,
      muscleGroup: day.muscleGroup,
      weekNumber: weekNumber,
      dayNumber: day.dayNumber,
      startedAt: DateTime.now(),
      exercises: exercises,
    );

    await _logDatasource.save(log);
    return log;
  }

  /// Persists an in-progress workout log.
  Future<void> saveLog(WorkoutLog log) => _logDatasource.save(log);

  /// Marks a workout complete, estimates calories, and records exercise history.
  Future<WorkoutLog> completeWorkout(WorkoutLog log) async {
    final endedAt = log.endedAt ?? DateTime.now();
    final duration = endedAt.difference(log.startedAt);
    final calories = CalorieEstimator.estimate(duration);

    final completed = log.copyWith(
      endedAt: endedAt,
      isCompleted: true,
      caloriesEstimate: calories,
    );

    await _logDatasource.save(completed);
    await _historyDatasource.appendFromWorkoutLog(completed);
    return completed;
  }

  Future<void> deleteLog(String id) => _logDatasource.delete(id);

  /// Resolves a day template from the program by id.
  Future<WorkoutDayTemplate?> findDayTemplate(String dayId) =>
      _programRepository.findDay(dayId);
}
