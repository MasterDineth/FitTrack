# FitTrack User Data Model & Database Schema

The FitTrack data architecture is local-first (SQLite via `sqflite` for relational entities + `SharedPreferences` for lightweight UI/settings state) and strictly separated behind Domain Repository interfaces.

---

## 1. User & Athlete Profile (`users`, `user_profiles`)
Used by Authentication, Onboarding, `profile_screen.dart`, and `account_details_screen.dart`.

### `users` Table (Authentication)
*   **id** `TEXT PRIMARY KEY`: UUID
*   **email** `TEXT UNIQUE NOT NULL`: Unique user email
*   **passwordHash** `TEXT NOT NULL`: Salted slow hash (Argon2 / PBKDF2 / bcrypt; never plaintext)
*   **createdAt** `TEXT NOT NULL`: ISO-8601 UTC timestamp
*   **updatedAt** `TEXT NOT NULL`: ISO-8601 UTC timestamp

### `user_profiles` Table (Account Details & Athlete Identity)
*   **userId** `TEXT PRIMARY KEY`: Foreign Key referencing `users.id` (ON DELETE CASCADE)
*   **displayName** `TEXT NOT NULL`: Full name or athlete display name
*   **username** `TEXT`: Optional handle (e.g. `@dineth_lifts`)
*   **email** `TEXT NOT NULL`: Contact email address
*   **phone** `TEXT`: Optional phone number
*   **bio** `TEXT`: Optional short athlete bio / training motto
*   **dateOfBirth** `TEXT`: ISO-8601 UTC date (`YYYY-MM-DD`). Age is derived dynamically at runtime, never stored as a static integer column.
*   **biologicalSex** `TEXT`: `male`, `female`, `other`
*   **avatarFilePath** `TEXT`: Local app-storage file path to the user's profile image (rendered via `ResizeImage`)
*   **updatedAt** `TEXT NOT NULL`: ISO-8601 UTC timestamp

---

## 2. Body Telemetry & Daily Biometrics (`body_telemetry`, `daily_bio_metrics`, `daily_habits`)
Used by Telemetry Setup, Dashboard (`telemetry_stack.dart`, `habits_recovery_section.dart`), and Units & Equipment Settings.

*   **Canonical Unit Storage Rule:** All weights (`kg`), heights (`cm`), and volumes (`ml`) are stored in **metric units** in SQLite. The user's `UnitSystem` preference (`metric` vs `imperial`) converts values purely in the presentation layer.

### `body_telemetry` Table
*   **id** `TEXT PRIMARY KEY`: UUID
*   **userId** `TEXT NOT NULL`: Foreign Key referencing `users.id`
*   **unitSystem** `TEXT NOT NULL`: Display preference at time of entry (`metric` or `imperial`)
*   **biologicalSex** `TEXT NOT NULL`: `male`, `female`, `other`
*   **dateOfBirth** `TEXT`: ISO-8601 date string (`YYYY-MM-DD`)
*   **weightKg** `REAL NOT NULL`: Recorded body weight in kilograms
*   **heightCm** `REAL NOT NULL`: Standing stature in centimeters
*   **bodyFatPercentage** `REAL`: Optional body fat percentage (`3.0` – `60.0`)
*   **recordedAt** `TEXT NOT NULL`: ISO-8601 UTC timestamp

### `daily_bio_metrics` Table
*   **dateKey** `TEXT PRIMARY KEY`: Normalized local date (`YYYY-MM-DD`)
*   **sleepMinutes** `INTEGER`: Total sleep duration in minutes
*   **waterIntakeMl** `INTEGER NOT NULL DEFAULT 0`: Logged daily hydration in milliliters
*   **waterTargetMl** `INTEGER NOT NULL DEFAULT 3000`: Daily hydration target in milliliters
*   **activeCaloriesBurned** `INTEGER NOT NULL DEFAULT 0`: Active kcal burned
*   **recoveryScore** `INTEGER`: Optional calculated recovery readiness (`0` – `100`)
*   **updatedAt** `TEXT NOT NULL`: ISO-8601 UTC timestamp

### `daily_habits` Table
*   **id** `TEXT PRIMARY KEY`: Habit UUID
*   **title** `TEXT NOT NULL`: Plain-language habit name (e.g. `Creatine 5g`, `8 Hours Sleep`, `Hit Daily Protein Goal`)
*   **category** `TEXT NOT NULL`: `nutrition`, `recovery`, `training`, `lifestyle`
*   **isCompletedToday** `INTEGER NOT NULL DEFAULT 0`: Boolean flag (`0` or `1`)
*   **lastCompletedDate** `TEXT`: ISO-8601 date string (`YYYY-MM-DD`)

