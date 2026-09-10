import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_log.freezed.dart';
part 'set_log.g.dart';

@freezed
abstract class SetLog with _$SetLog {
  const SetLog._();

  const factory SetLog({
    required String id,
    required String exerciseLogId,
    required int setNumber,
    required int actualReps,
    required int targetReps,
    required double actualWeightKg,
    required double targetWeightKg,
    @Default(false) bool isCompleted,
    required int restDurationSeconds,
  }) = _SetLog;

  factory SetLog.fromJson(Map<String, dynamic> json) => _$SetLogFromJson(json);
}
