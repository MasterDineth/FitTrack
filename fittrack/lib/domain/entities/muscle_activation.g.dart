// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_activation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MuscleActivation _$MuscleActivationFromJson(Map<String, dynamic> json) =>
    _MuscleActivation(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      muscleName: json['muscleName'] as String,
      role: $enumDecode(_$MuscleRoleEnumMap, json['role']),
      intensityPercentage: (json['intensityPercentage'] as num).toInt(),
    );

Map<String, dynamic> _$MuscleActivationToJson(_MuscleActivation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'muscleName': instance.muscleName,
      'role': _$MuscleRoleEnumMap[instance.role]!,
      'intensityPercentage': instance.intensityPercentage,
    };

const _$MuscleRoleEnumMap = {
  MuscleRole.agonist: 'agonist',
  MuscleRole.synergist: 'synergist',
  MuscleRole.stabilizer: 'stabilizer',
};