---

## 3. Fitness Profile (`fitness_profiles`)
Used by `fitness_profile_setup_screen.dart`, `workout_preferences_screen.dart`, and `units_equipment_screen.dart`.

*   **id** `TEXT PRIMARY KEY`: UUID
*   **userId** `TEXT NOT NULL`: Foreign Key referencing `users.id`
*   **primaryFocus** `TEXT NOT NULL`:
    *   `hypertrophy` (Build Muscle)
    *   `strength` (Increase Strength & PRs)
    *   `fat_loss` (Fat Loss & Conditioning)
*   **liftingExperience** `TEXT NOT NULL`:
    *   `beginner` (< 6 months)
    *   `intermediate` (6m - 2 years)
    *   `advanced` (2+ years)
*   **weeklyFrequency** `INTEGER NOT NULL`: Target training days per week (`1` – `7`)
*   **availableEquipment** `TEXT NOT NULL`:
    *   `full_gym`
    *   `barbell_dumbbells`
    *   `home_bodyweight`
*   **updatedAt** `TEXT NOT NULL`: ISO-8601 UTC timestamp

---

## 4. Workout Sessions, Active Execution & Summary (`workout_sessions`, `exercise_logs`, `set_logs`)
Used by `active_workout_screen.dart`, `active_rest_timer_view.dart`, Workout Modals (`workout_paused_modal.dart`, `discard_workout_modal.dart`, `end_workout_early_modal.dart`, `skip_exercise_modal.dart`, `save_session_modal.dart`), `workout_summary_screen.dart`, `workout_history_screen.dart`, and `workout_history_detail_screen.dart`.

### `workout_sessions` Table
*   **id** `TEXT PRIMARY KEY`: Unique session UUID (e.g. `sess-1`)
*   **scheduleId** `TEXT NOT NULL`: Foreign key referencing `schedules.id`
*   **status** `TEXT NOT NULL DEFAULT 'completed'`: Lifecycle status (`in_progress`, `paused`, `completed`, `discarded`)
*   **startTime** `TEXT NOT NULL`: ISO-8601 UTC timestamp of workout start (indexed: `idx_workout_sessions_start_time`)
*   **endTime** `TEXT`: ISO-8601 UTC timestamp of workout completion
*   **pausedAt** `TEXT`: Nullable ISO-8601 UTC timestamp when session was paused (`workout_paused_modal`)
*   **accumulatedPausedSeconds** `INTEGER NOT NULL DEFAULT 0`: Total seconds spent paused so active duration is accurately derived as `(now - startTime) - accumulatedPausedSeconds`
*   **activeRestEndsAt** `TEXT`: Nullable ISO-8601 UTC timestamp when the active rest timer expires (`active_rest_timer_view`)
*   **durationSeconds** `INTEGER`: Total active workout duration in seconds
*   **totalCalories** `INTEGER`: Estimated active calorie burn
*   **notes** `TEXT`: User workout notes and session reflections (editable on `workout_summary_screen` and `save_session_modal`)
*   **intensity** `TEXT`: Session intensity label (e.g. `High Intensity`, `Moderate`, `Light`)
*   **totalSets** `INTEGER`: Total completed sets aggregated in the session
*   **totalReps** `INTEGER`: Total repetitions across all completed sets in the session
*   **totalVolumeKg** `REAL`: Total volume in kg (`SUM(actualWeightKg * actualReps)`) lifted during the session

### `exercise_logs` Table
Represents an individual exercise performed within a workout session.
*   **id** `TEXT PRIMARY KEY`: Unique log UUID
*   **sessionId** `TEXT NOT NULL`: Foreign key referencing `workout_sessions.id` (ON DELETE CASCADE, indexed: `idx_exercise_logs_session_id`)
*   **exerciseId** `TEXT NOT NULL`: Foreign key referencing `exercises.id`
*   **orderIndex** `INTEGER NOT NULL`: 0-indexed execution sequence order
*   **isSkipped** `INTEGER NOT NULL DEFAULT 0`: Boolean flag (`1` if skipped via `skip_exercise_modal.dart`)
*   **skipReason** `TEXT`: Optional reason selected in `skip_exercise_modal.dart` (`equipment_busy`, `joint_discomfort`, `time_constraint`, `other`)

