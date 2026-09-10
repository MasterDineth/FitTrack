import '../../domain/entities/exercise.dart';
import '../../domain/entities/muscle_activation.dart';
import '../../domain/entities/execution_step.dart';
import '../../domain/entities/form_cue.dart';
import '../../domain/repositories/i_exercise_repository.dart';
import '../datasources/local/database_helper.dart';

class SqliteExerciseRepository implements IExerciseRepository {
  final DatabaseHelper _dbHelper;

  SqliteExerciseRepository(this._dbHelper);

  @override
  Future<List<Exercise>> getAllExercises() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');
    return maps.map((map) {
      final modMap = Map<String, dynamic>.from(map);
      modMap['isCustom'] = modMap['isCustom'] == 1;
      return Exercise.fromJson(modMap);
    }).toList();
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final modMap = Map<String, dynamic>.from(maps.first);
    modMap['isCustom'] = modMap['isCustom'] == 1;
    return Exercise.fromJson(modMap);
  }

  @override
  Future<List<MuscleActivation>> getMuscleActivations(String exerciseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'muscle_activations',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return maps.map((map) => MuscleActivation.fromJson(map)).toList();
  }

  @override
  Future<List<ExecutionStep>> getExecutionSteps(String exerciseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'execution_steps',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return maps.map((map) => ExecutionStep.fromJson(map)).toList();
  }

  @override
  Future<List<FormCue>> getFormCues(String exerciseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'form_cues',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return maps.map((map) {
      final modMap = Map<String, dynamic>.from(map);
      modMap['isPositive'] = modMap['isPositive'] == 1;
      return FormCue.fromJson(modMap);
    }).toList();
  }
}
