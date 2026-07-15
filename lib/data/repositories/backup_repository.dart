import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/exercise_history_datasource.dart';
import '../datasources/measurement_datasource.dart';
import '../datasources/settings_datasource.dart';
import '../datasources/workout_log_datasource.dart';
import '../models/local_profile.dart';
import '../models/measurement_models.dart';
import '../models/workout_log.dart';
import 'profile_repository.dart';

/// Machine-readable import failure codes mapped to l10n in the UI.
abstract final class BackupErrorCodes {
  static const cancelled = 'cancelled';
  static const unableToRead = 'unable_to_read';
  static const invalidFormat = 'invalid_format';
}

class BackupImportResult {
  const BackupImportResult({
    required this.success,
    this.error,
    this.workoutLogCount = 0,
    this.measurementCount = 0,
    this.exerciseProfileCount = 0,
  });

  final bool success;
  final String? error;
  final int workoutLogCount;
  final int measurementCount;
  final int exerciseProfileCount;

  bool get wasCancelled => error == BackupErrorCodes.cancelled;
}

class BackupExportResult {
  const BackupExportResult({
    required this.success,
    this.filePath,
    this.error,
  });

  final bool success;
  final String? filePath;
  final String? error;
}

/// Exports and imports the **active profile** only.
class BackupRepository {
  BackupRepository({
    required this.profileId,
    required SettingsDatasource settingsDatasource,
    required WorkoutLogDatasource workoutLogDatasource,
    required MeasurementDatasource measurementDatasource,
    required ExerciseHistoryDatasource exerciseHistoryDatasource,
    ProfileRepository? profileRepository,
  })  : _settingsDatasource = settingsDatasource,
        _workoutLogDatasource = workoutLogDatasource,
        _measurementDatasource = measurementDatasource,
        _exerciseHistoryDatasource = exerciseHistoryDatasource,
        _profileRepository = profileRepository ?? ProfileRepository();

  final String profileId;
  final SettingsDatasource _settingsDatasource;
  final WorkoutLogDatasource _workoutLogDatasource;
  final MeasurementDatasource _measurementDatasource;
  final ExerciseHistoryDatasource _exerciseHistoryDatasource;
  final ProfileRepository _profileRepository;

  static const String _backupVersion = '2.0';
  static const String _exportFileName = 'gym_coach_backup.json';

  Future<Map<String, dynamic>> exportToMap() async {
    final settings = await _settingsDatasource.exportJson();
    final workoutLogs = (await _workoutLogDatasource.getAll())
        .map((l) => l.toJson())
        .toList();
    final measurements = (await _measurementDatasource.getAll())
        .map((m) => m.toJson())
        .toList();
    final exerciseHistory = (await _exerciseHistoryDatasource.getAll())
        .map((p) => p.toJson())
        .toList();
    final profile = await _profileRepository.getById(profileId);

    return {
      'version': _backupVersion,
      'scope': 'activeProfile',
      'appName': AppConstants.appName,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile?.toJson(),
      'settings': settings,
      'workoutLogs': workoutLogs,
      'bodyMeasurements': measurements,
      'exerciseHistory': exerciseHistory,
    };
  }

  /// Restores into the active profile only (does not clear other profiles).
  Future<BackupImportResult> importFromMap(Map<String, dynamic> data) async {
    if (!_looksLikeBackup(data)) {
      return const BackupImportResult(
        success: false,
        error: BackupErrorCodes.invalidFormat,
      );
    }

    final logsSnapshot = await _workoutLogDatasource.getAll();
    final measurementsSnapshot = await _measurementDatasource.getAll();
    final historySnapshot = await _exerciseHistoryDatasource.getAll();
    final settingsSnapshot = await _settingsDatasource.exportJson();

    try {
      final settingsJson = data['settings'];
      if (settingsJson is Map) {
        await _settingsDatasource.importJson(
          Map<String, dynamic>.from(settingsJson),
        );
      }

      final profileJson = data['profile'];
      if (profileJson is Map) {
        final imported = LocalProfile.fromJson(
          Map<String, dynamic>.from(profileJson),
        );
        final existing = await _profileRepository.getById(profileId);
        if (existing != null) {
          await _profileRepository.save(
            existing.copyWith(
              name: imported.name,
              updatedAt: DateTime.now(),
              colorSeed: imported.colorSeed,
            ),
          );
        }
      }

      var workoutCount = 0;
      final workoutLogsJson = data['workoutLogs'];
      if (workoutLogsJson is List) {
        final logs = workoutLogsJson
            .map((e) => WorkoutLog.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await _workoutLogDatasource.replaceAll(logs);
        workoutCount = logs.length;
      }

      var measurementCount = 0;
      final measurementsJson = data['bodyMeasurements'];
      if (measurementsJson is List) {
        final measurements = measurementsJson
            .map(
              (e) => BodyMeasurement.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
        await _measurementDatasource.replaceAll(measurements);
        measurementCount = measurements.length;
      }

      var profileCount = 0;
      final historyJson = data['exerciseHistory'];
      if (historyJson is List) {
        final profiles = historyJson
            .map(
              (e) => ExerciseStrengthProfile.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
        await _exerciseHistoryDatasource.replaceAll(profiles);
        profileCount = profiles.length;
      }

      return BackupImportResult(
        success: true,
        workoutLogCount: workoutCount,
        measurementCount: measurementCount,
        exerciseProfileCount: profileCount,
      );
    } catch (e) {
      await _workoutLogDatasource.replaceAll(logsSnapshot);
      await _measurementDatasource.replaceAll(measurementsSnapshot);
      await _exerciseHistoryDatasource.replaceAll(historySnapshot);
      await _settingsDatasource.importJson(settingsSnapshot);
      return BackupImportResult(success: false, error: e.toString());
    }
  }

  Future<BackupExportResult> exportAndShare({
    required String subject,
    required String text,
  }) async {
    try {
      final data = await exportToMap();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final directory = await getApplicationDocumentsDirectory();
      final target = File('${directory.path}/$_exportFileName');
      final temp = File('${directory.path}/$_exportFileName.tmp');
      await temp.writeAsString(jsonString, flush: true);
      if (await target.exists()) {
        await target.delete();
      }
      await temp.rename(target.path);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(target.path)],
          subject: subject,
          text: text,
        ),
      );

      return BackupExportResult(success: true, filePath: target.path);
    } catch (e) {
      return BackupExportResult(success: false, error: e.toString());
    }
  }

  Future<BackupImportResult> importFromFilePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return const BackupImportResult(
          success: false,
          error: BackupErrorCodes.cancelled,
        );
      }

      final file = result.files.first;
      String jsonString;

      if (file.bytes != null) {
        jsonString = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        jsonString = await File(file.path!).readAsString();
      } else {
        return const BackupImportResult(
          success: false,
          error: BackupErrorCodes.unableToRead,
        );
      }

      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return const BackupImportResult(
          success: false,
          error: BackupErrorCodes.invalidFormat,
        );
      }
      return importFromMap(Map<String, dynamic>.from(decoded));
    } catch (e) {
      return BackupImportResult(success: false, error: e.toString());
    }
  }

  bool _looksLikeBackup(Map<String, dynamic> data) {
    return data.containsKey('workoutLogs') ||
        data.containsKey('settings') ||
        data.containsKey('bodyMeasurements') ||
        data.containsKey('exerciseHistory');
  }
}
