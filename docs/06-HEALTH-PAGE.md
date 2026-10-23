# Health Page — Data Guide

The planned 5th bottom-nav tab. **Design and functions are not planned yet**, so this
document is the data inventory: what exists today, what is fake, and what has to be built.

---

## 1. Adding the tab — the exact wiring

### 1.1 Router (`lib/presentation/router/app_router.dart`)

1. Add the navigator key after `shellNavigatorSettingsKey` (`:41`):
   ```dart
   final shellNavigatorHealthKey = GlobalKey<NavigatorState>(debugLabel: 'shellHealth');
   ```
2. Append a branch **after** the Settings branch (after `:376`, before the closing `],`):
   ```dart
   StatefulShellBranch(
     navigatorKey: shellNavigatorHealthKey,
     routes: [
       GoRoute(
         path: '/health',
         builder: (context, state) => const HealthScreen(),
       ),
     ],
   ),
   ```
3. Import the screen near the other screen imports (`:17-19`).

> **Append at the end.** Branch index == dock tab index. Inserting before Settings would
> shift Settings to index 4 and break `AnimatedGlassDock`'s hardcoded `index == 1` Workouts
> rotation (`animated_glass_dock.dart:327-333`).

The shell itself needs **no change** — `BranchTransitionContainer` is index-driven and
generic (`branch_transition_container.dart:73-85`).

### 1.2 Dock (`lib/presentation/widgets/animated_glass_dock.dart`)

Append a 5th entry to the static `_tabs` list (after the Settings entry, `:58`):

```dart
_DockTabItem(
  label: 'Health',
  outlineIcon: Icons.monitor_heart_outlined,
  filledIcon: Icons.monitor_heart_rounded,
),
```

The dock renders `List.generate(_tabs.length)`, so nothing else changes. 5 tabs fit in
the 353 dp dock (active tab `flex: 2`, inactive `flex: 1`).

### 1.3 Dead code to ignore

| Path | Status |
|---|---|
| `lib/presentation/widgets/bottom_nav_shell.dart:93-225` (`FloatingDock`) | **dead** second dock — the live one is `AnimatedGlassDock` |
| `lib/presentation/screens/dashboard_screen.dart` (69 KB, top level) | **dead** legacy dashboard; the router uses `screens/dashboard/dashboard_screen.dart` |
| `lib/presentation/screens/dashboard/widgets/hydration_banner.dart` | **dead** — `HydrationBanner` is mounted nowhere |

---

## 2. What health data exists today

### 2.1 Body metrics — one row, no history

- **Entity** `lib/domain/entities/user_profile.dart:25-41` — freezed `UserProfile`:
  `id, name, age, weightKg, heightCm, experienceLevel, primaryGoal,
  weeklyTargetDays, profileImagePath, address, phone, isPhoneVerified, dob, email, username`.
  Getters: `calculateBMI` (`:47-51`), `getBMICategory` (`:54-59`), `isComplete` (`:62-68`).
- **Table** `user_profile` — `database_helper.dart:501-518` (singular name).
- **Provider** `userProfileProvider` — `presentation/providers/user_profile_provider.dart:13-14`
  (keepAlive, `AsyncValue<UserProfile>`).
- **Repository** `IUserRepository` — `lib/domain/repositories/i_user_repository.dart:5-23`.
- **Entity** `BodyTelemetry` (`domain/entities/body_telemetry.dart`) exists but has **no
  table**; `SqliteUserRepository.saveBodyTelemetry` (`:49-59`) folds it into `user_profile`.
  `getBodyTelemetry` (`:62-75`) is **dead code that fabricates** `unitSystem: metric` and
  `biologicalSex: male`.
- **`UserProfileNotifier.saveTelemetry`** (`:190-202`) persists only `age`, `weightKg`,
  `heightCm`. **`biologicalSex` and `unitSystem` are discarded** — no column, no
  re-derivation. This must be fixed before the Health page can show sex-based BMR.

### 2.2 Movement / strain / recovery — 100% sample data

