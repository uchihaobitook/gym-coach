import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/json_helpers.dart';
import '../../core/utils/profile_storage_keys.dart';
import '../models/app_settings.dart';
import '../models/local_profile.dart';
import 'local_database.dart';

/// Profile registry, active profile selection, and legacy migration.
class ProfileDatasource {
  ProfileDatasource({
    LocalDatabase? database,
    SharedPreferences? preferences,
    Uuid? uuid,
  })  : _database = database ?? LocalDatabase.instance,
        _preferences = preferences,
        _uuid = uuid ?? const Uuid();

  final LocalDatabase _database;
  SharedPreferences? _preferences;
  final Uuid _uuid;

  Future<SharedPreferences> get _prefs async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<List<LocalProfile>> getAll() async {
    final box = _database.profilesBox;
    final profiles = box.values
        .map((raw) => LocalProfile.fromJson(deepJsonMap(raw)))
        .toList();
    profiles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return profiles;
  }

  Future<LocalProfile?> getById(String id) async {
    final raw = _database.profilesBox.get(ProfileStorageKeys.profileKey(id));
    if (raw == null) return null;
    return LocalProfile.fromJson(deepJsonMap(raw));
  }

  Future<String?> getActiveProfileId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.keyActiveProfileId);
  }

  Future<void> setActiveProfileId(String profileId) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.keyActiveProfileId, profileId);
  }

  Future<LocalProfile> save(LocalProfile profile) async {
    await _database.profilesBox.put(
      ProfileStorageKeys.profileKey(profile.id),
      profile.toJson(),
    );
    return profile;
  }

  Future<LocalProfile> create({required String name, int? colorSeed}) async {
    final now = DateTime.now();
    final profile = LocalProfile(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? 'VĐV' : name.trim(),
      createdAt: now,
      updatedAt: now,
      colorSeed: colorSeed ?? now.millisecondsSinceEpoch % 12,
    );
    await save(profile);
    return profile;
  }

  Future<LocalProfile> rename(String profileId, String name) async {
    final existing = await getById(profileId);
    if (existing == null) {
      throw StateError('Profile not found: $profileId');
    }
    final updated = existing.copyWith(
      name: name.trim().isEmpty ? existing.name : name.trim(),
      updatedAt: DateTime.now(),
    );
    await save(updated);
    return updated;
  }

  /// Deletes profile metadata and all namespaced user data.
  Future<void> deleteProfileData(String profileId) async {
    await _database.profilesBox.delete(ProfileStorageKeys.profileKey(profileId));

    Future<void> clearScoped(BoxLike box) async {
      final keys = box.keys
          .map((k) => k.toString())
          .where((k) => ProfileStorageKeys.belongsToProfile(k, profileId))
          .toList();
      for (final key in keys) {
        await box.delete(key);
      }
    }

    await clearScoped(_BoxAdapter(_database.settingsBox));
    await clearScoped(_BoxAdapter(_database.workoutLogsBox));
    await clearScoped(_BoxAdapter(_database.measurementsBox));
    await clearScoped(_BoxAdapter(_database.exerciseHistoryBox));
  }

  Future<int> schemaVersion() async {
    final prefs = await _prefs;
    return prefs.getInt(AppConstants.keyProfileSchemaVersion) ?? 0;
  }

  Future<void> setSchemaVersion(int version) async {
    final prefs = await _prefs;
    await prefs.setInt(AppConstants.keyProfileSchemaVersion, version);
  }

  /// Migrates global single-user data into the first profile if needed.
  ///
  /// Safe to call repeatedly — only commits schema version after success.
  Future<void> migrateIfNeeded() async {
    final version = await schemaVersion();
    if (version >= AppConstants.profileSchemaVersion) return;

    final profiles = await getAll();
    final prefs = await _prefs;

    final hasLegacyData = _hasLegacyHiveData() || _hasLegacyPrefs(prefs);

    if (profiles.isEmpty && hasLegacyData) {
      final name = prefs.getString(AppConstants.keyUserName)?.trim();
      final now = DateTime.now();
      final profile = LocalProfile(
        id: 'legacy-default',
        name: (name == null || name.isEmpty) ? 'VĐV' : name,
        createdAt: now,
        updatedAt: now,
        colorSeed: 0,
      );
      await save(profile);
      await _copyLegacyDataToProfile(profile.id, prefs);
      await setActiveProfileId(profile.id);
      await _deleteLegacyKeys(prefs);
    } else if (profiles.isNotEmpty) {
      final active = await getActiveProfileId();
      if (active == null || await getById(active) == null) {
        await setActiveProfileId(profiles.first.id);
      }
    }

    await setSchemaVersion(AppConstants.profileSchemaVersion);
  }

  bool _hasLegacyHiveData() {
    final logs = _database.workoutLogsBox.keys
        .any((k) => ProfileStorageKeys.isLegacyLogKey(k.toString()));
    final measurements = _database.measurementsBox.keys
        .any((k) => ProfileStorageKeys.isLegacyMeasurementKey(k.toString()));
    final exercises = _database.exerciseHistoryBox.keys
        .any((k) => ProfileStorageKeys.isLegacyExerciseKey(k.toString()));
    final settings = _database.settingsBox.keys
        .any((k) => ProfileStorageKeys.isLegacySettingsKey(k.toString()));
    return logs || measurements || exercises || settings;
  }

  bool _hasLegacyPrefs(SharedPreferences prefs) {
    return prefs.containsKey(AppConstants.keyUserName) ||
        prefs.containsKey(AppConstants.keyRestSeconds) ||
        prefs.containsKey(AppConstants.keyWeightUnit) ||
        prefs.containsKey(AppConstants.keySoundEnabled) ||
        prefs.containsKey(AppConstants.keyVibrateEnabled) ||
        prefs.containsKey('current_week') ||
        prefs.containsKey('current_day_index');
  }

  Future<void> _copyLegacyDataToProfile(
    String profileId,
    SharedPreferences prefs,
  ) async {
    // Settings
    final legacySettingsRaw =
        _database.settingsBox.get('app_settings');
    AppSettings settings;
    if (legacySettingsRaw != null) {
      settings = AppSettings.fromJson(deepJsonMap(legacySettingsRaw));
    } else {
      settings = AppSettings(
        themeMode: AppThemeModeSetting.values.firstWhere(
          (e) => e.name == prefs.getString(AppConstants.keyThemeMode),
          orElse: () => AppThemeModeSetting.dark,
        ),
        restSeconds: prefs.getInt(AppConstants.keyRestSeconds) ??
            AppConstants.defaultRestSeconds,
        weightUnit: WeightUnit.values.firstWhere(
          (e) => e.name == prefs.getString(AppConstants.keyWeightUnit),
          orElse: () => WeightUnit.kg,
        ),
        amoledBlack: prefs.getBool(AppConstants.keyAmoled) ?? false,
        userName: prefs.getString(AppConstants.keyUserName) ?? 'VĐV',
        soundEnabled: prefs.getBool(AppConstants.keySoundEnabled) ?? true,
        vibrateEnabled: prefs.getBool(AppConstants.keyVibrateEnabled) ?? true,
        currentWeek: prefs.getInt('current_week') ?? 1,
        currentDayIndex: prefs.getInt('current_day_index') ?? 0,
        language: AppLanguage.values.firstWhere(
          (e) => e.name == prefs.getString(AppConstants.keyLanguage),
          orElse: () => AppLanguage.vi,
        ),
      );
    }

    await _database.settingsBox.put(
      ProfileStorageKeys.settings(profileId),
      settings.toJson(),
    );

    // Ensure device prefs remain for theme/language/amoled.
    await prefs.setString(AppConstants.keyThemeMode, settings.themeMode.name);
    await prefs.setBool(AppConstants.keyAmoled, settings.amoledBlack);
    await prefs.setString(AppConstants.keyLanguage, settings.language.name);

    // Workout logs
    for (final key in _database.workoutLogsBox.keys.toList()) {
      final keyStr = key.toString();
      if (!ProfileStorageKeys.isLegacyLogKey(keyStr)) continue;
      final raw = _database.workoutLogsBox.get(key);
      if (raw == null) continue;
      final logId = keyStr.substring('log_'.length);
      await _database.workoutLogsBox.put(
        ProfileStorageKeys.log(profileId, logId),
        Map<String, dynamic>.from(deepJsonMap(raw)),
      );
    }

    // Measurements
    for (final key in _database.measurementsBox.keys.toList()) {
      final keyStr = key.toString();
      if (!ProfileStorageKeys.isLegacyMeasurementKey(keyStr)) continue;
      final raw = _database.measurementsBox.get(key);
      if (raw == null) continue;
      final id = keyStr.substring('measurement_'.length);
      await _database.measurementsBox.put(
        ProfileStorageKeys.measurement(profileId, id),
        Map<String, dynamic>.from(deepJsonMap(raw)),
      );
    }

    // Exercise history
    for (final key in _database.exerciseHistoryBox.keys.toList()) {
      final keyStr = key.toString();
      if (!ProfileStorageKeys.isLegacyExerciseKey(keyStr)) continue;
      final raw = _database.exerciseHistoryBox.get(key);
      if (raw == null) continue;
      final exerciseId = keyStr.substring('exercise_'.length);
      await _database.exerciseHistoryBox.put(
        ProfileStorageKeys.exercise(profileId, exerciseId),
        Map<String, dynamic>.from(deepJsonMap(raw)),
      );
    }
  }

  Future<void> _deleteLegacyKeys(SharedPreferences prefs) async {
    for (final key in _database.workoutLogsBox.keys.toList()) {
      if (ProfileStorageKeys.isLegacyLogKey(key.toString())) {
        await _database.workoutLogsBox.delete(key);
      }
    }
    for (final key in _database.measurementsBox.keys.toList()) {
      if (ProfileStorageKeys.isLegacyMeasurementKey(key.toString())) {
        await _database.measurementsBox.delete(key);
      }
    }
    for (final key in _database.exerciseHistoryBox.keys.toList()) {
      if (ProfileStorageKeys.isLegacyExerciseKey(key.toString())) {
        await _database.exerciseHistoryBox.delete(key);
      }
    }
    await _database.settingsBox.delete('app_settings');

    await Future.wait([
      prefs.remove(AppConstants.keyRestSeconds),
      prefs.remove(AppConstants.keyWeightUnit),
      prefs.remove(AppConstants.keyUserName),
      prefs.remove(AppConstants.keySoundEnabled),
      prefs.remove(AppConstants.keyVibrateEnabled),
      prefs.remove('current_week'),
      prefs.remove('current_day_index'),
    ]);
  }
}

/// Tiny adapter so delete helpers don't depend on the Hive package type here.
abstract class BoxLike {
  Iterable<dynamic> get keys;
  Future<void> delete(dynamic key);
}

class _BoxAdapter implements BoxLike {
  _BoxAdapter(this._box);
  final dynamic _box;

  @override
  Iterable<dynamic> get keys => _box.keys as Iterable<dynamic>;

  @override
  Future<void> delete(dynamic key) => _box.delete(key) as Future<void>;
}
