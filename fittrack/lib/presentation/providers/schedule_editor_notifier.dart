import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/schedule.dart';
import 'repository_providers.dart';
import 'schedules_provider.dart';

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
    this.equipment = 'Barbell',
    this.movementType = 'Compound',
    this.mediaUrl,
  });

  final String exerciseId;
  final String exerciseName;
  final String equipment;
  final String movementType;
  final String? mediaUrl;
  int targetSets;
  int targetReps;
  double targetWeightKg;
  int restDurationSeconds;

  String get formattedRestTime {
    final m = restDurationSeconds ~/ 60;
    final s = restDurationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  int get estimatedDurationMinutes {
    if (targetSets <= 0) return 0;
    final totalSec = (targetSets * 60) + ((targetSets - 1) * restDurationSeconds);
    return (totalSec / 60).round().clamp(1, 60);
  }

  ScheduleExerciseEntry copyWith({
    int? targetSets,
    int? targetReps,
    double? targetWeightKg,
    int? restDurationSeconds,
    String? equipment,
    String? movementType,
    String? mediaUrl,
  }) => ScheduleExerciseEntry(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    targetSets: targetSets ?? this.targetSets,
    targetReps: targetReps ?? this.targetReps,
    targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
    equipment: equipment ?? this.equipment,
    movementType: movementType ?? this.movementType,
    mediaUrl: mediaUrl ?? this.mediaUrl,
  );
}

// ── State ─────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the schedule editor form.
class ScheduleEditorState {
  const ScheduleEditorState({
    this.name = '',
    this.description = '',
    this.coverImagePath,
    this.targetMuscles = const [],
    this.assignedWeekdays = const [],
    this.exercises = const [],
    this.isSaving = false,
    this.saveError,
  });

  final String name;
  final String description;
  final String? coverImagePath;
  final List<String> targetMuscles;
  final List<int> assignedWeekdays;
  final List<ScheduleExerciseEntry> exercises;
  final bool isSaving;
  final String? saveError;

  ScheduleEditorState copyWith({
    String? name,
    String? description,
    String? coverImagePath,
    bool clearCoverImage = false,
    List<String>? targetMuscles,
    List<int>? assignedWeekdays,
    List<ScheduleExerciseEntry>? exercises,
    bool? isSaving,
    String? saveError,
  }) => ScheduleEditorState(
    name: name ?? this.name,
    description: description ?? this.description,
    coverImagePath: clearCoverImage ? null : (coverImagePath ?? this.coverImagePath),
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
    final mins = (totalDurationSeconds / 60).round();
    return '~$mins min';
  }

  int get totalSets => exercises.fold(0, (s, e) => s + e.targetSets);

  /// Estimate: ~5.2 kcal/min of lifting activity.
  int get estimatedCalories => ((totalDurationSeconds / 60) * 5.2).round();

  /// Required: name, target muscles (1-3), at least 3 exercises (3-12).
  /// Optional: cover image, description, weekly schedule (max 3 days).
  bool get isValid =>
      name.trim().isNotEmpty &&
      targetMuscles.isNotEmpty &&
      targetMuscles.length <= 3 &&
      exercises.length >= 3 &&
      exercises.length <= 12 &&
      assignedWeekdays.length <= 3;

  String? get validationMessage {
    if (name.trim().isEmpty) {
      return 'Please enter a schedule name';
    }
    if (targetMuscles.isEmpty) {
      return 'Please select at least 1 target muscle';
    }
    if (targetMuscles.length > 3) {
      return 'Maximum 3 target muscles allowed';
    }
    if (exercises.length < 3) {
      return 'Please add at least 3 exercises (currently ${exercises.length})';
    }
    if (exercises.length > 12) {
      return 'Maximum 12 exercises allowed';
    }
    if (assignedWeekdays.length > 3) {
      return 'Maximum 3 days per week allowed';
    }
    return null;
  }
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

  void setCoverImagePath(String? path) {
    if (path == null) {
      state = state.copyWith(clearCoverImage: true);
    } else {
      state = state.copyWith(coverImagePath: path);
    }
  }

  /// Toggles a target muscle. Enforces max 3 limit.
  /// Returns `true` if updated, `false` if blocked by max limit.
  bool toggleMuscle(String muscle) {
    final current = List<String>.from(state.targetMuscles);
    if (current.contains(muscle)) {
      current.remove(muscle);
      state = state.copyWith(targetMuscles: current);
      return true;
    }
    if (current.length >= 3) {
      return false;
    }
    current.add(muscle);
    state = state.copyWith(targetMuscles: current);
    return true;
  }

  /// Toggles a weekday (1 = Monday … 7 = Sunday). Enforces max 3 days limit.
  /// Returns `true` if updated, `false` if blocked by max limit.
  bool toggleWeekday(int weekday) {
    final current = List<int>.from(state.assignedWeekdays);
    if (current.contains(weekday)) {
      current.remove(weekday);
      current.sort();
      state = state.copyWith(assignedWeekdays: current);
      return true;
    }
    if (current.length >= 3) {
      return false;
    }
    current.add(weekday);
    current.sort();
    state = state.copyWith(assignedWeekdays: current);
    return true;
  }

  /// Adds a single exercise if current count < 12.
  bool addExercise(ScheduleExerciseEntry entry) {
    if (state.exercises.length >= 12) return false;
    state = state.copyWith(
      exercises: [...state.exercises, entry],
    );
    return true;
  }

  /// Adds multiple exercises up to the 12 exercises limit.
  void addExercises(List<ScheduleExerciseEntry> entries) {
    final remainingSlots = 12 - state.exercises.length;
    if (remainingSlots <= 0) return;
    final toAdd = entries.take(remainingSlots).toList();
    state = state.copyWith(
      exercises: [...state.exercises, ...toAdd],
    );
  }

  void removeExercise(int index) {
    if (index < 0 || index >= state.exercises.length) return;
    final updated = List<ScheduleExerciseEntry>.from(state.exercises)
      ..removeAt(index);
    state = state.copyWith(exercises: updated);
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.exercises.length) return;
    final list = List<ScheduleExerciseEntry>.from(state.exercises);
    final item = list.removeAt(oldIndex);
    final insertAt = newIndex.clamp(0, list.length);
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
    if (index < 0 || index >= state.exercises.length) return;
    final list = List<ScheduleExerciseEntry>.from(state.exercises);
    list[index] = list[index].copyWith(
      targetSets: sets?.clamp(1, 30),
      targetReps: reps?.clamp(1, 100),
      targetWeightKg: weightKg != null ? (weightKg < 0 ? 0.0 : weightKg) : null,
      restDurationSeconds: restSeconds?.clamp(0, 600),
    );
    state = state.copyWith(exercises: list);
  }

  void reset() {
    state = const ScheduleEditorState();
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
        daysPerWeek: state.assignedWeekdays.isNotEmpty ? state.assignedWeekdays.length : 3,
        estimatedMinutes: (state.totalDurationSeconds / 60).round().clamp(15, 120),
        isCustom: true,
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
      ref.invalidate(schedulesNotifierProvider);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, saveError: e.toString());
      return false;
    }
  }
}
