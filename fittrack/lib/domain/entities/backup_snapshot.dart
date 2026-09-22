import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_snapshot.freezed.dart';
part 'backup_snapshot.g.dart';

/// Immutable domain model representing a saved FitTrack database backup snapshot.
@freezed
abstract class BackupSnapshot with _$BackupSnapshot {
  const BackupSnapshot._();

  const factory BackupSnapshot({
    required String id,
    required String title,
    required String date,
    required String time,
    required String size,
    @Default(false) bool isLatest,
  }) = _BackupSnapshot;

  factory BackupSnapshot.fromJson(Map<String, dynamic> json) =>
      _$BackupSnapshotFromJson(json);
}
