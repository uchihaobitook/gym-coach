import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/exercise_history_datasource.dart';
import '../datasources/local_database.dart';
import '../datasources/measurement_datasource.dart';
import '../datasources/settings_datasource.dart';
import '../datasources/workout_log_datasource.dart';
import '../models/measurement_models.dart';
import '../models/workout_log.dart';

/// Machine-readable import failure codes mapped to l10n in the UI.
abstract final class BackupErrorCodes {
  static const cancelled = 'cancelled';
  static const unableToRead = 'unable_to_read';
  static const invalidFormat = 'invalid_format';
}

/// Result of a backup import operation.
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

/// Result of a backup export operation.
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

/// Exports and imports all local app data as a single JSON backup.
class BackupRepository {
  BackupRepository({
    LocalDatabase? database,
    SettingsDatasource? settingsDatasource,
    WorkoutLogDatasource? workoutLogDatasource,
    MeasurementDatasource? measurementDatasource,
    ExerciseHistoryDatasource? exerciseHistoryDatasource,
  })  : _database = database ?? LocalDatabase.instance,
        _settingsDatasource = settingsDatasource ?? SettingsDatasource(),
        _workoutLogDatasource = workoutLogDatasource ?? WorkoutLogDatasource(),
        _measurementDatasource =
            measurementDatasource ?? MeasurementDatasource(),
        _exerciseHistoryDatasource =
            exerciseHistoryDatasource ?? ExerciseHistoryDatasource();

  final LocalDatabase _database;
  final SettingsDatasource _settingsDatasource;
  final WorkoutLogDatasource _workoutLogDatasource;
  final MeasurementDatasource _measurementDatasource;
  final ExerciseHistoryDatasource _exerciseHistoryDatasource;

  static const String _backupVersion = '1.1';
  static const String _exportFileName = 'gym_coach_backup.json';

  /// Builds a JSON map containing all local data.
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

    return {
      'version': _backupVersion,
      'appName': AppConstants.appName,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings,
      'workoutLogs': workoutLogs,
      'bodyMeasurements': measurements,
      'exerciseHistory': exerciseHistory,
    };
  }

  /// Restores all local data from a backup JSON map.
  ///
  /// Snapshots current boxes first so a mid-import crash can be rolled back.
  Future<BackupImportResult> importFromMap(Map<String, dynamic> data) async {
    if (!_looksLikeBackup(data)) {
      return const BackupImportResult(
        success: false,
        error: BackupErrorCodes.invalidFormat,
      );
    }

    final snapshot = await _snapshotAll();

    try {
      final settingsJson = data['settings'];
      if (settingsJson is Map) {
        await _settingsDatasource.importJson(
          Map<String, dynamic>.from(settingsJson),
        );
      }

      final workoutLogsJson = data['workoutLogs'];
      var workoutCount = 0;
      if (workoutLogsJson is List) {
        final logs = workoutLogsJson
            .map((e) => WorkoutLog.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await _workoutLogDatasource.replaceAll(logs);
        workoutCount = logs.length;
      }

      final measurementsJson = data['bodyMeasurements'];
      var measurementCount = 0;
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

      final historyJson = data['exerciseHistory'];
      var profileCount = 0;
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
      await _restoreSnapshot(snapshot);
      return BackupImportResult(success: false, error: e.toString());
    }
  }

  /// Writes a backup file atomically and opens the share sheet.
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

  /// Picks a JSON backup file and imports its contents.
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

  Future<_BoxSnapshot> _snapshotAll() async {
    return _BoxSnapshot(
      settings: _copyBox(_database.settingsBox),
      workoutLogs: _copyBox(_database.workoutLogsBox),
      measurements: _copyBox(_database.measurementsBox),
      exerciseHistory: _copyBox(_database.exerciseHistoryBox),
    );
  }

  Map<String, dynamic> _copyBox(Box box) {
    final copy = <String, dynamic>{};
    for (final key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        copy[key.toString()] = Map<String, dynamic>.from(value);
      } else if (value != null) {
        copy[key.toString()] = value;
      }
    }
    return copy;
  }

  Future<void> _restoreSnapshot(_BoxSnapshot snapshot) async {
    await _restoreBox(_database.settingsBox, snapshot.settings);
    await _restoreBox(_database.workoutLogsBox, snapshot.workoutLogs);
    await _restoreBox(_database.measurementsBox, snapshot.measurements);
    await _restoreBox(_database.exerciseHistoryBox, snapshot.exerciseHistory);
  }

  Future<void> _restoreBox(Box box, Map<String, dynamic> data) async {
    await box.clear();
    if (data.isEmpty) return;
    await box.putAll(data);
  }
}

class _BoxSnapshot {
  const _BoxSnapshot({
    required this.settings,
    required this.workoutLogs,
    required this.measurements,
    required this.exerciseHistory,
  });

  final Map<String, dynamic> settings;
  final Map<String, dynamic> workoutLogs;
  final Map<String, dynamic> measurements;
  final Map<String, dynamic> exerciseHistory;
}
