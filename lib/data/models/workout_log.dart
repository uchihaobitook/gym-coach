import 'package:equatable/equatable.dart';

/// A single logged set during / after a workout.
class LoggedSet extends Equatable {
  const LoggedSet({
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.completed,
    this.isDropSet = false,
    this.isFail = false,
    this.rpe,
  });

  final int setNumber;
  final int reps;
  final double weight;
  final bool completed;
  final bool isDropSet;
  final bool isFail;
  final double? rpe;

  LoggedSet copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    bool? completed,
    bool? isDropSet,
    bool? isFail,
    double? rpe,
  }) {
    return LoggedSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      completed: completed ?? this.completed,
      isDropSet: isDropSet ?? this.isDropSet,
      isFail: isFail ?? this.isFail,
      rpe: rpe ?? this.rpe,
    );
  }

  factory LoggedSet.fromJson(Map<String, dynamic> json) {
    return LoggedSet(
      setNumber: json['setNumber'] as int,
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
      completed: json['completed'] as bool,
      isDropSet: (json['isDropSet'] as bool?) ?? false,
      isFail: (json['isFail'] as bool?) ?? false,
      rpe: (json['rpe'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'reps': reps,
        'weight': weight,
        'completed': completed,
        'isDropSet': isDropSet,
        'isFail': isFail,
        'rpe': rpe,
      };

  double get volume => weight * reps;

  @override
  List<Object?> get props => [setNumber, reps, weight, completed];
}

class LoggedExercise extends Equatable {
  const LoggedExercise({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    this.notes = '',
    this.isDropSet = false,
    this.isFail = false,
    this.previousBestWeight,
  });

  final String exerciseId;
  final String name;
  final String muscleGroup;
  final List<LoggedSet> sets;
  final String notes;
  final bool isDropSet;
  final bool isFail;
  final double? previousBestWeight;

  int get completedSets => sets.where((s) => s.completed).length;
  double get totalVolume =>
      sets.where((s) => s.completed).fold(0.0, (a, s) => a + s.volume);
  double get bestWeight => sets.isEmpty
      ? 0
      : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  LoggedExercise copyWith({
    String? exerciseId,
    String? name,
    String? muscleGroup,
    List<LoggedSet>? sets,
    String? notes,
    bool? isDropSet,
    bool? isFail,
    double? previousBestWeight,
  }) {
    return LoggedExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      isDropSet: isDropSet ?? this.isDropSet,
      isFail: isFail ?? this.isFail,
      previousBestWeight: previousBestWeight ?? this.previousBestWeight,
    );
  }

  factory LoggedExercise.fromJson(Map<String, dynamic> json) {
    return LoggedExercise(
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      notes: (json['notes'] as String?) ?? '',
      isDropSet: (json['isDropSet'] as bool?) ?? false,
      isFail: (json['isFail'] as bool?) ?? false,
      previousBestWeight: (json['previousBestWeight'] as num?)?.toDouble(),
      sets: (json['sets'] as List<dynamic>)
          .map((s) => LoggedSet.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'name': name,
        'muscleGroup': muscleGroup,
        'sets': sets.map((s) => s.toJson()).toList(),
        'notes': notes,
        'isDropSet': isDropSet,
        'isFail': isFail,
        'previousBestWeight': previousBestWeight,
      };

  @override
  List<Object?> get props => [exerciseId, sets, notes];
}

/// Persisted completed (or in-progress) workout session.
class WorkoutLog extends Equatable {
  const WorkoutLog({
    required this.id,
    required this.dayId,
    required this.dayName,
    required this.muscleGroup,
    required this.weekNumber,
    required this.dayNumber,
    required this.startedAt,
    required this.exercises,
    this.endedAt,
    this.notes = '',
    this.isCompleted = false,
    this.prCount = 0,
    this.caloriesEstimate = 0,
  });

  final String id;
  final String dayId;
  final String dayName;
  final String muscleGroup;
  final int weekNumber;
  final int dayNumber;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<LoggedExercise> exercises;
  final String notes;
  final bool isCompleted;
  final int prCount;
  final double caloriesEstimate;

  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  int get totalSets =>
      exercises.fold(0, (a, e) => a + e.sets.length);

  int get completedSets =>
      exercises.fold(0, (a, e) => a + e.completedSets);

  double get totalVolume =>
      exercises.fold(0.0, (a, e) => a + e.totalVolume);

  double get completionPercent =>
      totalSets == 0 ? 0 : (completedSets / totalSets) * 100;

  int get exercisesCompleted =>
      exercises.where((e) => e.completedSets > 0).length;

  WorkoutLog copyWith({
    String? id,
    String? dayId,
    String? dayName,
    String? muscleGroup,
    int? weekNumber,
    int? dayNumber,
    DateTime? startedAt,
    DateTime? endedAt,
    List<LoggedExercise>? exercises,
    String? notes,
    bool? isCompleted,
    int? prCount,
    double? caloriesEstimate,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      dayName: dayName ?? this.dayName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      weekNumber: weekNumber ?? this.weekNumber,
      dayNumber: dayNumber ?? this.dayNumber,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      prCount: prCount ?? this.prCount,
      caloriesEstimate: caloriesEstimate ?? this.caloriesEstimate,
    );
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as String,
      dayId: json['dayId'] as String,
      dayName: json['dayName'] as String,
      muscleGroup: json['muscleGroup'] as String,
      weekNumber: json['weekNumber'] as int,
      dayNumber: json['dayNumber'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      notes: (json['notes'] as String?) ?? '',
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      prCount: (json['prCount'] as int?) ?? 0,
      caloriesEstimate: (json['caloriesEstimate'] as num?)?.toDouble() ?? 0,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => LoggedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dayId': dayId,
        'dayName': dayName,
        'muscleGroup': muscleGroup,
        'weekNumber': weekNumber,
        'dayNumber': dayNumber,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'notes': notes,
        'isCompleted': isCompleted,
        'prCount': prCount,
        'caloriesEstimate': caloriesEstimate,
      };

  @override
  List<Object?> get props => [id, isCompleted, exercises];
}
