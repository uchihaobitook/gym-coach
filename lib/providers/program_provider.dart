import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_settings.dart';
import '../data/models/program_models.dart';
import 'repository_providers.dart';
import 'settings_provider.dart';

/// Loads the bundled coach workout program from assets.
final workoutProgramProvider = FutureProvider<WorkoutProgram>((ref) {
  return ref.watch(programRepositoryProvider).getProgram();
});

/// UI-selected week tab (1-based).
final selectedWeekProvider =
    NotifierProvider<SelectedWeekNotifier, int>(SelectedWeekNotifier.new);

class SelectedWeekNotifier extends Notifier<int> {
  @override
  int build() {
    // Only react to program-week progress, not unrelated setting changes.
    return ref.watch(
      settingsProvider.select((async) => async.value?.currentWeek ?? 1),
    );
  }

  void select(int week) => state = week;
}

/// Suggested workout day based on [AppSettings.currentWeek] and
/// [AppSettings.currentDayIndex].
final suggestedDayProvider = Provider<WorkoutDayTemplate?>((ref) {
  final program = ref.watch(workoutProgramProvider).value;
  final settings = ref.watch(settingsProvider).value ?? const AppSettings();
  if (program == null) return null;
  final week = program.findWeek(settings.currentWeek);
  if (week == null || week.days.isEmpty) return null;
  final index = settings.currentDayIndex.clamp(0, week.days.length - 1);
  return week.days[index];
});
