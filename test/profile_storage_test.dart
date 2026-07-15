import 'package:flutter_test/flutter_test.dart';
import 'package:gym_coach/core/utils/profile_storage_keys.dart';
import 'package:gym_coach/data/models/local_profile.dart';

void main() {
  group('ProfileStorageKeys', () {
    test('scopes keys per profile', () {
      expect(
        ProfileStorageKeys.log('a', '1'),
        'p::a::log_1',
      );
      expect(
        ProfileStorageKeys.belongsToProfile('p::a::log_1', 'a'),
        isTrue,
      );
      expect(
        ProfileStorageKeys.belongsToProfile('p::b::log_1', 'a'),
        isFalse,
      );
    });

    test('detects legacy keys', () {
      expect(ProfileStorageKeys.isLegacyLogKey('log_abc'), isTrue);
      expect(ProfileStorageKeys.isLegacyLogKey('p::x::log_abc'), isFalse);
      expect(ProfileStorageKeys.isLegacySettingsKey('app_settings'), isTrue);
    });
  });

  group('LocalProfile', () {
    test('initials from name', () {
      expect(
        LocalProfile(
          id: '1',
          name: 'Anh A',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ).initials,
        'AA',
      );
      expect(
        LocalProfile(
          id: '1',
          name: 'Minh',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ).initials,
        'MI',
      );
    });
  });
}
