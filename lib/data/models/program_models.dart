import 'package:equatable/equatable.dart';

/// Template exercise from the coach program JSON.
class ExerciseTemplate extends Equatable {
  const ExerciseTemplate({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    this.restSeconds = 90,
    this.isDropSet = false,
    this.isFail = false,
    this.videoUrl,
    this.notes,
    this.tips,
  });

  final String id;
  final String name;
  final String muscleGroup;
  final int sets;
  final String reps; // e.g. "8-12" or "10"
  final int restSeconds;
  final bool isDropSet;
  final bool isFail;
  final String? videoUrl;
  final String? notes;
  final String? tips;

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    return ExerciseTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      sets: json['sets'] as int,
      reps: json['reps'].toString(),
      restSeconds: (json['restSeconds'] as int?) ?? 90,
      isDropSet: (json['isDropSet'] as bool?) ?? false,
      isFail: (json['isFail'] as bool?) ?? false,
      videoUrl: json['videoUrl'] as String?,
      notes: json['notes'] as String?,
      tips: json['tips'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
        'isDropSet': isDropSet,
        'isFail': isFail,
        'videoUrl': videoUrl,
        'notes': notes,
        'tips': tips,
      };

  @override
  List<Object?> get props => [id, name, muscleGroup, sets, reps];
}

class WorkoutDayTemplate extends Equatable {
  const WorkoutDayTemplate({
    required this.id,
    required this.dayNumber,
    required this.name,
    required this.muscleGroup,
    required this.estimatedMinutes,
    required this.exercises,
    this.description,
  });

  final String id;
  final int dayNumber;
  final String name;
  final String muscleGroup;
  final int estimatedMinutes;
  final List<ExerciseTemplate> exercises;
  final String? description;

  int get exerciseCount => exercises.length;
  int get totalSets => exercises.fold(0, (s, e) => s + e.sets);

  factory WorkoutDayTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutDayTemplate(
      id: json['id'] as String,
      dayNumber: json['dayNumber'] as int,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      estimatedMinutes: json['estimatedMinutes'] as int,
      description: json['description'] as String?,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dayNumber': dayNumber,
        'name': name,
        'muscleGroup': muscleGroup,
        'estimatedMinutes': estimatedMinutes,
        'description': description,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, dayNumber, name];
}

class WeekProgramTemplate extends Equatable {
  const WeekProgramTemplate({
    required this.weekNumber,
    required this.title,
    required this.days,
    this.focus,
  });

  final int weekNumber;
  final String title;
  final List<WorkoutDayTemplate> days;
  final String? focus;

  factory WeekProgramTemplate.fromJson(Map<String, dynamic> json) {
    return WeekProgramTemplate(
      weekNumber: json['weekNumber'] as int,
      title: json['title'] as String,
      focus: json['focus'] as String?,
      days: (json['days'] as List<dynamic>)
          .map((d) => WorkoutDayTemplate.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'weekNumber': weekNumber,
        'title': title,
        'focus': focus,
        'days': days.map((d) => d.toJson()).toList(),
      };

  @override
  List<Object?> get props => [weekNumber, title];
}

/// Root coach program loaded from assets/data/workout_program.json
class WorkoutProgram extends Equatable {
  const WorkoutProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.weeks,
    this.author,
    this.version = '1.0',
  });

  final String id;
  final String name;
  final String description;
  final List<WeekProgramTemplate> weeks;
  final String? author;
  final String version;

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutProgram(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      author: json['author'] as String?,
      version: (json['version'] as String?) ?? '1.0',
      weeks: (json['weeks'] as List<dynamic>)
          .map((w) => WeekProgramTemplate.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'author': author,
        'version': version,
        'weeks': weeks.map((w) => w.toJson()).toList(),
      };

  WorkoutDayTemplate? findDay(String dayId) {
    for (final week in weeks) {
      for (final day in week.days) {
        if (day.id == dayId) return day;
      }
    }
    return null;
  }

  WeekProgramTemplate? findWeek(int weekNumber) {
    for (final week in weeks) {
      if (week.weekNumber == weekNumber) return week;
    }
    return null;
  }

  @override
  List<Object?> get props => [id, version];
}
