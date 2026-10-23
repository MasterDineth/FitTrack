# Design System Cookbook

The visual layer. Everything needed to build a screen that matches the house style.
**Read `docs/07-LESSONS-LEARNED.md` §4–§6 alongside this** (glass policy, header rules,
performance rules).

---

## 1. The reference implementation

`lib/presentation/screens/exercise_details/` is the current house style — copy its
structure, not its pixels.

| Lines | File | Public class |
|---|---|---|
| 230 | `exercise_details_screen.dart` | `ExerciseDetailsScreen` |
| 96 | `widgets/exercise_details_header.dart` | `ExerciseDetailsHeader` |
| 104 | `widgets/exercise_details_dock.dart` | `ExerciseDetailsDock` |
| 158 | `widgets/exercise_hero_card.dart` | `ExerciseHeroCard` |
| 241 | `widgets/exercise_media_hero.dart` | `ExerciseMediaHero` |
| 168 | `widgets/exercise_spec_strip.dart` | `ExerciseSpecStrip` |
| 161 | `widgets/exercise_video_row.dart` | `ExerciseVideoRow` |
| 189 | `widgets/execution_steps_section.dart` | `ExecutionStepsSection` |
| 142 | `widgets/form_cues_section.dart` | `FormCuesSection` |
| 354 | `widgets/muscles_worked_section.dart` | `MusclesWorkedSection` |
| 196 | `widgets/details_section_header.dart` | `DetailsSectionHeader`, `DetailsPill` |
| 136 | `widgets/concentric_activation_chart.dart` | `ConcentricActivationChart`, `ActivationBand` |
| 113 | `widgets/activation_ring.dart` | `AnimatedActivationRing` |

### 1.1 Screen skeleton (copy this)

```dart
Scaffold(
  backgroundColor: Colors.transparent,          // never an opaque colour
  body: Stack(
    children: [
      // 1. Mesh background — theme & accent aware
      const Positioned.fill(child: FtMeshBackground()),

      // 2. Scrollable content, phone-width clamped
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 393),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverSafeArea(
                top: true,
                bottom: false,                  // the dock owns the bottom inset
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

      // 3. Floating bottom dock
      Positioned(left: 0, right: 0, bottom: 0, child: <dock>),
    ],
  ),
)
```

- The **header lives inside the sliver list**, not in an `AppBar`.
- `bottomPadding` must clear the floating dock (reference uses `94 + safeArea`).
- Back navigation is guarded: try `context.canPop()`/`pop()`, fall back to
  `context.go('/<safe route>`, finally `Navigator.of(context).pop()`.

### 1.2 State branching order

**error → loading → data.** A failed provider can still report `isLoading` while it
retries, so `hasError` must be checked first (lessons §1.2).

```dart
if (async.hasError) return [errorCard];          // friendly message + retry action
final data = async.value;
if (data == null) return [loadingCard];
return [...sections, onlyForNonEmptyCollections];
```

### 1.3 Section header pattern

`DetailsSectionHeader` is the standard section header. Use it rather than hand-rolling
one:

```dart
DetailsSectionHeader(
  icon: Icons.monitor_heart_rounded,
  title: 'Muscles Worked',
  subtitle: 'Targeted activation breakdown',
  countLabel: '3 groups',
)
```

**The count chip must NOT be a flex child** — see lessons §2.1. The shared widget
already handles this; if you copy the pattern, copy it exactly:

```dart
Row(children: [
  iconTile,                       // 36x36, circular, primary @ 10-22%
  const SizedBox(width: 12),
  Expanded(child: Column(title, subtitle)),   // maxLines 1 + ellipsis each
  const SizedBox(width: 8),
  ConstrainedBox(                 // NOT Flexible — see lessons §2.1
    constraints: const BoxConstraints(maxWidth: 120),
    child: chip,
  ),
])
```

---

## 2. Glass surfaces

### 2.1 `GlassSurface` — the primary primitive

