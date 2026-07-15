import 'package:collection/collection.dart';

import '../../data/models/workout_log.dart';

/// Aggregated workout statistics derived from completed logs.
class WorkoutStats {
  const WorkoutStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalHours,
    required this.favoriteExercise,
    required this.mostTrainedMuscle,
    required this.completedDates,
    required this.totalVolume,
    required this.totalWorkouts,
    required this.totalSets,
  });

  final int currentStreak;
  final int longestStreak;
  final double totalHours;
  final String? favoriteExercise;
  final String? mostTrainedMuscle;
  final Set<DateTime> completedDates;
  final double totalVolume;
  final int totalWorkouts;
  final int totalSets;

  static const empty = WorkoutStats(
    currentStreak: 0,
    longestStreak: 0,
    totalHours: 0,
    favoriteExercise: null,
    mostTrainedMuscle: null,
    completedDates: {},
    totalVolume: 0,
    totalWorkouts: 0,
    totalSets: 0,
  );
}

/// Computes workout statistics from a list of [WorkoutLog] records.
abstract final class StatsCalculator {
  /// Builds a full [WorkoutStats] snapshot from [logs].
  ///
  /// Only completed logs contribute to streaks, volume, and favorites.
  static WorkoutStats calculate(List<WorkoutLog> logs) {
    final completed = logs.where((l) => l.isCompleted).toList();
    if (completed.isEmpty) return WorkoutStats.empty;

    final completedDates = _completedDates(completed);
    final currentStreak = _currentStreak(completedDates);
    final longestStreak = _longestStreak(completedDates);
    final totalHours = _totalHours(completed);
    final favoriteExercise = _favoriteExercise(completed);
    final mostTrainedMuscle = _mostTrainedMuscle(completed);
    final totalVolume =
        completed.fold(0.0, (sum, log) => sum + log.totalVolume);
    final totalSets =
        completed.fold(0, (sum, log) => sum + log.completedSets);

    return WorkoutStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalHours: totalHours,
      favoriteExercise: favoriteExercise,
      mostTrainedMuscle: mostTrainedMuscle,
      completedDates: completedDates,
      totalVolume: totalVolume,
      totalWorkouts: completed.length,
      totalSets: totalSets,
    );
  }

  static Set<DateTime> completedDates(List<WorkoutLog> logs) {
    return _completedDates(logs.where((l) => l.isCompleted));
  }

  static int currentStreak(List<WorkoutLog> logs) {
    return _currentStreak(completedDates(logs));
  }

  static int longestStreak(List<WorkoutLog> logs) {
    return _longestStreak(completedDates(logs));
  }

  static double totalHours(List<WorkoutLog> logs) {
    return _totalHours(logs.where((l) => l.isCompleted));
  }

  static String? favoriteExercise(List<WorkoutLog> logs) {
    return _favoriteExercise(logs.where((l) => l.isCompleted).toList());
  }

  static String? mostTrainedMuscle(List<WorkoutLog> logs) {
    return _mostTrainedMuscle(logs.where((l) => l.isCompleted).toList());
  }

  static double totalVolume(List<WorkoutLog> logs) {
    return logs
        .where((l) => l.isCompleted)
        .fold(0.0, (sum, log) => sum + log.totalVolume);
  }

  static Set<DateTime> _completedDates(Iterable<WorkoutLog> completed) {
    return completed
        .map((log) {
          final date = log.endedAt ?? log.startedAt;
          return DateTime(date.year, date.month, date.day);
        })
        .toSet();
  }

  static int _currentStreak(Set<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    if (!dates.contains(today) && !dates.contains(yesterday)) {
      return 0;
    }

    var streak = 0;
    var cursor = dates.contains(today) ? today : yesterday;

    while (dates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int _longestStreak(Set<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sorted = dates.toList()..sort();
    var longest = 1;
    var current = 1;

    for (var i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final day = sorted[i];
      if (day.difference(prev).inDays == 1) {
        current++;
      } else if (day != prev) {
        current = 1;
      }
      if (current > longest) longest = current;
    }
    return longest;
  }

  static double _totalHours(Iterable<WorkoutLog> completed) {
    final totalMinutes = completed.fold<int>(
      0,
      (sum, log) => sum + log.duration.inMinutes,
    );
    return totalMinutes / 60.0;
  }

  static String? _favoriteExercise(List<WorkoutLog> completed) {
    final counts = <String, int>{};
    for (final log in completed) {
      for (final exercise in log.exercises) {
        if (exercise.completedSets == 0) continue;
        counts[exercise.name] = (counts[exercise.name] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    return counts.entries
        .sortedBy<num>((e) => -e.value)
        .first
        .key;
  }

  static String? _mostTrainedMuscle(List<WorkoutLog> completed) {
    final volumeByMuscle = <String, double>{};
    for (final log in completed) {
      for (final exercise in log.exercises) {
        if (exercise.completedSets == 0) continue;
        volumeByMuscle[exercise.muscleGroup] =
            (volumeByMuscle[exercise.muscleGroup] ?? 0) + exercise.totalVolume;
      }
    }
    if (volumeByMuscle.isEmpty) return null;
    return volumeByMuscle.entries
        .sortedBy<num>((e) => -e.value)
        .first
        .key;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
