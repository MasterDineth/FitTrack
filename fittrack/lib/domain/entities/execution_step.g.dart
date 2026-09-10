// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'execution_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExecutionStep _$ExecutionStepFromJson(Map<String, dynamic> json) =>
    _ExecutionStep(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      stepNumber: (json['stepNumber'] as num).toInt(),
      title: json['title'] as String,
      instructions: json['instructions'] as String,
    );

Map<String, dynamic> _$ExecutionStepToJson(_ExecutionStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'stepNumber': instance.stepNumber,
      'title': instance.title,
      'instructions': instance.instructions,
    };