`lib/presentation/widgets/glass_surface.dart:13`

```dart
const GlassSurface({
  super.key,
  FtGlassTier tier = FtGlassTier.glass1,
  double? radius,                       // default FtGlassTheme.radiusCards (20)
  EdgeInsetsGeometry? padding,
  Widget? child,
  Color? borderTint,
  bool shadow = true,
  double? width,
  double? height,
  AlignmentGeometry? alignment,
  VoidCallback? onTap,
  bool enableBlur = true,
  GlassBackdrop backdrop = GlassBackdrop.auto,
  double? customBlurSigma,
});
```

It reads `themeNotifierProvider` for `enableGlassTransparency` + `blurIntensity` and
scales both the blur sigma and the fill alpha accordingly — so **any `GlassSurface`
automatically obeys the Appearance screen**.

### 2.2 `GlassBackdrop` — pick deliberately

`lib/presentation/widgets/glass/glass_backdrop.dart`

| Value | Behaviour | Use for |
|---|---|---|
| `auto` (default) | `glassFloating` → live; `glass1`/`glass2` → flat | in-flow cards over the static mesh |
| `live` | real `BackdropFilter` | **anything over scrolling / non-uniform content**: floating docks, the dynamic island, notification shade, modals, pinned bars, images |
| `flat` | fill + border + top highlight + shadow, no filter | in-flow cards |

Never hardcode `enableBlur: false` to opt out — use `backdrop:`.

### 2.3 Tier specs

`FtGlassTier` = `glass1` | `glass2` | `glassFloating`.

| Tier | Fill | Border | Blur σ | Shadow |
|---|---|---|---|---|
| `glass1` | white 60% | white 85% | 16 | `0x145F3BDC` blur 32 @(0,8) |
| `glass2` | white 50% | white 70% | 10 | none |
| `glassFloating` | white 78% | white 90% | 24 | `0x1F7C5CFA` blur 36 @(0,16) |

Dark variants (`glass1Dark`, `glass2Dark`, `glassFloatingDark`) and OLED variants
(`…Oled`) plus solid fallbacks (`solid1Light` … `solid2Oled`) exist; `specFor()` picks the
right one from `Theme.of(context).brightness` + `scaffoldBackgroundColor` and the
transparency toggle.

### 2.4 Radii

`FtGlassTheme.radiusHero` 26 · `radiusStackCards` 22 · `radiusCards` 20 (default) ·
`radiusTiles` 12 · `radiusIconTiles` 12 · `radiusPill` 999.

### 2.5 Legacy tier system — avoid

`lib/presentation/theme/glass_tokens.dart` (`GlassTier.surface/elevated/floating`) and
`FrostedGlassBox` are the **older** system. `FtGlassTheme`/`FtGlassTier`/`GlassSurface`
is current (224 vs 28 usages). `FrostedGlassBox` ignores the Appearance transparency and
blur sliders. `dashboard_screen.dart` and `bottom_nav_shell.dart` still use the legacy
one — don't copy them.

`glass_tokens.dart` also holds the **current** `MeshPalette`/`MeshGlow` mesh system used
by `AmbientMeshBackground`.

---

## 3. Colour & typography tokens

### 3.1 Colours

`FtGlassTheme` static constants (`lib/presentation/theme/ft_glass.dart:33-48`):

`primary #5F3BDC` · `primaryPressed #491AC6` · `light #9B7BFF` · `ink #1D1735` ·
`muted #6B6785` · `teal #14B8A6` · `peach #FEB78B` · `orange #F97316` · `rose #F43F5E` ·
`outlineVariant #CAC4D7` · `canvas #F6F4FF` · `amberText #92400E` · `amberFill #FEF3C7` ·
`amberBorder #FCD34D`.

**Context getters** (`FtThemeContext` extension, `ft_glass.dart:413-438`) — always use
these instead of raw constants:

