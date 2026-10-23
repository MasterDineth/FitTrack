# Lessons Learned — Pitfalls, Gotchas & Speed-Ups

Everything here was learned the hard way in this repo. Each entry is a trap that already
cost a debugging cycle. Read this file before writing any UI.

---

## 1. Riverpod 3 (3.4.3) — the two traps that silently break error states

### 1.1 `retry: null` does NOT disable retry

```dart
// WRONG — this means "use the default retry", which retries up to 10 times
// with exponential backoff for any Exception.
FutureProvider.autoDispose.family<X, String>((ref, id) async { ... }, retry: null);

// RIGHT — return null from the retry callback to actually stop.
FutureProvider.autoDispose.family<X, String>(
  (ref, id) async { ... },
  retry: (retryCount, error) => null,
);
```

`ProviderContainer.defaultRetry` retries any `Exception`; only `Error` and
`ProviderException` are exempt. Resolution order is
`origin.retry ?? container.retry ?? ProviderContainer.defaultRetry`.

Every codegen'd provider in this repo has `retry: null` in its `.g.dart`, i.e. they all
use the **default** auto-retry. Hand-written providers must choose deliberately.

### 1.2 `AsyncValue.when()` never reaches its `error:` branch while retrying

While a provider is retrying, its state is:

```
AsyncLoading<ExerciseDetails>(error: Exercise "ex" was not found, retrying: true)
```

i.e. `isLoading == true` **and** `hasError == true`. `when()` checks `isLoading` first, so
it returns the **loading** branch and the error branch is unreachable.

**Always branch on `hasError` before `hasValue`/`when()`:**

```dart
if (detailsAsync.hasError) { /* error UI */ }
final details = detailsAsync.value;
if (details == null) { /* loading UI */ }
```

### 1.3 `AsyncValue.valueOrNull` does not exist in this version

Use `.value` (nullable) or `.valueOrNull` only on Riverpod 2. In 3.4.3 use `.value`.

### 1.4 Provider family arguments must be value-equal

Never pass `DateTime.now()`, a random value, or a non-const object as a family argument —
every `build` would create a new provider instance and refetch in a loop. Normalise keys
(e.g. `DateTime(year, month)`) or hold the selection in a `Notifier`.

---

## 2. Flutter layout traps

### 2.1 `Expanded` + `Flexible` in the same `Row` split the free space 50/50

This is the single most common bug in this app. A trailing chip declared `Flexible`
(flex 1) next to a title declared `Expanded` (flex 1):

- the title column is forced into only half the remaining width → the title and subtitle
  ellipsise;
- `Flexible` uses a **loose** fit, so the chip sizes to its own content but aligns to the
  **start** of its half-slot → it floats inward instead of hugging the row's end.

**Rule: a small fixed-content chip/badge must NOT be a flex child.** Declare it as a plain
child (optionally wrapped in `ConstrainedBox(maxWidth: …)`) so it takes only its intrinsic
width, and let the `Expanded` sibling take the remainder.

```dart
// WRONG
Row(children: [icon, Expanded(titleColumn), const SizedBox(width: 8), Flexible(chip)])

// RIGHT
Row(children: [
  icon,
  const SizedBox(width: 12),
  Expanded(titleColumn),
  const SizedBox(width: 8),
  ConstrainedBox(constraints: const BoxConstraints(maxWidth: 120), child: chip),
])
```

### 2.2 `Container` has no `width`/`height` getters

`Container(width: 36, height: 36)` stores them as `constraints`, not as fields. In widget
predicates use `widget.constraints?.minWidth == 36`, not `widget.width == 36`.

### 2.3 `Container(width: double.infinity)` is fine; `SizedBox.expand()` in loose constraints is not

`Container(width: double.infinity)` is clamped by the parent's max width, so it works.
`SizedBox.expand()` inside loose constraints requests infinite size and throws. Use a
`SizedBox(width: double.infinity, height: h)` wrapper when you need a full-width band.

### 2.4 `Row`/`Column` `crossAxisAlignment: stretch` needs bounded height

