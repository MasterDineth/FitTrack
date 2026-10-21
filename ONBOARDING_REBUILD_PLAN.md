# Onboarding Rebuild — Analysis & Plan

Status: **proposal**. No production code changed by this document.
Baseline verified: `flutter analyze` → *No issues found* (2025-12-03, branch `ui-redesign-settings`).
All findings below are from source reading plus targeted greps; runtime behaviour was not exercised.

---

## 1. Verdict

The three onboarding screens (`welcome_screen.dart`, `telemetry_setup_screen.dart`,
`fitness_profile_setup_screen.dart`) are not a design-system problem — they are a
**flow-and-data problem wearing a design-system problem**. Rebuilding the pixels alone
would ship a prettier version of a flow that:

- collects 11 fields and **persists 4** of them,
- contains a **Back button that cannot go back**,
- contains **two buttons labelled "Skip" that do not skip**,
- shows a **"100% completed" badge before the user has completed anything**,
- and ships a **mock authentication repository inside the release build**.

The glass/token work (AGENTS.md §8) is necessary but is roughly the *smaller* half of the job.
The larger half is deciding what the flow is, what it stores, and where its edges are.

---

## 2. The flow as it exists today

```mermaid
flowchart TD
    S[/splash] --> W[Welcome<br/>step 1 of 4]
    W -->|Get Started / Sign In / SKIP SETUP| A[Auth<br/>step 2 of 4]
    A -->|signed in| T[Telemetry<br/>step 3 of 4]
    T -->|Continue| F[Fitness<br/>step 4 of 4]
    F -->|Complete Setup| D[/dashboard]
    T -.->|Back| W
    F -.->|Back| T
    T -.->|Back -> /welcome| X[redirect bounces<br/>straight back to Telemetry]
```

**The redirect is the gate** (`app_router.dart:61-107`): an authenticated user whose profile
is incomplete is forced to `/onboarding/telemetry` regardless of where they navigate.
This makes the Back button on the Telemetry screen a dead end — see §3.1.

### File sizes

| Screen | Lines | Limit (AGENTS.md §9) | Status |
|---|---|---|---|
| `welcome_screen.dart` | 336 | 400 | OK |
| `telemetry_setup_screen.dart` | 1103 | 400 | **2.7× over** |
| `fitness_profile_setup_screen.dart` | 508 | 400 | over |
| `auth_screen.dart` (in the same flow) | 560 | 400 | over |

---

## 3. P0 — behavioural defects (fix before any visual work)

### 3.1 The Telemetry Back button cannot go back

`telemetry_setup_screen.dart:132-151` and `:665-681` do:

```dart
if (context.canPop()) { context.pop(); } else { context.go('/welcome'); }
```

`context.pop()` is never true, because the flow enters Telemetry via `context.go(...)`
which replaces the stack. The fallback `context.go('/welcome')` then hits the redirect
(`app_router.dart:95-100`): the profile is incomplete, `/welcome` is neither telemetry nor
fitness, so the router returns `/onboarding/telemetry`. **The user is bounced straight back
to the screen they tried to leave.** The button is a no-op in production.

`test/telemetry_flow_test.dart:100-139` asserts that Back navigates to `/welcome` — but that
test builds its own router with **no redirect**, so it passes while the real app does the
opposite. The test encodes the bug as expected behaviour.

### 3.2 Two "Skip" buttons, neither of which skips

| Control | Label | Actual behaviour |
|---|---|---|
| `welcome_screen.dart:197-208` | `SKIP SETUP` | `context.go('/auth')` — skips the *welcome screen only*. The user is then forced into onboarding by the redirect. The label is false. |
| `fitness_profile_setup_screen.dart:121-131` | `Skip` | calls `_complete()` — i.e. it **saves everything and goes to the dashboard**. It is a duplicate of "Complete Setup", not a skip. |

### 3.3 Four of eleven collected fields are silently discarded

`saveTelemetry` (`user_profile_provider.dart:190-202`) persists only `name`, `age`,
`weightKg`, `heightCm`. `saveFitnessProfile` (`:205-231`) persists only `name`,
`experienceLevel`, `primaryGoal`, `weeklyTargetDays`.