### `set_logs` Table
Contains set-by-set weight, repetitions, and performance milestones.
*   **id** `TEXT PRIMARY KEY`: Unique set record UUID
*   **exerciseLogId** `TEXT NOT NULL`: Foreign key referencing `exercise_logs.id` (ON DELETE CASCADE, indexed: `idx_set_logs_exercise_log_id`)
*   **setNumber** `INTEGER NOT NULL`: 1-indexed set number within the exercise
*   **setType** `TEXT NOT NULL DEFAULT 'working'`: Set type (`warmup`, `working`, `dropset`, `failure`)
*   **targetReps** `INTEGER`: Planned target repetitions from schedule
*   **actualReps** `INTEGER`: Completed repetitions entered during active workout
*   **targetWeightKg** `REAL`: Target weight in kilograms from schedule
*   **actualWeightKg** `REAL`: Executed weight in kilograms entered during active workout
*   **rpe** `REAL`: Optional Rate of Perceived Exertion (`6.0` – `10.0`)
*   **isCompleted** `INTEGER NOT NULL DEFAULT 0`: Boolean flag (`0` or `1`) indicating set completion
*   **isPersonalRecord** `INTEGER NOT NULL DEFAULT 0`: Boolean flag (`1` if set achieved a new weight, volume, or estimated 1RM PR, highlighted on `workout_summary_screen.dart`)
*   **restDurationSeconds** `INTEGER`: Rest period duration in seconds following this set

---

## 5. Schedules & Schedule Details (`schedules`, `schedule_exercises`)
Used by `workouts_screen.dart`, `create_schedule_screen.dart`, and `workout_detail_screen.dart` (Schedule Details Screen).

### `schedules` Table
*   **id** `TEXT PRIMARY KEY`: Schedule UUID (e.g. `sched-push-a`)
*   **name** `TEXT NOT NULL`: Schedule title (e.g. `Push Hypertrophy A`)
*   **description** `TEXT`: Optional routine overview description
*   **targetMuscles** `TEXT`: Comma-separated list of target muscles (up to 3, e.g. `Chest,Shoulders,Triceps`)
*   **weeklyDays** `TEXT`: Comma-separated list of scheduled days of week (e.g. `Tuesday,Friday`)
*   **coverImagePath** `TEXT`: Optional local file path or bundled WebP asset path
*   **isFavorite** `INTEGER DEFAULT 0`: Favorite/bookmark toggle flag (`0` or `1`)
*   **completionCount** `INTEGER NOT NULL DEFAULT 0`: Number of times this schedule has been completed (used to dynamically rank trending programs)
*   **createdAt** `TEXT NOT NULL`: ISO-8601 UTC timestamp

### `schedule_exercises` Table
*   **id** `TEXT PRIMARY KEY`: Association entry UUID
*   **scheduleId** `TEXT NOT NULL`: Foreign key referencing `schedules.id` (ON DELETE CASCADE)
*   **exerciseId** `TEXT NOT NULL`: Foreign key referencing `exercises.id`
*   **orderIndex** `INTEGER NOT NULL`: 0-indexed order of execution (reorderable via drag)
*   **targetSets** `INTEGER NOT NULL DEFAULT 3`: Prescribed sets
*   **targetReps** `INTEGER NOT NULL DEFAULT 10`: Prescribed reps
*   **targetWeightKg** `REAL NOT NULL DEFAULT 0.0`: Prescribed weight in kilograms (`0.0` = bodyweight)
*   **restSeconds** `INTEGER NOT NULL DEFAULT 90`: Prescribed rest time between sets in seconds

### Schedule Details View Model (`ScheduleDetailSummary` — For `workout_detail_screen.dart`)
Computed via SQL join across `schedules`, `schedule_exercises`, `exercises`, `muscle_activations`, and `workout_sessions`:
*   **schedule** `Schedule`: Core schedule entity
*   **exercises** `List<ScheduleExerciseDetail>`: Ordered list containing prescribed `targetSets`, `targetReps`, `targetWeightKg`, `restSeconds` joined with `Exercise` (`name`, `equipment`, `movementClassification`, `mediaUrl`, `primaryMuscle`)
*   **totalExercises** `INTEGER`: `COUNT(schedule_exercises.id)`
*   **totalSets** `INTEGER`: `SUM(schedule_exercises.targetSets)`
*   **estimatedDurationMinutes** `INTEGER`: `ROUND(SUM(targetSets * (45 + restSeconds)) / 60.0)`
*   **estimatedCalories** `INTEGER`: Estimated session kcal expenditure
*   **completedCount** `INTEGER`: `COUNT(workout_sessions.id)` where `scheduleId = ? AND status = 'completed'`
*   **lastPerformedAt** `DateTime?`: Most recent `endTime` from `workout_sessions` for this schedule

---

## 6. Exercises & Biomechanical Anatomy (`exercises`, `muscle_activations`, `execution_steps`, `form_cues`)
Used by `workout_search_screen.dart`, `create_custom_exercise_screen.dart`, `exercise_details_screen.dart`, and `add_exercise_picker_sheet.dart`.