`CrossAxisAlignment.stretch` in a `Row` (or `Column`) requires a bounded cross-axis
constraint. Inside a scroll view the cross axis is unbounded → error. Wrap in
`IntrinsicHeight` when the children need equal heights (used by
`exercise_spec_strip.dart`).

### 2.5 A `Column` with `crossAxisAlignment: start` does not stretch its child

A child `Row` that contains an `Expanded` will still take the full max width (a flex child
forces a bounded width), but a child without a flex child will shrink-wrap. Know which
case you are in before measuring.

---

## 3. Widget-test pitfalls

### 3.1 The test font is a block font, not Plus Jakarta Sans

`flutter test` renders text with a fallback block font that is roughly **1.6× wider** than
Plus Jakarta Sans. Any assertion about text fitting (`RenderParagraph.didExceedMaxLines`,
"is the title truncated") will fail in tests even when the real device layout is perfect.

**Prefer geometric assertions** (child rect vs. parent content edge) over text-fit
assertions for layout regressions.

```dart
// GOOD — font independent
final chip = tester.getRect(chipContainer);
final card = tester.getRect(cardFinder);
expect((card.right - 16 - chip.right).abs(), lessThan(0.5));

// BAD — font dependent, fails in tests for the wrong reason
expect(renderParagraph.didExceedMaxLines, isFalse);
```

### 3.2 Anchor a content-edge measurement to a real content box

`Icons.*` widgets are 20–24 dp and are **centred** inside their tile `Container`. Using the
`Icon`'s rect as the anchor puts the measurement off by half the tile's padding. Anchor to
the tile `Container` instead (36×36 here), or derive the inset from a box that really is
flush with the content edge.

### 3.3 `pumpAndSettle` cannot advance a real FFI database

`sqflite_common_ffi` runs in a background isolate on real time; `pumpAndSettle` only
advances the **fake** clock, so a DB-backed widget test will hang until the 10-minute
timeout. Use `tester.runAsync(...)` around real I/O, or inject a fake repository.

### 3.4 `find.ancestor(of: X)` searches **up**; the card is usually **down**

A screen widget returns its card, so the card is a **descendant** of the screen widget, not
an ancestor. Use `find.descendant(of: screenFinder, matching: find.byType(GlassSurface))`.

`find.descendant` results can be ambiguous ("1 step" appears in both the section header
and the media hero) — scope with `find.descendant(of: …)` rather than a bare `find.text`.

### 3.5 `flutter test` needs `PROGRAMFILES` on this machine

The machine-level `ProgramFiles` / `ProgramFiles(x86)` env vars are empty, so `flutter test`
dies with `%PROGRAMFILES(X86)% environment variable not found.` (`flutter analyze` is
unaffected). Set them per shell before any test run:

```powershell
$env:PROGRAMFILES = "C:\Program Files"; ${env:PROGRAMFILES(X86)} = "C:\Program Files (x86)"
```

### 3.6 Widget-test processes hang after the body finishes

A widget test that calls `RenderRepaintBoundary.toImage()` writes its PNG but the test
process can fail to exit. The artefact is still written — check the file, don't re-run.

---

## 4. Glass design system rules (AGENTS.md §8)

- **Never hand-roll `Container` + `BackdropFilter`.** Use `GlassSurface` and select the
  behaviour with the `backdrop` parameter:
  - `GlassBackdrop.auto` (default) → `glassFloating` is **live**, `glass1`/`glass2` are **flat**.
  - `GlassBackdrop.live` → a real `BackdropFilter` (use for anything over scrolling or
    non-uniform content).
  - `GlassBackdrop.flat` → fill + border + highlight + shadow, no filter.
  - Do **not** hardcode `enableBlur: false` at call sites to opt out.
- `GlassSurface` automatically respects the Appearance screen's transparency toggle and
  blur-intensity slider. Anything hand-built does not.
- Never hardcode raw hex, `Colors.*`, font sizes or radii in a widget — use
  `context.ftPrimary` / `ftInk` / `ftMuted` / `ftCanvas`, `FtText.*`, `FtGlassTheme.radius*`.