| Collected on screen | Persisted? | Where it goes |
|---|---|---|
| Age | yes | `user_profile.age` (INTEGER NOT NULL) |
| Weight | yes | `user_profile.weightKg` |
| Height | yes | `user_profile.heightCm` |
| Lifting experience | yes (string) | `user_profile.experienceLevel` |
| Weekly frequency | yes | `user_profile.weeklyTargetDays` |
| Primary focus | lossy string | `user_profile.primaryGoal` — enum not recoverable |
| **Unit system** | **no** | dropped; a *different*, unlinked `weightUnit` lives in `WorkoutSettingsState` |
| **Biological sex** | **no** | local BMR constant only (`-161` / `+5`) |
| **Activity level** | **no** | no field on any entity, no column anywhere |
| **Available equipment** | **no** | dropped; `WorkoutSettingsState.gymProfile` is an unrelated free-text string |
| BMI / BMR / hydration | derived | never stored; the Dashboard hydration banner uses a separate provider with a hardcoded 2.5 L goal |

The `_activityLevel` selector (`telemetry_setup_screen.dart:30, 588-629`) is therefore a
**control that does nothing** — a direct AGENTS.md §10 violation.

The read path is worse than the write path. `getBodyTelemetry` hardcodes
`unitSystem: metric, biologicalSex: male` (`sqlite_user_repository.dart:68-69`) and
`getFitnessProfile` hardcodes `primaryFocus: hypertrophy, liftingExperience: advanced,
availableEquipment: fullGym` (`:111-114`). **Neither method is ever called from `lib/`** —
they are dead code that returns fabricated data.

### 3.4 Mock authentication is wired into the production graph

`repository_providers.dart:31-34`:

```dart
@Riverpod(keepAlive: true)
IAuthRepository authRepository(Ref ref) {
  return MockAuthRepository();
}
```

`MockAuthRepository` (`data/repositories/mock/mock_auth_repository.dart`) hardcodes user id
`'123'` and password-reset code `'123456'` (`:22, 24, 56`) and stores the **email address in
plaintext SharedPreferences** (`:23, 25, 34`).

This breaches AGENTS.md §3 ("mock repositories MUST NOT be reachable in release builds") and
§10 ("NEVER store plaintext passwords or tokens"). It is the reason onboarding currently has
no real identity to partition data by.

`MockUserRepository` is *not* reachable — `userRepositoryProvider` always returns
`SqliteUserRepository`. That one is fine.

### 3.5 Identity is a single hardcoded row

- Screens write `authProvider.value?.id ?? 'local'` into `BodyTelemetry.userId` /
  `FitnessProfile.userId` — then those ids are discarded.
- The provider reads and writes row `'1'` (`user_profile_provider.dart:18, 24`).
- **There is zero per-user partitioning.** A second signed-in user inherits row `'1'`
  and the previous user's body data.

### 3.6 Cold start bounces through onboarding

`app_router.dart:91` reads `userProfileState.value?.isComplete ?? false`. While the async
`userProfileProvider` build is in flight, `value` is `null` → `profileComplete` is `false` →
the router returns `/onboarding/telemetry` (`:99`). Once the profile resolves,
`GoRouterNotifier` (`:48`) re-runs the redirect and the user lands on `/dashboard`.

Every cold start therefore flashes the onboarding screen before the dashboard. The fix is to
treat "profile still loading" as a distinct state from "profile incomplete", and to hold the
redirect on the splash until the profile resolves.

### 3.7 No-op handlers

- `telemetry_setup_screen.dart:170` — "Why we ask" → `onPressed: () {}`
- `auth_screen.dart:148` — "Help" → `onPressed: () {}`
- `auth_screen.dart:417` — "Explore first without account →" → `onPressed: () {}`
- `auth_screen.dart:534` — both social sign-in buttons → `onPressed: () {}`

AGENTS.md §10: "A control is either implemented, disabled (null handler with a disabled
style), or removed." None of these is implemented, and none carries a `// TODO(<issue>)`.

