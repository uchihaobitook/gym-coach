import '../datasources/settings_datasource.dart';
import '../models/app_settings.dart';

/// Repository for user application settings scoped to one profile.
class SettingsRepository {
  SettingsRepository({required SettingsDatasource datasource})
      : _datasource = datasource;

  final SettingsDatasource _datasource;

  Future<AppSettings> load() => _datasource.load();

  Future<void> save(AppSettings settings) => _datasource.save(settings);

  Future<AppSettings> update(AppSettings Function(AppSettings) transform) async {
    final current = await load();
    final updated = transform(current);
    await save(updated);
    return updated;
  }

  Future<void> reset() => _datasource.clear();
}