- `context.isDark` and `context.isOled` for mode-specific colours.
- `FtText.fontFamily` is already set in `ThemeData` — do not repeat `fontFamily:` inline.

## 5. Header rules (MODULAR_HEADER_AND_NOTIFICATIONS_GUIDE.md)

- **Category A** (has a notification bell) → wrap in `FtDynamicHeader`.
  **Category B** (no bell) → never use `FtDynamicHeader`.
- Pattern 2 (sub-flow screen with a back button): `FtPressable` → `GlassSurface(tier:
  glass2, radius: 18–20, 40×40, shadow: false)` → `Icon(Icons.arrow_back_rounded)`, then a
  12 dp gap, then an `Expanded` title column, then `trailing: const FtHeaderAvatar()`.
- Bell↔avatar spacing is **exactly** `FtHeaderTokens.clusterGap` (8.0) and is owned by
  `FtDynamicHeader` — do not add your own gap.
- Header titles: `maxLines: 1` + `TextOverflow.ellipsis`, always.
- Passing `trailing: null` makes the bell anchor to the far right (the `AppearanceHeader`
  pattern) — use that for flow screens where an avatar is unwanted.

## 6. Performance rules (AGENTS.md §9)

- No synchronous file I/O (`existsSync`, `readAsBytesSync`) inside `build`.
- Every `Image.file` / `FileImage` needs `cacheWidth` sized to display width × DPR.
- Keep 1-second timers scoped to the widget that displays them, never the whole screen.
- Dispose every `AnimationController`; pause infinite animations when `TickerMode` is off.
- Honour `MediaQuery.disableAnimationsOf(context)` in every animation.
- No `shrinkWrap: true` lists inside scroll views — use slivers.

## 7. Data & repository rules

- `presentation → domain ← data`. Presentation must never import from `data` except in
  provider wiring files.
- New JSON annotations must not be added to domain entities; mapping lives in data-layer
  mappers.
- Schema changes bump `_databaseVersion` **and** add a new `onUpgrade` step. Never edit a
  shipped migration.
- Use `update` then `insert` for upserts, **not** `ConflictAlgorithm.replace`, when the row
  has children with `ON DELETE CASCADE` — `replace` deletes and re-inserts the row, which
  would cascade-delete the children.
- Multi-row writes belong in a transaction.
- Keep user-created rows out of any seed/migration that touches library rows: scope deletes
  by the ids you manage.

## 8. Speed-ups — how to work in this repo without burning tokens

1. **Read `docs/00-START-HERE.md` first.** It tells you which of the `docs/` guides to open
   for the task at hand. Do not scan `lib/` broadly.
2. **Read only the feature folder** you are changing plus the one or two shared components
   it uses. The `docs/` guides already list the exact file paths and line references.
3. **Grep for the widget, don't read the file.** `Select-String -Path "lib\**\*.dart" -Pattern
   "GlassSurface"` is far cheaper than opening files.
4. **Reuse before creating.** Before writing a widget, check `docs/01-DESIGN-SYSTEM.md` —
   `GlassSurface`, `GlassPillChip`, `GlassIconButton`, `GlassHairlineDivider`,
   `FrostedGlassBox`, `FtPrimaryButton`, `FtTextField`, `FtPressable`, `FtSettingsCard`,
   `SettingsGroupCard`, `SettingsTileRow` already cover most needs.
5. **Copy the reference implementation.** `lib/presentation/screens/exercise_details/` is the
   current house style: glass cards over `FtMeshBackground`, `DetailsSectionHeader` for
   section headers, `CustomScrollView` + slivers, floating `glassFloating` dock.
6. **Check `docs/07-LESSONS-LEARNED.md` before debugging.** Most "weird" layout or blank
   error states in this app are one of the traps listed above.
7. **Ask a subagent to gather data, not to decide.** A single `explore` agent with a precise
   question costs one round-trip; re-reading 20 files yourself costs many.
