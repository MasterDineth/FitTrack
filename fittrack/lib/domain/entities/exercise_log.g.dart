// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExerciseLog _$ExerciseLogFromJson(Map<String, dynamic> json) => _ExerciseLog(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  exerciseId: json['exerciseId'] as String,
  orderIndex: (json['orderIndex'] as num).toInt(),
  isSkipped: json['isSkipped'] as bool? ?? false,
  skipReason: json['skipReason'] as String?,
);

Map<String, dynamic> _$ExerciseLogToJson(_ExerciseLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'exerciseId': instance.exerciseId,
      'orderIndex': instance.orderIndex,
      'isSkipped': instance.isSkipped,
      'skipReason': instance.skipReason,
    };