- **Entity** `DailyBioMetrics` (`domain/entities/daily_bio_metrics.dart`):
  `movementSteps, movementGoal, movementPercent, movementTag, strainValue, strainGoal,
  strainTag, recoveryPercent, recoveryTime, recoveryTag, syncedAt, isOptimal`.
- **No DB table.**
- **Repository** `BioMetricsRepositoryImpl` (`data/repositories/bio_metrics_repository_impl.dart`)
  returns **hardcoded constants** (steps 6420, strain 12.4, recovery 92%, "7h 48m",
  "Prime Day") and returns `null` in release builds via `useSampleData =
  kUseTemplateSampleData` (`:5-8`). **This is the seam for a Health Connect
  implementation** — drop it behind `IBioMetricsRepository` and no presentation code
  changes.
- **Provider** `bioMetricsProvider` — `presentation/providers/dashboard_providers.dart:118-122`.
- **UI** `dashboard/widgets/telemetry_stack.dart:390-526` (`_BioMetricsBalanceCard`) —
  the empty-state string is `'Connect Health to see movement and recovery'` (`:464`).

### 2.3 Calories

**Stored:** only `workout_sessions.totalCalories INTEGER` (`database_helper.dart:451`).
**There is no calorie-intake table and no food logging anywhere.**

**Computed, not stored:**

| Value | Formula | Location |
|---|---|---|
| Session burn | `((elapsedSeconds / 60) * 8).round()` | `providers/active_workout_provider.dart:157-158` |
| Schedule preview | `(estMinutes * 6.5).round()` | `screens/workout_detail_screen.dart:343` |
| BMR (Mifflin–St Jeor) | `10w + 6.25h − 5a`, `+5` male/other, `−161` female | `screens/telemetry_setup_screen.dart:55-62` |
| Hydration target | `bmr / 1000` L | `screens/telemetry_setup_screen.dart:64-68` |
| TDEE | **does not exist** | — |

BMR is computed **only during onboarding** and never persisted — the Health page must
recompute it from `UserProfile` (which needs a stored biological sex).

**Aggregate SQL** — `data/repositories/sqlite_workout_session_repository.dart:36-49`:

```sql
SELECT
  COUNT(DISTINCT CASE WHEN startTime >= ? AND startTime < ? THEN substr(startTime, 1, 10) END) as daysTrained,
  COUNT(CASE WHEN endTime IS NOT NULL THEN 1 END) as workoutsCompleted,
  COALESCE(SUM(totalCalories), 0) as totalCalories,
  GROUP_CONCAT(DISTINCT CASE WHEN startTime >= ? AND startTime < ? THEN substr(startTime, 1, 10) END) as monthDates
FROM workout_sessions
```

Returned keys (`:66-71`): `daysTrainedThisWeek`, `totalWorkoutsCompleted`,
`totalCaloriesBurned` (all-time, **not** week-scoped), `activeDatesThisMonth`.
Provider: `dashboardMetricsProvider` — `providers/workout_logic_providers.dart:115-137`.

**Mock calorie numbers to distrust:** `providers/workout_history_provider.dart:76-93`
(`totalBurnCalories = 2840`, `avgCaloriesPerSession = 405`, `dailyBurns`,
`avgPulseBpm = 144`, `muscleReadinessScore = 92`, `efficiencyIndex = 98.2`); the
`ProfileStatsBento` fallback `3450` (`screens/profile/widgets/profile_stats_bento.dart:40-45`);
`s.totalCalories ?? 380` in history cards.

### 2.4 Hydration — in-memory only

- **Provider** `hydrationProgressProvider` — `providers/notifications_provider.dart:164-182`
  (keepAlive). `double build() => 1.8;` — **resets to 1.8 L on every app launch.**
  `setLiters` clamps 0.0–2.5; `addLiters`; `reset`.
- Mirrored by `DashboardNotificationsState.loggedWaterLiters` (`dashboard_providers.dart:21,27,42,55`).
- Increment path: `notificationFeedProvider.notifier.pushPreset(FtNotificationType.hydration)`
  → `addLiters(0.25)` (`notifications_provider.dart:294-301`).
