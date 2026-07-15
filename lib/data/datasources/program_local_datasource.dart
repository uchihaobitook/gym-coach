import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../models/program_models.dart';

/// Loads the bundled coach program from assets and caches it in memory.
class ProgramLocalDatasource {
  ProgramLocalDatasource({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  WorkoutProgram? _cachedProgram;

  /// Returns the cached program, loading from assets on first access.
  Future<WorkoutProgram> loadProgram() async {
    if (_cachedProgram != null) return _cachedProgram!;

    final jsonString =
        await _bundle.loadString(AppConstants.workoutProgramAsset);
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    _cachedProgram = WorkoutProgram.fromJson(json);
    return _cachedProgram!;
  }

  /// Synchronously returns the cached program, or null if not yet loaded.
  WorkoutProgram? get cachedProgram => _cachedProgram;

  /// Clears the in-memory cache so the next [loadProgram] re-reads assets.
  void clearCache() {
    _cachedProgram = null;
  }
}
