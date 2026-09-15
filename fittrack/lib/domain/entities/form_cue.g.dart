// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_cue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FormCue _$FormCueFromJson(Map<String, dynamic> json) => _FormCue(
  id: json['id'] as String,
  exerciseId: json['exerciseId'] as String,
  isPositive: json['isPositive'] as bool,
  description: json['description'] as String,
);

Map<String, dynamic> _$FormCueToJson(_FormCue instance) => <String, dynamic>{
  'id': instance.id,
  'exerciseId': instance.exerciseId,
  'isPositive': instance.isPositive,
  'description': instance.description,
};
