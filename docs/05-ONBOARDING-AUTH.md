# Onboarding & Authentication — Data Guide

> **The full analysis lives in `ONBOARDING_REBUILD_PLAN.md` (repo root, 526 lines).**
> Read that file for the complete defect list with line numbers. This page is the
> condensed, action-oriented summary so you do not have to re-read the whole plan.

---

## 1. The verdict

The onboarding screens are not a design-system problem — they are a **flow-and-data
problem wearing a design-system problem**. The existing analysis found:

- 11 fields collected, **4 persisted**.
- A **Back button that cannot go back** (the router redirect bounces the user forward).
- **Two buttons labelled "Skip" that do not skip.**
- A **"100% completed" badge shown before the user has completed anything.**
- A **mock authentication repository wired into the release build.**

Rebuilding the pixels alone would ship a prettier version of a broken flow.

---

## 2. The flow today

```
/splash → Welcome (1 of 4) → Auth (2 of 4) → Telemetry (3 of 4) → Fitness (4 of 4) → /dashboard
```

The **redirect is the gate** (`app_router.dart:61-107`): an authenticated user with an
incomplete profile is forced to `/onboarding/telemetry` from anywhere. That is why the
Back button is a dead end and why "SKIP SETUP" had to lie.

| Screen | File | Lines | Limit 400 |
|---|---|---|---|
| Welcome | `screens/welcome_screen.dart` | 336 | ok |
| Auth | `screens/auth_screen.dart` | 560 | over |
| Telemetry | `screens/telemetry_setup_screen.dart` | 1103 | ⚠️ 2.7× |
| Fitness | `screens/fitness_profile_setup_screen.dart` | 508 | over |

**Glass usage across all four: zero.** 0 `GlassSurface`, 0 `FtText`, 0
`AmbientMeshBackground`, 62 hand-rolled `fontSize:` values, 31 hand-rolled
`BorderRadius.circular`, and a hand-rolled `RadialGradient` "ambient glow" on Welcome.
The rest of the app has 1000+ token references.

---

## 3. P0 defects to fix before any visual work

| # | Defect | Where |
|---|---|---|
| 1 | **Back button cannot go back** — `context.pop()` is never true (the flow uses `context.go`), and the `context.go('/welcome')` fallback hits the redirect and bounces straight back to Telemetry | `telemetry_setup_screen.dart:132-151, 665-681`; redirect `app_router.dart:95-100` |
| 2 | "SKIP SETUP" only skips the Welcome screen | `welcome_screen.dart:197-208` |
| 3 | "Skip" on the Fitness screen calls `_complete()` — it saves everything | `fitness_profile_setup_screen.dart:121-131` |
| 4 | **Unit system, biological sex, activity level and available equipment are collected and silently dropped** | `user_profile_provider.dart:190-202` (`saveTelemetry`), `:205-231` (`saveFitnessProfile`) |
| 5 | `getBodyTelemetry` / `getFitnessProfile` fabricate values (hardcoded `metric`/`male`, `hypertrophy`/`advanced`/`fullGym`) and are **never called from `lib/`** | `sqlite_user_repository.dart:62-117` |
| 6 | **`MockAuthRepository` is the production auth provider** — hardcoded user id `'123'`, reset code `'123456'`, email in plaintext SharedPreferences | `repository_providers.dart:31-34`; `data/repositories/mock/mock_auth_repository.dart:22-56` |
| 7 | **No per-user partitioning** — the provider reads and writes row `'1'`; a second user inherits the first user's body data | `user_profile_provider.dart:18, 24` |
| 8 | **Cold start flashes onboarding** — while the profile is still loading, `isComplete` is false and the redirect fires | `app_router.dart:91` |
| 9 | No-op handlers: "Why we ask" `telemetry:170`, "Help" `auth:148`, "Explore first without account" `auth:417`, both social sign-in buttons `auth:534` | — |
| 10 | Raw exceptions reach the UI: `'Failed to save profile: $e'` | `telemetry_setup_screen.dart:105`; `fitness_profile_setup_screen.dart:53` |
| 11 | **Fabricated personal data is written to the DB** — the name `'Dineth'` is persisted on first onboarding; the account screen seeds edit fields with `77 123 4567`, `14 Oct 2003`, `742 Evergreen Terrace, Colombo` and persists them on Save | `user_profile_provider.dart:25,194,223`; `account_details_screen.dart:83-86` |
| 12 | `age` and `dob` coexist and are never reconciled; `dob` is written by the account screen while `age` is left stale | `user_profile.dart`; `account_details_screen.dart:138-144` |
| 13 | **Schema divergence** — `_onCreate` creates `age`/`weightKg`/… as `NOT NULL`; the `oldVersion < 5` upgrade creates the same columns **nullable** | `database_helper.dart:492-510` vs `:48-60` |
| 14 | There is **no way back into onboarding** — the redirect forbids it and no Settings row offers it. Unit system and equipment are unchangeable after onboarding | `app_router.dart:102-104` |
| 15 | `DATA_MODEL.md` is substantially wrong (5 documented tables do not exist) | `DATA_MODEL.md` |

