import 'package:freezed_annotation/freezed_annotation.dart';

part 'execution_step.freezed.dart';
part 'execution_step.g.dart';

@freezed
abstract class ExecutionStep with _$ExecutionStep {
  const ExecutionStep._();

  const factory ExecutionStep({
    required String id,
    required String exerciseId,
    required int stepNumber,
    required String title,
    required String instructions,
  }) = _ExecutionStep;

  factory ExecutionStep.fromJson(Map<String, dynamic> json) => _$ExecutionStepFromJson(json);
}
