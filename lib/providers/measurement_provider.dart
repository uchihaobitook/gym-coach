import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/measurement_models.dart';
import '../data/repositories/measurement_repository.dart';
import 'active_profile_provider.dart';
import 'repository_providers.dart';

final measurementsProvider =
    AsyncNotifierProvider<MeasurementsNotifier, List<BodyMeasurement>>(
  MeasurementsNotifier.new,
);

class MeasurementsNotifier extends AsyncNotifier<List<BodyMeasurement>> {
  MeasurementRepository get _repo => ref.read(measurementRepositoryProvider);

  @override
  Future<List<BodyMeasurement>> build() async {
    await ref.watch(profileBootstrapProvider.future);
    return _repo.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<BodyMeasurement> add(BodyMeasurement measurement) async {
    final saved = await _repo.save(measurement);
    await refresh();
    return saved;
  }

  Future<BodyMeasurement> updateMeasurement(BodyMeasurement measurement) async {
    final saved = await _repo.save(measurement);
    await refresh();
    return saved;
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await refresh();
  }
}
