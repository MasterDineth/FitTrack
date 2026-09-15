import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

@freezed
abstract class WorkoutSession with _$WorkoutSession {
  const WorkoutSession._();

  const factory WorkoutSession({
    required String id,
    required String scheduleId,
    required DateTime startTime,
    DateTime? endTime,
    int? durationSeconds,
    int? totalCalories,
    String? notes,
    String? intensity,
    @Default(0) int totalSets,
    @Default(0) int totalReps,
    @Default(0.0) double totalVolumeKg,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}