### 3.8 Raw exceptions leak to the UI

`telemetry_setup_screen.dart:105` → `'Failed to save profile: $e'`;
`fitness_profile_setup_screen.dart:53` → `'Failed to complete setup: $e'`.
AGENTS.md §4 requires typed failures at the data boundary; the raw exception must not
reach the user.

### 3.9 Fabricated personal data is written to the database

`user_profile_provider.dart:25, 194, 223` write the hardcoded name `'Dineth'` as the
persisted `name` on first onboarding. `account_details_screen.dart:83-86` seeds edit-field
defaults with the phone number `77 123 4567`, date of birth `14 Oct 2003` and address
`742 Evergreen Terrace, Colombo` — **and persists them if the user taps Save**.
`security_modals.dart:39` and `password_security_screen.dart:97` hardcode
`dineth@fittrack.io`. AGENTS.md §10: "No fabricated status."

---

## 4. P1 — design-system compliance (the visible half)

### 4.1 Zero glass, zero tokens

Measured across the three onboarding screens:

| Token | welcome | telemetry | fitness | auth |
|---|---|---|---|---|
| `FtText.*` | 0 | 0 | 0 | 0 |
| `GlassSurface(` | 0 | 0 | 0 | 0 |
| `AmbientMeshBackground` | 0 | 0 | 0 | 0 |
| hand-rolled `fontSize:` | 8 | 32 | 11 | 11 |
| `BorderRadius.circular` | 4 | 17 | 5 | 5 |
| `Colors.*` / raw `Color(0x…)` | 5 | 3 | 0 | 3 |
| `GestureDetector` | 1 | 5 | 2 | 2 |
| no-op handlers | 0 | 1 | 0 | 3 |

For contrast, the rest of the app has **1063** `FtText` / `GlassSurface` / radius-token
references. The onboarding flow is the only part of the app that never touched the
design system. It sits on a flat `Scaffold(backgroundColor: theme.scaffoldBackgroundColor)`
and hand-rolls its own shadows (`shadow.withValues(alpha: 0.04), blurRadius: 8, offset: (0,2)`)
on every card.

`welcome_screen.dart:24-43` even hand-rolls a `RadialGradient` "Ambient glow" circle — an
ad-hoc imitation of `AmbientMeshBackground`.

### 4.2 Off-brand hardcoded colours

| File:line | Value | Problem |
|---|---|---|
| `welcome_screen.dart:169-170` | `Colors.indigo` | off-brand; not a `ColorScheme` role |
| `welcome_screen.dart:177-178` | `Colors.amber` / `Colors.amber.shade800` | off-brand; not a `ColorScheme` role |
| `telemetry_setup_screen.dart:49` | `Colors.blueAccent` | off-brand |
| `telemetry_setup_screen.dart:51` | `const Color(0xFFF59E0B)` | raw hex — the exact thing AGENTS.md §8 forbids |
| `auth_screen.dart:558` | `Colors.red` | raw, for the Google glyph |

### 4.3 Four different header and progress languages in one flow

| Screen | Back control | Progress affordance |
|---|---|---|
| Welcome | none | `FtStepIndicator(currentStep: 0)` in the **footer** |
| Auth | real `IconButton` | 8 px dot + "Step 2 of 4" text, **no indicator** |
| Telemetry | `GestureDetector` in a 40×40 `Container` | "STEP 3 OF 4" pill **and** `FtStepIndicator(currentStep: 2)` — two of them |
| Fitness | `GestureDetector` in a 40×40 `Container` | "STEP 4 OF 4" pill **and** `FtStepIndicator(currentStep: 3)` — two of them |

