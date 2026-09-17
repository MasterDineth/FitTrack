// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  weightKg: (json['weightKg'] as num).toDouble(),
  heightCm: (json['heightCm'] as num).toDouble(),
  experienceLevel: json['experienceLevel'] as String,
  primaryGoal: json['primaryGoal'] as String,
  weeklyTargetDays: (json['weeklyTargetDays'] as num).toInt(),
  profileImagePath: json['profileImagePath'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'weightKg': instance.weightKg,
      'heightCm': instance.heightCm,
      'experienceLevel': instance.experienceLevel,
      'primaryGoal': instance.primaryGoal,
      'weeklyTargetDays': instance.weeklyTargetDays,
      'profileImagePath': instance.profileImagePath,
    };