> **Note on #13:** the schema is now at **v15** (the v15 migration added the rich exercise
> seed). The next migration is **v16** — use that for the onboarding data foundation.

---

## 4. Target flow

**Stop counting Welcome and Auth as onboarding steps.** Welcome is pre-auth marketing;
Auth is an account gate. Numbering them "1 of 4" is what creates the "SKIP SETUP" lie and
the duplicated progress indicators.

```
/splash (hold until the profile resolves)
  → Welcome          (not a numbered step)
  → Auth             (gate, not a numbered step)
  → Step 1 of 2 — About you      (unit · date of birth · sex · height · weight)
  → Step 2 of 2 — Your training  (activity · goal · days/week · experience · equipment)
  → Health Connect import (optional, Android only)
  → /dashboard
```

Both profile steps get a **real Skip** that writes a minimal valid profile and lands on
the dashboard, leaving a "Complete your profile" prompt in the app. Body data is
sensitive; letting a user defer it is the honest behaviour.

A **"re-run onboarding" Settings row** makes the flow recoverable and makes the
"you can edit anytime" claim true.

---

## 5. Additions to build

| # | Addition | Where |
|---|---|---|
| A1 | `OnboardingHeader` shared widget (back button + **one** progress indicator) | `presentation/widgets/onboarding_header.dart` |
| A2 | `OnboardingStepFooter` shared widget | `presentation/widgets/onboarding_step_footer.dart` |
| A3 | Real `GlassSurface` cards (`glass1`, `FtGlassTheme.radiusCards`) + a `glassFloating`/`GlassBackdrop.live` sticky footer | both profile screens |
| A4 | `FtMeshBackground` substrate with a transparent `Scaffold` | both profile screens |
| A5 | `FtText.*` + `FtGlassTheme.radius*` everywhere (62 hand-rolled sizes → 0) | all four screens |
| A6 | A real **"Why we ask"** bottom sheet per field | `modal_backdrop_helper.dart` + the shared glass modal |
| A7 | **Persist the four dropped fields** | v16 migration + `UserProfile` |
| A8 | Make the unit toggle authoritative (bind it to `WorkoutSettingsState.weightUnit` / `bodyUnit` so it agrees with the Units & Equipment screen) | `workout_settings_provider.dart` |
| A9 | Derive `age` from `dob` — removes the redundant `NOT NULL` column | entity + migration |
| A10 | Replace `MockAuthRepository` with a real local implementation (salted hash, platform secure storage, per-user rows) | `data/repositories/` |
| A11 | Hold the redirect until the profile resolves | `app_router.dart` |
| A12 | A real Skip on both steps | both profile screens |
| A13 | A "Complete your profile" prompt for users who skipped | dashboard |
| A14 | A "re-run onboarding" Settings row | `settings_sections_list.dart` |
| A15 | Health Connect import step (Android only, optional) | new screen, platform-gated |
| A16 | Inline validation with readable errors + a typed-failure path | screens + data layer |
| A17 | A summary/review before finishing | end of step 2 |
| A18 | Tests that assert the **round trip** (one assertion would have caught all four dropped fields) | `test/` |

---

## 6. Removals

