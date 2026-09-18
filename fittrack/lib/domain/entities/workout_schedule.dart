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
}
