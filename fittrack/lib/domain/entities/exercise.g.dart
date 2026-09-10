// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  id: json['id'] as String,
  name: json['name'] as String,
  equipment: $enumDecode(_$EquipmentEnumMap, json['equipment']),
  movementClassification: $enumDecode(
    _$MovementClassificationEnumMap,
    json['movementClassification'],
  ),
  mediaUrl: json['mediaUrl'] as String?,
  youtubeUrl: json['youtubeUrl'] as String?,
  biomechanicsNotes: json['biomechanicsNotes'] as String?,
  isCustom: json['isCustom'] as bool? ?? false,
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'equipment': _$EquipmentEnumMap[instance.equipment]!,
  'movementClassification':
      _$MovementClassificationEnumMap[instance.movementClassification]!,
  'mediaUrl': instance.mediaUrl,
  'youtubeUrl': instance.youtubeUrl,
  'biomechanicsNotes': instance.biomechanicsNotes,
  'isCustom': instance.isCustom,
};

const _$EquipmentEnumMap = {
  Equipment.barbell: 'barbell',
  Equipment.dumbbell: 'dumbbell',
  Equipment.cable: 'cable',
  Equipment.machine: 'machine',
  Equipment.bodyweight: 'bodyweight',
  Equipment.other: 'other',
};

const _$MovementClassificationEnumMap = {
  MovementClassification.compound: 'compound',
  MovementClassification.isolation: 'isolation',
  MovementClassification.calisthenics: 'calisthenics',
  MovementClassification.mobility: 'mobility',
  MovementClassification.other: 'other',
};
