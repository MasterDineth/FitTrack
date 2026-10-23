# Settings Sub-Screens — Data Guide

The seven Settings screens slated for redesign. Every fact here was read from source
(file:line); nothing is inferred.

**Common facts**

- All seven are routed in `lib/presentation/router/app_router.dart` with
  `parentNavigatorKey: rootNavigatorKey` and **inline string literals** — there is no
  `AppRoutes` class anywhere.
- All seven are reached from `lib/presentation/screens/settings/widgets/settings_sections_list.dart`
  via `context.push('/settings/...')`.
- **None of the seven touches SQLite.** They use `SharedPreferences` (through providers) or
  hold state in memory only.
- **None of the seven uses the glass design system.** All use raw `colorScheme.*` +
  `Container`/`BoxDecoration` + inline `TextStyle` with the literal
  `'Plus Jakarta Sans'` (127 inline occurrences across the seven). None imports
  `presentation/theme/ft_glass.dart` except password / workout-prefs / units / data, and
  those only to call `FtGlassTheme.cardDecoration` through a private helper.
- **None uses `AmbientMeshBackground` / `FtMeshBackground`.**
- **Zero `onPressed: () {}` no-ops inside the seven.** (One exists outside them:
  `settings_logout_button.dart:43` in the scope-less static fallback path.)
- **Zero test coverage** — no file in `test/` references any of the seven class names.
  `test/settings_screen_test.dart` only covers the entry-point `SettingsScreen`.

### Line counts vs the 400-line limit (AGENTS.md §9)

| Screen | File | Lines | Over |
|---|---|---|---|
| Security and privacy | `settings/security_app_lock_screen.dart` | 1040 | ⚠️ 2.6× |
| Password and authentication | `settings/password_security_screen.dart` | 1010 | ⚠️ 2.5× |
| Data and Integrations | `settings/data_management_screen.dart` | 972 | ⚠️ 2.4× |
| Units and equipment | `settings/units_equipment_screen.dart` | 811 | ⚠️ 2.0× |
| Workout preferences | `settings/workout_preferences_screen.dart` | 517 | ⚠️ 1.3× |
| Help center | `settings/help_center_screen.dart` | 39 | ✅ |
| About | `settings/about_screen.dart` | 39 | ✅ |

---

## 1. Security and privacy

- **Route** `/settings/security` (`app_router.dart:242-245`)
- **File** `lib/presentation/screens/settings/security_app_lock_screen.dart` (1040 lines)
- **Class** `SecurityAppLockScreen extends ConsumerStatefulWidget` (`:11`)
- **Reached from** `settings_sections_list.dart:137-146` — row `'Security & Privacy'` /
  `'App Lock & Biometrics'`, icon `Icons.shield_outlined`
- **Provider** `securitySettingsNotifierProvider` → `SecuritySettings` (`AsyncValue`)
  — `providers/security_settings_provider.dart:12` (alias `:130`)
- **Repository** `ISecurityRepository` → `SecurityRepositoryImpl`
  (`data/repositories/security_repository_impl.dart:7`) — **JSON string in
  `SharedPreferences`**, key `fittrack_security_settings_v1` (`:8`). No SQLite table.
- **Entity** `SecuritySettings` (`domain/entities/security_settings.dart:49`):
  `isAppLockEnabled`, `isBiometricEnabled`, `isPasscodeFallbackEnabled`, `lockTimeout`,
  `hideContent`, `requireForSensitive`, `failedAttemptsCooldown`.
  `LockTimeout` enum: `immediate` / `min5` / `min15` / `min30` (`:6-46`).
- **Sections:** App Lock · Biometrics · Require Lock (auto-timeout) · Privacy & Data Guard.
- **Fabricated / unimplemented claims to remove during the redesign**

  | Line | String | Reality |
  |---|---|---|
  | `:477` | `'Hardware Secured'` | unconditional badge, no capability check |
  | `:56`, provider `:102-103` | `'Hardware Token Authenticated: Sub-millisecond response confirmed.'` | fabricated latency claim |
  | `:584` | `'instantaneous zero-latency unlock'` | fabricated |
  | `:415` | "Require biometric authentication every time FitTrack is opened or resumed from background" | **app lock is never enforced** — `isAppLockEnabled` is read nowhere else |
  | `:890` | "30-second security lockdown following 5 consecutive unrecognized attempts" | only a boolean is persisted; no cooldown logic exists |
  | `:874` | "Require credential confirmation before exporting…" | `requireForSensitive` never read outside this file |
  | `:858` | "Hide Content in App Switcher" | `hideContent` never read outside this file |
  | `:1026` | "managed exclusively by Secure Enclave / Android KeyStore" | `local_auth` only |

