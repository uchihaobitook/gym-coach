/// App-wide constants for Gym Coach.
abstract final class AppConstants {
  static const String appName = 'Gym Coach';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String settingsBox = 'settings';
  static const String workoutLogsBox = 'workout_logs';
  static const String measurementsBox = 'body_measurements';
  static const String exerciseHistoryBox = 'exercise_history';
  static const String profilesBox = 'profiles';

  /// Removed in v1.1 — progress lives in [AppSettings]. Kept only to delete
  /// leftover disks from older installs.
  static const String legacyProgramProgressBox = 'program_progress';

  // SharedPreferences keys — device-global
  static const String keyThemeMode = 'theme_mode';
  static const String keyAmoled = 'amoled_black';
  static const String keyLanguage = 'language';
  static const String keyActiveProfileId = 'active_profile_id';
  static const String keyProfileSchemaVersion = 'profile_schema_version';

  // Legacy SharedPreferences keys (pre multi-profile)
  static const String keyRestSeconds = 'rest_seconds';
  static const String keyWeightUnit = 'weight_unit';
  static const String keyUserName = 'user_name';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrateEnabled = 'vibrate_enabled';

  /// Schema version for local multi-profile storage.
  static const int profileSchemaVersion = 2;

  // Assets
  static const String workoutProgramAsset = 'assets/data/workout_program.json';
  static const String timerSoundAsset = 'assets/sounds/timer_complete.wav';

  // Defaults
  static const int defaultRestSeconds = 90;
  static const List<int> restPresets = [60, 90, 120];
  static const String defaultWeightUnit = 'kg';

  // Estimated calories burn per minute of resistance training
  static const double caloriesPerMinute = 6.5;
}
