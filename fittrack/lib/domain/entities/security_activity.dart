import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_activity.freezed.dart';
part 'security_activity.g.dart';

@freezed
abstract class SecurityActivity with _$SecurityActivity {
  const SecurityActivity._();

  const factory SecurityActivity({
    required String id,
    required String title,
    required String timestamp,
    required String deviceInfo,
    required String location,
    required String statusBadge,
  }) = _SecurityActivity;

  factory SecurityActivity.fromJson(Map<String, dynamic> json) =>
      _$SecurityActivityFromJson(json);
}
