import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/exercise_history_datasource.dart';
import '../data/datasources/local_database.dart';
import '../data/datasources/measurement_datasource.dart';
import '../data/datasources/settings_datasource.dart';
import '../data/datasources/workout_log_datasource.dart';
import '../data/repositories/backup_repository.dart';
import '../data/repositories/measurement_repository.dart';
import '../data/repositories/program_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/workout_repository.dart';
import 'active_profile_provider.dart';

/// Hive singleton — must be opened via [LocalDatabase.instance.open] before use.
final localDatabaseProvider = Provider<LocalDatabase>(
  (ref) => LocalDatabase.instance,
);

final programRepositoryProvider = Provider<ProgramRepository>(
  (ref) => ProgramRepository(),
);

final workoutLogDatasourceProvider = Provider<WorkoutLogDatasource>((ref) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) {
    throw StateError('No active profile');
  }
  return WorkoutLogDatasource(
    profileId: profileId,
    database: ref.watch(localDatabaseProvider),
  );
});

final measurementDatasourceProvider = Provider<MeasurementDatasource>((ref) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) {
    throw StateError('No active profile');
  }
  return MeasurementDatasource(
    profileId: profileId,
    database: ref.watch(localDatabaseProvider),
  );
});

final exerciseHistoryDatasourceProvider =
    Provider<ExerciseHistoryDatasource>((ref) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) {
    throw StateError('No active profile');
  }
  return ExerciseHistoryDatasource(
    profileId: profileId,
    database: ref.watch(localDatabaseProvider),
  );
});

final settingsDatasourceProvider = Provider<SettingsDatasource>((ref) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) {
    throw StateError('No active profile');
  }
  return SettingsDatasource(
    profileId: profileId,
    database: ref.watch(localDatabaseProvider),
  );
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(
    logDatasource: ref.watch(workoutLogDatasourceProvider),
    historyDatasource: ref.watch(exerciseHistoryDatasourceProvider),
    programRepository: ref.watch(programRepositoryProvider),
  );
});

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  return MeasurementRepository(
    datasource: ref.watch(measurementDatasourceProvider),
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    datasource: ref.watch(settingsDatasourceProvider),
  );
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) {
    throw StateError('No active profile');
  }
  return BackupRepository(
    profileId: profileId,
    settingsDatasource: ref.watch(settingsDatasourceProvider),
    workoutLogDatasource: ref.watch(workoutLogDatasourceProvider),
    measurementDatasource: ref.watch(measurementDatasourceProvider),
    exerciseHistoryDatasource: ref.watch(exerciseHistoryDatasourceProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});
