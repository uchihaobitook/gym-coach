import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/measurement_models.dart';
import 'repository_providers.dart';
import 'workout_logs_provider.dart';

/// Strength profile for a single exercise, or null when no history exists.
final exerciseStrengthProfileProvider =
    FutureProvider.family<ExerciseStrengthProfile?, String>(
  (ref, exerciseId) {
    return ref
        .read(exerciseHistoryDatasourceProvider)
        .getByExerciseId(exerciseId);
  },
);

/// All stored exercise strength profiles.
final allExerciseStrengthProfilesProvider =
    FutureProvider<List<ExerciseStrengthProfile>>((ref) {
  ref.watch(workoutLogsProvider);
  return ref.read(exerciseHistoryDatasourceProvider).getAll();
});
