import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/execution_step.dart';
import '../../domain/entities/form_cue.dart';
import '../../domain/entities/muscle_activation.dart';
import 'repository_providers.dart';

part 'custom_exercise_notifier.g.dart';

// ── Mutable draft types ───────────────────────────────────────────────────────

class ExecutionStepDraft {
  ExecutionStepDraft({required this.title, required this.instructions});
  String title;
  String instructions;

  ExecutionStepDraft copyWith({String? title, String? instructions}) =>
      ExecutionStepDraft(
        title: title ?? this.title,
        instructions: instructions ?? this.instructions,
      );
}

class FormCueDraft {
  FormCueDraft({required this.isPositive, required this.description});
  bool isPositive;
  String description;

  FormCueDraft copyWith({bool? isPositive, String? description}) => FormCueDraft(
        isPositive: isPositive ?? this.isPositive,
        description: description ?? this.description,
      );
}

class MuscleActivationDraft {
  MuscleActivationDraft({
    required this.muscleName,
    required this.role,
    required this.intensityPercentage,
  });

  String muscleName;
  MuscleRole role;
  int intensityPercentage;

  MuscleActivationDraft copyWith({
    String? muscleName,
    MuscleRole? role,
    int? intensityPercentage,
  }) => MuscleActivationDraft(
        muscleName: muscleName ?? this.muscleName,
        role: role ?? this.role,
        intensityPercentage: intensityPercentage ?? this.intensityPercentage,
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class CustomExerciseState {
  const CustomExerciseState({
    this.title = '',
    this.equipment = Equipment.other,
    this.movementClassification = MovementClassification.other,
    this.mediaPath,
    this.youtubeUrl,
    this.biomechanicsNotes,
    this.executionSteps = const [],
    this.formCues = const [],
    this.muscleActivations = const [],
    this.isSaving = false,
    this.saveError,
  });

  final String title;
  final Equipment equipment;
  final MovementClassification movementClassification;
  final String? mediaPath;
  final String? youtubeUrl;
  final String? biomechanicsNotes;
  final List<ExecutionStepDraft> executionSteps;
  final List<FormCueDraft> formCues;
  final List<MuscleActivationDraft> muscleActivations;
  final bool isSaving;
  final String? saveError;

  bool get isValid => title.trim().isNotEmpty;

  CustomExerciseState copyWith({
    String? title,
    Equipment? equipment,
    MovementClassification? movementClassification,
    String? mediaPath,
    String? youtubeUrl,
    String? biomechanicsNotes,
    List<ExecutionStepDraft>? executionSteps,
    List<FormCueDraft>? formCues,
    List<MuscleActivationDraft>? muscleActivations,
    bool? isSaving,
    String? saveError,
  }) => CustomExerciseState(
    title: title ?? this.title,
    equipment: equipment ?? this.equipment,
    movementClassification:
        movementClassification ?? this.movementClassification,
    mediaPath: mediaPath ?? this.mediaPath,
    youtubeUrl: youtubeUrl ?? this.youtubeUrl,
    biomechanicsNotes: biomechanicsNotes ?? this.biomechanicsNotes,
    executionSteps: executionSteps ?? this.executionSteps,
    formCues: formCues ?? this.formCues,
    muscleActivations: muscleActivations ?? this.muscleActivations,
    isSaving: isSaving ?? this.isSaving,
    saveError: saveError,
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

@riverpod
class CustomExerciseNotifier extends _$CustomExerciseNotifier {
  static const _uuid = Uuid();

  @override
  CustomExerciseState build() => const CustomExerciseState();

  void setTitle(String value) => state = state.copyWith(title: value);

  void setEquipment(Equipment value) =>
      state = state.copyWith(equipment: value);

  void setMovementClassification(MovementClassification value) =>
      state = state.copyWith(movementClassification: value);

  void setYoutubeUrl(String value) =>
      state = state.copyWith(youtubeUrl: value);

  void setBiomechanicsNotes(String value) =>
      state = state.copyWith(biomechanicsNotes: value);

  // ── Execution Steps ────────────────────────────────────────────────────

  void addExecutionStep() {
    state = state.copyWith(
      executionSteps: [
        ...state.executionSteps,
        ExecutionStepDraft(title: '', instructions: ''),
      ],
    );
  }

  void updateExecutionStep(int index, {String? title, String? instructions}) {
    final list = List<ExecutionStepDraft>.from(state.executionSteps);
    list[index] = list[index].copyWith(title: title, instructions: instructions);
    state = state.copyWith(executionSteps: list);
  }

  void removeExecutionStep(int index) {
    final list = List<ExecutionStepDraft>.from(state.executionSteps)
      ..removeAt(index);
    state = state.copyWith(executionSteps: list);
  }

  // ── Form Cues ──────────────────────────────────────────────────────────

  void addFormCue(FormCueDraft cue) {
    state = state.copyWith(formCues: [...state.formCues, cue]);
  }

  void removeFormCue(int index) {
    final list = List<FormCueDraft>.from(state.formCues)..removeAt(index);
    state = state.copyWith(formCues: list);
  }

  // ── Muscle Activations ─────────────────────────────────────────────────

  void addMuscleActivation(MuscleActivationDraft activation) {
    state = state.copyWith(
      muscleActivations: [...state.muscleActivations, activation],
    );
  }

  void updateMuscleActivationIntensity(int index, int intensity) {
    final list = List<MuscleActivationDraft>.from(state.muscleActivations);
    list[index] = list[index].copyWith(intensityPercentage: intensity);
    state = state.copyWith(muscleActivations: list);
  }

  void removeMuscleActivation(int index) {
    final list = List<MuscleActivationDraft>.from(state.muscleActivations)
      ..removeAt(index);
    state = state.copyWith(muscleActivations: list);
  }

  // ── Save ───────────────────────────────────────────────────────────────

  /// Persists the custom exercise with all sub-entities. Returns `true` on success.
  Future<bool> save() async {
    if (!state.isValid) return false;
    state = state.copyWith(isSaving: true, saveError: null);

    try {
      final repo = ref.read(exerciseRepositoryProvider);
      final exerciseId = _uuid.v4();

      final exercise = Exercise(
        id: exerciseId,
        name: state.title.trim(),
        equipment: state.equipment,
        movementClassification: state.movementClassification,
        youtubeUrl: state.youtubeUrl?.trim().isNotEmpty == true
            ? state.youtubeUrl
            : null,
        biomechanicsNotes: state.biomechanicsNotes?.trim().isNotEmpty == true
            ? state.biomechanicsNotes
            : null,
        isCustom: true,
      );

      await repo.saveExercise(exercise);

      await repo.saveExecutionSteps(
        exerciseId,
        state.executionSteps.asMap().entries.map((e) {
          return ExecutionStep(
            id: _uuid.v4(),
            exerciseId: exerciseId,
            stepNumber: e.key + 1,
            title: e.value.title,
            instructions: e.value.instructions,
          );
        }).toList(),
      );

      await repo.saveFormCues(
        exerciseId,
        state.formCues.map((c) {
          return FormCue(
            id: _uuid.v4(),
            exerciseId: exerciseId,
            isPositive: c.isPositive,
            description: c.description,
          );
        }).toList(),
      );

      await repo.saveMuscleActivations(
        exerciseId,
        state.muscleActivations.map((a) {
          return MuscleActivation(
            id: _uuid.v4(),
            exerciseId: exerciseId,
            muscleName: a.muscleName,
            role: a.role,
            intensityPercentage: a.intensityPercentage,
          );
        }).toList(),
      );

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, saveError: e.toString());
      return false;
    }
  }
}
