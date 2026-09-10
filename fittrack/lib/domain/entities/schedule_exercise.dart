import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_exercise.freezed.dart';
part 'schedule_exercise.g.dart';

@freezed
abstract class ScheduleExercise with _$ScheduleExercise {
  const ScheduleExercise._();

  const factory ScheduleExercise({
    required String id,
    required String scheduleId,
    required String exerciseId,
    required int sortOrder,
    required int targetSets,
    required int targetReps,
    required double targetWeightKg,
    required int restDurationSeconds,
  }) = _ScheduleExercise;

  factory ScheduleExercise.fromJson(Map<String, dynamic> json) => _$ScheduleExerciseFromJson(json);
}
