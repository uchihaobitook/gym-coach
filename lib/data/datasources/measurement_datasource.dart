import '../../core/utils/json_helpers.dart';
import '../../core/utils/profile_storage_keys.dart';
import '../models/measurement_models.dart';
import 'local_database.dart';

/// Hive-backed CRUD for [BodyMeasurement] records scoped to one profile.
class MeasurementDatasource {
  MeasurementDatasource({
    required this.profileId,
    LocalDatabase? database,
  }) : _database = database ?? LocalDatabase.instance;

  final String profileId;
  final LocalDatabase _database;

  Future<List<BodyMeasurement>> getAll() async {
    final box = _database.measurementsBox;
    final measurements = <BodyMeasurement>[];
    for (final key in box.keys) {
      final keyStr = key.toString();
      if (!ProfileStorageKeys.belongsToProfile(keyStr, profileId)) continue;
      final raw = box.get(key);
      if (raw == null) continue;
      measurements.add(BodyMeasurement.fromJson(deepJsonMap(raw)));
    }
    measurements.sort((a, b) => b.date.compareTo(a.date));
    return measurements;
  }

  Future<BodyMeasurement?> getById(String id) async {
    final raw = _database.measurementsBox.get(_keyFor(id));
    if (raw == null) return null;
    return BodyMeasurement.fromJson(deepJsonMap(raw));
  }

  Future<void> save(BodyMeasurement measurement) async {
    await _database.measurementsBox.put(
      _keyFor(measurement.id),
      measurement.toJson(),
    );
  }

  Future<void> delete(String id) async {
    await _database.measurementsBox.delete(_keyFor(id));
  }

  /// Replaces only this profile's measurements.
  Future<void> replaceAll(List<BodyMeasurement> measurements) async {
    final box = _database.measurementsBox;
    final profileKeys = box.keys
        .map((k) => k.toString())
        .where((k) => ProfileStorageKeys.belongsToProfile(k, profileId))
        .toList();
    final snapshot = <String, dynamic>{
      for (final key in profileKeys) key: box.get(key),
    };

    try {
      for (final key in profileKeys) {
        await box.delete(key);
      }
      if (measurements.isEmpty) return;
      await box.putAll({
        for (final m in measurements) _keyFor(m.id): m.toJson(),
      });
    } catch (_) {
      for (final key in profileKeys) {
        await box.delete(key);
      }
      if (snapshot.isNotEmpty) await box.putAll(snapshot);
      rethrow;
    }
  }

  String _keyFor(String id) =>
      ProfileStorageKeys.measurement(profileId, id);
}