- **Also:** `debugPrint` of personal auth events (`:56`, provider `:94/110/122`) — AGENTS.md
  privacy rule. `_pulseController.repeat(reverse: true)` (`:30-33`) is never paused when
  `TickerMode` is off (AGENTS.md §9).

---

## 2. Password and authentication

- **Route** `/settings/password` (`app_router.dart:247-250`)
- **File** `lib/presentation/screens/settings/password_security_screen.dart` (1010 lines)
- **Class** `PasswordSecurityScreen extends ConsumerStatefulWidget` (`:26`)
- **Reached from** `settings_sections_list.dart:148-155` **and**
  `settings/account_details/widgets/account_security_card.dart:19`
- **Providers** `securityNotifierProvider` → `SecurityState`
  (`providers/security_provider.dart:7`); `themeNotifierProvider`
- **Repository / storage: NONE.** `SecurityNotifier.build()` (`:107-118`) returns a
  **hard-coded in-memory state**: `currentPassword: 'OriginalAthletePass2024!'`,
  `newPassword`/`confirmPassword: 'P@ceSetter2025#'`. The audit log is 3 mock entries
  (`:120-145`) and is lost on restart.
- **Entity** `SecurityActivity` (`domain/entities/security_activity.dart:7`) — `id`,
  `title`, `timestamp`, `deviceInfo`, `location`, `statusBadge`.
- **Modals** `widgets/security_modals.dart` (1200 lines) —
  `showPasswordConfirmationModal` (`:37`), `showPasswordSuccessModal` (`:503`),
  `showPasswordFailedModal` (`:891`).
- **Fabricated / unimplemented**

  | Line | String | Reality |
  |---|---|---|
  | `:97` | `targetAccount: 'dineth@fittrack.io'` | hard-coded identity |
  | `:351` | "A recovery code will be dispatched to your registered primary email address." | no email or recovery code exists |
  | `:245` | "biometric sync encrypted" | no encryption, no sync |
  | `:791` | `'Contact Support ↗'` | a plain `TextSpan` in a `Text.rich` — **not tappable** |
  | — | audit log rows | 100% mock, in-memory |
  | — | passwords in provider state | plain `String`, no hashing, no secure storage — AGENTS.md §10 conflict |

- **Also:** `state.canSubmit` (provider `:79`) is **never checked** — `_handleUpdatePassword`
  (`:75`) always opens the confirmation modal. `ListView.separated(shrinkWrap: true)` at
  `:745-754` violates AGENTS.md §9. `_buildActivityCard(context, dynamic activity)`
  (`:859`) uses `dynamic` and loses the entity's type safety. 15 raw `Color(0x…)` literals.

---

## 3. Workout preferences

- **Route** `/settings/workout-preferences` (`app_router.dart:267-270`)
- **File** `lib/presentation/screens/settings/workout_preferences_screen.dart` (517 lines)
- **Class** `WorkoutPreferencesScreen extends ConsumerWidget` (`:15`)
- **Reached from** `settings_sections_list.dart:161-169`;
  `profile/widgets/profile_settings_links.dart:83-92`;
  `active_workout/active_workout_screen.dart:243`;
  `workout_detail/widgets/workout_detail_header.dart:132`
- **Provider** `workoutSettingsNotifierProvider` → `WorkoutSettingsState` (freezed,
  `providers/workout_settings_provider.dart:12`): `defaultRestTimer`,
  `autoStartRestTimer`, `keepScreenAwake`, `enableRPE`, `includeWarmups`,
  `plateCalculator`, `weightUnit`, `distanceUnit`, `bodyUnit`, `barbellWeight`,
  `ezBarWeight`, `gymProfile`
- **Storage** `SharedPreferences`, keys prefixed `workout_settings_` (`:32`). No SQLite,
  no repository interface.
- **Sections:** Timers & Workflow · Tracking & Progression.
- **Modal** `showDefaultRestTimerModal(context)` → `widgets/modals/default_rest_timer_modal.dart:19`
- **Fabricated / unimplemented**

  | Line | String | Reality |
  |---|---|---|
  | `:446` | `'Cloud Sync Active'` | no cloud, no sync |
  | `:456` | "automatically sync across your phone, tablet, and smart watch while logged in" | no sync implementation |
  | `:293` | "Log Rate of Perceived Exertion (1–10) for working sets" | `enableRPE` persisted but never read by the logger |
  | `:338` | "Automatically calculate warm-up volume based on working weight" | `includeWarmups` unused elsewhere |
  | `:383` | "Show visual plate loading breakdown for barbell exercises" | `plateCalculator` unused elsewhere |
  | `:235` | "Prevent device from locking during an active workout" | `keepScreenAwake` not wired to wakelock |

