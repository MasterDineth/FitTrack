import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

@freezed
class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required String id,
    required String scheduleId,
    required DateTime startTime,
    DateTime? endTime,
    int? durationSeconds,
    int? totalCalories,
    String? notes,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
}
