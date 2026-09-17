import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "FitTrack.db";
  static const _databaseVersion = 4;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop all tables
    final tables = [
      'user_profile',
      'set_logs', 'exercise_logs', 'workout_sessions',
      'schedule_exercises', 'schedules', 'form_cues',
      'execution_steps', 'muscle_activations', 'exercises'
    ];
    for (var table in tables) {
      await db.execute('DROP TABLE IF EXISTS $table');
    }
    // Recreate
    await _onCreate(db, newVersion);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        equipment TEXT NOT NULL,
        movementClassification TEXT NOT NULL,
        mediaUrl TEXT,
        youtubeUrl TEXT,
        biomechanicsNotes TEXT,
        isCustom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE muscle_activations (
        id TEXT PRIMARY KEY,
        exerciseId TEXT NOT NULL,
        muscleName TEXT NOT NULL,
        role TEXT NOT NULL,
        intensityPercentage INTEGER NOT NULL,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE execution_steps (
        id TEXT PRIMARY KEY,
        exerciseId TEXT NOT NULL,
        stepNumber INTEGER NOT NULL,
        title TEXT NOT NULL,
        instructions TEXT NOT NULL,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE form_cues (
        id TEXT PRIMARY KEY,
        exerciseId TEXT NOT NULL,
        isPositive INTEGER NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        targetMuscles TEXT NOT NULL,
        assignedWeekdays TEXT NOT NULL,
        orderIndex INTEGER NOT NULL,
        isArchived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE schedule_exercises (
        id TEXT PRIMARY KEY,
        scheduleId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        sortOrder INTEGER NOT NULL,
        targetSets INTEGER NOT NULL,
        targetReps INTEGER NOT NULL,
        targetWeightKg REAL NOT NULL,
        restDurationSeconds INTEGER NOT NULL,
        FOREIGN KEY (scheduleId) REFERENCES schedules (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        scheduleId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationSeconds INTEGER,
        totalCalories INTEGER,
        notes TEXT,
        FOREIGN KEY (scheduleId) REFERENCES schedules (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_logs (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        orderIndex INTEGER NOT NULL,
        isSkipped INTEGER NOT NULL DEFAULT 0,
        skip_reason TEXT,
        FOREIGN KEY (sessionId) REFERENCES workout_sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE set_logs (
        id TEXT PRIMARY KEY,
        exerciseLogId TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        actualReps INTEGER NOT NULL,
        targetReps INTEGER NOT NULL,
        actualWeightKg REAL NOT NULL,
        targetWeightKg REAL NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        restDurationSeconds INTEGER NOT NULL,
        FOREIGN KEY (exerciseLogId) REFERENCES exercise_logs (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        weightKg REAL NOT NULL,
        heightCm REAL NOT NULL,
        experienceLevel TEXT NOT NULL,
        primaryGoal TEXT NOT NULL,
        weeklyTargetDays INTEGER NOT NULL,
        profileImagePath TEXT
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Default User Profile
    await db.insert('user_profile', {
      'id': '1',
      'name': 'Dineth',
      'age': 20,
      'weightKg': 80.0,
      'heightCm': 170.0,
      'experienceLevel': 'Advanced',
      'primaryGoal': 'Hypertrophy & Strength',
      'weeklyTargetDays': 4,
      'profileImagePath': null,
    });

    // 10 Default Exercises
    final exercises = [
      {'id': 'ex1', 'name': 'BB Bench Press', 'equipment': 'barbell', 'movementClassification': 'compound'},
      {'id': 'ex2', 'name': 'Incline DB Press', 'equipment': 'dumbbell', 'movementClassification': 'compound'},
      {'id': 'ex3', 'name': 'Cable Flyes', 'equipment': 'cable', 'movementClassification': 'isolation'},
      {'id': 'ex4', 'name': 'Overhead Press', 'equipment': 'barbell', 'movementClassification': 'compound'},
      {'id': 'ex5', 'name': 'Lateral Raises', 'equipment': 'dumbbell', 'movementClassification': 'isolation'},
      {'id': 'ex6', 'name': 'Tricep Pushdowns', 'equipment': 'cable', 'movementClassification': 'isolation'},
      {'id': 'ex7', 'name': 'Overhead Tricep Extension', 'equipment': 'cable', 'movementClassification': 'isolation'},
      {'id': 'ex8', 'name': 'Barbell Squat', 'equipment': 'barbell', 'movementClassification': 'compound'},
      {'id': 'ex9', 'name': 'Bent-Over Row', 'equipment': 'barbell', 'movementClassification': 'compound'},
      {'id': 'ex10', 'name': 'Deadlift', 'equipment': 'barbell', 'movementClassification': 'compound'},
    ];

    for (var ex in exercises) {
      await db.insert('exercises', ex);
    }

    // 3 Default Schedules
    final schedules = [
      {
        'id': 'sch1', 'name': 'Day 1: Chest, Shoulders & Triceps', 'description': 'Push day focus',
        'targetMuscles': '["Chest", "Shoulders", "Triceps"]', 'assignedWeekdays': '[1, 4]', 'orderIndex': 1
      },
      {
        'id': 'sch2', 'name': 'Day 2: Back & Biceps', 'description': 'Pull day focus',
        'targetMuscles': '["Back", "Biceps"]', 'assignedWeekdays': '[2, 5]', 'orderIndex': 2
      },
      {
        'id': 'sch3', 'name': 'Day 3: Legs & Posterior Chain', 'description': 'Lower body focus',
        'targetMuscles': '["Legs", "Glutes", "Lower Back"]', 'assignedWeekdays': '[3, 6]', 'orderIndex': 3
      },
    ];

    for (var sch in schedules) {
      await db.insert('schedules', sch);
    }

    // Link schedule Day 1 (sch1) to 7 exercises
    final scheduleExercises = [
      {'id': 'se1', 'scheduleId': 'sch1', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 3, 'targetReps': 8, 'targetWeightKg': 60.0, 'restDurationSeconds': 120},
      {'id': 'se2', 'scheduleId': 'sch1', 'exerciseId': 'ex2', 'sortOrder': 2, 'targetSets': 3, 'targetReps': 10, 'targetWeightKg': 25.0, 'restDurationSeconds': 90},
      {'id': 'se3', 'scheduleId': 'sch1', 'exerciseId': 'ex3', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 15.0, 'restDurationSeconds': 60},
      {'id': 'se4', 'scheduleId': 'sch1', 'exerciseId': 'ex4', 'sortOrder': 4, 'targetSets': 3, 'targetReps': 8, 'targetWeightKg': 40.0, 'restDurationSeconds': 120},
      {'id': 'se5', 'scheduleId': 'sch1', 'exerciseId': 'ex5', 'sortOrder': 5, 'targetSets': 4, 'targetReps': 15, 'targetWeightKg': 10.0, 'restDurationSeconds': 60},
      {'id': 'se6', 'scheduleId': 'sch1', 'exerciseId': 'ex6', 'sortOrder': 6, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 20.0, 'restDurationSeconds': 60},
      {'id': 'se7', 'scheduleId': 'sch1', 'exerciseId': 'ex7', 'sortOrder': 7, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 15.0, 'restDurationSeconds': 60},
    ];

    for (var se in scheduleExercises) {
      await db.insert('schedule_exercises', se);
    }
  }
}
