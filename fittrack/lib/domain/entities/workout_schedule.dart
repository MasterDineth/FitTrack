import 'package:freezed_annotation/freezed_annotation.dart';
import 'schedule_exercise.dart';

part 'workout_schedule.freezed.dart';
part 'workout_schedule.g.dart';

@freezed
abstract class WorkoutSchedule with _$WorkoutSchedule {
  const WorkoutSchedule._();

  const factory WorkoutSchedule({
    required String id,
    required String title,
    required String description,
    required String focus, // Hypertrophy, Strength, General
    required String experience, // Beginner, Intermediate, Advanced
    required String equipment, // Full Gym, Dumbbells, Bodyweight
    required int durationWeeks,
    required int daysPerWeek,
    @Default(false) bool isFavorite,
    @Default(false) bool isCustom,
    @Default(<String>[]) List<String> targetMuscles,
    @Default(0) int exerciseCount,
    @Default(0) int estimatedMinutes,
    @Default(<ScheduleExercise>[]) List<ScheduleExercise> exercises,
  }) = _WorkoutSchedule;

  factory WorkoutSchedule.fromJson(Map<String, dynamic> json) =>
      _$WorkoutScheduleFromJson(json);

  factory WorkoutSchedule.fromSchedule(
    dynamic schedule, [
    List<ScheduleExercise> exercises = const [],
  ]) {
    return WorkoutSchedule(
      id: schedule.id as String,
      title: (schedule.name ?? schedule.title ?? '') as String,
      description: (schedule.description ?? '') as String,
      focus: (schedule.focus ?? 'Hypertrophy') as String,
      experience: (schedule.experience ?? 'Intermediate') as String,
      equipment: (schedule.equipment ?? 'Full Gym') as String,
      durationWeeks: (schedule.durationWeeks ?? 8) as int,
      daysPerWeek: (schedule.daysPerWeek ?? 4) as int,
      isFavorite: (schedule.isFavorite ?? false) as bool,
      isCustom: (schedule.isCustom ?? false) as bool,
      targetMuscles: List<String>.from((schedule.targetMuscles as Iterable?) ?? const []),
      exerciseCount: exercises.isNotEmpty ? exercises.length : 0,
      estimatedMinutes: (schedule.estimatedMinutes ?? 45) as int,
      exercises: exercises,
    );
  }
}
