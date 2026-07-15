import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_settings.dart';
import '../data/repositories/settings_repository.dart';
import 'active_profile_provider.dart';
import 'repository_providers.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

/// Maps persisted [AppSettings.themeMode] to Flutter [ThemeMode].
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (s) => switch (s.themeMode) {
      AppThemeModeSetting.dark => ThemeMode.dark,
      AppThemeModeSetting.light => ThemeMode.light,
      AppThemeModeSetting.system => ThemeMode.system,
    },
    loading: () => ThemeMode.dark,
    error: (_, _) => ThemeMode.dark,
  );
});

/// Whether AMOLED black surfaces should be used (dark theme only).
final amoledBlackProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).value?.amoledBlack ?? false;
});

/// Resolved [Locale] from settings (default Vietnamese).
final localeProvider = Provider<Locale>((ref) {
  final language =
      ref.watch(settingsProvider).value?.language ?? AppLanguage.vi;
  switch (language) {
    case AppLanguage.en:
      return const Locale('en');
    case AppLanguage.vi:
      return const Locale('vi');
    case AppLanguage.system:
      final code =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      return code == 'vi' ? const Locale('vi') : const Locale('en');
  }
});

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  Future<AppSettings> build() async {
    await ref.watch(profileBootstrapProvider.future);
    return _repo.load();
  }

  Future<void> _persist(AppSettings Function(AppSettings) transform) async {
    state = await AsyncValue.guard(() => _repo.update(transform));
  }

  Future<void> setTheme(AppThemeModeSetting theme) =>
      _persist((s) => s.copyWith(themeMode: theme));

  Future<void> setRest(int seconds) =>
      _persist((s) => s.copyWith(restSeconds: seconds));

  Future<void> setUnit(WeightUnit unit) =>
      _persist((s) => s.copyWith(weightUnit: unit));

  Future<void> setAmoled(bool enabled) =>
      _persist((s) => s.copyWith(amoledBlack: enabled));

  Future<void> setName(String name) =>
      _persist((s) => s.copyWith(userName: name.trim()));

  Future<void> setSound(bool enabled) =>
      _persist((s) => s.copyWith(soundEnabled: enabled));

  Future<void> setVibrate(bool enabled) =>
      _persist((s) => s.copyWith(vibrateEnabled: enabled));

  Future<void> setCurrentWeek(int week) =>
      _persist((s) => s.copyWith(currentWeek: week));

  Future<void> setCurrentDay(int dayIndex) =>
      _persist((s) => s.copyWith(currentDayIndex: dayIndex));

  Future<void> setLanguage(AppLanguage language) =>
      _persist((s) => s.copyWith(language: language));

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.load);
  }
}
