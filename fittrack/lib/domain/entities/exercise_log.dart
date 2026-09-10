import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_log.freezed.dart';
part 'exercise_log.g.dart';

@freezed
class ExerciseLog with _$ExerciseLog {
  const factory ExerciseLog({
    required String id,
    required String sessionId,
    required String exerciseId,
    required int orderIndex,
    @Default(false) bool isSkipped,
  }) = _ExerciseLog;

  factory ExerciseLog.fromJson(Map<String, dynamic> json) => _$ExerciseLogFromJson(json);
}
