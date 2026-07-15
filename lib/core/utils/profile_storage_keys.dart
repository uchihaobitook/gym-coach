/// Helpers for profile-scoped Hive keys.
abstract final class ProfileStorageKeys {
  static const separator = '::';

  static String profileKey(String profileId) => 'profile_$profileId';

  static String settings(String profileId) =>
      'p$separator$profileId${separator}settings';

  static String log(String profileId, String logId) =>
      'p$separator$profileId${separator}log_$logId';

  static String measurement(String profileId, String measurementId) =>
      'p$separator$profileId${separator}measurement_$measurementId';

  static String exercise(String profileId, String exerciseId) =>
      'p$separator$profileId${separator}exercise_$exerciseId';

  static bool belongsToProfile(String key, String profileId) {
    return key.startsWith('p$separator$profileId$separator');
  }

  /// Returns true for pre-profile-v2 keys that should be migrated.
  static bool isLegacyLogKey(String key) =>
      key.startsWith('log_') && !key.contains(separator);

  static bool isLegacyMeasurementKey(String key) =>
      key.startsWith('measurement_') && !key.contains(separator);

  static bool isLegacyExerciseKey(String key) =>
      key.startsWith('exercise_') && !key.contains(separator);

  static bool isLegacySettingsKey(String key) => key == 'app_settings';
}
