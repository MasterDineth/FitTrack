import 'package:flutter/material.dart';
import '../providers/schedule_editor_notifier.dart';
import 'exercise_picker/add_exercise_picker_sheet.dart';

export 'exercise_picker/add_exercise_picker_sheet.dart';

/// Backward-compatible wrapper delegating to the redesigned [AddExercisePickerSheet].
class AddExerciseBottomSheet extends StatelessWidget {
  const AddExerciseBottomSheet({
    super.key,
    required this.onExercisesAdded,
    this.onCreateNew,
    this.currentExercisesCount = 0,
    this.existingExerciseIds = const <String>{},
  });

  final void Function(List<ScheduleExerciseEntry> selected) onExercisesAdded;
  final VoidCallback? onCreateNew;
  final int currentExercisesCount;
  final Set<String> existingExerciseIds;

  @override
  Widget build(BuildContext context) {
    return AddExercisePickerSheet(
      onExercisesAdded: onExercisesAdded,
      onCreateNew: onCreateNew,
      currentExercisesCount: currentExercisesCount,
      existingExerciseIds: existingExerciseIds,
    );
  }
}