Delete the no-op handlers, the fake "SKIP SETUP" / "Skip" labels, the duplicated "STEP N OF
4" pills, the fabricated completion badges (`75% completed`, `100% completed`), the
jargon badges (`FITTRACK CORE`, `TELEMETRY ENGINE`, `REALTIME CALC`, `ESTIMATED BMI`,
`BASAL BURN (BMR)`, `Hydration Baseline:`, `FITNESS & ACTIVITY PROFILE`), the fabricated
status (`Avg: 175`, `High Volume ↑`, `Balanced ✓`, `Low Volume ↓`), the off-brand colours
(`Colors.indigo`, `Colors.amber`, `Colors.blueAccent`, `Color(0xFFF59E0B)`, `Colors.red`),
the hand-rolled `RadialGradient` glow, the dead `BodyTelemetry` / `FitnessProfile`
construction, the dead repository methods, the `'Dineth'` fallbacks, the fabricated
phone/dob/address defaults, the redundant `age` column, and the stale `'120 cm'`/`'220 cm'`
labels that stay metric when Imperial is selected.

---

## 7. Target file structure

```
lib/presentation/screens/onboarding/
  welcome_screen.dart            (state-free; hero + 3 feature cards)
  about_you_screen.dart         (step 1 — state + validation + navigation)
  training_setup_screen.dart     (step 2 — state + validation + navigation)
  widgets/
    onboarding_header.dart       (shared: back button + step indicator)
    onboarding_step_footer.dart  (shared: back/continue + progress)
    welcome_hero.dart
    welcome_feature_card.dart
    about_you_card.dart
    body_metrics_summary.dart
    activity_selector.dart
    goal_selector.dart
    weekly_days_card.dart
    experience_selector.dart
    equipment_selector.dart
    why_we_ask_sheet.dart
```

Every file under 400 lines. Each screen:
`Scaffold(transparent) → FtMeshBackground → Center → ConstrainedBox(maxWidth: 393) →
CustomScrollView → SliverSafeArea → SliverPadding → SliverList`, 16–20 dp gaps —
matching `presentation/screens/exercise_details/` and `create_schedule_screen.dart`.

**`FtDynamicHeader` must NOT be used here.** It owns the notification bell + avatar
cluster; onboarding has neither, and AGENTS.md §8 explicitly exempts bell-less screens.
Use a dedicated `OnboardingHeader` that reuses the token contract (the pattern already
exists at `create_schedule/widgets/create_schedule_header.dart:29-46`:
`FtPressable` → `GlassSurface(tier: glass2, radius: 18, 40×40, shadow: false)`).

---

## 8. Sequencing (one branch per slice, AGENTS.md §13)

| Slice | Scope |
|---|---|
| 1 | **Data foundation** — v16 migration adding `dob`, `sex`, `activityLevel`, `equipment`, `unitSystem`; derive `age` from `dob`; fix the `NOT NULL`/nullable divergence; drop the dead telemetry/fitness repository methods; make `UserProfile` validate |
| 2 | **Real auth** — replace `MockAuthRepository`; per-user profile rows; hold the router redirect until the profile resolves |
| 3 | **Shared onboarding chrome** — `OnboardingHeader`, `OnboardingStepFooter`, glass surfaces, `FtText` migration, `disableAnimationsOf` |
| 4 | **Rebuild step 1** (About you) |
| 5 | **Rebuild step 2** (Your training) |
| 6 | **Honest flow** — real skip paths, "why we ask" sheet, re-run entry point, "complete your profile" prompt |
| 7 | **Health Connect** import step (Android, optional) |
| 8 | **Tests** — real-router redirect test, round-trip repository test, widget tests per state, migration test |
| 9 | **`DATA_MODEL.md` rewrite** to match the real schema |

---

## 9. Open questions — ask the user

1. **Should body metrics be a time series?** A `body_metrics` table with a date column
   enables weight/BMI history and changes slices 1 and 4.
2. **How long can unit system live in SharedPreferences?** It is not per-user and does not
   survive an account switch.
3. **Is a guest mode wanted?** If not, the dead "Explore first without account" button
   should simply go.
4. **Is "Sign in with Apple" in scope?** It is iOS-only per AGENTS.md §2 but is currently
   shown unconditionally on Android.
5. **Renumber the flow at all?** The proposal is 2 numbered steps. If Welcome and Auth
   stay numbered, the "of N" count must at least be consistent — one indicator, one
   language, on all screens.
6. **Which `AmbientMeshBackground` vs `FtMeshBackground`?** AGENTS.md §8 names the former;
   every finalized screen uses the latter. Pick one and use it everywhere.
