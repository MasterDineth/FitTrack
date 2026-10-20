# Antigravity instructions — Notifications v2

Two phases on one feature, in this order: **Phase 1 implements the design** (screen, settings persistence, island upgrade). **Phase 2 makes it real** (device notifications, live workout notification with rest controls, deep links, reminders).

Analysed repo: `MasterDineth/FitTrack` @ `0c592b9` (PR #11). Nothing here was compiled or run. **Plugin names and signatures below come from memory: check them against the current package docs before coding and say so in the PR where they differ.**

## 0. Master prompt (paste into Antigravity)

```text
Read AGENTS.md completely first. Then read this file. Implement Notifications v2 in two phases on branch feature/notifications-v2.
Phase 1 = design: build the new Notifications screen and the upgraded dynamic island exactly as the Stitch screens "NTF 01 … NTF 07" (fetch code.html and
screenshot via the Stitch MCP) and the interactive reference FitTrack_Notifications_Design.html show. If a Stitch screen is missing, build from the HTML.
Phase 2 = functionality: real device notifications as specified in section 3. Do not start Phase 2 until Phase 1 passes analyze and tests.
The old screens/settings/notifications_settings_screen.dart is a placeholder: delete it, do not extend it.
Follow AGENTS.md. Use the GlassBackdrop policy (backdrop: flat/live), never enableBlur: false. Before editing list files you will create/change/delete.
Report what you could not verify on a physical Android device.
```

## 1. Repo facts this brief relies on

| Area | Fact |
|------|------|
| Settings screen | `/settings/notifications` → `screens/settings/notifications_settings_screen.dart` (1383 lines, no real delivery) |
| Settings state | `NotificationSettingsState` (freezed, prefs prefix `notif_settings_`): `systemNotifications`, `liveWorkoutStatus`, `showScheduleProgress`, `showSetProgress`, `showRestTimerControls`, `routineWorkoutReminders`, `hydrationReminders`, `hydrationInterval` (String such as `Every 2 hrs`), `scheduleStatusAlerts`, `workoutScheduleCompletion`, `historyRecordedSaved`, 6 haptic flags, 5 audio flags |
| In-app system | `notificationFeedProvider` (`push`, `dismiss`, `clearAll`), `notificationIslandProvider` (one `FtNotificationItem?`), `notificationShadeProvider`, `hydrationProgressProvider`; `FtNotificationType {hydration, pr, strain, habit}`; the island renders inside `widgets/header/ft_dynamic_header.dart` |
| Active workout | `ActiveWorkoutNotifier` in `providers/active_workout_provider.dart`: `completeSet()`, `skipRest()`, `adjustRestTime(int delta)` (clamps 0–600), `pauseSession()` / `resumeSession()` / `togglePause()`, `finishSession()`. Phases `loading, active, resting, paused, finished, discarded, error`. State has `restRemainingSeconds`, `elapsedSeconds`, `entries`, `currentExerciseIndex`, `currentSetIndex`, `completedSets`, `skippedExerciseIds`, `schedule` |
| Timers | Both use `Timer.periodic(1 s)` and **decrement or increment a counter**, so they drift or freeze when the app is backgrounded. The saved session id is a local `uuid` created inside `_persistSession` |
| Routes | `/history/detail/:sessionId`, `/history` (shell tab), `/workouts/active/:scheduleId`, `/workout/execute/:id`, `/workouts/summary`, `/dashboard`, `/settings/notifications`; `routerProvider`, `rootNavigatorKey` |
| Platform | `pubspec.yaml` has **no** notification, timezone or permission packages. `AndroidManifest.xml` only declares biometric permissions; the activity is `singleTop` |
| Layers | `core/`, `data/{datasources,repositories}`, `domain/{entities,repositories}`, `presentation/`. No services folder yet |
| Glass | `GlassBackdrop {auto, live, flat}` exists (`widgets/glass/glass_backdrop.dart`). AGENTS §8 forbids `enableBlur: false` at call sites |

---

# PHASE 1 — Implement the design

## 1.1 Settings model (additive, same prefs prefix)

Add to `NotificationSettingsState` (freezed) and `NotificationSettingsNotifier` with setters, defaults and persistence. Keep every existing field and key.

| New field | Type | Default |
|-----------|------|---------|
| `reminderDays` | `Set<int>` (1 = Mon … 7 = Sun), stored as CSV | `{1,3,5}` |
| `reminderMinutes` | int, minutes after midnight | 1110 (6:30 PM) |
| `skipReminderIfTrained` | bool | true |
| `hydrationStartHour`, `hydrationEndHour` | int | 8, 20 |
| `weeklyRecap`, `weeklyRecapDay` (1–7), `weeklyRecapMinutes` | bool, int, int | true, 7, 1080 |
| `achievementPr`, `achievementStreak` | bool | true, false |
| `quietHoursEnabled`, `quietStartMinutes`, `quietEndMinutes`, `quietAllowLive` | bool, int, int, bool | true, 1320, 390, true |
| `inAppBanners`, `bannerSeconds` (3/5/8), `livePillEverywhere` | bool, int, bool | true, 5, true |
| `lockScreenDetails` | bool | true |
| `allowCompleteSetFromNotification` | bool | false (see decision D3) |

Mapping of existing fields to the new UI: `liveWorkoutStatus` = Live workout switch; `showScheduleProgress` = exercise progress bar; `showSetProgress` = set counter; `showRestTimerControls` = −15s · Skip · +15s; `routineWorkoutReminders` = Workout reminders; `hydrationReminders` + `hydrationInterval` = Water reminders; `workoutScheduleCompletion` = workout summary; `historyRecordedSaved` = also add an inbox entry when a workout is saved; `scheduleStatusAlerts` = **Important alerts, locked on in the UI** (keep the field, force true). The ten haptic/audio sub-flags stay, reachable from a "Customize" row under *Feel and sound* (use the existing sheet pattern). Add a unit test for loading old stored values.

## 1.2 Screen and widgets (each file < 400 lines)

Replace the old screen with `screens/settings/notifications/notifications_screen.dart` (route unchanged) and:

`notification_status_card.dart` (permission state), `live_notification_preview.dart`, `island_preview.dart`, `device_category_card.dart` (expandable, reuse for all categories), `reminder_sheet.dart` (day chips + time wheel, NTF 07), `quiet_hours_card.dart`, `in_app_section.dart`, `feel_sound_section.dart`. Section order and copy exactly as the design. Use `select` per switch so one toggle rebuilds one row. Master off (`systemNotifications` false or permission blocked) dims the sections to 40% and disables them.

**Shared model for the previews.** Create pure Dart `domain/entities/live_notification_spec.dart` (title, body, progress 0–1, chronometer mode, actions) and `domain/services/live_notification_formatter.dart` that builds it from a `LiveWorkoutSnapshot`. The preview widget renders that spec, so Phase 2's real notification and the preview can never disagree. Progress rule: `finishedExercises = entries where all sets logged or exercise skipped`; 2 of 10 gives 0.20 and the title `2 of 10 exercises · 20%`.

## 1.3 Dynamic island upgrade

Keep the existing banner. Add two persistent variants fed by `activeWorkoutProvider` through a new `liveIslandProvider` (states: none, live, rest, complete):

- **Live** (while a session is active and the user is not on the active-workout screen): compact pill with a progress ring and `2/10`; tap expands to workout name, current exercise, elapsed, progress bar.
- **Rest**: compact teal ring with the countdown; expanded shows `−15s`, `Skip`, `+15s` that call **the same notifier methods** as the in-app card (`adjustRestTime(±15)`, `skipRest()`).
- **Complete**: banner "Workout complete" with a View summary action to `/history/detail/:sessionId` once the id exists (Phase 2); in Phase 1 link to `/workouts/summary`.

Honour `inAppBanners`, `bannerSeconds`, `livePillEverywhere`, and the master switch. Render inside `FtDynamicHeader`; do not add a second overlay.

## 1.4 Rules

- Glass: in-flow cards `backdrop: GlassBackdrop.flat`; the island pill and sheets `live`. Never put `Opacity` above a live surface. At most two live blurs per screen.
- Countdown text updates in its own small widget; no whole-screen rebuild per second. Dispose and pause every controller when covered.
- Tap targets ≥ 48 dp, text scale 1.6 must not clip, labels for every switch (Semantics).
- No no-op handlers. "Send test notification" in Phase 1 pushes an in-app banner via `notificationFeedProvider`; "Open settings" and the status card stay behind `kShowDeviceNotificationSettings = false` until Phase 2, so the screen never claims device notifications work before they do.
- Remove the placeholder demo strip and sample items outside `kDebugMode`.

## 1.5 Tests and acceptance

Settings round-trip and migration; each switch persists; the island variants render from a fake `ActiveWorkoutState`; rest buttons call the notifier; screen builds at 1.6× text; golden-free overflow tests. `flutter analyze` clean, `flutter test` green, screens visually match NTF 01–07.

---

# PHASE 2 — Make it work

## 2.1 Packages and Android setup

Add (verify current versions and setup pages): `flutter_local_notifications`, `timezone`, `flutter_timezone`, `app_settings` (open system settings). Follow the plugin's Android setup: enable core-library desugaring in `android/app/build.gradle`, add the plugin receivers and the foreground service to the manifest, add a monochrome status-bar icon `ic_stat_fittrack`.

Manifest permissions (confirm each against current Android and Play policy): `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, `FOREGROUND_SERVICE` plus the foreground-service type permission you choose, `SCHEDULE_EXACT_ALARM` (request only if exact reminders are enabled; fall back to inexact when denied). Keep the activity `singleTop`.

## 2.2 Architecture

```text
domain/
  entities/live_workout_snapshot.dart      sessionId, scheduleId, scheduleName, totalExercises, finishedExercises,
                                           exerciseName, setNumber, totalSets, phase, startedAt, pausedAccumulated,
                                           pausedAt?, restEndsAt?, restDuration, updatedAt   (JSON round-trip)
  entities/notification_payload.dart       {v:1, type, route, sessionId?, scheduleId?}  + parse/encode
  services/notification_service.dart       abstract: init, permissionStatus, requestPermission, openSystemSettings,
                                           showLive(spec), clearLive, scheduleAt(...), cancelRange, show(...), tapStream
  services/live_workout_reducer.dart       apply(snapshot, AdjustRest(d)|SkipRest|Pause|Resume|CompleteSet, now) -> snapshot
  services/live_notification_formatter.dart  snapshot + settings + now -> LiveNotificationSpec
  services/reminder_planner.dart           settings + schedules + completedToday + now + tz -> List<PlannedReminder>
data/
  services/local_notification_service.dart  plugin implementation (the only file importing the plugin)
  datasources/live_snapshot_store.dart      SharedPreferences JSON (key live_workout_snapshot_v1)
presentation/providers/
  notification_service_provider.dart, notification_permission_provider.dart,
  notification_coordinator_provider.dart  (keepAlive; listens to active workout, settings, schedules, app lifecycle)
  notification_action_bridge.dart          ReceivePort registered with IsolateNameServer
```

The reducer, formatter, payload and planner are **pure Dart** (no Flutter imports) so the background isolate can reuse them and unit tests are trivial. Screens never import the plugin.

## 2.3 Make the session survive and tell the truth about time

1. **Timestamps, not counters.** Add `restEndsAt` and `sessionStartedAt` + `pausedAccumulated` to `ActiveWorkoutNotifier`. The 1 s timers only *refresh* `restRemainingSeconds` and `elapsedSeconds` from those timestamps (keep the existing state fields so the UI is unchanged). `adjustRestTime(d)` moves `restEndsAt` (clamp 0–600 s as today), `completeSet()` sets `restEndsAt = now + restDuration`, pause freezes the remaining time, resume recomputes the end.
2. **Expose the saved id.** `_persistSession` must store the generated session id in state (`lastSavedSessionId`) only after the DB write succeeded; the completion notification needs it.
3. **Snapshot and recovery.** Write the `LiveWorkoutSnapshot` (plus what is needed to rebuild the session: schedule id, custom exercises, completed sets, indexes) to `LiveSnapshotStore` on every change (debounce 250 ms). On app start, if a snapshot younger than 12 h exists, show a "Resume your workout?" sheet; Resume rebuilds via `startSession` and applies the snapshot, Discard clears it and the notification. This is required because the Dart state is otherwise lost whenever Android recreates the engine.

## 2.4 Live workout notification (spec)

One notification id (e.g. 1001), channel `live_workout` (low importance, silent), `ongoing`, `onlyAlertOnce`, hosted by a foreground service while a session is active, lock-screen visibility according to `lockScreenDetails`.

| Mode | Content | Actions |
|------|---------|---------|
| Workout | Title `{name} · {finished} of {total} exercises` (progress shown as `{pct}%`), body `{exercise} · Set {n} of {m}`, determinate progress bar `finished/total` (2/10 = 20%), native chronometer counting up from `sessionStartedAt` (no per-second updates) | Pause (Resume when paused; chronometer off and "Paused" shown), Open; **Complete set** only if `allowCompleteSetFromNotification` |
| Rest | Same id. Title `Rest · {exercise}`, body `Next: Set {n} of {m}`, **chronometer counting down to `restEndsAt`**, workout progress bar kept | **−15s**, **Skip rest**, **+15s** (only if `showRestTimerControls`) |
| Complete | Live notification removed. A normal notification on channel `summaries`: `Workout complete · {name}`, body `{minutes} min · {sets} sets · {exercises} exercises` | tap = open workout details |

Each setting maps to behavior: `liveWorkoutStatus` off ⇒ no live notification; `showScheduleProgress` off ⇒ no bar; `showSetProgress` off ⇒ body shows only the exercise; `showRestTimerControls` off ⇒ countdown without buttons.

**Rest end.** At `restEndsAt` the notification must flip back to Workout mode even if Dart is suspended: schedule an exact notification with **the same live id and Workout-mode content** at `restEndsAt` on channel `rest_alerts` (high importance, sound/vibration per `audioTimerCountdown` / `hapticTimerCountdowns`), and cancel/reschedule it on every ±15s, skip, pause, resume, discard and finish. If the app is in the foreground, skip the alert (the in-app sound/haptic already fires). Verify on a device that this replaces the foreground-service notification in place; if the OS or OEM refuses, fall back to a small native Kotlin foreground service that owns the notification and timers (MethodChannel to Dart) and tell me.

## 2.5 Buttons that behave exactly like the app

Plugin action handlers run in a background isolate. Do this:

1. In the main isolate register `ReceivePort` under the name `ft_notification_actions` (`IsolateNameServer`). Its listener calls the **same notifier methods the in-app buttons call**: `adjustRestTime(-15 | 15)`, `skipRest()`, `pauseSession()` / `resumeSession()`.
2. The top-level `@pragma('vm:entry-point')` background handler looks the port up and sends `{action}`. If the port exists, return.
3. If it does not (engine gone): load the snapshot, `LiveWorkoutReducer.apply`, save it, re-schedule the rest-end alert and update the notification directly. The next app start reconciles from the snapshot (if `restEndsAt` already passed, apply "advance" once).
4. Every path ends in the coordinator re-emitting the notification from the new state, so the notification, the in-app island and the active-workout screen always agree.

## 2.6 Deep links from notifications

Payload JSON is versioned (`v:1`). Handle three entry points: foreground tap, background tap, **cold start** (`getNotificationAppLaunchDetails`). On cold start store a `pendingRoute` and navigate only after the router redirect has resolved (auth and onboarding gating).

| Type | Navigation |
|------|------------|
| `workout_complete`, `pr` | `go('/history')` then `push('/history/detail/{sessionId}')` so Back returns to History. If the session no longer exists open `/history` and show "That workout is no longer available" |
| `live_workout`, `rest_over` | `/workouts/active/{scheduleId}` if that session is active, else `/dashboard` |
| `workout_reminder` | `/workouts` (pass the schedule id so the card is highlighted) |
| `hydration` | `/dashboard` |
| `weekly_summary` | `/history` |
| `important` | the relevant `/settings/...` page |

Use `routerProvider` and `rootNavigatorKey`; do not navigate if already on the destination. Screens never navigate for gating (AGENTS §7); only the notification route handler may.

## 2.7 Reminders

`ReminderPlanner` returns the next 14 days of occurrences; schedule them with `zonedSchedule` (exact if allowed, else inexact). Replan on: settings change, schedule change, app start and resume, a workout being completed (cancel today's workout reminder when `skipReminderIfTrained`), timezone change (compare the stored tz name on resume), and boot. Id ranges: workout 2000–2099, hydration 3000–3199, weekly recap 4000. Quiet hours remove hydration, weekly and reminder occurrences that fall inside the window. Hydration uses `hydrationInterval` between `hydrationStartHour` and `hydrationEndHour`.

## 2.8 Permission and channel UX

`notificationPermissionProvider` exposes `granted | denied | blocked | unknown` and refreshes on every app resume. Ask **in context**, never on first launch: when the user turns on a device category, taps "Send test notification", or starts their first workout, show a short explanation sheet first, then the system prompt. If blocked, the status card shows NTF 02 and "Open settings" calls `openSystemSettings()`. Detect channels disabled at OS level and show a "Turned off in system settings" chip on that category. Channels: `live_workout`, `rest_alerts`, `reminders`, `hydration`, `summaries`, `achievements`, `important`.

## 2.9 Keep in-app and device notifications in step

Foreground app: show the island only (plus the live notification, which is always on). Background app: system notification. In both cases also `notificationFeedProvider.push` so the inbox has the history. Extend `FtNotificationType` with `workoutComplete`, `restOver`, `reminder`, `summary`, `system`. Respect `systemNotifications` as the master for everything except Important alerts.

## 2.10 Android and OEM notes

Choose the foreground-service type honestly (`specialUse` with a justification, or the type Play accepts for workout tracking) and document it. Xiaomi/HyperOS and similar skins kill background work: add a "Keep live workouts running" row in the screen that opens the app's battery/autostart settings and explains why. Optional later: Android 16 live-update (progress-style) notifications through a native channel.

## 2.11 Tests

**Unit:** progress math (2 of 10 → 0.20, skipped counts as finished), reducer (±15 clamp, skip, pause/resume keeps remaining), formatter for all three modes and each setting off, payload round trip, planner (quiet hours, DST, completed today, 14-day window), settings migration. **Provider:** with a fake `NotificationService`, `completeSet()` emits a Rest spec with `restEndsAt`; `adjustRestTime(15)` re-emits and reschedules the alert; `skipRest()` returns to Workout mode; `finishSession()` clears live and emits the completion payload with the saved session id; permission blocked suppresses everything. **Widget:** settings screen states, rest buttons in the island call the notifier.

**Device matrix (physical phone, report each row):** live notification appears on start and survives screen off; progress bar moves when an exercise finishes; rest countdown runs without Dart ticks; −15s, +15s, Skip rest work from the shade and lock screen with the app foreground, backgrounded and swiped from recents; countdown end returns to progress with an alert; completion notification opens `History → Workout details` from foreground, background and cold start; reminders fire at the set time and after a reboot; denied permission, blocked channel and denied exact-alarm paths; quiet hours; timezone change.

---

## 3. Order of work (small commits, analyze and test green at each)

1. Phase 1: settings fields and migration → screen and widgets → island variants → tests.
2. Phase 2 foundation: pure domain logic and its unit tests → timestamp refactor, snapshot, recovery, `lastSavedSessionId`.
3. Plugin, permissions, channels, `LocalNotificationService`, coordinator → live notification and actions bridge → rest-end alert → completion and deep links.
4. Reminders planner and scheduling → permission UX → device matrix → cleanup (delete the old screen, tests that referenced it, update AGENTS §14 module map).

## 4. Decisions (defaults used if you do not answer)

| # | Question | Default |
|---|----------|---------|
| D1 | Plugin-hosted foreground notification, or native Kotlin service from the start? | **Plugin first; native only if the device matrix fails** |
| D2 | Prefill reminder days from the user's schedules? | **Prefill once when first enabled, then manual** |
| D3 | Offer a "Complete set" button in the notification? | **Off by default behind a setting** |
| D4 | Quiet hours on by default? | **On, 10 PM to 6:30 AM** |
| D5 | iOS | **Out of scope; keep the abstraction so it can follow** |

## 5. Definition of done

Phase 1: design matches, settings persist, no device claims shown. Phase 2: every switch on the screen changes real behavior (table in 2.4 and 2.10 is the test list), buttons in the notification and in the app produce identical state, completion opens the right History detail, analyze and tests green, device matrix reported honestly, no placeholder or sample data left in release.
