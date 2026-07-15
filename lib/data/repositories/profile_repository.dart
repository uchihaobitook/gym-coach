import '../datasources/profile_datasource.dart';
import '../models/local_profile.dart';

/// Repository for local athlete profiles.
class ProfileRepository {
  ProfileRepository({ProfileDatasource? datasource})
      : _datasource = datasource ?? ProfileDatasource();

  final ProfileDatasource _datasource;

  Future<void> migrateIfNeeded() => _datasource.migrateIfNeeded();

  Future<List<LocalProfile>> getAll() => _datasource.getAll();

  Future<LocalProfile?> getById(String id) => _datasource.getById(id);

  Future<String?> getActiveProfileId() => _datasource.getActiveProfileId();

  Future<void> setActiveProfileId(String profileId) =>
      _datasource.setActiveProfileId(profileId);

  Future<LocalProfile> create({required String name}) =>
      _datasource.create(name: name);

  Future<LocalProfile> rename(String profileId, String name) =>
      _datasource.rename(profileId, name);

  Future<LocalProfile> save(LocalProfile profile) =>
      _datasource.save(profile);

  Future<void> deleteProfileData(String profileId) =>
      _datasource.deleteProfileData(profileId);

  /// Ensures at least one profile exists and returns the active profile id.
  Future<String> ensureActiveProfile({String defaultName = 'VĐV'}) async {
    await migrateIfNeeded();
    var profiles = await getAll();
    if (profiles.isEmpty) {
      final created = await create(name: defaultName);
      await setActiveProfileId(created.id);
      return created.id;
    }

    final activeId = await getActiveProfileId();
    if (activeId != null && profiles.any((p) => p.id == activeId)) {
      return activeId;
    }
    await setActiveProfileId(profiles.first.id);
    return profiles.first.id;
  }
}
