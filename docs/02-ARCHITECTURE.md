# Architecture & Conventions

Everything needed to place new code correctly. Companion to `AGENTS.md` (the constitution)
and `docs/01-DESIGN-SYSTEM.md` (the visual layer).

---

## 1. Layer rules (AGENTS.md §3)

```
presentation ──▶ domain ◀── data
```

- `lib/domain/` — entities, repository **interfaces**. No Flutter imports, no JSON
  annotations on new entities, no I/O.
- `lib/data/` — datasources (SQLite), repository **implementations**, mappers.
- `lib/presentation/` — screens, widgets, providers, router, theme.

**Presentation must never import from `data/`** except inside provider wiring files
(`lib/presentation/providers/`). Screens consume repository *interfaces* via providers.

Mock repositories (`lib/data/repositories/mock/`) are test/debug only and must not be
reachable in a release build.

## 2. Folder map

```
lib/
  domain/
    entities/          one file per entity (freezed + json_serializable)
    repositories/      one interface per repository (I<Entity>Repository)
  data/
    datasources/local/ database_helper.dart, seed/
    repositories/      implementations (sqlite_*, *_impl)
  presentation/
    providers/         Riverpod providers (generated + hand-written)
    router/            app_router.dart
    screens/           one folder per feature; sub-widgets in <feature>/widgets/
    theme/             ft_glass.dart (current), glass_tokens.dart (legacy)
    widgets/           shared primitives (glass/, header/, modals/, …)
  main.dart
```

## 3. Feature folder convention

A feature screen lives in `lib/presentation/screens/<feature>/`:

```
lib/presentation/screens/exercise_details/
  exercise_details_screen.dart      ← screen: state, providers, navigation
  widgets/
    <part>.dart                      ← dumb widgets: plain values + VoidCallbacks
```

Rules for the child widgets:
- They take **plain values** and `VoidCallback`s — no provider reads, no `setState`.
- No file over **400 lines** (AGENTS.md §9). If a screen grows past that, decompose into
  `widgets/` immediately.
- One shared concept per file. `exercise_details/widgets/` has 12 small files averaging
  ~150 lines each.

## 4. Riverpod conventions

| Rule | Detail |
|---|---|
| Provider location | `lib/presentation/providers/<name>_provider.dart` |
| Generated providers | use `@Riverpod` / `@riverpod` + `part '*.g.dart'`; the `.g.dart` files are committed |
| Manual providers | plain `final xProvider = FutureProvider...` — always set `retry:` deliberately (see lessons §1.1) |
| Family arguments | must be value-equal (string id, normalised date) — never `DateTime.now()` |
| Repository providers | `keepAlive: true` so they are stable family arguments |
| One provider per concern | each screen section watches only what it needs; use `.select()` |
| Reads vs watches | `ref.watch` in `build`, `ref.read` in callbacks, `ref.listen` for side effects |
| Side effects | never inside `build` |
| Writes | after any write, invalidate/bump the specific dependent providers once |
| Aggregates | compute in SQL, never load all rows to count them |
| AsyncValue | handle loading, error and empty explicitly; check `hasError` before `when()` (lessons §1.2) |

## 5. Adding a screen — the exact recipe

1. **Create** `lib/presentation/screens/<feature>/<feature>_screen.dart` (+ `widgets/`).
2. **Route** in `lib/presentation/router/app_router.dart`:
   - Root-level detail/flow screens use `parentNavigatorKey: rootNavigatorKey` and a
     `builder:`; screen transitions use `pageBuilder:` + `CustomTransitionPage`.
   - Shell-branch screens go inside `StatefulShellRoute.branches[].routes` with a
     **relative** path.
   - There are no route-name constants in this repo — routes are literal path strings.
3. **Gating** (splash / auth / onboarding) happens in the router `redirect`, driven by
   providers. Screens never call `context.go` for gating.
4. **Shell tab**: add the branch to `StatefulShellRoute` and the tab to the `_tabs` list in
   `lib/presentation/widgets/animated_glass_dock.dart`.

The canonical screen skeleton (copy from
`lib/presentation/screens/exercise_details/exercise_details_screen.dart`):

```dart
Scaffold(
  backgroundColor: Colors.transparent,
  body: Stack(
    children: [
      const Positioned.fill(child: FtMeshBackground()),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 393),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverSafeArea(
                top: true,
                bottom: false,
                sliver: SliverPadding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([...]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(left: 0, right: 0, bottom: 0, child: <floating dock>),
    ],
  ),
)
```

