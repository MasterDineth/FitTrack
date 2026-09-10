import '../entities/exercise.dart';
import '../entities/muscle_activation.dart';
import '../entities/execution_step.dart';
import '../entities/form_cue.dart';

abstract class IExerciseRepository {
  Future<List<Exercise>> getAllExercises();
  Future<Exercise?> getExerciseById(String id);
  Future<List<MuscleActivation>> getMuscleActivations(String exerciseId);
  Future<List<ExecutionStep>> getExecutionSteps(String exerciseId);
  Future<List<FormCue>> getFormCues(String exerciseId);
}