---

## 4. Units and equipment

- **Route** `/settings/units-equipment` (`app_router.dart:272-275`)
- **File** `lib/presentation/screens/settings/units_equipment_screen.dart` (811 lines)
- **Class** `UnitsEquipmentScreen extends ConsumerWidget` (`:15`)
- **Reached from** `settings_sections_list.dart:171-179` — row `'Units & Equipment'`,
  subtitle `'${isMetric ? "Metric" : "Imperial"} barbell'`,
  `trailingPreview: isMetric ? 'Metric' : 'Imperial'`. **No other entry point.**
- **Provider / storage** same `workoutSettingsNotifierProvider` as Workout preferences.
  Keys: `workout_settings_weightUnit|distanceUnit|bodyUnit|barbellWeight|ezBarWeight|gymProfile`.
- **Sections:** Measurements (weight / distance / body units) · Hardware Defaults
  (standard barbell, EZ curl bar) · Available Equipment (gym profile radios).
- **Fabricated / unimplemented**

  | Line | String | Reality |
  |---|---|---|
  | `:551` | `'Profile synced to Cloud'` | no cloud |
  | `:42` | `'Changes synced to workout logs'` | a `PopScope` snackbar only |
  | `:451` | `'WORKOUT FILTER'` | no filtering behaviour wired |
  | `:486` | "Filter routines and exercise substitutes based on your gear." | `gymProfile` persisted but never consumed elsewhere |

- **Also:** deprecated `RadioListTile.groupValue` (`:775`, `:801`) — Flutter 3.32+ migration
  risk.

> ⚠️ **Cross-screen conflict:** this screen's `weightUnit` / `gymProfile` are **different
> fields** from the ones onboarding collects and discards (see
> `docs/05-ONBOARDING-AUTH.md`). The user currently cannot change their onboarding unit
> system or equipment at all. A redesign should make one of them authoritative.

---

## 5. Data and Integrations

- **Route** `/settings/data` (`app_router.dart:257-260`)
- **File** `lib/presentation/screens/settings/data_management_screen.dart` (972 lines)
- **Class** `DataManagementScreen extends ConsumerWidget` (`:14`)
- **Reached from** `settings_sections_list.dart:206-215` — row `'Data & Integrations'` /
  `'Health Connect, Google Fit, cloud backup'`; and
  `profile/widgets/profile_settings_links.dart:70-79`
- **Provider** `dataManagementNotifierProvider` → `DataManagementState` (freezed,
  `providers/data_management_provider.dart:12`): `isAutoBackupEnabled`,
  `exportBackupBeforeDelete`, `snapshots: List<BackupSnapshot>`, `isBackingUp`,
  `isRestoring`, `activeOperationMessage`
- **Entity** `BackupSnapshot` (`domain/entities/backup_snapshot.dart:8`) — `id`, `title`,
  `date`, `time`, `size`, `isLatest`
- **Storage: NONE.** `DataManagementNotifier.build()` (`:27-58`) returns **3 hard-coded
  snapshots** and every mutator is a `Future.delayed` simulation (`createBackup` `:72-102`
  700 ms, `restoreBackup` `:105-117` 650 ms, `refreshBackups` `:120-124` 400 ms,
  `clearCategoryData` `:127-133` 450 ms, `clearAllData` `:136-145` 600 ms). In-memory only.
- **Modal** `showDataManagementInfoModal({required BuildContext context})` →
  `widgets/data_modals.dart:439` (raw `BackdropFilter`, not `GlassSurface`)
- **Fabricated / unimplemented**

  | Line | String | Reality |
  |---|---|---|
  | `:745` | `'Cloud Synced'` | always rendered, independent of `isAutoBackupEnabled` |
  | `:141` | `'Last snapshot: Today at 2:15 PM'` | hard-coded, not derived from `snapshots` |
  | `:157` / `:161` | `'842 Workouts'` / `'14 Templates'` | hard-coded counts, not from SQL |
  | `:131` | `'FitTrack Cloud Vault'` | no cloud exists |
  | `:319` | "Sync workout logs automatically over Wi-Fi" | no Wi-Fi check, no scheduler |
  | `:549/559/588` | "Import Workout Template / Hevy, Strong, CSV logs / Import" | **no importer** — `:943-952` is a snackbar |
  | `:429/450/476` | `.fittrack` restore | no file format validation, no real backup-before-destructive |
  | `:644` | "delete all routines, exercise sets, personal records, and measurements" | the button only navigates to `/settings/data/erase` |
  | `settings_sections_list.dart:211` | `'Health Connect, Google Fit, cloud backup'` | **zero** Health Connect / Google Fit code in `lib/` |

