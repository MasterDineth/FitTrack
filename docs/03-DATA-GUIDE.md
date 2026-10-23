# Data Guide — Schema, Repositories & Seed System

Everything needed to read or write app data. **The authoritative schema is
`lib/data/datasources/local/database_helper.dart`**; this file is the map to it.

> ⚠️ `DATA_MODEL.md` (repo root) describes an **aspirational schema that does not match
> the real SQLite schema** — see §6. Trust this file and the source, not `DATA_MODEL.md`.

**Current schema version: 15** (`database_helper.dart:8`).

---

## 1. The real schema

`onCreate` — `database_helper.dart:347-529`.

| Table | Columns | Source |
|---|---|---|
| `exercises` | `id` PK · `name` · `equipment` · `movementClassification` · `mediaUrl` · `youtubeUrl` · `biomechanicsNotes` · `isCustom` | `:349-359` |
| `muscle_activations` | `id` PK · `exerciseId` FK→exercises CASCADE · `muscleName` · `role` · `intensityPercentage` | `:361-371` |
| `execution_steps` | `id` PK · `exerciseId` FK CASCADE · `stepNumber` · `title` · `instructions` | `:372-382` |
| `form_cues` | `id` PK · `exerciseId` FK CASCADE · `isPositive` INTEGER · `description` | `:383-392` |
| `schedules` | `id` PK · `name` · `description` · `targetMuscles` · `assignedWeekdays` · `orderIndex` · `isArchived` · `isFavorite` · `focus` · `experience` · `equipment` · `durationWeeks` · `daysPerWeek` · `estimatedMinutes` · `isCustom` · `completionCount` | `:394-412` |
| `schedule_exercises` | `id` PK · `scheduleId` FK CASCADE · `exerciseId` FK CASCADE · `sortOrder` · `targetSets` · `targetReps` · `targetWeightKg` · `restDurationSeconds` | `:421-434` |
| `bookmarked_items` | `id` PK · `createdAt` | `:414-419` |
| `workout_sessions` | `id` PK · `scheduleId` FK SET NULL · `startTime` · `endTime` · `durationSeconds` · `totalCalories` · `notes` · `intensity` · `totalSets` · `totalReps` · `totalVolumeKg` | `:444-459` |
| `exercise_logs` | `id` PK · `sessionId` · `exerciseId` · `orderIndex` · `isSkipped` · `skip_reason` | `:465-476` |
| `set_logs` | `id` PK · `exerciseLogId` · `setNumber` · `actualReps` · `targetReps` · `actualWeightKg` · `targetWeightKg` · `isCompleted` · `restDurationSeconds` | `:478-491` |
| `user_profile` | `id` PK · `name` · `age` · `weightKg` · `heightCm` · `experienceLevel` · `primaryGoal` · `weeklyTargetDays` · `profileImagePath` · `address` · `phone` · `isPhoneVerified` · `dob` · `email` · `username` | `:501-518` |
| `daily_habits` | `id` PK · `title` · `subtitle` · `isCompleted` · `status` · `orderIndex` | `:521-529` |

Indexes: `idx_workout_sessions_start_time` (`:461-463`), `idx_exercise_logs_session_id` and
`idx_set_logs_exercise_log_id` (`:308-313`).

### Conventions

- Dates are stored as **ISO-8601 strings** via `toIso8601String()` (local offset).
  `substr(startTime, 1, 10)` and lexicographic comparisons assume a fixed offset —
  normalise to UTC for new date-range queries (AGENTS.md §11).
- `isCustom`, `isCompleted`, `isPositive`, `isSkipped` are **INTEGER 0/1**, converted in
  the repository layer.
- `role` stores the `MuscleRole` enum **name** (`agonist` / `synergist` / `stabilizer`).
- `equipment` / `movementClassification` store the enum **name**.
- `targetMuscles` / `assignedWeekdays` are **JSON-encoded strings**
  (e.g. `'["Chest","Shoulders"]'`, `'[1,4]'`).

---

## 2. Repository layer