| Getter | Returns |
|---|---|
| `context.isDark` | `Theme.of(this).brightness == Brightness.dark` |
| `context.isOled` | dark **and** scaffold is pure black |
| `context.ftPrimary` | `colorScheme.primary` (follows the accent) |
| `context.ftPrimaryLight` | primary, HSL lightness +0.20 |
| `context.ftInk` | dark → white, else `ink` |
| `context.ftMuted` | dark → `#94A3B8`, else `muted` |
| `context.ftSubtext` | dark → `#CBD5E1`, else `muted` |
| `context.ftCanvas` | dark → scaffold bg, else `canvas` |
| `context.glassSpec(tier)` | the resolved `FtGlassSpec` |

### 3.2 Typography — `FtText`

`fontFamily = 'Plus Jakarta Sans'` (already in every `TextTheme` entry — **do not repeat
`fontFamily:` inline**).

| Constant | Size | Weight | Tracking | Colour |
|---|---|---|---|---|
| `h1` | 26 | w800 | −0.65 | ink |
| `sectionTitle` | 20 | w700 | — | ink |
| `cardTitle` | 12 | w700 | — | ink |
| `body12` | 12 | w500 | — | ink |
| `body10` | 10 | w500 | — | ink |
| `sub14Muted` | 14 | w500 | — | muted |
| `sub10Muted` | 10 | w500 | — | muted |
| `micro11` / `micro10` / `micro9` | 11 / 10 / 9 | w700 | — | ink |
| `uppercase11` / `uppercase10` / `uppercase9` | 11 / 10 / 9 | w700 | +0.55 / +0.50 / +0.45 | muted |
| `FtText.number(size, {color})` | dynamic | w800 | — | ink |
| `FtText.unit(size, {color})` | dynamic | w700 | — | muted |

`FtText` styles have **no `height`** except `h1`. When you need line-height, set it
locally on a copy.

---

## 4. Shared widget catalogue

### 4.1 `lib/presentation/widgets/` (root)

| Widget | Constructor |
|---|---|
| `GlassSurface` | `({key, tier=glass1, radius, padding, child, borderTint, shadow=true, width, height, alignment, onTap, enableBlur=true, backdrop=auto, customBlurSigma})` |
| `FtPrimaryButton` | `({key, required String label, required VoidCallback? onPressed, bool isLoading=false, Widget? trailingIcon, double width=double.infinity, double height=54, Color? backgroundColor, Color? textColor})` |
| `FtTextField` | `({key, required TextEditingController controller, required String label, String placeholder='', Widget? prefixIcon, bool obscureText=false, TextInputType? keyboardType, Widget? suffixIcon, bool enabled=true, String? errorText, String? helperText, TextInputAction? textInputAction, ValueChanged<String>? onSubmitted})` |
| `FtSelectionCard` | `({key, required String label, required bool isSelected, required VoidCallback onTap, String? subtitle, Widget? leadingIcon, List<String> trailingChips=const []})` |
| `FtStepIndicator` | `({key, required int totalSteps, required int currentStep})` |
| `FtLogoEmblem` | `({key, double size=64})` |
| `FtExitConfirmation` | `({key, required Widget child})` + `static Future<bool> show(BuildContext)` |
| `AnimatedGlassDock` | `({key, required int currentIndex, required ValueChanged<int> onTap})` |
| `BottomNavShell` | `({key, required StatefulNavigationShell navigationShell})` |
| `MainScaffold` | `({key, required StatefulNavigationShell navigationShell})` |
| `BranchTransitionContainer` | `({key, required int currentIndex, required List<Widget> children})` |
| `FtMeshBackground` | `({key})` — the background |
| `AmbientMeshBackground` | `({key, Widget? child})` — legacy substrate |
| `AddExerciseBottomSheet` | `({key, required void Function(List<ScheduleExerciseEntry>) onExercisesAdded, VoidCallback? onCreateNew, int currentExercisesCount=0, Set<String> existingExerciseIds=const {}})` |
| `GlobalNotificationShadeHost` | `({key, required Widget child})` |
| `ActiveRestTimerView` | `({key})` |

