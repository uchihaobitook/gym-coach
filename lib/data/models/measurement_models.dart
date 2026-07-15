import 'package:equatable/equatable.dart';

/// Body measurement snapshot for progress tracking.
class BodyMeasurement extends Equatable {
  const BodyMeasurement({
    required this.id,
    required this.date,
    this.weight,
    this.chest,
    this.waist,
    this.arm,
    this.forearm,
    this.thigh,
    this.calf,
    this.shoulder,
    this.notes,
  });

  final String id;
  final DateTime date;
  final double? weight;
  final double? chest;
  final double? waist;
  final double? arm;
  final double? forearm;
  final double? thigh;
  final double? calf;
  final double? shoulder;
  final String? notes;

  BodyMeasurement copyWith({
    String? id,
    DateTime? date,
    double? weight,
    double? chest,
    double? waist,
    double? arm,
    double? forearm,
    double? thigh,
    double? calf,
    double? shoulder,
    String? notes,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      arm: arm ?? this.arm,
      forearm: forearm ?? this.forearm,
      thigh: thigh ?? this.thigh,
      calf: calf ?? this.calf,
      shoulder: shoulder ?? this.shoulder,
      notes: notes ?? this.notes,
    );
  }

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num?)?.toDouble(),
      chest: (json['chest'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      arm: (json['arm'] as num?)?.toDouble(),
      forearm: (json['forearm'] as num?)?.toDouble(),
      thigh: (json['thigh'] as num?)?.toDouble(),
      calf: (json['calf'] as num?)?.toDouble(),
      shoulder: (json['shoulder'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weight': weight,
        'chest': chest,
        'waist': waist,
        'arm': arm,
        'forearm': forearm,
        'thigh': thigh,
        'calf': calf,
        'shoulder': shoulder,
        'notes': notes,
      };

  /// Returns measurement value by field key (for charts).
  double? valueOf(String field) {
    switch (field) {
      case 'weight':
        return weight;
      case 'chest':
        return chest;
      case 'waist':
        return waist;
      case 'arm':
        return arm;
      case 'forearm':
        return forearm;
      case 'thigh':
        return thigh;
      case 'calf':
        return calf;
      case 'shoulder':
        return shoulder;
      default:
        return null;
    }
  }

  static const List<String> fields = [
    'weight',
    'chest',
    'waist',
    'arm',
    'forearm',
    'thigh',
    'calf',
    'shoulder',
  ];

  static String labelOf(String field) {
    switch (field) {
      case 'weight':
        return 'Body Weight';
      case 'chest':
        return 'Chest';
      case 'waist':
        return 'Waist';
      case 'arm':
        return 'Arm';
      case 'forearm':
        return 'Forearm';
      case 'thigh':
        return 'Thigh';
      case 'calf':
        return 'Calf';
      case 'shoulder':
        return 'Shoulder';
      default:
        return field;
    }
  }

  @override
  List<Object?> get props => [id, date];
}

/// Aggregated strength history for a single exercise.
class ExerciseHistoryEntry extends Equatable {
  const ExerciseHistoryEntry({
    required this.date,
    required this.bestWeight,
    required this.bestReps,
    required this.bestVolume,
    required this.workoutLogId,
  });

  final DateTime date;
  final double bestWeight;
  final int bestReps;
  final double bestVolume;
  final String workoutLogId;

  factory ExerciseHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ExerciseHistoryEntry(
      date: DateTime.parse(json['date'] as String),
      bestWeight: (json['bestWeight'] as num).toDouble(),
      bestReps: json['bestReps'] as int,
      bestVolume: (json['bestVolume'] as num).toDouble(),
      workoutLogId: json['workoutLogId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'bestWeight': bestWeight,
        'bestReps': bestReps,
        'bestVolume': bestVolume,
        'workoutLogId': workoutLogId,
      };

  @override
  List<Object?> get props => [date, bestWeight, workoutLogId];
}

class ExerciseStrengthProfile extends Equatable {
  const ExerciseStrengthProfile({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    required this.history,
  });

  final String exerciseId;
  final String name;
  final String muscleGroup;
  final List<ExerciseHistoryEntry> history;

  double get bestWeight => history.isEmpty
      ? 0
      : history.map((h) => h.bestWeight).reduce((a, b) => a > b ? a : b);

  int get bestReps => history.isEmpty
      ? 0
      : history.map((h) => h.bestReps).reduce((a, b) => a > b ? a : b);

  double get bestVolume => history.isEmpty
      ? 0
      : history.map((h) => h.bestVolume).reduce((a, b) => a > b ? a : b);

  factory ExerciseStrengthProfile.fromJson(Map<String, dynamic> json) {
    return ExerciseStrengthProfile(
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      history: (json['history'] as List<dynamic>)
          .map((e) => ExerciseHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'name': name,
        'muscleGroup': muscleGroup,
        'history': history.map((h) => h.toJson()).toList(),
      };

  @override
  List<Object?> get props => [exerciseId, history];
}
