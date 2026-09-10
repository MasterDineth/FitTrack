// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SetLog _$SetLogFromJson(Map<String, dynamic> json) => _SetLog(
  id: json['id'] as String,
  exerciseLogId: json['exerciseLogId'] as String,
  setNumber: (json['setNumber'] as num).toInt(),
  actualReps: (json['actualReps'] as num).toInt(),
  targetReps: (json['targetReps'] as num).toInt(),
  actualWeightKg: (json['actualWeightKg'] as num).toDouble(),
  targetWeightKg: (json['targetWeightKg'] as num).toDouble(),
  isCompleted: json['isCompleted'] as bool? ?? false,
  restDurationSeconds: (json['restDurationSeconds'] as num).toInt(),
);

Map<String, dynamic> _$SetLogToJson(_SetLog instance) => <String, dynamic>{
  'id': instance.id,
  'exerciseLogId': instance.exerciseLogId,
  'setNumber': instance.setNumber,
  'actualReps': instance.actualReps,
  'targetReps': instance.targetReps,
  'actualWeightKg': instance.actualWeightKg,
  'targetWeightKg': instance.targetWeightKg,
  'isCompleted': instance.isCompleted,
  'restDurationSeconds': instance.restDurationSeconds,
};