None is `FtHeaderTokens`-aligned (margin 16 vs the token's 20; back button 40 dp vs the
token's 48 dp `minTouchTarget`).

**`FtDynamicHeader` should not be used here.** It owns the notification bell + avatar
dynamic-island cluster; onboarding has neither, and AGENTS.md §8 explicitly exempts
bell-less screens. The right answer is a dedicated `OnboardingHeader` that reuses the
token contract — the pattern already exists at
`create_schedule/widgets/create_schedule_header.dart:29-46`
(`FtPressable` → `GlassSurface(tier: glass2, radius: 18, 40×40, shadow: false)`).

### 4.4 Accessibility

- **Tap targets under 48 dp:** back buttons 40×40, steppers 32×32, weekly-day chips 38×38,
  and the Welcome "Sign In" link is a bare `GestureDetector` on 12 sp text (~16 dp tall).
- **No `Semantics` anywhere** in the three files (zero grep matches). Icon-only controls are
  unlabelled. Finalized screens wrap them — `dashboard/widgets/telemetry_stack.dart:123-138`.
- **`GestureDetector` instead of `InkWell`/`IconButton`** — no ripple, no focus, no hover.
- **`MediaQuery.disableAnimationsOf` is not honoured** by any of the 9 `AnimatedContainer`s
  (200 ms / 150 ms) or by `FtStepIndicator`'s 300 ms transition.

### 4.5 Copy: jargon and fabricated status

AGENTS.md §8 forbids internal jargon in visible text and AGENTS.md §10 forbids fabricated
status. The flow is dense with both.

| Current string | Location | Problem | Proposed |
|---|---|---|---|
| `FITTRACK CORE` | welcome:117 | jargon badge | delete (the brand mark is already on screen) |
| `…reach your fitness goals with precision telemetry.` | welcome:147 | jargon | `…reach your fitness goals.` |
| `Auto-regulated progressive overload tracking` | welcome:165 | jargon | `Plans that grow with you` |
| `Precision Rest Intervals` | welcome:172 | jargon | `Rest timer` |
| `Haptic audio cues & set-by-set telemetry` | welcome:173 | jargon | `Cues between sets` |
| `Real-time strength milestones & graphs` | welcome:181 | jargon | `Progress over time` |
| `SKIP SETUP` | welcome:200 | **label is false** | `Skip` — and make it actually skip |
| `STEP 3 OF 4` / `STEP 4 OF 4` | telemetry:160, fitness:112 | shouting, duplicated | `Step 3 of 4` — one indicator only |
| `Calibrates your personalized calorie burn, metabolic baseline (BMR), and dynamic target load.` | telemetry:210 | jargon | `We use these to estimate how much energy you burn each day.` |
| `TELEMETRY ENGINE` | telemetry:478 | jargon | `Your numbers` |
| `REALTIME CALC` | telemetry:499 | fabricated badge | `Updates as you edit` (or delete) |
| `ESTIMATED BMI` | telemetry:518 | jargon | `BMI` |
| `BASAL BURN (BMR)` / `Daily base metabolic rate` | telemetry:527,530 | jargon | `Calories at rest` / `Calories your body uses at rest` |
| `Hydration Baseline:` | telemetry:559 | jargon | `Water:` |
| `FITNESS & ACTIVITY PROFILE` | telemetry:586 | jargon | `How active are you?` |
| `Avg: 175` | telemetry:418 | fabricated | delete (or compute from the user) |
| `adjust` | telemetry:912 | filler | delete |
| `75% completed` | telemetry:653 | fabricated | delete (progress is implied) |
| `100% completed` | fitness:401 | **false — nothing is done yet** | delete |
| `High Volume ↑` / `Balanced ✓` / `Low Volume ↓` | fitness:319-323 | fabricated status | delete |
| `Exercise alternatives auto-generated` | fitness:345 | claims a feature | `We will suggest swaps for equipment you do not have` |
| `Powers your program structure & rep ranges` | fitness:169 | jargon | `Sets how your program is built` |
| `Determines starting loads & volume` | fitness:208 | jargon | `Sets your starting weights` |

Also stale: the height slider's min/max labels stay in centimetres (`'120 cm'`, `'220 cm'`)
even when Imperial is selected (`telemetry_setup_screen.dart:403, 427`).

---

## 5. P2 — data model and documentation

### 5.1 `age` and `dob` coexist and are never reconciled

`UserProfile` has **both** `age` (required `int`, `NOT NULL` column) and `dob` (`String?`).
AGENTS.md §11 says to derive rather than store duplicates. Onboarding writes `age`;
`account_details_screen.dart:138-144` writes `dob` and leaves `age` untouched. Nothing
derives age from dob anywhere in the app.

### 5.2 Schema divergence between fresh installs and upgraded installs

`_onCreate` (`database_helper.dart:492-510`) creates `age`/`weightKg`/`heightCm`/
`experienceLevel`/`primaryGoal`/`weeklyTargetDays` as `NOT NULL`. The v<5 upgrade block
(`:48-60`) creates the same columns as **nullable**. The same table therefore has two
different schemas depending on install path. Since AGENTS.md §11 forbids editing a shipped
migration, this must be reconciled forward in a v15 migration.

### 5.3 There is no `body_telemetry` or `fitness_profiles` table

Neither table exists. The `BodyTelemetry` and `FitnessProfile` entities are constructed in
the screens and immediately partially projected into `user_profile`; the repository methods
`saveBodyTelemetry` / `saveFitnessProfile` (`sqlite_user_repository.dart:49-102`) duplicate
that mapping and are never called from `lib/`.

### 5.4 `DATA_MODEL.md` is substantially wrong

Of the tables it documents, `users`, `user_profiles`, `body_telemetry`,
`daily_bio_metrics` and `fitness_profiles` **do not exist**; the real table is the singular
`user_profile` with entirely different columns. It also claims (`:24`) that age is
"derived dynamically at runtime, never stored as a static integer column" — the exact
opposite of the code. The only accurate line in the file is the schema version (`14`).

Note the file lives at the **repo root**, not `fittrack/DATA_MODEL.md` as AGENTS.md §11
implies.

### 5.5 There is no way back into onboarding

The redirect (`app_router.dart:102-104`) actively forbids reaching `/onboarding/*` once the
profile is complete, and no Settings or Profile screen offers a "re-run onboarding" entry
point. Post-onboarding editing is ad-hoc free-text modals in
`profile/widgets/profile_personal_info_section.dart`. **Unit system and equipment cannot be
changed after onboarding at all** — the Units & Equipment screen edits
`WorkoutSettingsState.weightUnit` / `gymProfile`, which are different fields from the ones
onboarding dropped.

### 5.6 The tests do not test the router

- `onboarding_navigation_test.dart:96-210` is titled "Router Redirect Logic Tests" but
  **re-implements** the redirect as a local `computeRedirect` copy — already missing the
  `splashDoneProvider` branch. The real router can break with no failure.
- `telemetry_flow_test.dart` builds routers with no redirect, and asserts only that the
  title, a "Continue" button and a navigation happened. **It never asserts what was
  persisted** — which is exactly why four dropped fields went unnoticed.

---

## 6. Recommended target flow

The core structural recommendation: **stop counting Welcome and Auth as onboarding steps.**
Welcome is pre-auth marketing; Auth is an account gate. Numbering them "1 of 4" and "2 of 4"
is what creates the "SKIP SETUP" lie and the duplicated progress indicators. The flow should
be honestly two steps, plus one optional import step.

```mermaid
flowchart TD
    S[/splash<br/>hold until profile resolves] --> W[Welcome<br/>not a numbered step]
    W -->|Get Started| A[Auth<br/>gate, not a numbered step]
    A -->|signed in| P1[Step 1 of 2 — About you<br/>unit · date of birth · sex · height · weight]
    P1 -->|Continue| P2[Step 2 of 2 — Your training<br/>activity · goal · days/week · experience · equipment]
    P2 -->|Finish| H[Health Connect import<br/>optional, Android only]
    H --> D[/dashboard]
    P1 -.->|Skip| D
    P2 -.->|Skip| D
    D -->|Settings / Profile| R[Re-run onboarding<br/>edit stored profile]
```

**Why two steps, not three or four:** the existing two profile screens already carry the
right *content*; what they lack is a shared visual language, real persistence, and honest
labels. Splitting them further would add navigation without adding clarity.

**Why add the Health Connect step:** AGENTS.md §2 lists Health Connect as a real
Android-only capability that must be platform-gated, and it is the single highest-value
onboarding affordance for a fitness app that then shows you a dashboard. It should be
*optional* and skippable, and it must not block the dashboard.

**Why allow Skip on both steps:** the current redirect makes skipping impossible, which is
why "SKIP SETUP" had to lie. A real skip writes a minimal valid profile, lands on the
dashboard, and leaves a "Complete your profile" prompt in the app. Body data is sensitive;
letting a user defer it is the honest behaviour.

**Why add a re-run entry point:** the user cannot change their unit system or equipment
today. One Settings row fixes it and makes the whole flow recoverable.

---

## 7. What to add

| # | Addition | Why | Where |
|---|---|---|---|
| A1 | `OnboardingHeader` shared widget (back button, one progress indicator) | removes 3 ad-hoc header implementations and one duplicate indicator per screen | `presentation/widgets/onboarding_header.dart` |
| A2 | `OnboardingStepFooter` shared widget | back/continue + step dots, identical across steps | `presentation/widgets/onboarding_step_footer.dart` |
| A3 | Real `GlassSurface` cards (tier `glass1`, `radius: FtGlassTheme.radiusCards`) and a `glassFloating` + `GlassBackdrop.live` sticky footer | visual parity with the finalized screens | both profile screens |
| A4 | `AmbientMeshBackground` substrate with a transparent `Scaffold` | every other screen sits on the mesh | both profile screens |
| A5 | `FtText.*` typography scale and `FtGlassTheme.radius*` tokens everywhere | 51 hand-rolled font sizes → 0 | all four screens |
| A6 | **A real "Why we ask"** bottom sheet per field | the button already exists as a no-op; body data deserves a privacy explanation | use `modal_backdrop_helper.dart` + the shared glass modal |
| A7 | **Persist the four dropped fields** | unit, sex, activity level, equipment currently do nothing | v15 migration + `UserProfile` |
| A8 | **Make the unit toggle authoritative** | bind it to `WorkoutSettingsState.weightUnit` / `bodyUnit` so it has a real effect and the Units & Equipment screen agrees | `workout_settings_provider.dart` |
| A9 | **Make `age` derive from `dob`** | removes the redundant NOT NULL column and the AGENTS.md §11 violation | entity + migration |
| A10 | **Replace `MockAuthRepository`** with a real local implementation (salted hash via `crypto`/`argon2`, platform secure storage, per-user rows) | §3 and §10 are currently breached; it also unblocks per-user data partitioning | `data/repositories/` |
| A11 | **Hold the redirect until the profile resolves** | kills the cold-start onboarding flash | `app_router.dart` |
| A12 | **A real Skip on both steps** that writes a minimal profile and lands on the dashboard | makes "Skip" truthful and respects sensitive data | both profile screens |
| A13 | **A "Complete your profile" prompt** for users who skipped | the dashboard then shows a real empty state instead of zeros | dashboard |
| A14 | **A "re-run onboarding" Settings row** | today unit and equipment are unchangeable after onboarding | `settings_subscreens.dart` |
| A15 | **Health Connect import step** (Android only, optional) | the highest-value onboarding affordance the app is missing | new screen, platform-gated |
| A16 | **Inline validation** with readable errors (age 14–95, weight, height) + a real typed-failure path | replaces `'Failed to save profile: $e'` | both profile screens + data layer |
| A17 | **A summary/review before finishing** | "you can edit anytime" is true only if editing works — A14 makes it true | end of step 2 |
| A18 | **Widget + repository tests that assert the round trip** | a single round-trip assertion would have caught all four dropped fields | `test/` |

---

## 8. What to remove

| # | Removal | Where |
|---|---|---|
| R1 | `onPressed: () {}` on "Why we ask" — implement it (A6) or delete the button | `telemetry_setup_screen.dart:170` |
| R2 | `onPressed: () {}` on "Help" | `auth_screen.dart:148` |
| R3 | `onPressed: () {}` on "Explore first without account →" — implement a real guest mode or delete | `auth_screen.dart:417` |
| R4 | `onPressed: () {}` on both social sign-in buttons — implement or delete | `auth_screen.dart:534` |
| R5 | `SKIP SETUP` → `Skip`, wired to a real skip (A12) | `welcome_screen.dart:200` |
| R6 | `Skip` on the fitness screen — it calls `_complete`; rename to `Finish` or make it skip | `fitness_profile_setup_screen.dart:124` |
| R7 | The "STEP N OF 4" pills — one indicator is enough | telemetry:160, fitness:112 |
| R8 | `75% completed` and `100% completed` (fabricated) | telemetry:653, fitness:401 |
| R9 | `100% completed` in particular — it shows before the user has done anything | fitness:401 |
| R10 | `TELEMETRY ENGINE`, `REALTIME CALC`, `FITTRACK CORE`, `ESTIMATED BMI`, `BASAL BURN (BMR)`, `Hydration Baseline:` | telemetry:478,499,518,527,559; welcome:117 |
| R11 | `Avg: 175`, `adjust`, the hardcoded `'120 cm'`/`'220 cm'` labels | telemetry:418, 912, 403, 427 |
| R12 | `High Volume ↑` / `Balanced ✓` / `Low Volume ↓` (fabricated status) | fitness:319-323 |
| R13 | `Colors.indigo`, `Colors.amber`, `Colors.blueAccent`, `Color(0xFFF59E0B)`, `Colors.red` | welcome:169-178, telemetry:49,51, auth:558 |
| R14 | The hand-rolled `RadialGradient` ambient glow on Welcome | welcome:24-43 |
| R15 | The hand-rolled `BoxShadow(... alpha 0.04, blur 8, offset (0,2))` on every card | all cards in all three screens |
| R16 | The dead `BodyTelemetry` / `FitnessProfile` construction in the screens, once A7 lands | telemetry:85-94, fitness:34-42 |
| R17 | `getBodyTelemetry` / `getFitnessProfile` — dead code that fabricates values, never called from `lib/` | `sqlite_user_repository.dart:62-117` |
| R18 | The dead `saveBodyTelemetry` / `saveFitnessProfile` repository methods | `sqlite_user_repository.dart:49-102` |
| R19 | The hardcoded `'Dineth'` name fallbacks | `user_profile_provider.dart:25, 194, 223` |
| R20 | The fabricated phone / dob / address edit-field defaults | `account_details_screen.dart:83-86` |
| R21 | The redundant `age` column, once A9 lands | entity + migration |
| R22 | The unused `BodyTelemetry` / `FitnessProfile` enum members that no longer map to a stored field | `body_telemetry.dart`, `fitness_profile.dart` |

---

## 9. Target file structure

Follows the `presentation/screens/dashboard/` and `presentation/screens/create_schedule/`
pattern: the screen file holds state + providers + navigation only; each child is a dumb
widget taking plain values and `VoidCallback`s, with no provider reads and no `setState`.

```
lib/presentation/
  screens/
    onboarding/
      welcome_screen.dart              (state-free; hero + 3 feature cards)
      telemetry_setup_screen.dart       (state + validation + navigation)
      fitness_setup_screen.dart        (state + validation + navigation)
      widgets/
        onboarding_header.dart         (shared: back button + step indicator)
        onboarding_step_footer.dart    (shared: back/continue + progress)
        welcome_hero.dart
        welcome_feature_card.dart
        about_you_card.dart            (unit toggle + dob + sex + height + weight)
        body_metrics_summary.dart      (BMI / calories at rest, plain copy)
        activity_selector.dart
        goal_selector.dart
        weekly_days_card.dart
        experience_selector.dart
        equipment_selector.dart
        why_we_ask_sheet.dart
  widgets/
    onboarding_header.dart             (if the house prefers shared widgets here)
    onboarding_step_footer.dart
```

Every file stays under 400 lines (AGENTS.md §9). Each profile screen should render
`Scaffold(transparent) → AmbientMeshBackground → Center → ConstrainedBox(maxWidth: 393) →
CustomScrollView → SliverSafeArea → SliverPadding → SliverList`, with 16–20 dp gaps —
matching `dashboard_screen.dart:92-137` and `create_schedule_screen.dart:219-309`.

---

## 10. Suggested sequencing

One branch per slice (AGENTS.md §13). Each slice is independently shippable and leaves
`flutter analyze` and `flutter test` green.

| Slice | Scope | Why first |
|---|---|---|
| **1** | Data foundation: v15 migration adding `dob`, `sex`, `activityLevel`, `equipment`, `unitSystem`; derive `age` from `dob`; fix the `NOT NULL`/nullable divergence; drop the dead telemetry/fitness repository methods; make `UserProfile` validate | Everything else writes to this |
| **2** | Replace `MockAuthRepository` with a real local auth implementation; per-user profile rows; hold the router redirect until the profile resolves | Removes the release-build mock and unblocks per-user data |
| **3** | Shared onboarding chrome: `OnboardingHeader`, `OnboardingStepFooter`, glass surfaces, `FtText` migration, `MediaQuery.disableAnimationsOf` | Establishes the pattern before the screens use it |
| **4** | Rebuild the Telemetry screen (step 1) | The worst offender at 1103 lines |
| **5** | Rebuild the Fitness screen (step 2) | Depends on slice 4's chrome |
| **6** | Real skip paths, "why we ask" sheet, re-run entry point in Settings, "complete your profile" prompt | Turns the flow honest |
| **7** | Health Connect import step (Android, optional) | New capability, isolated |
| **8** | Tests: real-router redirect test, round-trip repository test, widget tests per state, migration test | Closes the gaps in §5.6 |
| **9** | `DATA_MODEL.md` rewrite to match the real schema; document the new decisions | AGENTS.md §11 requires the docs to land in the same PR as the schema |

---

## 11. Open questions

These change the shape of the rebuild and are not answerable from the code alone.

1. **Should body metrics be time-series?** The rebuild above widens `user_profile` (one
   row, one snapshot). If you want weight/BMI history over time — which the Dashboard
   telemetry stack and `bio_metrics_repository_impl` hint at — the correct shape is real
   `body_telemetry` and `fitness_profiles` tables with their own repositories and a history
   screen. That is a larger build, and it changes slices 1 and 4.
2. **How long can unit system live in SharedPreferences?** A8 wires the onboarding toggle
   to `WorkoutSettingsState`, which is not per-user and does not survive an account switch
   cleanly. Moving unit preference onto `UserProfile` is more correct but touches the
   Units & Equipment screen and the workout logging code that reads `weightUnit`.
3. **Is a guest mode wanted?** A3 (removing the dead "Explore first without account"
   button) is trivial, but implementing a real guest mode changes the redirect contract and
   the whole gating model. If not wanted, the button should simply go.
4. **Is "Sign in with Apple" in scope?** AGENTS.md §2 lists it as an iOS-only feature that
   must be platform-gated, but the Auth screen shows it unconditionally on Android. Either
   gate it or drop it from the rebuilt Auth screen.
5. **Do we renumber the flow at all?** The proposal is 2 numbered steps. If Welcome and Auth
   should remain numbered for product reasons, then the "of N" count must at least be
   consistent — one indicator, one language, on all four screens.

---

## 12. Assumptions

- Findings are from source reading and targeted greps. `flutter analyze` was run and is
  clean; no widget test or runtime behaviour was exercised.
- "Stitch" was **not** consulted for this analysis — no Stitch MCP was available in this
  session, and no `DESIGN.md` exists in the repo. If Stitch holds onboarding screens, it
  takes priority over this document and the visual section should be re-derived from it
  (AGENTS.md §2: *Stitch screen code > screenshot > DESIGN.md*).
- The rebuild assumes the current frosted-glass system in `presentation/theme/` and
  `presentation/widgets/glass_surface.dart` is the target, per AGENTS.md §8.
- `AGENTS.md` §8 names `AmbientMeshBackground` as the required background, but the
  finalized screens actually use `FtMeshBackground` (`dashboard_screen.dart:92-99`,
  `appearance_settings_screen.dart:35`). This ambiguity should be resolved before the
  rebuild — pick one and use it everywhere.
