// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSchedule _$WorkoutScheduleFromJson(Map<String, dynamic> json) =>
    _WorkoutSchedule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      focus: json['focus'] as String,
      experience: json['experience'] as String,
      equipment: json['equipment'] as String,
      durationWeeks: (json['durationWeeks'] as num).toInt(),
      daysPerWeek: (json['daysPerWeek'] as num).toInt(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? false,
      targetMuscles:
          (json['targetMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 0,
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => ScheduleExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ScheduleExercise>[],
    );

Map<String, dynamic> _$WorkoutScheduleToJson(_WorkoutSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'focus': instance.focus,
      'experience': instance.experience,
      'equipment': instance.equipment,
      'durationWeeks': instance.durationWeeks,
      'daysPerWeek': instance.daysPerWeek,
      'isFavorite': instance.isFavorite,
      'isCustom': instance.isCustom,
      'targetMuscles': instance.targetMuscles,
      'exerciseCount': instance.exerciseCount,
      'estimatedMinutes': instance.estimatedMinutes,
      'exercises': instance.exercises,
    };