- The **2.5 L ceiling is hardcoded** in three places (`:172`, `:176`, `:215`, `:300`).
- Notification *reminders* (not intake) live in `NotificationSettingsState`
  (`notification_settings_provider.dart:36-37`: `hydrationReminders`, `hydrationInterval`).

### 2.5 Habits — real, but not actually daily

- **Table** `daily_habits` — `database_helper.dart:521-529`:
  `id, title, subtitle, isCompleted, status, orderIndex`. **No date column** → the same
  three rows repeat every day.
- **Entity** `DailyHabit` (`domain/entities/daily_habit.dart`), `HabitChipStatus
  {done, pending, tonight}`.
- **Repository** `HabitsRepositoryImpl` (`data/repositories/habits_repository_impl.dart`) —
  `getHabits()` with a 250 ms timeout and an in-memory fallback; `toggleHabit(id)` updates
  memory **and** the row.
- **Provider** `habitsProvider` — `dashboard_providers.dart:125-138` (+ `toggle`).
- **UI** `dashboard/widgets/habits_recovery_section.dart` (393 lines).

### 2.6 Lifestyle content

- `ILifestyleContentRepository.getFeaturedContent()` → `LifestyleContentRepositoryImpl`
  reads `assets/data/lifestyle_content.json`.
- **The JSON is a top-level array** (not an object) with **2 entries**; keys per entry:
  `id, category, tagColor, duration, title, description, actionLabel, imagePath, isVideo`.
- Provider `lifestyleContentProvider` — `dashboard_providers.dart:144-148`.
- UI `dashboard/widgets/lifestyle_masterclass_section.dart`.

### 2.7 Workout sessions

- **Table** `workout_sessions` — `database_helper.dart:444-459`; index on `startTime` (`:461-463`).
- Related: `exercise_logs` (`:465-476`), `set_logs` (`:478-491`).
- **Entity** `WorkoutSession` — `domain/entities/workout_session.dart:10-22`.
- **Repository** `IWorkoutSessionRepository` — `domain/repositories/i_workout_session_repository.dart:5-38`
  (14 public methods, incl. `getDashboardMetrics`, `getSessionsForMonth`,
  `getSessionsSince`, `getRecentSessions`, `getSessionStartDatesInRange`).

> ⚠️ **Date caveat:** `startTime` is stored with `toIso8601String()`, which includes the
> **local** offset, while the SQL compares with `substr(startTime,1,10)` and lexicographic
> `>=` / `<`. Same-offset usage is fine today; any new date-range query on the Health
> page should normalise to UTC (AGENTS.md §11).

### 2.8 Sleep / steps / heart rate — do not exist

No entity, table, repository or provider. The only traces are hardcoded strings
(`'92% readiness after 7h 48m sleep'` in `notifications_provider.dart:221-222`;
`avgPulseBpm = 144`; `muscleReadinessScore = 92`; `recoveryTime = '7h 48m'`), decorative
icons, and `DobPickerModal.calculateMaxHeartRate(dob)` = 220 − age (display only).

**Everything in this group must be built from scratch or shown as an empty state.**

---

## 3. Health Connect — nothing exists

- No `health` package in `pubspec.yaml` (`:30-56`).
- No `android.permission.health.READ_*` in `AndroidManifest.xml`
  (`FOREGROUND_SERVICE_HEALTH` is for the local-notification workout service, unrelated).
- No `NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription` in
  `ios/Runner/Info.plist`.
- Zero matches repo-wide for `health_connect`, `healthkit`, `HealthDataType`.
- AGENTS.md §2 lists Health Connect as a real Android-only capability that **must be
  platform-gated**.

**Seam:** `IBioMetricsRepository` / `bioMetricsRepositoryProvider` is the designed
integration point — it already returns `null` in release builds.

---

## 4. Providers available to the Health page

`lib/presentation/providers/` (keepAlive = ✅):

