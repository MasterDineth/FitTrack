// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BackupSnapshot _$BackupSnapshotFromJson(Map<String, dynamic> json) =>
    _BackupSnapshot(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      size: json['size'] as String,
      isLatest: json['isLatest'] as bool? ?? false,
    );

Map<String, dynamic> _$BackupSnapshotToJson(_BackupSnapshot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'date': instance.date,
      'time': instance.time,
      'size': instance.size,
      'isLatest': instance.isLatest,
    };
