import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

/// Central Hive access for Gym Coach offline storage.
///
/// All boxes store [Map<String, dynamic>] JSON-compatible maps — no TypeAdapters.
class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  bool _isOpen = false;

  Box? _settingsBox;
  Box? _workoutLogsBox;
  Box? _measurementsBox;
  Box? _exerciseHistoryBox;
  Box? _profilesBox;

  bool get isOpen => _isOpen;

  Box get settingsBox {
    _assertOpen();
    return _settingsBox!;
  }

  Box get workoutLogsBox {
    _assertOpen();
    return _workoutLogsBox!;
  }

  Box get measurementsBox {
    _assertOpen();
    return _measurementsBox!;
  }

  Box get exerciseHistoryBox {
    _assertOpen();
    return _exerciseHistoryBox!;
  }

  Box get profilesBox {
    _assertOpen();
    return _profilesBox!;
  }

  /// Initializes Hive and opens all application boxes.
  Future<void> open() async {
    if (_isOpen) return;

    await Hive.initFlutter();

    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _workoutLogsBox = await Hive.openBox(AppConstants.workoutLogsBox);
    _measurementsBox = await Hive.openBox(AppConstants.measurementsBox);
    _exerciseHistoryBox = await Hive.openBox(AppConstants.exerciseHistoryBox);
    _profilesBox = await Hive.openBox(AppConstants.profilesBox);

    // Legacy empty box from earlier builds — drop if present.
    if (await Hive.boxExists(AppConstants.legacyProgramProgressBox)) {
      await Hive.deleteBoxFromDisk(AppConstants.legacyProgramProgressBox);
    }

    _isOpen = true;
  }

  /// Closes all open Hive boxes.
  Future<void> close() async {
    if (!_isOpen) return;

    await _settingsBox?.close();
    await _workoutLogsBox?.close();
    await _measurementsBox?.close();
    await _exerciseHistoryBox?.close();
    await _profilesBox?.close();

    _settingsBox = null;
    _workoutLogsBox = null;
    _measurementsBox = null;
    _exerciseHistoryBox = null;
    _profilesBox = null;
    _isOpen = false;
  }

  /// Clears every application box without closing Hive.
  Future<void> clearAll() async {
    _assertOpen();
    await Future.wait([
      _settingsBox!.clear(),
      _workoutLogsBox!.clear(),
      _measurementsBox!.clear(),
      _exerciseHistoryBox!.clear(),
      _profilesBox!.clear(),
    ]);
  }

  void _assertOpen() {
    if (!_isOpen) {
      throw StateError(
        'LocalDatabase is not open. Call LocalDatabase.instance.open() first.',
      );
    }
  }
}
