// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    _WorkoutSession(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      totalCalories: (json['totalCalories'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$WorkoutSessionToJson(_WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scheduleId': instance.scheduleId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'totalCalories': instance.totalCalories,
      'notes': instance.notes,
    };
