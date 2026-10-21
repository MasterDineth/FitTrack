import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/execution_step.dart';
import '../../domain/entities/form_cue.dart';
import '../../domain/entities/muscle_activation.dart';
import 'repository_providers.dart';

/// Raised when an exercise id cannot be resolved to a stored exercise.
class ExerciseNotFoundException implements Exception {
  const ExerciseNotFoundException(this.exerciseId);

  final String exerciseId;

  @override
  String toString() => 'Exercise "$exerciseId" was not found';
}

/// Every persisted detail recorded for a single exercise.
///
/// Mirrors what the Create Exercise screen stores, so the details screen can
/// render exactly what the user recorded — nothing is invented or back-filled.
class ExerciseDetails {
  const ExerciseDetails({
    required this.exercise,
    required this.steps,
    required this.cues,
    required this.activations,
  });

  final Exercise exercise;
  final List<ExecutionStep> steps;
  final List<FormCue> cues;
  final List<MuscleActivation> activations;

  /// The muscle carrying the highest recorded activation, if any.
  MuscleActivation? get primaryActivation {
    if (activations.isEmpty) return null;
    final sorted = [...activations]
      ..sort((a, b) => b.intensityPercentage.compareTo(a.intensityPercentage));
    return sorted.first;
  }

  /// Description recorded with the exercise, or `null` when left empty.
  String? get description {
    final notes = exercise.biomechanicsNotes?.trim();
    if (notes == null || notes.isEmpty) return null;
    return notes;
  }

  /// YouTube link recorded with the exercise, or `null` when left empty.
  String? get youtubeLink {
    final url = exercise.youtubeUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return url;
  }
}

/// Loads an exercise together with its steps, cues and muscle activations.
///
/// Automatic retry is disabled: a missing exercise is a permanent condition
/// rather than a transient failure, and the screen offers a manual "Try again"
/// action for genuine read errors.
final exerciseDetailsProvider =
    FutureProvider.autoDispose.family<ExerciseDetails, String>((ref, exerciseId) async {
  final repository = ref.watch(exerciseRepositoryProvider);

  final exercise = await repository.getExerciseById(exerciseId);
  if (exercise == null) {
    throw ExerciseNotFoundException(exerciseId);
  }

  final steps = await repository.getExecutionSteps(exerciseId);
  final cues = await repository.getFormCues(exerciseId);
  final activations = await repository.getMuscleActivations(exerciseId);

  return ExerciseDetails(
    exercise: exercise,
    steps: steps,
    cues: cues,
    activations: activations,
  );
}, retry: (retryCount, error) => null);
