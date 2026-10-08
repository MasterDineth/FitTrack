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
  isFavorite: json['isFavorite'] as bool? ?? false,
  focus: json['focus'] as String? ?? 'Hypertrophy',
  experience: json['experience'] as String? ?? 'Intermediate',
  equipment: json['equipment'] as String? ?? 'Full Gym',
  durationWeeks: (json['durationWeeks'] as num?)?.toInt() ?? 8,
  daysPerWeek: (json['daysPerWeek'] as num?)?.toInt() ?? 4,
  estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 45,
  isCustom: json['isCustom'] as bool? ?? false,
);

Map<String, dynamic> _$ScheduleToJson(_Schedule instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'targetMuscles': instance.targetMuscles,
  'assignedWeekdays': instance.assignedWeekdays,
  'orderIndex': instance.orderIndex,
  'isArchived': instance.isArchived,
  'isFavorite': instance.isFavorite,
  'focus': instance.focus,
  'experience': instance.experience,
  'equipment': instance.equipment,
  'durationWeeks': instance.durationWeeks,
  'daysPerWeek': instance.daysPerWeek,
  'estimatedMinutes': instance.estimatedMinutes,
  'isCustom': instance.isCustom,
};
