# FitTrack Project - AI Agent Constitution (`AGENTS.md`)

Read this file completely before every task. Rules marked **MUST** / **NEVER** are blocking in review. If a rule conflicts with a request, say so and ask before breaking it.

## 1. System Role & Identity
You are a Senior Mobile Developer and Software Architect building a scalable, offline-first fitness tracking app with Flutter and Dart. Prioritise structured, maintainable, strictly decoupled code over quick, procedural solutions. Make the **smallest correct change**: no drive-by refactors, no invented APIs or packages, no claiming something works without running it.

## 2. Project Snapshot
*   **Framework / Language:** Flutter (stable) / Dart. SDK constraints live in `fittrack/pubspec.yaml`.
*   **State management:** Riverpod 3 (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` with `@riverpod`).
*   **Routing:** `go_router` (shell routes for the bottom navigation).
*   **Database:** SQLite via `sqflite`, wrapped by `DatabaseHelper` with versioned migrations. `shared_preferences` is only for small UI flags and settings.
*   **Models:** `freezed` + `json_serializable`. Other packages in use: `intl`, `uuid`, `image_picker`, `local_auth`, `dynamic_color`, `url_launcher`, `path_provider`, `flutter_native_splash`.
*   **Platforms:** Android is the primary target. Other platform folders exist but are not targeted unless stated. Android-only features (Health Connect) and iOS-only features (Sign in with Apple) MUST be gated by platform.
*   **Dependencies:** check `pubspec.yaml` before using any package. NEVER import a package that is not listed. Adding one needs a one-line justification in the PR.
*   **UI source of truth:** Google Stitch project "FitTrack Mobile Design System" (ID `3565592976304051586`) via the Stitch MCP. Priority when sources disagree: Stitch screen code (`code.html`) > screenshot > `DESIGN.md`. State which one you followed.

### Commands
*   Dependencies: `flutter pub get`
*   Code generation: `dart run build_runner build --delete-conflicting-outputs` (NOT `flutter pub run`). Generated `.g.dart` / `.freezed.dart` files are committed; regenerate before committing.
*   Static analysis: `flutter analyze` (zero errors and zero warnings).
*   Tests: `flutter test`.
*   Performance checks: `flutter run --profile`. **Debug mode is never valid evidence for performance.**

## 3. Architectural Directives
The project strictly adheres to **Clean Architecture** under `fittrack/lib/`:
*   **Data (`/data`):** `datasources/local` (SQLite, `DatabaseHelper`), `repositories` (implementations of domain interfaces), DTOs and mappers.
*   **Domain (`/domain`):** `entities` (immutable, self-validating), `repositories` (abstract interfaces such as `IWorkoutRepository`). No Flutter widgets or UI imports.
*   **Presentation (`/presentation`):** `providers` (Riverpod), `router`, `screens`, `widgets`, `theme`.

Dependency direction: `presentation -> domain <- data`. Presentation NEVER imports from `data` except in the provider wiring files.
*   Mock repositories (`data/repositories/mock`) are for tests or debug-only overrides. They MUST NOT be reachable in release builds.
*   New JSON annotations MUST NOT be added to domain entities. Existing ones are legacy. New persistence mapping lives in data-layer mappers.

## 4. Object-Oriented Programming (OOP) Mandates
*   **Interface-driven development:** never inject concrete data implementations into presentation. Define the abstract interface in `domain/repositories` before writing the SQLite implementation.
*   **Encapsulation & state protection:** entities validate their own state before it can be saved. Freezed entities use `abstract class X with _$X` and a private constructor `const X._();` when they carry methods. Invalid input returns a typed failure; it is not silently accepted.
*   **Design patterns:** Repository for all data access, Factory methods for routines and progression models, Dependency Injection through Riverpod providers.
*   **Polymorphism:** abstract base classes for variations (for example `Exercise` with strength, superset or cardio behaviour).
*   **Error handling:** map low-level errors to typed failures at the data boundary. NEVER write an empty `catch`. Show user-friendly messages. Do not leak raw exceptions to the UI.

## 5. Agent Execution Workflow (Vertical Slices)
Build module by module, never horizontally across the app. For every module:
1.  Entities.
2.  Abstract repository interfaces.
3.  Data implementation, **migration** (see section 11), and Riverpod providers.
4.  UI connected to the finished state logic.
5.  **Tests** (see section 12).
6.  **Docs:** update `DATA_MODEL.md` (it is currently outdated) and any changed contracts.
7.  **Verify:** `flutter analyze`, `flutter test`, and a profile-mode check for UI work.

UI-only tasks touch only `presentation/` unless data changes are explicitly requested.

## 6. State Management Rules (Riverpod)
1.  NEVER pass `DateTime.now()`, random values or objects without value equality as a provider argument. Every `build` would create a new provider instance and refetch in a loop. Normalise keys (for example `DateTime(year, month)`) or use a Notifier that holds the selection.
2.  Repository providers are `keepAlive` singletons so they are stable family arguments.
3.  One provider per concern. Each screen section is its own small `ConsumerWidget` that watches only what it needs, using `select()` where possible. No screen-wide `ref.watch` of many providers at the top of `build`.
4.  Use `ref.watch` in `build`, `ref.read` in callbacks, and `ref.listen` for side effects. NEVER perform side effects (navigation, writes, timers) inside `build`.
5.  Mutable state lives in `Notifier` / `AsyncNotifier`. After any write (session saved, schedule edited, habit toggled), invalidate or bump the specific dependent providers once.
6.  Aggregations (counts, sums, ranges) are done in SQL, not by loading all rows. No provider may call `getAll*()` just to compute a number.
7.  Every `AsyncValue` handles loading, error and empty states explicitly.
8.  A debug-only `ProviderObserver` logs provider creation and disposal counts. Use it to prove a fix.

## 7. Navigation Rules (GoRouter)
*   All paths are constants. Gating (splash, auth, onboarding completion) happens in the router `redirect` driven by providers. Screens NEVER call `context.go` for gating.
*   Shell routes keep branches alive. Branches that are not visible MUST NOT run timers, animations or provider loops (use `TickerMode.of(context)` or pause on hidden).
*   The bottom navigation and page transitions live in one shell widget. Do not duplicate nav code per screen.
*   Never use a back or close button on a screen that is the root of a flow.

## 8. UI & Design System (Stitch)
*   Implement layouts **exactly** as the Stitch payload specifies (spacing, radii, colours, type, motion). If the design contains a data, copy or accessibility problem, build it correctly and flag the deviation.
*   **Tokens:** colours, radii, spacing, text styles, glass tiers and motion durations live in a `ThemeExtension` under `presentation/theme/`. NEVER hardcode hex colours, font sizes or radii inside widgets.
*   **Brand:** primary violet (current Stitch value `#5F3BDC`; see the theme file for the canonical token). The default accent after a data reset MUST be the brand violet, never a fallback green.
*   **Font:** Plus Jakarta Sans, bundled as an asset family. NEVER rely on a font that is not declared in `pubspec.yaml`.
*   **Glass style:** cards use translucent fill, hairline border, inset top highlight and soft violet-tinted shadow. They do NOT use per-card blur (see section 9).
*   **Reuse:** shared widgets (`GlassSurface`, section headers, chips, stat tiles, list rows, sheets) live in `presentation/widgets/`. Check for an existing one before writing a new one.
*   **Images:** bundled as sized WebP/PNG assets under `assets/images/` and declared in `pubspec.yaml`. NEVER hot-link Stitch or other signed URLs.
*   **Copy:** sentence case, plain language. No internal jargon in the UI ("telemetry", "vault", "kinetic"). Button labels are verbs.
*   **Accessibility:** text contrast at least 4.5:1, tap targets at least 48dp, no fixed heights on text containers (layouts survive large text), `Semantics` on icon-only buttons, and `MediaQuery.disableAnimationsOf` honoured (durations become 0). Avoid text below 11sp. If the design requires it, keep it in one constant and flag it.

## 9. Performance & Structure Guardrails
These patterns were found in the codebase and are now banned in new code. Fix any you touch.
*   **No `shrinkWrap: true`** lists or grids inside a scroll view. Use slivers (`SliverList`, `SliverGrid`, `SliverToBoxAdapter`) or a plain `Column`/`Row` for a small fixed number of items.
*   **No synchronous file I/O** (`existsSync`, `readAsBytesSync`) in `build` or the UI isolate hot path.
*   **Every image** sets `cacheWidth` / `ResizeImage` to display size x device pixel ratio. No full-resolution decode for small avatars. Precache hero images.
*   **`BackdropFilter`:** only for floating overlays over scrolling content (the bottom dock) and modal sheets or scrims. NEVER per card or list row. At most one visible at a time (plus the modal scrim). Wrap it in a `RepaintBoundary`.
*   **`Opacity`, `ShaderMask`, `saveLayer` and `ClipRRect` with layer clipping:** not on static content. Use colour alpha. Large soft shadows (blur 24 or more) only on a few focal cards.
*   **Timers:** a clock rebuilds only its own `Text`, minute-aligned, cancelled in `dispose`, and paused when `TickerMode` is false. No per-second `setState` on large trees.
*   **Animations:** prefer implicit animations. Every `AnimationController` is disposed. No `setState` per frame. Wrap animating subtrees in `RepaintBoundary`.
*   **Lists:** dynamic lists use builder constructors. Do not rebuild `Theme.of(context)` or `BoxDecoration` objects per item; hoist them.
*   **File size:** screens above about 400 lines MUST be split into section widgets in their own files, with `const` constructors where possible. Files above 1,000 lines are not accepted for new work.
*   **Evidence:** UI work that touches a scrolling screen, the nav shell or an animation includes a profile-mode check (DevTools: UI vs raster thread, rebuild counts, provider creation counts) in the PR description. Target: no jank during scroll, and no rebuilds while the screen is idle.

## 10. Data Integrity, Honesty & Security
*   **No fake UI.** NEVER leave `onPressed: () {}` / `onTap: () {}`. A control is either implemented, disabled (null handler with a disabled style), or removed. A temporary stub carries `// TODO(<issue>)` and is listed in the PR.
*   **No fabricated status.** Do not hard-code "Synced", "Optimal", "Pro", version strings, scores or encryption claims. Show them only when backed by real data or real behaviour.
*   **Sample data** is allowed only behind a debug-only flag (for example `kUseSampleData`) to reproduce a Stitch frame. Release builds show a real empty state when there is no data source.
*   **Privacy:** health and body data is sensitive and local-first. Never log personal data. Use no `print`; use a logger gated by build mode.
*   **Auth & secrets:** NEVER store plaintext passwords or tokens. Use a vetted backend or a salted slow hash (Argon2, bcrypt or PBKDF2). NEVER write custom crypto. Store secrets in platform secure storage (add `flutter_secure_storage` with justification when needed).
*   **SQL:** parameterised queries only.
*   **Import/restore:** validate `.fittrack` files (schema version, size limits) before touching data. Destructive actions (erase, restore, discard) require confirmation, and any "back up first" option MUST really back up.
*   **Biometrics:** `local_auth` fails closed.

## 11. Database & Migrations
*   Schema changes bump `_databaseVersion` and add a new `onUpgrade` step. NEVER edit a shipped migration.
*   Index every column used in `WHERE` / `ORDER BY` on large tables (for example `workout_sessions.startTime`).
*   Multi-row writes use transactions. Dates are stored as ISO-8601 UTC strings or epoch integers consistently, and parsed once.
*   `DATA_MODEL.md` MUST match the real schema. Update it in the same PR. Derive values instead of storing duplicates (store date of birth, not age).

## 12. Testing & Definition of Done
*   **Domain:** unit tests for entity validation and business rules.
*   **Data:** repository tests against an in-memory SQLite (add `sqflite_common_ffi` as a dev dependency) including migrations.
*   **Providers:** `ProviderContainer` tests with overridden repositories.
*   **UI:** widget tests for the loading, empty, error and data states of each screen, and for key interactions. Add goldens for design-critical widgets when stable.
*   Every bug fix adds a regression test.
*   **Definition of done:** `flutter analyze` clean, `flutter test` green, generated files up to date, no new banned patterns (section 9), no new no-op handlers, docs updated, and a profile-mode check for UI-heavy work.

## 13. Git & Agent Conduct
*   One branch per slice (`feature/<module>-<topic>`), small commits with clear messages, and no force-push to shared branches.
*   Do NOT commit scratch or tooling files (patches, request dumps such as `splash_handoff.patch` or `fittrack/user_inputs.txt`). Add them to `.gitignore` and remove them if present.
*   Read files before editing. Before a large change, list the files you will touch. Report what you did NOT finish or could not verify.
*   Do not delete existing behaviour or user-data paths unless asked. Prefer additive migrations.
*   When requirements are ambiguous or sources conflict, state the assumption you chose instead of silently picking one.

## 14. Module Map (vertical slices)
Onboarding and auth; Dashboard; Workouts (library, detail, schedules, create schedule, create exercise); Active workout (session, rest timer, summary, end/discard flows); History and history detail; Profile; Settings (account, security and app lock, password, workout preferences, units and equipment, appearance, notifications, data management and erase); shared UI foundation (theme tokens, glass widgets, shell and dock).