### `exercises` Table
*   **id** `TEXT PRIMARY KEY`: Unique exercise UUID (e.g. `ex-bench-press`)
*   **name** `TEXT NOT NULL`: Exercise name (e.g. `Barbell Flat Bench Press`)
*   **equipment** `TEXT NOT NULL`: Required equipment type (`barbell`, `dumbbell`, `cable`, `machine`, `bodyweight`, `other`)
*   **movementClassification** `TEXT NOT NULL`: Biomechanical movement type (`compound`, `isolation`, `unilateral`, `isometric`, `other`)
*   **mediaUrl** `TEXT`: Local file path or bundled asset URI to cover demonstration image
*   **youtubeUrl** `TEXT`: Optional YouTube tutorial or demonstration URL
*   **biomechanicsNotes** `TEXT`: Biomechanical movement commentary or tips
*   **isCustom** `INTEGER NOT NULL DEFAULT 0`: Flag distinguishing user-created exercises (`1`) from system exercises (`0`)

### `muscle_activations` Table
*   **id** `TEXT PRIMARY KEY`: Unique activation UUID
*   **exerciseId** `TEXT NOT NULL`: Foreign key referencing `exercises.id` (ON DELETE CASCADE)
*   **muscleName** `TEXT NOT NULL`: Muscle group name (e.g. `Pectoralis Major`, `Triceps Brachii`)
*   **role** `TEXT NOT NULL`: Biomechanical role (`primeMover`, `synergist`, `stabilizer`)
*   **intensityPercentage** `INTEGER NOT NULL`: Activation share percentage (`5` – `100`)

### `execution_steps` Table
*   **id** `TEXT PRIMARY KEY`: Unique step UUID
*   **exerciseId** `TEXT NOT NULL`: Foreign key referencing `exercises.id` (ON DELETE CASCADE)
*   **stepNumber** `INTEGER NOT NULL`: 1-indexed execution sequence number
*   **title** `TEXT NOT NULL`: Short phase title (e.g. `Set Up & Grip`, `Eccentric Descent`, `Drive`)
*   **instructions** `TEXT NOT NULL`: Detailed execution instruction paragraph

