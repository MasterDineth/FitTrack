// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SecurityActivity _$SecurityActivityFromJson(Map<String, dynamic> json) =>
    _SecurityActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      timestamp: json['timestamp'] as String,
      deviceInfo: json['deviceInfo'] as String,
      location: json['location'] as String,
      statusBadge: json['statusBadge'] as String,
    );

Map<String, dynamic> _$SecurityActivityToJson(_SecurityActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'timestamp': instance.timestamp,
      'deviceInfo': instance.deviceInfo,
      'location': instance.location,
      'statusBadge': instance.statusBadge,
    };