| Interface | Implementation | Storage |
|---|---|---|
| `IExerciseRepository` (`domain/repositories/i_exercise_repository.dart`) | `SqliteExerciseRepository` (`data/repositories/sqlite_exercise_repository.dart`) | SQLite |
| `IWorkoutSessionRepository` (`i_workout_session_repository.dart`, 14 methods) | `SqliteWorkoutSessionRepository` | SQLite |
| `IScheduleRepository` (`i_schedule_repository.dart`) | `SqliteScheduleRepository` | SQLite |
| `IUserRepository` (`i_user_repository.dart`) | `SqliteUserRepository` | SQLite (`user_profile`) |
| `IHabitsRepository` (`i_habits_repository.dart`) | `HabitsRepositoryImpl` | SQLite (`daily_habits`) + in-memory fallback |
| `ILifestyleContentRepository` (`i_lifestyle_content_repository.dart`) | `LifestyleContentRepositoryImpl` | `assets/data/lifestyle_content.json` |
| `IBioMetricsRepository` (`i_bio_metrics_repository.dart`) | `BioMetricsRepositoryImpl` | **none** — returns hardcoded sample data, `null` in release builds |
| `ISecurityRepository` (`i_security_repository.dart`) | `SecurityRepositoryImpl` | `SharedPreferences` JSON, key `fittrack_security_settings_v1` |
| `IThemeRepository` (`i_theme_repository.dart`) | `ThemeRepositoryImpl` | `SharedPreferences` |
| `IAuthRepository` (`i_auth_repository.dart`) | **`MockAuthRepository`** | `SharedPreferences` — ⚠️ **release-build mock** (see `docs/05-ONBOARDING-AUTH.md`) |

**Workout settings, data management and notification settings have no repository
interface** — their providers talk to `SharedPreferences` directly.

### `SharedPreferences` keys

| Prefix / key | Owner |
|---|---|
| `workout_settings_*` (`defaultRestTimer`, `autoStartRestTimer`, `keepScreenAwake`, `enableRPE`, `includeWarmups`, `plateCalculator`, `weightUnit`, `distanceUnit`, `bodyUnit`, `barbellWeight`, `ezBarWeight`, `gymProfile`) | `providers/workout_settings_provider.dart:52-60` |
| `notif_settings_*` (incl. `hydrationReminders`, `hydrationInterval`) | `providers/notification_settings_provider.dart:76` |
| `fittrack_security_settings_v1` | `data/repositories/security_repository_impl.dart:8` |
| theme settings | `providers/theme_provider.dart` → `ThemeRepositoryImpl` |

---

## 3. Provider → repository map

`lib/presentation/providers/repository_providers.dart` (all `keepAlive: true`):

| Provider | Returns |
|---|---|
| `authRepositoryProvider` | `MockAuthRepository` ⚠️ |
| `userRepositoryProvider` | `SqliteUserRepository` |
| `scheduleRepositoryProvider` | `SqliteScheduleRepository` |
| `workoutSessionRepositoryProvider` | `SqliteWorkoutSessionRepository` |
| `exerciseRepositoryProvider` | `SqliteExerciseRepository` |
| `securityRepositoryProvider` | `SecurityRepositoryImpl` |
| `themeRepositoryProvider` | `ThemeRepositoryImpl` (or in-memory fallback) |
| `bioMetricsRepositoryProvider` | `BioMetricsRepositoryImpl` (sample data) |
| `habitsRepositoryProvider` | `HabitsRepositoryImpl` |
| `lifestyleContentRepositoryProvider` | `LifestyleContentRepositoryImpl` |

Feature providers worth knowing: `exerciseByIdProvider` (`:98`), `userProfileProvider`,
`bioMetricsProvider`, `habitsProvider`, `lifestyleContentProvider`, `dashboardMetricsProvider`,
`hydrationProgressProvider`, `workoutSettingsNotifierProvider`,
`securitySettingsNotifierProvider`, `securityNotifierProvider`, `dataManagementNotifierProvider`,
`notificationSettingsNotifierProvider`, `themeNotifierProvider`, `activeWorkoutProvider`,
`exerciseDetailsProvider` (new, for the Exercise Details screen).

---

## 4. The exercise library & seed system

### 4.1 Files

| File | Purpose |
|---|---|
| `lib/domain/entities/exercise_catalog.dart` | 25 canonical `ExerciseSpec`s + alias resolution + `resolveImage(exerciseId)` + `resolveName` / `resolveMuscle` |
| `lib/data/datasources/local/seed/exercise_seed_data.dart` | **the content** — one `SeedExercise` per canonical id: name, equipment, movement, image asset, description, 3 steps, 3 cues, 3 muscle activations; plus `kSeedExerciseAliases` |
| `lib/data/datasources/local/seed/exercise_library_seeder.dart` | **the write logic** — `ExerciseLibrarySeeder.seed(DatabaseExecutor)`; public so it can be tested |
| `lib/data/datasources/local/database_helper.dart` | `_seedVersion13Data` (v13: base exercises + schedules + session history) and `_seedVersion15Data` (v15: the rich exercise detail) |

### 4.2 How a new seeded exercise works

1. Add a `SeedExercise` to `kSeedExercises` in `exercise_seed_data.dart` with a **unique id**
   and 1–3 steps / cues / muscle activations (one agonist, one synergist, one stabilizer).
