import '../../core/utils/json_helpers.dart';
import '../models/measurement_models.dart';
import 'local_database.dart';

/// Hive-backed CRUD for [BodyMeasurement] records stored as JSON maps.
class MeasurementDatasource {
  MeasurementDatasource({LocalDatabase? database})
      : _database = database ?? LocalDatabase.instance;

  final LocalDatabase _database;

  static const String _recordKeyPrefix = 'measurement_';

  /// Returns all measurements sorted by date descending (newest first).
  Future<List<BodyMeasurement>> getAll() async {
    final box = _database.measurementsBox;
    final measurements = box.values
        .map((raw) => BodyMeasurement.fromJson(deepJsonMap(raw)))
        .toList();
    measurements.sort((a, b) => b.date.compareTo(a.date));
    return measurements;
  }

  /// Returns a measurement by id, or null if missing.
  Future<BodyMeasurement?> getById(String id) async {
    final box = _database.measurementsBox;
    final raw = box.get(_keyFor(id));
    if (raw == null) return null;
    return BodyMeasurement.fromJson(deepJsonMap(raw));
  }

  /// Persists a measurement (insert or update).
  Future<void> save(BodyMeasurement measurement) async {
    final box = _database.measurementsBox;
    await box.put(_keyFor(measurement.id), measurement.toJson());
  }

  /// Deletes a measurement by id.
  Future<void> delete(String id) async {
    final box = _database.measurementsBox;
    await box.delete(_keyFor(id));
  }

  /// Replaces all stored measurements with a snapshot rollback on failure.
  Future<void> replaceAll(List<BodyMeasurement> measurements) async {
    final box = _database.measurementsBox;
    final snapshot = Map<dynamic, dynamic>.from(box.toMap());
    try {
      final next = <String, Map<String, dynamic>>{
        for (final m in measurements) _keyFor(m.id): m.toJson(),
      };
      await box.clear();
      if (next.isNotEmpty) await box.putAll(next);
    } catch (_) {
      await box.clear();
      if (snapshot.isNotEmpty) await box.putAll(snapshot);
      rethrow;
    }
  }

  String _keyFor(String id) => '$_recordKeyPrefix$id';
}