- **Three fake actions implemented as snackbars only:** `_handleExportArchive` (`:921-930`,
  writes no file), `_handleChooseBackupFile` (`:932-941`, no picker),
  `_handleImportThirdParty` (`:943-952`, no importer).
- **Also:** `ListView.separated(shrinkWrap: true)` at `:368-387` violates AGENTS.md §9.
  41 raw `Color(0x…)` literals. `state.exportBackupBeforeDelete` is never surfaced.

---

## 6. Help center

- **Route** `/settings/help` (`app_router.dart:277-280`)
- **File** `lib/presentation/screens/settings/help_center_screen.dart` (**39 lines**)
- **Class** `HelpCenterScreen extends StatelessWidget` (`:3`)
- **Reached from** `settings_sections_list.dart:221-228` — row `'Help Center & FAQs'` /
  `'Guides, tutorials, contact support'`
- **Providers: NONE. Repository: NONE.**
- **Body is `const SizedBox.shrink()` (`:36`) — the screen renders nothing.**
- Plain `AppBar` + inline `TextStyle`; no glass, no mesh background; uses
  `Navigator.of(context).maybePop()` instead of `context.pop()`.
- **Gap:** the parent row advertises guides, tutorials and contact support; the screen is
  an empty placeholder.

---

## 7. About

- **Route** `/settings/about` (`app_router.dart:292-295`)
- **File** `lib/presentation/screens/settings/about_screen.dart` (**39 lines**)
- **Class** `AboutScreen extends StatelessWidget` (`:3`)
- **Reached from** `settings_sections_list.dart:239-247` — row `'About FitTrack'` /
  `'Version information, terms & privacy'`, **`trailingPreview: 'v1.4.2'` (`:245`)**
- **Providers: NONE. Repository: NONE.**
- **Body is `const SizedBox.shrink()` (`:36`) — renders nothing.**
- ⚠️ **The version `'v1.4.2'` is fabricated** — `pubspec.yaml:19` declares `version: 1.0.0+1`.
  A redesign must read the version from the package info at runtime.
- Same structural notes as Help center.

---

## 8. Shared settings components (use these)

All in `lib/presentation/screens/settings/widgets/`:

| Widget | Constructor | Notes |
|---|---|---|
| `FtSettingsCard` (`ft_settings_card.dart`, 66) | `({key, double radius=20, EdgeInsetsGeometry padding=EdgeInsets.zero, required Widget child, VoidCallback? onTap})` | Watches `themeNotifierProvider`; uses `FtGlassTheme.cardDecoration`. Optional `Material`/`InkWell`. |
| `SettingsGroupCard` (`settings_group_card.dart`, 74) | `({key, required String title, required List<Widget> children})` | Uppercase 11sp w700 section label, auto `Divider` (indent 62) between children, wraps in `FtSettingsCard(radius: 20)`. Returns `SizedBox.shrink()` when `children` is empty. |
| `SettingsTileRow` (`settings_tile_row.dart`, 131) | `({key, required IconData icon, required Color iconBgColor, required Color iconColor, Color? iconBorderColor, required String title, required String subtitle, String? trailingPreview, Color? trailingPreviewColor, required VoidCallback onTap})` | 38×38 r12 icon tile, 14sp w600 title, 12sp muted subtitle, optional trailing value, `Icons.chevron_right_rounded`. |
| `SettingsHeader` (`settings_header.dart`, 50) | `({key})` | `FtDynamicHeader`, title `'Settings'`, subtitle `'Manage your account, preferences & hardware'`. |
| `SettingsSearchBar` (`settings_search_bar.dart`, 206) | `({key, required TextEditingController controller, FocusNode? focusNode, ValueChanged<String>? onChanged, VoidCallback? onClear})` | Custom blur-intensity→alpha curve, animated focus glow. |
| `SettingsSectionsList` (`settings_sections_list.dart`, 318) | `({key, required String searchQuery})` | **Builds all 4 groups / 12 rows.** Detects `ProviderScope` at `:26-41` and falls back to a static list with **fabricated defaults** (`:32-40`). |
| `SettingsLogoutButton` (`settings_logout_button.dart`, 191) | `({key})` | Static fallback path uses **`onConfirm: () async {}`** (`:43`) — a no-op. |
| `showFitTrackRatingSheet` (`settings_rating_sheet.dart`, 127) | `(BuildContext)` | 5 stars; "Rate on App Store" only pops + snackbars — **no `url_launcher` / store link**. |
| `AthleteProfileHeroCard` (`athlete_profile_hero_card.dart`, 250) | `({key})` | 60×60 gradient-ring avatar, `Image.file(cacheWidth: 120)` + asset fallback, emerald verified badge, pushes `/settings/profile`. Fallback name `'Dineth'` (`:52`), fallback `'Advanced Lifter'` (`:56`). |

