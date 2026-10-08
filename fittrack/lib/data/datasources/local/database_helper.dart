import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "FitTrack.db";
  static const _databaseVersion = 11;

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
    if (oldVersion < 5) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user_profile (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            age INTEGER,
            weightKg REAL,
            heightCm REAL,
            experienceLevel TEXT,
            primaryGoal TEXT,
            weeklyTargetDays INTEGER,
            profileImagePath TEXT
          )
        ''');
      } on DatabaseException catch (_) {
        // Table may already exist
      } catch (_) {}
    }

    if (oldVersion < 6) {
      final columns = [
        'ALTER TABLE user_profile ADD COLUMN address TEXT',
        'ALTER TABLE user_profile ADD COLUMN phone TEXT',
        'ALTER TABLE user_profile ADD COLUMN isPhoneVerified INTEGER NOT NULL DEFAULT 0',
        'ALTER TABLE user_profile ADD COLUMN dob TEXT',
        'ALTER TABLE user_profile ADD COLUMN email TEXT',
        'ALTER TABLE user_profile ADD COLUMN username TEXT',
      ];

      for (final sql in columns) {
        try {
          await db.execute(sql);
        } on DatabaseException catch (_) {
          // Column may already exist; catch DatabaseException to prevent app launch crash
        } catch (_) {}
      }
    }

    if (oldVersion < 7) {
      try {
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_workout_sessions_start_time ON workout_sessions(startTime)',
        );
      } on DatabaseException catch (_) {}
    }

    if (oldVersion < 9) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS daily_habits (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            subtitle TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL,
            orderIndex INTEGER NOT NULL
          )
        ''');
        await db.insert('daily_habits', {
          'id': 'habit-1',
          'title': 'Morning Hydration (1L)',
          'subtitle': 'Completed at 7:45 AM',
          'isCompleted': 1,
          'status': 'done',
          'orderIndex': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('daily_habits', {
          'id': 'habit-2',
          'title': 'Target Protein Synthesis',
          'subtitle': '35g remaining for dinner',
          'isCompleted': 0,
          'status': 'pending',
          'orderIndex': 1,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('daily_habits', {
          'id': 'habit-3',
          'title': 'Sleep Protocol (8h target)',
          'subtitle': 'Wind-down routine at 10:30 PM',
          'isCompleted': 0,
          'status': 'tonight',
          'orderIndex': 2,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      } on DatabaseException catch (_) {}
    }

    if (oldVersion < 10) {
      try {
        final existingCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM workout_sessions'),
        ) ?? 0;
        if (existingCount == 0) {
          final now = DateTime.now();
          final s1Time = now.subtract(const Duration(days: 1, hours: 2));
          final s2Time = now.subtract(const Duration(days: 3, hours: 4));
          final s3Time = now.subtract(const Duration(days: 5, hours: 1));

          await db.insert('workout_sessions', {
            'id': 'sess-1',
            'scheduleId': 'sch1',
            'startTime': s1Time.toIso8601String(),
            'endTime': s1Time.add(const Duration(minutes: 52)).toIso8601String(),
            'durationSeconds': 3120,
            'totalCalories': 420,
            'notes': 'Push Hypertrophy',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await db.insert('workout_sessions', {
            'id': 'sess-2',
            'scheduleId': 'sch2',
            'startTime': s2Time.toIso8601String(),
            'endTime': s2Time.add(const Duration(minutes: 44)).toIso8601String(),
            'durationSeconds': 2640,
            'totalCalories': 365,
            'notes': 'Pull & Dynamic Core',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await db.insert('workout_sessions', {
            'id': 'sess-3',
            'scheduleId': 'sch3',
            'startTime': s3Time.toIso8601String(),
            'endTime': s3Time.add(const Duration(minutes: 55)).toIso8601String(),
            'durationSeconds': 3300,
            'totalCalories': 480,
            'notes': 'Legs & Posterior Chain',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      } on DatabaseException catch (_) {} catch (_) {}
    }

    if (oldVersion < 11) {
      final scheduleColumns = [
        'ALTER TABLE schedules ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0',
        'ALTER TABLE schedules ADD COLUMN focus TEXT NOT NULL DEFAULT "Hypertrophy"',
        'ALTER TABLE schedules ADD COLUMN experience TEXT NOT NULL DEFAULT "Intermediate"',
        'ALTER TABLE schedules ADD COLUMN equipment TEXT NOT NULL DEFAULT "Full Gym"',
        'ALTER TABLE schedules ADD COLUMN durationWeeks INTEGER NOT NULL DEFAULT 8',
        'ALTER TABLE schedules ADD COLUMN daysPerWeek INTEGER NOT NULL DEFAULT 4',
        'ALTER TABLE schedules ADD COLUMN estimatedMinutes INTEGER NOT NULL DEFAULT 45',
        'ALTER TABLE schedules ADD COLUMN isCustom INTEGER NOT NULL DEFAULT 0',
      ];

      for (final sql in scheduleColumns) {
        try {
          await db.execute(sql);
        } on DatabaseException catch (_) {} catch (_) {}
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS bookmarked_items (
            id TEXT PRIMARY KEY,
            createdAt TEXT NOT NULL
          )
        ''');
      } on DatabaseException catch (_) {} catch (_) {}

      try {
        await db.update('schedules', {
          'isFavorite': 1,
          'focus': 'Hypertrophy',
          'experience': 'Advanced',
          'equipment': 'Full Gym',
          'durationWeeks': 8,
          'daysPerWeek': 4,
          'estimatedMinutes': 50,
        }, where: 'id = ?', whereArgs: ['sch1']);

        await db.update('schedules', {
          'isFavorite': 0,
          'focus': 'Strength',
          'experience': 'Advanced',
          'equipment': 'Full Gym',
          'durationWeeks': 6,
          'daysPerWeek': 3,
          'estimatedMinutes': 55,
        }, where: 'id = ?', whereArgs: ['sch2']);

        await db.update('schedules', {
          'isFavorite': 1,
          'focus': 'Hypertrophy',
          'experience': 'Advanced',
          'equipment': 'Full Gym',
          'durationWeeks': 10,
          'daysPerWeek': 6,
          'estimatedMinutes': 60,
        }, where: 'id = ?', whereArgs: ['sch3']);

        await db.insert('schedules', {
          'id': 'sch4',
          'name': 'German Volume Training (GVT)',
          'description': '10×10 volume protocol for high neuromuscular exhaustion and extreme hypertrophy adaptation.',
          'targetMuscles': '["Chest", "Quads", "Back"]',
          'assignedWeekdays': '[1, 2, 4, 5]',
          'orderIndex': 4,
          'isArchived': 0,
          'isFavorite': 0,
          'focus': 'Advanced',
          'experience': 'Advanced',
          'equipment': 'Full Gym',
          'durationWeeks': 6,
          'daysPerWeek': 4,
          'estimatedMinutes': 40,
          'isCustom': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        await db.insert('schedules', {
          'id': 'sch5',
          'name': 'Torso & Limb Split',
          'description': 'Separates chest/back days from arm and quad isolation for maximum recovery and tendon longevity.',
          'targetMuscles': '["Torso", "Arms", "Quads", "Hamstrings"]',
          'assignedWeekdays': '[1, 2, 4, 5]',
          'orderIndex': 5,
          'isArchived': 0,
          'isFavorite': 0,
          'focus': 'Intermediate',
          'experience': 'Intermediate',
          'equipment': 'Barbell & Cable',
          'durationWeeks': 8,
          'daysPerWeek': 4,
          'estimatedMinutes': 45,
          'isCustom': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        await db.insert('schedule_exercises', {
          'id': 'se_sch4_1', 'scheduleId': 'sch4', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 10, 'targetReps': 10, 'targetWeightKg': 60.0, 'restDurationSeconds': 60,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('schedule_exercises', {
          'id': 'se_sch4_2', 'scheduleId': 'sch4', 'exerciseId': 'ex8', 'sortOrder': 2, 'targetSets': 10, 'targetReps': 10, 'targetWeightKg': 80.0, 'restDurationSeconds': 60,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('schedule_exercises', {
          'id': 'se_sch4_3', 'scheduleId': 'sch4', 'exerciseId': 'ex9', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 50.0, 'restDurationSeconds': 60,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        await db.insert('schedule_exercises', {
          'id': 'se_sch5_1', 'scheduleId': 'sch5', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 8, 'targetWeightKg': 70.0, 'restDurationSeconds': 90,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('schedule_exercises', {
          'id': 'se_sch5_2', 'scheduleId': 'sch5', 'exerciseId': 'ex9', 'sortOrder': 2, 'targetSets': 4, 'targetReps': 10, 'targetWeightKg': 55.0, 'restDurationSeconds': 90,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('schedule_exercises', {
          'id': 'se_sch5_3', 'scheduleId': 'sch5', 'exerciseId': 'ex3', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 15.0, 'restDurationSeconds': 60,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (_) {}
    }
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
        isArchived INTEGER NOT NULL DEFAULT 0,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        focus TEXT NOT NULL DEFAULT 'Hypertrophy',
        experience TEXT NOT NULL DEFAULT 'Intermediate',
        equipment TEXT NOT NULL DEFAULT 'Full Gym',
        durationWeeks INTEGER NOT NULL DEFAULT 8,
        daysPerWeek INTEGER NOT NULL DEFAULT 4,
        estimatedMinutes INTEGER NOT NULL DEFAULT 45,
        isCustom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarked_items (
        id TEXT PRIMARY KEY,
        createdAt TEXT NOT NULL
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

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_workout_sessions_start_time ON workout_sessions(startTime)',
    );

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
        profileImagePath TEXT,
        address TEXT,
        phone TEXT,
        isPhoneVerified INTEGER NOT NULL DEFAULT 0,
        dob TEXT,
        email TEXT,
        username TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        orderIndex INTEGER NOT NULL
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
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

    // 5 Default Schedules matching Stitch Design System
    final schedules = [
      {
        'id': 'sch1',
        'name': 'Push–Pull–Legs Split',
        'description': 'High mechanical tension for progressive muscular overload across push and pull patterns.',
        'targetMuscles': '["Chest", "Shoulders", "Triceps"]',
        'assignedWeekdays': '[1, 4]',
        'orderIndex': 1,
        'isArchived': 0,
        'isFavorite': 1,
        'focus': 'Hypertrophy',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 8,
        'daysPerWeek': 4,
        'estimatedMinutes': 50,
        'isCustom': 0,
      },
      {
        'id': 'sch2',
        'name': 'Strength Plateau Breaker',
        'description': 'Periodized heavy singles and dynamic effort waves designed to systematically shatter plateaus.',
        'targetMuscles': '["Back", "Core", "Quads"]',
        'assignedWeekdays': '[2, 5]',
        'orderIndex': 2,
        'isArchived': 0,
        'isFavorite': 0,
        'focus': 'Strength',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 6,
        'daysPerWeek': 3,
        'estimatedMinutes': 55,
        'isCustom': 0,
      },
      {
        'id': 'sch3',
        'name': 'Arnold Split Classic',
        'description': 'Chest & Back agonist/antagonist pairings followed by shoulders, arms, and leg specialization.',
        'targetMuscles': '["Chest", "Back", "Shoulders", "Arms", "Legs"]',
        'assignedWeekdays': '[3, 6]',
        'orderIndex': 3,
        'isArchived': 0,
        'isFavorite': 1,
        'focus': 'Hypertrophy',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 10,
        'daysPerWeek': 6,
        'estimatedMinutes': 60,
        'isCustom': 0,
      },
      {
        'id': 'sch4',
        'name': 'German Volume Training (GVT)',
        'description': '10×10 volume protocol for high neuromuscular exhaustion and extreme hypertrophy adaptation.',
        'targetMuscles': '["Chest", "Quads", "Back"]',
        'assignedWeekdays': '[1, 2, 4, 5]',
        'orderIndex': 4,
        'isArchived': 0,
        'isFavorite': 0,
        'focus': 'Advanced',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 6,
        'daysPerWeek': 4,
        'estimatedMinutes': 40,
        'isCustom': 0,
      },
      {
        'id': 'sch5',
        'name': 'Torso & Limb Split',
        'description': 'Separates chest/back days from arm and quad isolation for maximum recovery and tendon longevity.',
        'targetMuscles': '["Torso", "Arms", "Quads", "Hamstrings"]',
        'assignedWeekdays': '[1, 2, 4, 5]',
        'orderIndex': 5,
        'isArchived': 0,
        'isFavorite': 0,
        'focus': 'Intermediate',
        'experience': 'Intermediate',
        'equipment': 'Barbell & Cable',
        'durationWeeks': 8,
        'daysPerWeek': 4,
        'estimatedMinutes': 45,
        'isCustom': 0,
      },
    ];

    for (var sch in schedules) {
      await db.insert('schedules', sch, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Link schedules to exercises
    final scheduleExercises = [
      // sch1 (Push-Pull-Legs)
      {'id': 'se1', 'scheduleId': 'sch1', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 3, 'targetReps': 8, 'targetWeightKg': 60.0, 'restDurationSeconds': 120},
      {'id': 'se2', 'scheduleId': 'sch1', 'exerciseId': 'ex2', 'sortOrder': 2, 'targetSets': 3, 'targetReps': 10, 'targetWeightKg': 25.0, 'restDurationSeconds': 90},
      {'id': 'se3', 'scheduleId': 'sch1', 'exerciseId': 'ex3', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 15.0, 'restDurationSeconds': 60},
      {'id': 'se4', 'scheduleId': 'sch1', 'exerciseId': 'ex4', 'sortOrder': 4, 'targetSets': 3, 'targetReps': 8, 'targetWeightKg': 40.0, 'restDurationSeconds': 120},
      {'id': 'se5', 'scheduleId': 'sch1', 'exerciseId': 'ex5', 'sortOrder': 5, 'targetSets': 4, 'targetReps': 15, 'targetWeightKg': 10.0, 'restDurationSeconds': 60},
      {'id': 'se6', 'scheduleId': 'sch1', 'exerciseId': 'ex6', 'sortOrder': 6, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 20.0, 'restDurationSeconds': 60},
      {'id': 'se7', 'scheduleId': 'sch1', 'exerciseId': 'ex7', 'sortOrder': 7, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 15.0, 'restDurationSeconds': 60},

      // sch2 (Strength Plateau Breaker)
      {'id': 'se_sch2_1', 'scheduleId': 'sch2', 'exerciseId': 'ex8', 'sortOrder': 1, 'targetSets': 5, 'targetReps': 3, 'targetWeightKg': 100.0, 'restDurationSeconds': 180},
      {'id': 'se_sch2_2', 'scheduleId': 'sch2', 'exerciseId': 'ex1', 'sortOrder': 2, 'targetSets': 5, 'targetReps': 3, 'targetWeightKg': 85.0, 'restDurationSeconds': 180},
      {'id': 'se_sch2_3', 'scheduleId': 'sch2', 'exerciseId': 'ex10', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 5, 'targetWeightKg': 120.0, 'restDurationSeconds': 180},
      {'id': 'se_sch2_4', 'scheduleId': 'sch2', 'exerciseId': 'ex9', 'sortOrder': 4, 'targetSets': 4, 'targetReps': 6, 'targetWeightKg': 65.0, 'restDurationSeconds': 120},

      // sch3 (Arnold Split Classic)
      {'id': 'se_sch3_1', 'scheduleId': 'sch3', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 10, 'targetWeightKg': 70.0, 'restDurationSeconds': 90},
      {'id': 'se_sch3_2', 'scheduleId': 'sch3', 'exerciseId': 'ex9', 'sortOrder': 2, 'targetSets': 4, 'targetReps': 10, 'targetWeightKg': 55.0, 'restDurationSeconds': 90},
      {'id': 'se_sch3_3', 'scheduleId': 'sch3', 'exerciseId': 'ex4', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 35.0, 'restDurationSeconds': 90},
      {'id': 'se_sch3_4', 'scheduleId': 'sch3', 'exerciseId': 'ex6', 'sortOrder': 4, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 20.0, 'restDurationSeconds': 60},

      // sch4 (GVT)
      {'id': 'se_sch4_1', 'scheduleId': 'sch4', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 10, 'targetReps': 10, 'targetWeightKg': 60.0, 'restDurationSeconds': 60},
      {'id': 'se_sch4_2', 'scheduleId': 'sch4', 'exerciseId': 'ex8', 'sortOrder': 2, 'targetSets': 10, 'targetReps': 10, 'targetWeightKg': 80.0, 'restDurationSeconds': 60},
      {'id': 'se_sch4_3', 'scheduleId': 'sch4', 'exerciseId': 'ex9', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 50.0, 'restDurationSeconds': 60},

      // sch5 (Torso & Limb Split)
      {'id': 'se_sch5_1', 'scheduleId': 'sch5', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 8, 'targetWeightKg': 70.0, 'restDurationSeconds': 90},
      {'id': 'se_sch5_2', 'scheduleId': 'sch5', 'exerciseId': 'ex9', 'sortOrder': 2, 'targetSets': 4, 'targetReps': 10, 'targetWeightKg': 55.0, 'restDurationSeconds': 90},
      {'id': 'se_sch5_3', 'scheduleId': 'sch5', 'exerciseId': 'ex3', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 15.0, 'restDurationSeconds': 60},
    ];

    for (var se in scheduleExercises) {
      await db.insert('schedule_exercises', se, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Default Habits
    await db.insert('daily_habits', {
      'id': 'habit-1',
      'title': 'Morning Hydration (1L)',
      'subtitle': 'Completed at 7:45 AM',
      'isCompleted': 1,
      'status': 'done',
      'orderIndex': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('daily_habits', {
      'id': 'habit-2',
      'title': 'Target Protein Synthesis',
      'subtitle': '35g remaining for dinner',
      'isCompleted': 0,
      'status': 'pending',
      'orderIndex': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('daily_habits', {
      'id': 'habit-3',
      'title': 'Sleep Protocol (8h target)',
      'subtitle': 'Wind-down routine at 10:30 PM',
      'isCompleted': 0,
      'status': 'tonight',
      'orderIndex': 2,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Default Recent Sessions
    final now = DateTime.now();
    final s1Time = now.subtract(const Duration(days: 1, hours: 2));
    final s2Time = now.subtract(const Duration(days: 3, hours: 4));
    final s3Time = now.subtract(const Duration(days: 5, hours: 1));

    await db.insert('workout_sessions', {
      'id': 'sess-1',
      'scheduleId': 'sch1',
      'startTime': s1Time.toIso8601String(),
      'endTime': s1Time.add(const Duration(minutes: 52)).toIso8601String(),
      'durationSeconds': 3120,
      'totalCalories': 420,
      'notes': 'Push Hypertrophy',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('workout_sessions', {
      'id': 'sess-2',
      'scheduleId': 'sch2',
      'startTime': s2Time.toIso8601String(),
      'endTime': s2Time.add(const Duration(minutes: 44)).toIso8601String(),
      'durationSeconds': 2640,
      'totalCalories': 365,
      'notes': 'Pull & Dynamic Core',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('workout_sessions', {
      'id': 'sess-3',
      'scheduleId': 'sch3',
      'startTime': s3Time.toIso8601String(),
      'endTime': s3Time.add(const Duration(minutes: 55)).toIso8601String(),
      'durationSeconds': 3300,
      'totalCalories': 480,
      'notes': 'Legs & Posterior Chain',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
