import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

/// Bootstraps migration and ensures an active profile exists.
final profileBootstrapProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.ensureActiveProfile();
});

/// Currently selected profile id (null until bootstrap completes).
final activeProfileIdProvider =
    NotifierProvider<ActiveProfileIdNotifier, String?>(
  ActiveProfileIdNotifier.new,
);

class ActiveProfileIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final bootstrap = ref.watch(profileBootstrapProvider);
    return bootstrap.asData?.value;
  }

  Future<void> setActive(String profileId) async {
    await ref.read(profileRepositoryProvider).setActiveProfileId(profileId);
    state = profileId;
  }
}