`lib/presentation/screens/settings/settings_subscreens.dart` (12 lines) is a pure barrel
of `export`s — imported once by `app_router.dart:31`.

### The four groups and twelve rows (`settings_sections_list.dart`)

| Group | Row | Route |
|---|---|---|
| `ACCOUNT & SECURITY` (`:289`) | Account Details (`:128`) | `/settings/account` |
| | **Security & Privacy** (`:137`) | `/settings/security` |
| | **Password & Authentication** (`:148`) | `/settings/password` |
| `WORKOUT & TIMERS` (`:294`) | **Workout Preferences** (`:161`) | `/settings/workout-preferences` |
| | **Units & Equipment** (`:171`) | `/settings/units-equipment` |
| `APP PREFERENCES` (`:299`) | Appearance & Display (`:185`) | `/settings/appearance` |
| | Notifications & Reminders (`:195`) | `/settings/notifications` |
| | **Data & Integrations** (`:206`) | `/settings/data` |
| `SUPPORT & ABOUT` (`:304`) | **Help Center & FAQs** (`:221`) | `/settings/help` |
| | Share & Rate FitTrack (`:230`) | `showFitTrackRatingSheet(context)` |
| | **About FitTrack** (`:239`) | `/settings/about` |

Search filter `matches(title, subtitle)` at `:120-123`; empty state
`'No settings found for "$searchQuery"'` at `:269`.

**The icon tints are 23 hard-coded `Color(0x…)` literals** in this one file
(`:130`–`:242`) — all off-palette (indigo, violet, emerald, cyan, pink, blue, amber,
rose, slate). A redesign should derive them from the accent.

### Entry points

1. **Primary** `lib/presentation/screens/settings_screen.dart` (140 lines) —
   `SettingsScreen extends StatefulWidget` (`:18`), route `/settings`, bottom-nav tab 3.
   `SettingsHeader()` `:103` → `SettingsSearchBar` `:106-119` →
   `AthleteProfileHeroCard()` `:122` → `SettingsSectionsList(searchQuery:)` `:125` →
   `SettingsLogoutButton()` `:128`. `CustomScrollView` + `SliverList` `:86-132`,
   `ConstrainedBox(maxWidth: 430)` `:85`, `PopScope` `:67-80`.
2. **Profile** `lib/presentation/screens/profile/widgets/profile_settings_links.dart` (174) —
   `ProfileSettingsLinks` (`:12`), used at `profile/profile_screen.dart:256`. Only
   **3** tiles: Account Details, Data & Backup, Workout Settings. **Does not link to
   security, password, units, help or about.**
3. **Account details** `settings/account_details/widgets/account_security_card.dart:19` →
   `/settings/password`.

---

## 9. Redesign checklist (per screen)

1. Replace the hand-rolled `Container` cards with `GlassSurface` (or `FtSettingsCard` /
   `SettingsGroupCard` for the settings family).
2. Replace every `fontFamily: 'Plus Jakarta Sans'` inline with `FtText.*` styles; replace
   raw `colorScheme.*` with `context.ft*` tokens; replace raw `Color(0x…)` with
   `FtGlassTheme` constants.
3. Put the screen on `FtMeshBackground` with a transparent `Scaffold`.
4. Use `FtDynamicHeader` (Category A — these have a bell) with a back button; follow
   `docs/01-DESIGN-SYSTEM.md` §1.
5. Decompose into `<screen>/widgets/` so every file is under 400 lines.
6. **Delete or implement every fabricated claim** in the tables above. If a feature is not
   real (cloud sync, Health Connect, app lock enforcement, recovery email), the honest
   options are to implement it or to remove the copy and the control.
7. Fix the `shrinkWrap: true` lists and the deprecated `RadioListTile.groupValue`.
8. Add widget tests for loading / empty / error / data states (none exist today).

### Highest-risk fabricated strings

`security_app_lock_screen.dart:477,56,415,890,1026` ·
`password_security_screen.dart:97,351,791` ·
`workout_preferences_screen.dart:446,456` ·
`units_equipment_screen.dart:551,42` ·
`data_management_screen.dart:141,157,161,745,925,936,947` ·
`settings_sections_list.dart:245` (`'v1.4.2'` vs pubspec `1.0.0+1`), `:211`
("Health Connect, Google Fit" — neither exists).