`bottomPadding` must clear the floating dock so the last card is never trapped under it.

## 6. Backgrounds — pick one

`FtMeshBackground` (`lib/presentation/widgets/ft_background_painter.dart`) is what the
finalized screens use (dashboard, appearance, create schedule, create exercise, exercise
details). It is a `CustomPaint` that rasterises once inside a `RepaintBoundary` and never
repaints on scroll; it derives its four radial glows from the **active accent colour**, so
it re-tints automatically with the Appearance screen.

`AmbientMeshBackground` (`lib/presentation/widgets/ambient_mesh_background.dart`) is the
older substrate. **Use `FtMeshBackground`** for new screens — that is the current house
style and it is theme-aware. (This ambiguity is flagged in `ONBOARDING_REBUILD_PLAN.md` §12
and should be resolved by making `AmbientMeshBackground` a thin wrapper or removing it.)

## 7. Testing conventions (AGENTS.md §12)

| Layer | Where | Rule |
|---|---|---|
| Domain | `test/` | unit tests for entity validation and business rules |
| Data | `test/` | repository tests against **in-memory SQLite** (`sqflite_common_ffi`) including migrations |
| Providers | `test/` | `ProviderContainer` tests with overridden repositories |
| UI | `test/` | widget tests for **loading, empty, error and data** states + key interactions |
| Regression | `test/` | every bug fix adds a test |

`sqflite_common_ffi` is a **dev_dependency** (added for this purpose). `pumpAndSettle`
cannot advance a real FFI database — see lessons §3.3.

Existing test files that encode important behaviour — read before changing the thing they
cover:

| File | Guards |
|---|---|
| `test/glass_backdrop_policy_test.dart` | glass tier ↔ BackdropFilter policy |
| `test/blur_intensity_test.dart` | blur intensity + fill alpha scaling |
| `test/header_modular_actions_test.dart` | header tokens, bell/avatar geometry, per-screen headers |
| `test/dynamic_header_test.dart` | the dynamic-island morph |
| `test/exercise_details_screen_test.dart` | the reference screen: all four states |
| `test/exercise_library_seed_test.dart` | seed content completeness, alias mirroring, migration safety |
| `test/onboarding_navigation_test.dart` | router redirect logic (**re-implements** it locally — the real router is not covered) |
| `test/telemetry_flow_test.dart` | onboarding navigation (builds its own router, no redirect) |

## 8. Git (AGENTS.md §13)

- One branch per slice: `feature/<module>-<topic>`.
- Small commits with clear messages. No force-push to shared branches.
- Do **not** commit scratch or tooling files (patches, request dumps, `user_inputs.txt`).
  Add them to `.gitignore` and remove them if present.
- Read files before editing. List the files you will touch before a large change.
- Do not delete existing behaviour or user-data paths unless asked; prefer additive migrations.
- When requirements are ambiguous or sources conflict, state the assumption instead of
  silently picking one.

## 9. Content rules (AGENTS.md §8, §10)

- Sentence case, plain language. No internal jargon in visible text ("telemetry",
  "vault", "kinetic"). Button labels are verbs.
- **No fabricated status** — never hard-code "Synced", "Optimal", "Pro", scores, version
  strings or encryption claims. Show them only when backed by real data.
- **No fake UI** — a control is implemented, disabled (null handler + disabled style), or
  removed. A temporary stub carries `// TODO(<issue>)` and is listed in the PR.
- Never log personal data. Use a logger gated by build mode; no `print`.
- Accessibility: 4.5:1 text contrast, ≥48 dp tap targets, no fixed heights on text
  containers, `Semantics` on icon-only buttons, honour `MediaQuery.disableAnimationsOf`.

## 10. Where the durable docs live

| Document | Path | Authority |
|---|---|---|
| Agent constitution | `AGENTS.md` | highest — blocking rules |
| Header & notification spec | `MODULAR_HEADER_AND_NOTIFICATIONS_GUIDE.md` | header/bell/avatar |
| Notifications implementation notes | `Antigravity_Instructions_Notifications.md` | notification system |
| Onboarding analysis & plan | `ONBOARDING_REBUILD_PLAN.md` | onboarding/auth rework |
| Schema reference | `DATA_MODEL.md` | must match the real schema |
| **This guide set** | `docs/` | working references — read `docs/00-START-HERE.md` first |
