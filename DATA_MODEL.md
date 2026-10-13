# FitTrack User Data Model & Database Schema

Based on the onboarding flow analysis, the data model is divided into three core domains: Authentication, Body Telemetry, and Fitness Goals.

## 1. User (Authentication)
Handles identity and security.
*   **id** `String (UUID)`: Primary Key
*   **email** `String`: Unique user email
*   **passwordHash** `String`: Encrypted password
*   **createdAt** `DateTime`: Account creation timestamp
*   **updatedAt** `DateTime`: Last update timestamp

## 2. Body Telemetry
Captures biometric data required for calculating BMI, BMR, and physical tracking.
*   **id** `String (UUID)`: Primary Key
*   **userId** `String (UUID)`: Foreign Key (User)
*   **unitSystem** `Enum`: `metric` (kg/cm) or `imperial` (lbs/ft)
*   **biologicalSex** `Enum`: `male`, `female`, `other`
*   **age** `Integer`: User's age in years (e.g., 24)
*   **weight** `Double`: Current weight
*   **height** `Double`: Standing stature
*   **recordedAt** `DateTime`: Timestamp of when the telemetry was recorded

## 3. Fitness Profile (Goals & Setup)
Captures the user's training experience, goals, and constraints to tailor the algorithm.
*   **id** `String (UUID)`: Primary Key
*   **userId** `String (UUID)`: Foreign Key (User)
*   **primaryFocus** `Enum`: 
    *   `hypertrophy` (Build Muscle)
    *   `strength` (Increase Strength & PRs)
    *   `fat_loss` (Fat Loss & Conditioning)
*   **liftingExperience** `Enum`: 
    *   `beginner` (< 6 months)
    *   `intermediate` (6m - 2 years)
    *   `advanced` (2+ years)
*   **weeklyFrequency** `Integer`: Days per week (e.g., 2, 3, 4, 5, 6)
*   **availableEquipment** `Enum`: 
    *   `full_gym`
    *   `barbell_dumbbells`
    *   `home_bodyweight`
*   **updatedAt** `DateTime`: Timestamp of the last profile update

## 4. Workout Sessions & Execution History (Database Version 12)
Manages completed and active workout sessions, exercise logs, and set-by-set telemetry.

### `workout_sessions` Table
Captures high-level telemetry and status for an individual workout session.
*   **id** `TEXT PRIMARY KEY`: Unique session identifier (e.g. `sess-1`)
*   **scheduleId** `TEXT NOT NULL`: Foreign key referencing the workout schedule
*   **startTime** `TEXT NOT NULL`: ISO-8601 UTC timestamp of workout start (indexed: `idx_workout_sessions_start_time`)
*   **endTime** `TEXT`: ISO-8601 UTC timestamp of workout completion
*   **durationSeconds** `INTEGER`: Total active workout duration in seconds
*   **totalCalories** `INTEGER`: Estimated active calorie burn
*   **notes** `TEXT`: User workout notes and session reflections (e.g., PR comments)
*   **intensity** `TEXT` *(Added in v12)*: Subjective or telemetry intensity label (e.g. `Intense Session`, `RPE 8.8 (Optimal)`)
*   **totalSets** `INTEGER` *(Added in v12)*: Total completed sets aggregated in the session
*   **totalReps** `INTEGER` *(Added in v12)*: Total repetitions across all sets in the session
*   **totalVolumeKg** `REAL` *(Added in v12)*: Total volume in kg lifted during the session

### `exercise_logs` Table
Represents an individual exercise performed within a workout session.
*   **id** `TEXT PRIMARY KEY`: Unique log identifier
*   **sessionId** `TEXT NOT NULL`: Foreign key referencing `workout_sessions` (indexed: `idx_exercise_logs_session_id`)
*   **exerciseId** `TEXT NOT NULL`: Foreign key referencing `exercises`
*   **orderIndex** `INTEGER NOT NULL`: 0-indexed execution sequence order

### `set_logs` Table
Contains set-by-set weight, repetitions, and performance milestones.
*   **id** `TEXT PRIMARY KEY`: Unique set record identifier
*   **exerciseLogId** `TEXT NOT NULL`: Foreign key referencing `exercise_logs` (indexed: `idx_set_logs_exercise_log_id`)
*   **setNumber** `INTEGER NOT NULL`: 1-indexed set number within the exercise
*   **targetReps** `INTEGER`: Planned target repetitions
*   **actualReps** `INTEGER`: Completed repetitions
*   **targetWeightKg** `REAL`: Target weight in kilograms
*   **actualWeightKg** `REAL`: Executed weight in kilograms
*   **isCompleted** `INTEGER NOT NULL`: Boolean flag (0 or 1) indicating set completion
*   **restDurationSeconds** `INTEGER`: Rest period duration in seconds

### Database Migrations Summary
*   **Version 1-11:** User authentication, body telemetry, fitness goals, routines, and initial workout logging.
*   **Version 12:** Added `intensity`, `totalSets`, `totalReps`, `totalVolumeKg` columns to `workout_sessions`, created composite indexes `idx_exercise_logs_session_id`, `idx_set_logs_exercise_log_id`, and `idx_workout_sessions_start_time`, and seeded initial September 2026 workout history records for Stitch compliance.

