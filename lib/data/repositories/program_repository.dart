import '../datasources/program_local_datasource.dart';
import '../models/program_models.dart';

/// Repository for accessing the bundled coach workout program.
class ProgramRepository {
  ProgramRepository({ProgramLocalDatasource? datasource})
      : _datasource = datasource ?? ProgramLocalDatasource();

  final ProgramLocalDatasource _datasource;

  /// Loads and returns the full workout program.
  Future<WorkoutProgram> getProgram() => _datasource.loadProgram();

  /// Returns the cached program without loading from assets.
  WorkoutProgram? get cachedProgram => _datasource.cachedProgram;

  /// Finds a workout day template by its id across all weeks.
  Future<WorkoutDayTemplate?> findDay(String dayId) async {
    final program = await getProgram();
    return program.findDay(dayId);
  }

  /// Finds a week template by week number.
  Future<WeekProgramTemplate?> findWeek(int weekNumber) async {
    final program = await getProgram();
    return program.findWeek(weekNumber);
  }

  /// Returns all workout day templates flattened across weeks.
  Future<List<WorkoutDayTemplate>> getAllDays() async {
    final program = await getProgram();
    return program.weeks
        .expand((week) => week.days)
        .toList(growable: false);
  }

  /// Clears the in-memory program cache.
  void clearCache() => _datasource.clearCache();
}
