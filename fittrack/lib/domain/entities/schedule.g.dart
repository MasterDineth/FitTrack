// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Schedule _$ScheduleFromJson(Map<String, dynamic> json) => _Schedule(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  targetMuscles: (json['targetMuscles'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  assignedWeekdays: (json['assignedWeekdays'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  orderIndex: (json['orderIndex'] as num).toInt(),
  isArchived: json['isArchived'] as bool? ?? false,
);

Map<String, dynamic> _$ScheduleToJson(_Schedule instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'targetMuscles': instance.targetMuscles,
  'assignedWeekdays': instance.assignedWeekdays,
  'orderIndex': instance.orderIndex,
  'isArchived': instance.isArchived,
};
