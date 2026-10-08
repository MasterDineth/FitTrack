import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

@freezed
abstract class Schedule with _$Schedule {
  const Schedule._();

  const factory Schedule({
    required String id,
    required String name,
    required String description,
    required List<String> targetMuscles,
    required List<int> assignedWeekdays,
    required int orderIndex,
    @Default(false) bool isArchived,
    @Default(false) bool isFavorite,
    @Default('Hypertrophy') String focus,
    @Default('Intermediate') String experience,
    @Default('Full Gym') String equipment,
    @Default(8) int durationWeeks,
    @Default(4) int daysPerWeek,
    @Default(45) int estimatedMinutes,
    @Default(false) bool isCustom,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);
}
