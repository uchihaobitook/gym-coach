import '../datasources/settings_datasource.dart';
import '../models/app_settings.dart';

/// Repository for user application settings.
class SettingsRepository {
  SettingsRepository({SettingsDatasource? datasource})
      : _datasource = datasource ?? SettingsDatasource();

  final SettingsDatasource _datasource;

  Future<AppSettings> load() => _datasource.load();

  Future<void> save(AppSettings settings) => _datasource.save(settings);

  /// Updates a subset of settings fields and persists the result.
  Future<AppSettings> update(AppSettings Function(AppSettings) transform) async {
    final current = await load();
    final updated = transform(current);
    await save(updated);
    return updated;
  }

  Future<void> reset() => _datasource.clear();
}