### `form_cues` Table
*   **id** `TEXT PRIMARY KEY`: Unique cue UUID
*   **exerciseId** `TEXT NOT NULL`: Foreign key referencing `exercises.id` (ON DELETE CASCADE)
*   **isPositive** `INTEGER NOT NULL`: Boolean flag (`1` for DO check, `0` for DON'T warning)
*   **description** `TEXT NOT NULL`: Concise actionable technique cue string (up to 120 chars)

---

## 7. Settings Domain Models (Appearance, Workout Preferences, Units, Notifications, Security & Data Management)
Used across `settings_screen.dart` and all Settings sub-screens (`appearance_settings_screen.dart`, `workout_preferences_screen.dart`, `units_equipment_screen.dart`, `notifications_settings_screen.dart`, `password_security_screen.dart`, `security_app_lock_screen.dart`, `data_management_screen.dart`, `erase_data_screen.dart`, `about_screen.dart`, `help_center_screen.dart`).

### 7.1 `ThemeSettings` (`theme_settings.dart` — SharedPreferences)
*   **themeMode** `Enum`: `system`, `light`, `dark`
*   **useOledBlack** `BOOLEAN`: Pure `#000000` background base in dark mode (`false` default)
*   **accentColorHex** `INTEGER`: Active primary seed color (Default: Brand Violet `0xFF5F3BDC`)
*   **secondaryAccentColorHex** `INTEGER?`: Optional secondary gradient stop for gradient accent mode
*   **useDynamicColor** `BOOLEAN`: Material You wallpaper extraction on Android 12+ (`false` default)
*   **enableFrostedGlass** `BOOLEAN`: Master toggle for `BackdropFilter` frosted glass across `GlassSurface` / `FrostedGlassBox` (`true` default)
*   **blurIntensity** `DOUBLE`: User-selected frosted blur and glass surface opacity multiplier (`0.0` – `1.0`, default `0.7`)

### 7.2 `WorkoutSettings` (`workout_settings_provider.dart` — SharedPreferences)
Used by `workout_preferences_screen.dart`, `units_equipment_screen.dart`, `default_rest_timer_modal.dart`, and `active_workout_screen.dart`.
*   **weightUnit** `Enum`: `kg` (default) or `lbs`
*   **distanceUnit** `Enum`: `km` (default) or `miles`
*   **bodyMeasurementUnit** `Enum`: `cm` (default) or `inches`
*   **defaultRestSeconds** `INTEGER`: Default rest countdown timer in seconds (`90` default)
*   **restStepIncrementSeconds** `INTEGER`: Step +/- button delta on rest timer (`15` seconds default)
*   **autoStartRestTimer** `BOOLEAN`: Automatically trigger rest timer when a set is marked completed (`true` default)
*   **keepScreenAwake** `BOOLEAN`: Keep display awake during an active workout (`true` default)
*   **soundEffectsEnabled** `BOOLEAN`: Play completion chime when rest countdown finishes (`true` default)
*   **hapticsEnabled** `BOOLEAN`: Haptic feedback on set checkoff, timer finish, and PRs (`true` default)
*   **showPreviousSetPerformance** `BOOLEAN`: Display last session's weight x reps beside each set row (`true` default)
*   **defaultBarbellWeightKg** `REAL`: Standard barbell weight (`20.0` kg / `45.0` lbs default)
*   **availableEquipment** `List<String>`: Active equipment inventory (`barbell`, `dumbbell`, `cable`, `machine`, `kettlebell`, `bands`, `bodyweight`)

### 7.3 `NotificationSettings` (`notification_settings_provider.dart` — SharedPreferences)
Used by `notifications_settings_screen.dart`.
*   **masterNotificationsEnabled** `BOOLEAN`: Global toggle (`true` default)
*   **workoutRemindersEnabled** `BOOLEAN`: Scheduled training day reminders (`true` default)
*   **reminderTimeHour** `INTEGER`: 24-hour clock hour (`17` default)
*   **reminderTimeMinute** `INTEGER`: Minute (`30` default)
*   **restTimerAlertsEnabled** `BOOLEAN`: Alert when rest timer expires while app is backgrounded (`true` default)
*   **streakProtectionAlertsEnabled** `BOOLEAN`: Evening nudge before a weekly streak is broken (`true` default)
*   **prAndMilestoneAlertsEnabled** `BOOLEAN`: Celebrate new volume and strength milestones (`true` default)
*   **quietHoursEnabled** `BOOLEAN`: Mute non-workout notifications overnight (`false` default)
*   **quietHoursStart** `TEXT`: `22:00` default
*   **quietHoursEnd** `TEXT`: `07:00` default

### 7.4 `SecuritySettings` & `SecurityActivity` (`security_settings.dart`, `security_activity.dart`)
Used by `security_app_lock_screen.dart` and `password_security_screen.dart`.
*   **isAppLockEnabled** `BOOLEAN`: Require PIN/biometrics on launch (`false` default)
*   **isBiometricEnabled** `BOOLEAN`: Allow fingerprint/face unlock via `local_auth` (`false` default)
*   **autoLockDelaySeconds** `INTEGER`: `0` (Immediately), `60` (1 min), `300` (5 min), `900` (15 min)
*   **hideSensitiveMetricsInSwitcher** `BOOLEAN`: Blur app preview in OS app switcher (`true` default)
*   **pinHash** `TEXT?`: Salted hash stored in secure storage
*   **`security_activities` Log Entries:**
    *   **id** `TEXT`: UUID
    *   **title** `TEXT`: Event description (e.g. `Password Updated`, `Biometric Lock Enabled`, `Backup Exported`)
    *   **deviceName** `TEXT`: Device model identifier
    *   **timestamp** `DateTime`: UTC timestamp of event

### 7.5 `BackupSnapshot` & Data Erase Scopes (`backup_snapshot.dart`, `data_management_provider.dart`)
Used by `data_management_screen.dart` and `erase_data_screen.dart`.
*   **schemaVersion** `INTEGER`: Matches `DatabaseHelper._databaseVersion` (`14`)
*   **createdAt** `DateTime`: Export timestamp
*   **appVersion** `String`: Semantic version string
*   **dataPayload**: Serialized JSON map of `userProfile`, `bodyTelemetry`, `fitnessProfile`, `schedules`, `scheduleExercises`, `customExercises`, `workoutSessions`, `exerciseLogs`, `setLogs`, and user settings.
*   **Erase Operations (`erase_data_screen.dart`):**
    1.  **Clear Workout History:** Deletes `set_logs`, `exercise_logs`, and `workout_sessions` in a single SQLite transaction while keeping schedules, custom exercises, and profile intact.
    2.  **Delete Custom Exercises & Schedules:** Deletes user-created routines and custom exercises (`isCustom = 1`).
    3.  **Factory Reset (Erase All Data):** Transactional wipe of all SQLite tables + `SharedPreferences` reset, restoring `ThemeSettings` primary color to canonical Brand Violet (`#5F3BDC`).