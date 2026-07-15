import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/json_helpers.dart';
import '../../core/utils/profile_storage_keys.dart';
import '../models/app_settings.dart';
import 'local_database.dart';

/// Loads/saves merged device + profile settings for one profile.
///
/// Device-global: themeMode, amoledBlack, language (SharedPreferences).
/// Profile-scoped: rest, weight unit, sound, vibration, week/day, userName
/// (Hive key under the active profile).
class SettingsDatasource {
  SettingsDatasource({
    required this.profileId,
    LocalDatabase? database,
    SharedPreferences? preferences,
  })  : _database = database ?? LocalDatabase.instance,
        _preferences = preferences;

  final String profileId;
  final LocalDatabase _database;
  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<AppSettings> load() async {
    final prefs = await _prefs;
    final profileRaw =
        _database.settingsBox.get(ProfileStorageKeys.settings(profileId));

    final profileSettings = profileRaw == null
        ? const AppSettings()
        : AppSettings.fromJson(deepJsonMap(profileRaw));

    return profileSettings.copyWith(
      themeMode: AppThemeModeSetting.values.firstWhere(
        (e) => e.name == prefs.getString(AppConstants.keyThemeMode),
        orElse: () => profileSettings.themeMode,
      ),
      amoledBlack:
          prefs.getBool(AppConstants.keyAmoled) ?? profileSettings.amoledBlack,
      language: AppLanguage.values.firstWhere(
        (e) => e.name == prefs.getString(AppConstants.keyLanguage),
        orElse: () => profileSettings.language,
      ),
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await _prefs;

    // Device-global preferences.
    await Future.wait([
      prefs.setString(AppConstants.keyThemeMode, settings.themeMode.name),
      prefs.setBool(AppConstants.keyAmoled, settings.amoledBlack),
      prefs.setString(AppConstants.keyLanguage, settings.language.name),
    ]);

    // Profile-scoped preferences (store full JSON for backup simplicity).
    await _database.settingsBox.put(
      ProfileStorageKeys.settings(profileId),
      settings.toJson(),
    );
  }

  Future<void> clear() async {
    await _database.settingsBox.delete(ProfileStorageKeys.settings(profileId));
  }

  Future<Map<String, dynamic>> exportJson() async {
    final settings = await load();
    return settings.toJson();
  }

  Future<void> importJson(Map<String, dynamic> json) async {
    await save(AppSettings.fromJson(json));
  }
}
