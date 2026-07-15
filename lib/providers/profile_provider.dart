import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/local_profile.dart';
import '../data/repositories/profile_repository.dart';
import 'active_profile_provider.dart';
import 'active_workout_provider.dart';
import 'exercise_strength_provider.dart';
import 'measurement_provider.dart';
import 'rest_timer_provider.dart';
import 'settings_provider.dart';
import 'workout_logs_provider.dart';

export 'active_profile_provider.dart';

final profilesProvider =
    AsyncNotifierProvider<ProfilesNotifier, List<LocalProfile>>(
  ProfilesNotifier.new,
);

final currentProfileProvider = Provider<LocalProfile?>((ref) {
  final profiles = ref.watch(profilesProvider).value;
  final activeId = ref.watch(activeProfileIdProvider);
  if (profiles == null || activeId == null) return null;
  for (final profile in profiles) {
    if (profile.id == activeId) return profile;
  }
  return profiles.isEmpty ? null : profiles.first;
});

class ProfilesNotifier extends AsyncNotifier<List<LocalProfile>> {
  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  @override
  Future<List<LocalProfile>> build() async {
    await ref.watch(profileBootstrapProvider.future);
    return _repo.getAll();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<LocalProfile> create(String name) async {
    final created = await _repo.create(name: name);
    await refresh();
    return created;
  }

  Future<void> rename(String profileId, String name) async {
    await _repo.rename(profileId, name);
    final activeId = ref.read(activeProfileIdProvider);
    if (activeId == profileId) {
      await ref.read(settingsProvider.notifier).setName(name);
    }
    await refresh();
  }

  Future<void> switchTo(String profileId, {bool force = false}) async {
    final currentId = ref.read(activeProfileIdProvider);
    if (currentId == profileId) return;

    if (!force) {
      final active = ref.read(activeWorkoutProvider);
      if (active != null && !active.isCompleted) {
        throw const ActiveWorkoutInProgressException();
      }
    }

    ref.read(restTimerServiceProvider).cancel();
    ref.read(activeWorkoutProvider.notifier).clearSession();

    await ref.read(activeProfileIdProvider.notifier).setActive(profileId);

    ref.invalidate(settingsProvider);
    ref.invalidate(workoutLogsProvider);
    ref.invalidate(measurementsProvider);
    ref.invalidate(allExerciseStrengthProfilesProvider);
    ref.invalidate(activeWorkoutProvider);
  }

  Future<void> delete(String profileId) async {
    final profiles = state.value ?? await _repo.getAll();
    if (profiles.length <= 1) {
      throw const CannotDeleteLastProfileException();
    }

    final activeId = ref.read(activeProfileIdProvider);
    final remaining = profiles.where((p) => p.id != profileId).toList();
    final nextActive = remaining.first;

    if (activeId == profileId) {
      ref.read(restTimerServiceProvider).cancel();
      ref.read(activeWorkoutProvider.notifier).clearSession();
      await ref.read(activeProfileIdProvider.notifier).setActive(nextActive.id);
    }

    await _repo.deleteProfileData(profileId);
    await refresh();

    ref.invalidate(settingsProvider);
    ref.invalidate(workoutLogsProvider);
    ref.invalidate(measurementsProvider);
    ref.invalidate(allExerciseStrengthProfilesProvider);
    ref.invalidate(activeWorkoutProvider);
  }
}

class ActiveWorkoutInProgressException implements Exception {
  const ActiveWorkoutInProgressException();
}

class CannotDeleteLastProfileException implements Exception {
  const CannotDeleteLastProfileException();
}