| Provider | Holds |
|---|---|
| `userProfileProvider` ✅ | `AsyncValue<UserProfile>` — body metrics |
| `bioMetricsProvider` ❌ | `DailyBioMetrics?` (sample data) |
| `habitsProvider` ❌ | `List<DailyHabit>` + `toggle` |
| `lifestyleContentProvider` ❌ | `List<LifestyleArticle>` |
| `hydrationProgressProvider` ✅ | `double` litres (in-memory) |
| `dashboardMetricsProvider` ❌ | week/all-time aggregates map |
| `weeklyMomentumProvider` ❌ | sessions, 7-day strip, streak, points |
| `weeklyLoadProvider` ❌ | volume, load index, PR delta |
| `calendarActivityProvider` ❌ | active days in month |
| `recentWorkoutSessionsProvider` ❌ | last 5 sessions |
| `selectedMonthProvider` ✅ | normalised `DateTime(year, month, 1)` |
| `sessionsRevisionProvider` ✅ | bump after writes |
| `workoutSettingsProvider` ✅ | `WorkoutSettings` (prefs) |
| `securitySettingsProvider` ✅ | biometrics / app lock |
| `themeNotifierProvider` ✅ | `ThemeSettings` |
| `notificationSettingsProvider` ✅ | notification preferences |
| `dataManagementProvider` ✅ | backup / erase |
| `activeWorkoutProvider` ✅ | live session state |

---

## 5. Build order (derived from the data reality)

| # | Slice | Why it must come first |
|---|---|---|
| 1 | **v16 migration**: add `biologicalSex`, `unitSystem`, and a per-day body-metrics table (`body_metrics` with a date column) | Everything else reads body data; `age`/`dob` duplication should be reconciled in the same migration |
| 2 | **Persist hydration + calorie intake** — new tables, repository interfaces, providers | Both are currently volatile/fake; a Health page that shows them without persistence is a lie |
| 3 | **Fix the `user_profile` writes** so sex + unit are not discarded, and make the unit toggle authoritative against `workoutSettingsProvider` | The Health page must agree with the Units & Equipment screen |
| 4 | **Replace the sample bio-metrics repo** with a real implementation behind `IBioMetricsRepository`; show honest empty states until then | Removes fake "Prime Day" / "7h 48m sleep" data from a user-facing screen |
| 5 | **Give `daily_habits` a date dimension** (or a `habit_log` table) | "Daily habits" that never reset are not daily |
| 6 | **Recompute BMR/TDEE from `UserProfile`** and surface BMI + category | Already possible once sex is stored |
| 7 | **Build the Health screen** on top of 1–6 | Content first, then pixels |
| 8 | **Health Connect** (Android only, optional) | New capability, isolated, needs platform permissions |

---

## 6. Doc-vs-reality gaps (fix when the schema changes)

`DATA_MODEL.md` describes an **aspirational schema that does not exist**:

| `DATA_MODEL.md` claims | Reality |
|---|---|
| `users` + `user_profiles` tables | real table is singular `user_profile` with different columns |
| `body_telemetry` table | folded into `user_profile` |
| `daily_bio_metrics` table with sleep/water/calorie columns | no such table |
| `fitness_profiles` table | synthesised from `user_profile` |
| `daily_habits` with `category`, `isCompletedToday`, `lastCompletedDate` | real table has `subtitle`, `isCompleted`, `status`, `orderIndex` and no dates |
| `workout_sessions.status / pausedAt / accumulatedPausedSeconds / activeRestEndsAt` | not columns; pause state lives in `LiveSnapshotStore` (prefs) |
| `set_logs.setType / rpe / isPersonalRecord` | not columns |

AGENTS.md §11 requires `DATA_MODEL.md` to match the real schema — any Health-screen
migration must update it in the same PR.

---

## 7. Open questions for the user

1. **Is the Health page read-only or does it accept input?** (Calorie intake logging and
   water logging both need write paths; a read-only page can start with the data that
   already exists.)
2. **Health Connect — in scope, or explicit empty states?** AGENTS.md §2 lists it as a
   capability, but it needs the `health` package, Android permissions and an iOS
   `Info.plist` entry.
3. **Should body metrics become a time series?** A single `user_profile` row cannot show
   weight or BMI over time. A `body_metrics` table with a date column can, and it also
   fixes the "derive `age` from `dob`" duplication.
4. **Which 5th tab position?** Appending keeps Settings at index 3; inserting before
   Settings shifts every index and breaks the dock's hardcoded `index == 1` rotation.