Top-level functions: `showEraseDataConfirmationModal(...)`, `showDataManagementInfoModal(...)`
(`data_modals.dart`); `showPasswordConfirmationModal(...)`, `showPasswordSuccessModal(...)`,
`showPasswordFailedModal(...)` (`security_modals.dart`).

### 4.2 `lib/presentation/widgets/glass/`

| Widget | Constructor |
|---|---|
| `GlassPillChip` | `({key, String label='', Widget? labelWidget, Color? dotColor, Color? textColor, Color? borderColor, Color? fillColor, double height=24, double fontSize=11, FontWeight fontWeight=w700, double letterSpacing=0.4, EdgeInsetsGeometry? padding, Widget? leading, Widget? trailing, VoidCallback? onTap})` |
| `GlassIconButton` | `({key, required Widget icon, VoidCallback? onTap, bool showBadge=false, Color? badgeColor, double size=44, String? tooltip, Color? iconColor})` |
| `GlassHairlineDivider` | `({key, Color? color, double thickness=1, bool isVertical=false, EdgeInsetsGeometry? margin})` |
| `FrostedGlassBox` | legacy tier system — **avoid** |

### 4.3 `lib/presentation/widgets/header/`

| Widget | Constructor |
|---|---|
| `FtDynamicHeader` | `({key, required Widget leftChild, Widget? trailing, double height=54, EdgeInsetsGeometry padding=EdgeInsets.only(top: 12)})` |
| `FtHeaderActions` | `({key, bool showBell=true, bool showAvatar=true, List<Widget> extraActions=const []})` |
| `FtHeaderAvatar` | `({key})` — 36×36, pushes `/settings/profile` |
| `FtNotificationBell` | `({key})` — 40×40, opens the shade |

`FtHeaderTokens`: `topPadding 12` · `horizontalMargin 20` · `bellVisualSize 40` ·
`avatarVisualSize 36` · `clusterGap 8` · `minTouchTarget 48` · `badgeSize 8` ·
`badgeRingWidth 1.8`.

### 4.4 `lib/presentation/widgets/modals/`

| API | Signature |
|---|---|
| `showBlurBottomSheet<T>` | `({required BuildContext context, required Widget child, bool barrierDismissible=true, Duration duration=300ms})` |
| `showBlurModal<T>` | `({required BuildContext context, required Widget child, bool barrierDismissible=true, Duration duration=280ms})` |
| `SelectionModal` | `({key, required String title, String? subtitle, required List<String> options, required String selectedOption})` |
| `TextInputModal` | `({key, required String title, required String initialValue, String? subtitle, TextInputType keyboardType=text, String? suffixText, String? hintText})` |
| `DobPickerModal` | `({key, required DateTime initialDate, int minYear=1920, required int maxYear})` |
| `DiscardChangesDialog` | `({key, title, message, confirmLabel, cancelLabel, icon})` |
| `AddMusclePickerSheet` | `({key, int currentCount=0, Set<String> existingMuscles=const {}})` |
| `AddFormCueDialog` | `({key})` |
| `showDefaultRestTimerModal` | `(BuildContext)` |
| `showDiscardWorkoutModal` | `(BuildContext, {required ActiveWorkoutState state, required VoidCallback onDiscard})` |
| `showEndWorkoutEarlyModal` | `(BuildContext, {state, notifier, onFinishAndSave, onDiscard})` |
| `showLeaveWithoutSavingModal` | `(BuildContext) → Future<bool>` |
| `showResumeWorkoutRecoveryModal` | `(BuildContext, {snapshot, onResume, onDiscard})` |
| `showSaveSessionModal` | `(BuildContext, {state, onSave})` |
| `showSkipExerciseModal` | `(BuildContext, {state, notifier})` |
| `showWorkoutPausedModal` | `(BuildContext, {state, notifier, onEndWorkout})` |

