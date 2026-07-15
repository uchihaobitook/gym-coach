import 'package:uuid/uuid.dart';

import '../datasources/measurement_datasource.dart';
import '../models/measurement_models.dart';

/// Repository for body measurement tracking scoped to one profile.
class MeasurementRepository {
  MeasurementRepository({
    required MeasurementDatasource datasource,
    Uuid? uuid,
  })  : _datasource = datasource,
        _uuid = uuid ?? const Uuid();

  final MeasurementDatasource _datasource;
  final Uuid _uuid;

  Future<List<BodyMeasurement>> getAll() => _datasource.getAll();

  Future<BodyMeasurement?> getById(String id) => _datasource.getById(id);

  Future<BodyMeasurement> save(BodyMeasurement measurement) async {
    final toSave = measurement.id.isEmpty
        ? measurement.copyWith(id: _uuid.v4())
        : measurement;
    await _datasource.save(toSave);
    return toSave;
  }

  Future<void> delete(String id) => _datasource.delete(id);

  Future<List<BodyMeasurement>> getAllChronological() async {
    final all = await getAll();
    return all.reversed.toList(growable: false);
  }
}