## 5. Schedules & Schedule Exercises (`schedules`, `schedule_exercises`)
Manages workout routines, training splits, and exercise definitions.

### `schedules` Table
*   **id** `TEXT PRIMARY KEY`: Schedule UUID (e.g. `sched-push-a`)
*   **name** `TEXT NOT NULL`: Schedule title (e.g. `Push Hypertrophy A`)
*   **description** `TEXT`: Optional description
*   **targetMuscles** `TEXT`: Comma-separated list of target muscles (up to 3, e.g. `Chest,Shoulders,Triceps`)
*   **weeklyDays** `TEXT`: Comma-separated list of days of week (up to 3, e.g. `Tuesday,Friday`)
*   **coverImagePath** `TEXT`: Optional file path or bundled asset URL
*   **isFavorite** `INTEGER DEFAULT 0`: Favorite/bookmark toggle flag
*   **createdAt** `TEXT NOT NULL`: ISO-8601 UTC timestamp

### `schedule_exercises` Table
*   **id** `TEXT PRIMARY KEY`: Association entry UUID
*   **scheduleId** `TEXT NOT NULL`: Foreign key referencing `schedules`
*   **exerciseId** `TEXT NOT NULL`: Foreign key referencing `exercises`
*   **orderIndex** `INTEGER NOT NULL`: 0-indexed order of execution (reorderable via drag)
*   **targetSets** `INTEGER NOT NULL DEFAULT 3`: Prescribed sets
*   **targetReps** `INTEGER NOT NULL DEFAULT 10`: Prescribed reps
*   **targetWeightKg** `REAL NOT NULL DEFAULT 0.0`: Prescribed weight in kilograms (0 = bodyweight)
*   **restSeconds** `INTEGER NOT NULL DEFAULT 90`: Rest time between sets in seconds

## 6. Exercises & Biomechanical Anatomy (`exercises`, `muscle_activations`, `execution_steps`, `form_cues`)
Manages standard and user-defined custom exercises, step-by-step execution guides, form cues, and muscle activation ratios.

### `exercises` Table
*   **id** `TEXT PRIMARY KEY`: Unique exercise UUID (e.g. `ex-bench-press`)
*   **name** `TEXT NOT NULL`: Exercise name (e.g. `Barbell Flat Bench Press`)
*   **equipment** `TEXT NOT NULL`: Required equipment type (`barbell`, `dumbbell`, `cable`, `machine`, `bodyweight`, `other`)
*   **movementClassification** `TEXT NOT NULL`: Biomechanical movement type (`compound`, `isolation`, `unilateral`, `isometric`, `other`)
*   **mediaUrl** `TEXT`: Local file path or asset URI to cover demonstration image
*   **youtubeUrl** `TEXT`: Optional YouTube tutorial or demonstration URL
*   **biomechanicsNotes** `TEXT`: Biomechanical movement commentary or tips
*   **isCustom** `INTEGER NOT NULL DEFAULT 0`: Flag distinguishing user-created exercises (1) from system exercises (0)

### `muscle_activations` Table
Maps muscle involvement, role, and activation percentage for each exercise (up to 3 target muscles).
*   **id** `TEXT PRIMARY KEY`: Unique activation UUID
*   **exerciseId** `TEXT NOT NULL`: Foreign key referencing `exercises` (ON DELETE CASCADE)
*   **muscleName** `TEXT NOT NULL`: Muscle group name (e.g. `Pectoralis Major`, `Triceps Brachii`)
*   **role** `TEXT NOT NULL`: Biomechanical role (`primeMover`, `synergist`, `stabilizer`)
*   **intensityPercentage** `INTEGER NOT NULL`: Activation intensity share percentage (5% - 100%)

### `execution_steps` Table
Sequential, ordered instructions for proper exercise execution (up to 3 steps).
*   **id** `TEXT PRIMARY KEY`: Unique step UUID
*   **exerciseId** `TEXT NOT NULL`: Foreign key referencing `exercises` (ON DELETE CASCADE)
*   **stepNumber** `INTEGER NOT NULL`: 1-indexed execution sequence number
*   **title** `TEXT NOT NULL`: Short phase title (e.g. `Set Up & Grip`, `Eccentric Descent`, `Drive`)
*   **instructions** `TEXT NOT NULL`: Detailed biomechanical instruction paragraph

### `form_cues` Table
Technique tips and execution rules classified as positive DOs or negative DON'Ts (up to 3 cues).
*   **id** `TEXT PRIMARY KEY`: Unique cue UUID
*   **exerciseId** `TEXT NOT NULL`: Foreign key referencing `exercises` (ON DELETE CASCADE)
*   **isPositive** `INTEGER NOT NULL`: Boolean flag (1 for DO technique check, 0 for DON'T error warning)
*   **description** `TEXT NOT NULL`: Concise actionable technique cue string (up to 120 chars)