### 4.5 Screen-local shared components (not in `presentation/widgets/`)

| Widget | Location |
|---|---|
| `FtPressable` | `lib/presentation/screens/dashboard/widgets/ft_pressable.dart` — `({key, required Widget child, VoidCallback? onTap, VoidCallback? onLongPress, double pressedScale=0.95, HitTestBehavior behavior=opaque, bool enableHaptics=true})` |
| `FtSettingsCard` | `lib/presentation/screens/settings/widgets/ft_settings_card.dart` |
| `SettingsGroupCard` | `lib/presentation/screens/settings/widgets/settings_group_card.dart` |
| `SettingsTileRow` | `lib/presentation/screens/settings/widgets/settings_tile_row.dart` |
| `DetailsSectionHeader`, `DetailsPill` | `lib/presentation/screens/exercise_details/widgets/details_section_header.dart` |

---

## 5. Motion

| Element | Pattern |
|---|---|
| Ring / arc reveal | `TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: target), duration: 900–1100ms, curve: Curves.easeOutCubic)` |
| Staggered concentric chart | one driver 0→1; each band starts at `i * 0.14` of the timeline |
| Press feedback | `FtPressable(pressedScale: 0.95–0.98)` — 100 ms down / 160 ms up |
| Header dynamic island | `FtDynamicHeader` — 460 ms `easeOutCubic` morph, 700 ms bell swing, 2000 ms auto-collapse |
| Dock / modal entrance | `showBlurModal` / `showBlurBottomSheet` scale-or-slide 280–300 ms |
| Route transition | `CustomTransitionPage` — 380 ms in / 280 ms out, fade + 6% slide |

**Every animation must honour `MediaQuery.disableAnimationsOf(context)`** (duration →
`Duration.zero`) and pause when `TickerMode.valuesOf(context).enabled` is false.

---

## 6. Iconography

Material Symbols/Icons only. The Stitch designs use Material Symbols; Flutter's
`Icons.*` is the equivalent set. Common mappings:

`arrow_back_rounded` · `fitness_center_rounded` · `layers_rounded` · `format_list_numbered_rounded` ·
`verified_rounded` · `monitor_heart_rounded` · `play_arrow_rounded` / `play_circle_filled` ·
`smart_display_rounded` · `person_rounded` · `lock_rounded` · `cancel_rounded` ·
`check_circle_rounded` · `hourglass_empty_rounded` · `error_outline_rounded` ·
`chevron_right_rounded` · `add_circle_outline_rounded` · `edit_rounded` ·
`settings_rounded` · `grid_view_rounded` · `schedule_rounded` · `favorite_rounded`.

---

## 7. Copy rules (AGENTS.md §8)

- Sentence case. Plain language. **No internal jargon** in visible text — "telemetry",
  "vault", "kinetic", "biomechanical telemetry" are all banned.
- Button labels are verbs: "Back to workout", "Add to workout", "Try again", "Continue".
- No fabricated status ("Synced", "Optimal", "Pro", a hard-coded score).
- No raw exceptions in user-facing text — use a friendly message and a typed failure at
  the data boundary.
- Counts read as "3 steps" / "3 cues" / "3 groups" (singular forms: "1 step").

---

## 8. Accessibility checklist

- [ ] Text contrast ≥ 4.5:1 (use `ftInk` / `ftMuted`, not raw greys).
- [ ] Tap targets ≥ 48×48 dp — icon buttons are visually 30–44 but need padding.
- [ ] `Semantics(button: true, label: '…')` on every icon-only control.
- [ ] No fixed heights on text containers (survives `TextScaler.linear(1.4)`).
- [ ] `maxLines: 1` + `TextOverflow.ellipsis` on single-line labels.
- [ ] `MediaQuery.disableAnimationsOf` honoured in animations.
- [ ] `FittedBox(fit: BoxFit.scaleDown)` for numeric values that must never wrap.
