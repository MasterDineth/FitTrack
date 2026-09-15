import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/schedule_exercise.dart';
import 'repository_providers.dart';

part 'schedule_editor_notifier.g.dart';

// ── Editable exercise entry (mutable in-form state) ──────────────────────────

/// A mutable view of a [ScheduleExercise] as edited inside the schedule form.
class ScheduleExerciseEntry {
  ScheduleExerciseEntry({
    required this.exerciseId,
    required this.exerciseName,
    this.targetSets = 3,
    this.targetReps = 10,
    this.targetWeightKg = 0.0,
    this.restDurationSeconds = 90,
  });

  final String exerciseId;
  final String exerciseName;
  int targetSets;
  int targetReps;
  double targetWeightKg;
  int restDurationSeconds;

  ScheduleExerciseEntry copyWith({
    int? targetSets,
    int? targetReps,
    double? targetWeightKg,
    int? restDurationSeconds,
  }) => ScheduleExerciseEntry(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    targetSets: targetSets ?? this.targetSets,
    targetReps: targetReps ?? this.targetReps,
    targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
  );
}

// ── State ─────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the schedule editor form.
class ScheduleEditorState {
  const ScheduleEditorState({
    this.name = '',
    this.description = '',
    this.targetMuscles = const [],
    this.assignedWeekdays = const [],
    this.exercises = const [],
    this.isSaving = false,
    this.saveError,
  });

  final String name;
  final String description;
  final List<String> targetMuscles;
  final List<int> assignedWeekdays;
  final List<ScheduleExerciseEntry> exercises;
  final bool isSaving;
  final String? saveError;

  ScheduleEditorState copyWith({
    String? name,
    String? description,
    List<String>? targetMuscles,
    List<int>? assignedWeekdays,
    List<ScheduleExerciseEntry>? exercises,
    bool? isSaving,
    String? saveError,
  }) => ScheduleEditorState(
    name: name ?? this.name,
    description: description ?? this.description,
    targetMuscles: targetMuscles ?? this.targetMuscles,
    assignedWeekdays: assignedWeekdays ?? this.assignedWeekdays,
    exercises: exercises ?? this.exercises,
    isSaving: isSaving ?? this.isSaving,
    saveError: saveError,
  );

  // ── Computed properties ──────────────────────────────────────────────────

  /// Estimated total workout duration in seconds.
  int get totalDurationSeconds {
    int total = 0;
    for (final ex in exercises) {
      if (ex.targetSets <= 0) continue;
      total += (ex.targetSets * 60) +
          ((ex.targetSets - 1) * ex.restDurationSeconds) +
          90;
    }
    return total;
  }

  String get totalDurationFormatted {
    final mins = totalDurationSeconds ~/ 60;
    return '${mins}m';
  }

  int get totalSets => exercises.fold(0, (s, e) => s + e.targetSets);

  /// Rough estimate: ~5 kcal/min of lifting activity.
  int get estimatedCalories => ((totalDurationSeconds / 60) * 5).round();

  bool get isValid => name.trim().isNotEmpty;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

@riverpod
class ScheduleEditorNotifier extends _$ScheduleEditorNotifier {
  static const _uuid = Uuid();

  @override
  ScheduleEditorState build() => const ScheduleEditorState();

  void setName(String value) => state = state.copyWith(name: value);

  void setDescription(String value) =>
      state = state.copyWith(description: value);

  void toggleMuscle(String muscle) {
    final current = List<String>.from(state.targetMuscles);
    if (current.contains(muscle)) {
      current.remove(muscle);
    } else {
      current.add(muscle);
    }
    state = state.copyWith(targetMuscles: current);
  }

  /// Toggles a weekday (1 = Monday … 7 = Sunday).
  void toggleWeekday(int weekday) {
    final current = List<int>.from(state.assignedWeekdays);
    if (current.contains(weekday)) {
      current.remove(weekday);
    } else {
      current.add(weekday);
    }
    current.sort();
    state = state.copyWith(assignedWeekdays: current);
  }

  void addExercise(ScheduleExerciseEntry entry) {
    state = state.copyWith(
      exercises: [...state.exercises, entry],
    );
  }

  void removeExercise(int index) {
    final updated = List<ScheduleExerciseEntry>.from(state.exercises)
      ..removeAt(index);
    state = state.copyWith(exercises: updated);
  }

  void reorderExercises(int oldIndex, int newIndex) {
    final list = List<ScheduleExerciseEntry>.from(state.exercises);
    final item = list.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    list.insert(insertAt, item);
    state = state.copyWith(exercises: list);
  }

  void updateExerciseParam(
    int index, {
    int? sets,
    int? reps,
    double? weightKg,
    int? restSeconds,
  }) {
    final list = List<ScheduleExerciseEntry>.from(state.exercises);
    list[index] = list[index].copyWith(
      targetSets: sets,
      targetReps: reps,
      targetWeightKg: weightKg,
      restDurationSeconds: restSeconds,
    );
    state = state.copyWith(exercises: list);
  }

  /// Persists the schedule. Returns `true` on success.
  Future<bool> save() async {
    if (!state.isValid) return false;
    state = state.copyWith(isSaving: true, saveError: null);

    try {
      final repo = ref.read(scheduleRepositoryProvider);
      final scheduleId = _uuid.v4();

      final schedule = Schedule(
        id: scheduleId,
        name: state.name.trim(),
        description: state.description.trim(),
        targetMuscles: state.targetMuscles,
        assignedWeekdays: state.assignedWeekdays,
        orderIndex: DateTime.now().millisecondsSinceEpoch,
      );

      final exercises = state.exercises.asMap().entries.map((entry) {
        return ScheduleExercise(
          id: _uuid.v4(),
          scheduleId: scheduleId,
          exerciseId: entry.value.exerciseId,
          sortOrder: entry.key,
          targetSets: entry.value.targetSets,
          targetReps: entry.value.targetReps,
          targetWeightKg: entry.value.targetWeightKg,
          restDurationSeconds: entry.value.restDurationSeconds,
        );
      }).toList();

      await repo.saveSchedule(schedule, exercises);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, saveError: e.toString());
      return false;
    }
  }
}
