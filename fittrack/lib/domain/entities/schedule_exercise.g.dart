// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleExercise _$ScheduleExerciseFromJson(Map<String, dynamic> json) =>
    _ScheduleExercise(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      exerciseId: json['exerciseId'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      targetSets: (json['targetSets'] as num).toInt(),
      targetReps: (json['targetReps'] as num).toInt(),
      targetWeightKg: (json['targetWeightKg'] as num).toDouble(),
      restDurationSeconds: (json['restDurationSeconds'] as num).toInt(),
    );

Map<String, dynamic> _$ScheduleExerciseToJson(_ScheduleExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scheduleId': instance.scheduleId,
      'exerciseId': instance.exerciseId,
      'sortOrder': instance.sortOrder,
      'targetSets': instance.targetSets,
      'targetReps': instance.targetReps,
      'targetWeightKg': instance.targetWeightKg,
      'restDurationSeconds': instance.restDurationSeconds,
    };
