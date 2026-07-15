import 'package:uuid/uuid.dart';

import '../datasources/measurement_datasource.dart';
import '../models/measurement_models.dart';

/// Repository for body measurement tracking.
class MeasurementRepository {
  MeasurementRepository({
    MeasurementDatasource? datasource,
    Uuid? uuid,
  })  : _datasource = datasource ?? MeasurementDatasource(),
        _uuid = uuid ?? const Uuid();

  final MeasurementDatasource _datasource;
  final Uuid _uuid;

  Future<List<BodyMeasurement>> getAll() => _datasource.getAll();

  Future<BodyMeasurement?> getById(String id) => _datasource.getById(id);

  /// Saves a measurement, assigning a new id when [measurement.id] is empty.
  Future<BodyMeasurement> save(BodyMeasurement measurement) async {
    final toSave = measurement.id.isEmpty
        ? measurement.copyWith(id: _uuid.v4())
        : measurement;
    await _datasource.save(toSave);
    return toSave;
  }

  Future<void> delete(String id) => _datasource.delete(id);

  /// Returns measurements sorted by date ascending (oldest first) for charts.
  Future<List<BodyMeasurement>> getAllChronological() async {
    final all = await getAll();
    return all.reversed.toList(growable: false);
  }
}
