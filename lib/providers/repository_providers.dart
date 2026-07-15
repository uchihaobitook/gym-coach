import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/rest_timer_service.dart';
import '../data/datasources/exercise_history_datasource.dart';
import '../data/datasources/local_database.dart';
import '../data/repositories/backup_repository.dart';
import '../data/repositories/measurement_repository.dart';
import '../data/repositories/program_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/workout_repository.dart';

/// Hive singleton — must be opened via [LocalDatabase.instance.open] before use.
final localDatabaseProvider = Provider<LocalDatabase>(
  (ref) => LocalDatabase.instance,
);

final programRepositoryProvider = Provider<ProgramRepository>(
  (ref) => ProgramRepository(),
);

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(
    programRepository: ref.watch(programRepositoryProvider),
  ),
);

final measurementRepositoryProvider = Provider<MeasurementRepository>(
  (ref) => MeasurementRepository(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(
    database: ref.watch(localDatabaseProvider),
  ),
);

final exerciseHistoryDatasourceProvider = Provider<ExerciseHistoryDatasource>(
  (ref) => ExerciseHistoryDatasource(
    database: ref.watch(localDatabaseProvider),
  ),
);

final restTimerServiceProvider = Provider<RestTimerService>((ref) {
  final service = RestTimerService();
  ref.onDispose(service.dispose);
  return service;
});
