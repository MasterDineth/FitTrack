import 'package:freezed_annotation/freezed_annotation.dart';

part 'muscle_activation.freezed.dart';
part 'muscle_activation.g.dart';

enum MuscleRole {
  agonist,
  synergist,
  stabilizer
}

@freezed
abstract class MuscleActivation with _$MuscleActivation {
  const MuscleActivation._();

  const factory MuscleActivation({
    required String id,
    required String exerciseId,
    required String muscleName,
    required MuscleRole role,
    required int intensityPercentage,
  }) = _MuscleActivation;

  factory MuscleActivation.fromJson(Map<String, dynamic> json) => _$MuscleActivationFromJson(json);
}
