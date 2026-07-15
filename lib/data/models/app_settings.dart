import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

enum AppThemeModeSetting { dark, light, system }

enum WeightUnit { kg, lbs }

/// App language preference. [system] follows device locale (vi/en).
enum AppLanguage { system, en, vi }

/// User preferences persisted via SharedPreferences + Hive.
class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeModeSetting.dark,
    this.restSeconds = AppConstants.defaultRestSeconds,
    this.weightUnit = WeightUnit.kg,
    this.amoledBlack = false,
    this.userName = 'VĐV',
    this.soundEnabled = true,
    this.vibrateEnabled = true,
    this.currentWeek = 1,
    this.currentDayIndex = 0,
    this.language = AppLanguage.vi,
  });

  final AppThemeModeSetting themeMode;
  final int restSeconds;
  final WeightUnit weightUnit;
  final bool amoledBlack;
  final String userName;
  final bool soundEnabled;
  final bool vibrateEnabled;
  final int currentWeek;
  final int currentDayIndex;
  final AppLanguage language;

  AppSettings copyWith({
    AppThemeModeSetting? themeMode,
    int? restSeconds,
    WeightUnit? weightUnit,
    bool? amoledBlack,
    String? userName,
    bool? soundEnabled,
    bool? vibrateEnabled,
    int? currentWeek,
    int? currentDayIndex,
    AppLanguage? language,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      restSeconds: restSeconds ?? this.restSeconds,
      weightUnit: weightUnit ?? this.weightUnit,
      amoledBlack: amoledBlack ?? this.amoledBlack,
      userName: userName ?? this.userName,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrateEnabled: vibrateEnabled ?? this.vibrateEnabled,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDayIndex: currentDayIndex ?? this.currentDayIndex,
      language: language ?? this.language,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeModeSetting.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeModeSetting.dark,
      ),
      restSeconds:
          (json['restSeconds'] as int?) ?? AppConstants.defaultRestSeconds,
      weightUnit: WeightUnit.values.firstWhere(
        (e) => e.name == json['weightUnit'],
        orElse: () => WeightUnit.kg,
      ),
      amoledBlack: (json['amoledBlack'] as bool?) ?? false,
      userName: (json['userName'] as String?) ?? 'VĐV',
      soundEnabled: (json['soundEnabled'] as bool?) ?? true,
      vibrateEnabled: (json['vibrateEnabled'] as bool?) ?? true,
      currentWeek: (json['currentWeek'] as int?) ?? 1,
      currentDayIndex: (json['currentDayIndex'] as int?) ?? 0,
      language: AppLanguage.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => AppLanguage.vi,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'restSeconds': restSeconds,
        'weightUnit': weightUnit.name,
        'amoledBlack': amoledBlack,
        'userName': userName,
        'soundEnabled': soundEnabled,
        'vibrateEnabled': vibrateEnabled,
        'currentWeek': currentWeek,
        'currentDayIndex': currentDayIndex,
        'language': language.name,
      };

  @override
  List<Object?> get props => [
        themeMode,
        restSeconds,
        weightUnit,
        amoledBlack,
        userName,
        soundEnabled,
        vibrateEnabled,
        currentWeek,
        currentDayIndex,
        language,
      ];
}