2. If it needs a legacy alias, add it to `kSeedExerciseAliases` (alias → canonical id).
3. Bump `_databaseVersion` in `database_helper.dart` and add an `onUpgrade` step
   (`if (oldVersion < 16) { await _seedVersion16Data(db); }`).
4. Add a `SeedExercise` to `ExerciseCatalog.specs` in `exercise_catalog.dart` so
   `resolveName` / `resolveImage` agree with the DB.

The seeder **upserts** the `exercises` row (update-then-insert, never
`ConflictAlgorithm.replace` — a replace would cascade-delete `schedule_exercises`),
then **replaces only the child rows for the ids it manages**, leaving user-created
exercises and their details untouched. Alias rows are separate rows in `exercises`, so
each alias also receives the full detail — which is why the details resolve no matter
which id a workout references.

### 4.3 Image resolution

`Exercise.mediaUrl` holds **either** a bundled asset path
(`assets/images/dashboard/hero_workout.webp`) **or** an absolute local file path (the
picked image from the create-exercise screen). The UI must branch on the prefix —
see `presentation/screens/exercise_details/widgets/exercise_media_hero.dart`.

`ExerciseCatalog.resolveImage(exerciseId)` returns the canonical default asset for an id
(`exercise_catalog.dart:368-377`).

### 4.4 Bundled assets

`assets/images/dashboard/` — `brand_mark.webp`, `coaching_bench.webp`, `hero_workout.webp`,
`nutrition_bowl.webp`, `sample_avatar.webp`. Plus `assets/data/lifestyle_content.json`
and `assets/fonts/`. Declared in `pubspec.yaml:100-102` as directories, so a new file
dropped into `assets/images/dashboard/` is picked up with no pubspec change.

---

## 5. Aggregates & the "compute in SQL" rule (AGENTS.md §6.6)

`getDashboardMetrics` — `data/repositories/sqlite_workout_session_repository.dart:36-49`:

```sql
SELECT
  COUNT(DISTINCT CASE WHEN startTime >= ? AND startTime < ? THEN substr(startTime, 1, 10) END) as daysTrained,
  COUNT(CASE WHEN endTime IS NOT NULL THEN 1 END) as workoutsCompleted,
  COALESCE(SUM(totalCalories), 0) as totalCalories,
  GROUP_CONCAT(DISTINCT CASE WHEN startTime >= ? AND startTime < ? THEN substr(startTime, 1, 10) END) as monthDates
FROM workout_sessions
```

Returned keys: `daysTrainedThisWeek`, `totalWorkoutsCompleted`, `totalCaloriesBurned`
(**all-time**, not week-scoped), `activeDatesThisMonth`.

Other SQL in the same file: `getSessionStartDatesInRange` (`:81-87`),
`getSessionsSince` (`:99-104`), `getRecentSessions` (`:112-116`),
`getSessionsForMonth` (`:230-235`), the set-log join (`:194-200`).

**Never load all rows to count them.** Add a repository method with the aggregate in SQL.

---

## 6. `DATA_MODEL.md` is out of date

| `DATA_MODEL.md` claims | Reality |
|---|---|
| `users` + `user_profiles` tables | the real table is singular `user_profile` with different columns |
| `body_telemetry` table | folded into `user_profile` |
| `daily_bio_metrics` table with sleep / water / calorie columns | no such table |
| `fitness_profiles` table | synthesised from `user_profile` |
| `daily_habits` with `category`, `isCompletedToday`, `lastCompletedDate` | real columns are `subtitle`, `isCompleted`, `status`, `orderIndex` — **no date columns** |
| `workout_sessions.status / pausedAt / accumulatedPausedSeconds / activeRestEndsAt` | not columns; pause state lives in `LiveSnapshotStore` (prefs) |
| `set_logs.setType / rpe / isPersonalRecord` | not columns |
| "age is derived dynamically at runtime, never stored as a static integer column" | the opposite — `age` is a `NOT NULL` column and `dob` is a separate nullable column, never reconciled |

AGENTS.md §11 requires `DATA_MODEL.md` to match the real schema — update it in the same
PR as any migration. The file lives at the **repo root**, not `fittrack/DATA_MODEL.md`.

---

## 7. Migration rules (AGENTS.md §11)

- Bump `_databaseVersion` **and** add a new `if (oldVersion < N)` block in `_onUpgrade`.
- **Never edit a shipped migration.** `v13` and `v14` re-seed the whole library; `v15`
  enriches it.
- `_onCreate` (fresh installs) must call the same seeders the upgrade path does.
- Multi-row writes go in a transaction (`db.transaction((txn) => …)`).
- Index every column used in `WHERE` / `ORDER BY` on large tables.
- Upsert with `update` + `insert`, **not** `ConflictAlgorithm.replace`, when the row has
  cascading children.
