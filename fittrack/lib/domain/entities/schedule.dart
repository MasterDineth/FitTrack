import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

@freezed
class Schedule with _$Schedule {
  const factory Schedule({
    required String id,
    required String name,
    required String description,
    required List<String> targetMuscles,
    required List<int> assignedWeekdays,
    required int orderIndex,
    @Default(false) bool isArchived,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);
}
