import 'package:freezed_annotation/freezed_annotation.dart';

part 'form_cue.freezed.dart';
part 'form_cue.g.dart';

@freezed
class FormCue with _$FormCue {
  const factory FormCue({
    required String id,
    required String exerciseId,
    required bool isPositive,
    required String description,
  }) = _FormCue;

  factory FormCue.fromJson(Map<String, dynamic> json) => _$FormCueFromJson(json);
}
