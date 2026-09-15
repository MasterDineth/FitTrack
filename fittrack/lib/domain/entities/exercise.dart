import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

enum Equipment {
  barbell,
  dumbbell,
  cable,
  machine,
  bodyweight,
  other
}

enum MovementClassification {
  compound,
  isolation,
  calisthenics,
  mobility,
  other
}

@freezed
abstract class Exercise with _$Exercise {
  const Exercise._();

  const factory Exercise({
    required String id,
    required String name,
    required Equipment equipment,
    required MovementClassification movementClassification,
    String? mediaUrl,
    String? youtubeUrl,
    String? biomechanicsNotes,
    @Default(false) bool isCustom,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
}
