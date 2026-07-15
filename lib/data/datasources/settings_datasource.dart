import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_settings.dart';
import 'local_database.dart';

/// Persists [AppSettings] via SharedPreferences (primary) with a Hive mirror.
class SettingsDatasource {
  SettingsDatasource({
    LocalDatabase? database,
    this._preferences,
  }) : _database = database ?? LocalDatabase.instance;

  final LocalDatabase _database;
  SharedPreferences? _preferences;

  static const String _hiveMirrorKey = 'app_settings';
  static const String _keyCurrentWeek = 'current_week';
  static const String _keyCurrentDayIndex = 'current_day_index';

  Future<SharedPreferences> get _prefs async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  /// Loads settings from SharedPreferences, falling back to Hive mirror.
  Future<AppSettings> load() async {
    final prefs = await _prefs;

    final hasPrefs = prefs.containsKey(AppConstants.keyThemeMode) ||
        prefs.containsKey(AppConstants.keyUserName);

    if (hasPrefs) {
      return _fromPreferences(prefs);
    }

    final mirror = _database.settingsBox.get(_hiveMirrorKey);
    if (mirror != null) {
      final settings = AppSettings.fromJson(Map<String, dynamic>.from(mirror));
      await _saveToPreferences(prefs, settings);
      return settings;
    }

    return const AppSettings();
  }

  /// Saves settings to SharedPreferences and mirrors to Hive.
  Future<void> save(AppSettings settings) async {
    final prefs = await _prefs;
    await _saveToPreferences(prefs, settings);
    await _database.settingsBox.put(_hiveMirrorKey, settings.toJson());
  }

  /// Clears settings from both SharedPreferences and Hive mirror.
  Future<void> clear() async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.remove(AppConstants.keyThemeMode),
      prefs.remove(AppConstants.keyRestSeconds),
      prefs.remove(AppConstants.keyWeightUnit),
      prefs.remove(AppConstants.keyAmoled),
      prefs.remove(AppConstants.keyUserName),
      prefs.remove(AppConstants.keySoundEnabled),
      prefs.remove(AppConstants.keyVibrateEnabled),
      prefs.remove(AppConstants.keyLanguage),
      prefs.remove(_keyCurrentWeek),
      prefs.remove(_keyCurrentDayIndex),
      _database.settingsBox.delete(_hiveMirrorKey),
    ]);
  }

  AppSettings _fromPreferences(SharedPreferences prefs) {
    return AppSettings(
      themeMode: AppThemeModeSetting.values.firstWhere(
        (e) => e.name == prefs.getString(AppConstants.keyThemeMode),
        orElse: () => AppThemeModeSetting.dark,
      ),
      restSeconds:
          prefs.getInt(AppConstants.keyRestSeconds) ??
              AppConstants.defaultRestSeconds,
      weightUnit: WeightUnit.values.firstWhere(
        (e) => e.name == prefs.getString(AppConstants.keyWeightUnit),
        orElse: () => WeightUnit.kg,
      ),
      amoledBlack: prefs.getBool(AppConstants.keyAmoled) ?? false,
      userName: prefs.getString(AppConstants.keyUserName) ?? 'VĐV',
      soundEnabled: prefs.getBool(AppConstants.keySoundEnabled) ?? true,
      vibrateEnabled: prefs.getBool(AppConstants.keyVibrateEnabled) ?? true,
      currentWeek: prefs.getInt(_keyCurrentWeek) ?? 1,
      currentDayIndex: prefs.getInt(_keyCurrentDayIndex) ?? 0,
      language: AppLanguage.values.firstWhere(
        (e) => e.name == prefs.getString(AppConstants.keyLanguage),
        orElse: () => AppLanguage.vi,
      ),
    );
  }

  Future<void> _saveToPreferences(
    SharedPreferences prefs,
    AppSettings settings,
  ) async {
    await Future.wait([
      prefs.setString(AppConstants.keyThemeMode, settings.themeMode.name),
      prefs.setInt(AppConstants.keyRestSeconds, settings.restSeconds),
      prefs.setString(AppConstants.keyWeightUnit, settings.weightUnit.name),
      prefs.setBool(AppConstants.keyAmoled, settings.amoledBlack),
      prefs.setString(AppConstants.keyUserName, settings.userName),
      prefs.setBool(AppConstants.keySoundEnabled, settings.soundEnabled),
      prefs.setBool(AppConstants.keyVibrateEnabled, settings.vibrateEnabled),
      prefs.setInt(_keyCurrentWeek, settings.currentWeek),
      prefs.setInt(_keyCurrentDayIndex, settings.currentDayIndex),
      prefs.setString(AppConstants.keyLanguage, settings.language.name),
    ]);
  }

  /// Returns settings as a JSON map (for backup export).
  Future<Map<String, dynamic>> exportJson() async {
    final settings = await load();
    return settings.toJson();
  }

  /// Imports settings from a JSON map (for backup restore).
  Future<void> importJson(Map<String, dynamic> json) async {
    await save(AppSettings.fromJson(json));
  }

  /// Debug helper: serializes current settings to a JSON string.
  Future<String> exportJsonString() async {
    return jsonEncode(await exportJson());
  }
}
