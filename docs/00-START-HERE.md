# FitTrack — Agent Reference Guides

**Read this file first.** It tells you which guide to open for a task so you don't scan
`lib/` broadly.

These guides exist to save tokens: each one already contains the file paths, line
references, data model, provider names and gotchas that would otherwise cost a full
codebase scan to rediscover.

---

## 1. Guide index

| Guide | Read it when | Contents |
|---|---|---|
| **[01-DESIGN-SYSTEM.md](01-DESIGN-SYSTEM.md)** | building or restyling **any UI** | The reference screen's anatomy, glass tiers & `GlassBackdrop` policy, colour/typography tokens, the full shared-widget catalogue with constructor signatures, motion patterns, copy rules, accessibility checklist |
| **[02-ARCHITECTURE.md](02-ARCHITECTURE.md)** | adding **any** code | Layer rules, folder map, feature-folder convention, Riverpod rules, the "add a screen" recipe, testing conventions, git & content rules, where the durable docs live |
| **[03-DATA-GUIDE.md](03-DATA-GUIDE.md)** | reading or writing **data** | The real SQLite schema (all 13 tables), repository layer, provider→repository map, the exercise seed system (how to add a seeded exercise), aggregate SQL, `DATA_MODEL.md` accuracy gaps, migration rules |
| **[04-SETTINGS-SUBSCREENS.md](04-SETTINGS-SUBSCREENS.md)** | redesigning the **7 settings screens** | Per screen: route, file, provider, entity, storage, every fabricated claim with line numbers, the shared settings components, the redesign checklist |
| **[05-ONBOARDING-AUTH.md](05-ONBOARDING-AUTH.md)** | rebuilding the **onboarding / auth flow** | The condensed plan: 15 P0 defects, the target flow, 18 additions, target file structure, sequencing, open questions |
| **[06-HEALTH-PAGE.md](06-HEALTH-PAGE.md)** | building the **new Health tab** | How to add the 5th tab (router + dock), what health data exists vs what is fake, the build order, open questions |
| **[07-LESSONS-LEARNED.md](07-LESSONS-LEARNED.md)** | **always, before debugging** | Every trap that already cost a debugging cycle: Riverpod retry semantics, `Expanded`+`Flexible` space splitting, widget-test font pitfalls, glass & header rules, performance rules, and the speed-up playbook |

### The durable docs (outside `docs/`)

| Document | Authority |
|---|---|
| `AGENTS.md` (repo root) | the constitution — blocking rules |
| `MODULAR_HEADER_AND_NOTIFICATIONS_GUIDE.md` | header / bell / avatar spec |
| `Antigravity_Instructions_Notifications.md` | the notification system |
| `ONBOARDING_REBUILD_PLAN.md` | the full onboarding analysis (526 lines) — `05` condenses it |
| `DATA_MODEL.md` | ⚠️ **out of date** — see `03-DATA-GUIDE.md` §6 |

---

## 2. The three workstreams queued

### A. Redesign the 7 Settings sub-screens

`security_app_lock_screen.dart` (1040) · `password_security_screen.dart` (1010) ·
`data_management_screen.dart` (972) · `units_equipment_screen.dart` (811) ·
`workout_preferences_screen.dart` (517) · `help_center_screen.dart` (39, **empty**) ·
`about_screen.dart` (39, **empty**).

→ **`docs/04-SETTINGS-SUBSCREENS.md`**

All seven are hand-rolled: **0** `GlassSurface`, **0** `FtText`, **0**
`AmbientMeshBackground`, 127 inline `fontFamily:` strings, 60+ raw `Color(0x…)` literals,
and **no test coverage**. Five are over the 400-line limit. Two render nothing at all.

**The pattern to copy:** `lib/presentation/screens/exercise_details/` — see
`docs/01-DESIGN-SYSTEM.md` §1.

**The thing to be careful about:** these screens make a lot of *unbacked claims* —
"Cloud Synced", "Hardware Secured", app-lock enforcement, a 30-second cooldown, a
recovery email, "842 Workouts", "Health Connect, Google Fit". Several are outright false
(there is no cloud, no Health Connect, no Google Fit, no app-lock enforcement, and the
audit log is mock data). Per AGENTS.md §10 these must be **implemented or removed**, not
re-styled.

**Suggested order:** start with **Help Center** and **About** (39 lines each, currently
empty — cheap wins that establish the pattern), then **Workout Preferences** (517, the
smallest real one), then the rest.

### B. Rebuild onboarding & authentication

→ **`docs/05-ONBOARDING-AUTH.md`** and the full `ONBOARDING_REBUILD_PLAN.md`

The flow is a data problem first: 11 fields collected, 4 persisted, a Back button that
cannot go back, two "Skip" buttons that don't skip, a mock auth repository in the release
build, and no per-user partitioning. Land the **v16 data migration** and the **real auth
repository** before touching pixels.

### C. New Health page (5th bottom-nav tab)

→ **`docs/06-HEALTH-PAGE.md`**

Design and functions are not planned yet, so this guide is the **data inventory**:
what exists (session calories, in-memory hydration, habits, a single body-metrics row,
sample-only movement/strain/recovery rings), what is fabricated (sleep, steps, heart rate,
TDEE, calorie intake — none of it exists), and the build order. It also has the exact
router + dock edits to add the tab.

---

## 3. The house style in one screen

```
Scaffold(backgroundColor: Colors.transparent)
 └ Stack
    ├ Positioned.fill(FtMeshBackground())                       ← theme + accent aware
    ├ Center > ConstrainedBox(maxWidth: 393) > CustomScrollView
    │    └ SliverSafeArea > SliverPadding(16,16,bottom) > SliverList
    │         ├ <Flow header>            FtDynamicHeader, back button, no avatar
    │         ├ <Glass hero card>        GlassSurface(tier: glass1, radius: 26)
    │         ├ <Section>                GlassSurface + DetailsSectionHeader
    │         └ …
    └ Positioned(bottom: 0) > <floating dock>  GlassSurface(tier: glassFloating,
                                                        backdrop: GlassBackdrop.live)
```

Rules that are easy to get wrong:

1. **`Expanded` + `Flexible` in one `Row` split the space 50/50** — never make a small
   chip a flex child (lessons §2.1).
2. **Check `hasError` before `when()`** — a retrying provider reports loading *and* an
   error (lessons §1.2).
3. **Never hand-roll `Container` + `BackdropFilter`** — use `GlassSurface` + `backdrop:`
   (lessons §4).
4. **Never hardcode hex / `Colors.*` / font sizes** — use `context.ft*`, `FtText.*`,
   `FtGlassTheme.*` (lessons §4).
5. **Files stay under 400 lines** — decompose into `<feature>/widgets/`.
6. **No fabricated status and no fake UI** — a control is implemented, disabled, or gone.
7. **`flutter test` needs `PROGRAMFILES` set** on this machine (lessons §3.5).

---

## 4. Speed-ups

1. Read only the guide for the task at hand, then only the feature folder it names.
2. `Select-String -Path "lib\**\*.dart" -Pattern "GlassSurface"` beats opening files.
3. Check `docs/01-DESIGN-SYSTEM.md` §4 before creating a widget — most needs are covered.
4. Ask one `explore` subagent a precise question instead of reading 20 files yourself.
5. Check `docs/07-LESSONS-LEARNED.md` before debugging — most "weird" layout or blank
   error states in this app are already listed there.
6. `flutter analyze` is fast (5–40 s); the full `flutter test` is ~50 s. Analyze often
   catches the compile error you were about to chase.
