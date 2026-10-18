# FitTrack — TASK 4: Universal In-Header Dynamic Island Morph & Animations

> **STATUS:** Specification & Implementation Guide (New Module)  
> **PREREQUISITES:** Read `AGENTS.md` completely. Tasks 2 & 3 must be completed and passing all tests.

---

## 1. Objective & Philosophy

Bring the signature **Dynamic Island Morph & Animations** to **every screen with a notification icon** (Dashboard, Workouts, History, Settings, Create Schedule, Create Exercise, Workout Search, and History Detail) without breaking any screen's unique header design, typography, back buttons, or custom layout:

1. **In-Header Choreography (No Floating Overlay):**
   * The morphing island lives directly inside each screen's header row, replacing the 40×40 circular bell button in-place.
   * On notification arrival, that screen's specific left-side content (title/subtitle or back button) and right-side avatar smoothly fade and scale down, allowing the bell to expand into the full-width frosted glass pill.
2. **Identical Motion & Animations Everywhere:**
   * Oscillating bell swing animation (`_bellSwingController`) with primary category badge.
   * Auto-collapse 3.2s depleting progress line (`_progressController`).
   * Haptic feedback on arrival (`HapticFeedback.mediumImpact()`) and collapse (`HapticFeedback.selectionClick()`).
   * Single-line rich text message (bold title + muted body) with ellipsis.
   * Tap expands the global `NotificationShadeOverlay`; swipe-up dismisses.
3. **Encapsulated & Reusable (`FtDynamicHeader`):**
   * Encapsulate the entire animation physics, layout constraints, and controllers into one clean reusable component: `presentation/widgets/header/ft_dynamic_header.dart`.
   * Individual screens remain simple: they supply their custom `leftChild` (title/back button) and optional `trailing` action (avatar), while `FtDynamicHeader` handles all island expansion choreography automatically.

---

## 2. Shared Dynamic Island Header Widget (`ft_dynamic_header.dart`)

Create `presentation/widgets/header/ft_dynamic_header.dart`:

```dart
class FtDynamicHeader extends ConsumerStatefulWidget {
  final Widget leftChild;
  final Widget? trailing;
  final double height;
  final EdgeInsetsGeometry padding;

  const FtDynamicHeader({
    super.key,
    required this.leftChild,
    this.trailing,
    this.height = 54.0,
    this.padding = const EdgeInsets.only(top: 12.0),
  });

  @override
  ConsumerState<FtDynamicHeader> createState() => _FtDynamicHeaderState();
}
```

### 2.1 State & Animation Controllers
```dart
class _FtDynamicHeaderState extends ConsumerState<FtDynamicHeader>
    with TickerProviderStateMixin {
  late final AnimationController _bellSwingController;
  late final AnimationController _progressController;
  String? _lastIslandItemId;

  @override
  void initState() {
    super.initState();
    _bellSwingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  @override
  void dispose() {
    _bellSwingController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _triggerIslandAnimations(FtNotificationItem? activeItem) {
    if (activeItem != null && activeItem.id != _lastIslandItemId) {
      _lastIslandItemId = activeItem.id;
      HapticFeedback.mediumImpact();
      _bellSwingController.repeat(reverse: true);
      _progressController.forward(from: 0.0);
    } else if (activeItem == null && _lastIslandItemId != null) {
      _lastIslandItemId = null;
      _bellSwingController.stop();
      _bellSwingController.reset();
      _progressController.stop();
      HapticFeedback.selectionClick();
    }
  }
}
```

### 2.2 Layout Stack & In-Header Morphing
Inside `build(BuildContext context)`:
1. Watch `notificationIslandProvider` (for `activeIslandItem`) and `unreadNotificationCountProvider`.
2. Wrap inside `LayoutBuilder` to compute `maxHeaderWidth = constraints.maxWidth`.
3. Construct a `Stack(alignment: Alignment.center)`:
   * **Left-Hand Layer (`leftChild`):**
     * Wrapped with `AnimatedOpacity(duration: 240ms, opacity: isExpanded ? 0.0 : 1.0)`.
     * Wrapped with `AnimatedScale(duration: 280ms, scale: isExpanded ? 0.92 : 1.0, alignment: Alignment.centerLeft)`.
     * `IgnorePointer(ignoring: isExpanded)` to prevent phantom touches while island is open.
   * **Right-Hand Layer (`trailing` / Avatar):**
     * Positioned at `right: 0.0`.
     * Wrapped with `AnimatedOpacity(duration: 220ms, opacity: isExpanded ? 0.0 : 1.0)`.
     * Wrapped with `AnimatedScale(duration: 260ms, scale: isExpanded ? 0.85 : 1.0)`.
     * `IgnorePointer(ignoring: isExpanded)`.
   * **Morphing Frosted Island Layer:**
     * `AnimatedPositioned(duration: 460ms, curve: Curves.easeOutCubic)`:
       * `right: isExpanded ? 0.0 : 44.0`
       * `width: isExpanded ? maxHeaderWidth : 40.0`
       * `height: isExpanded ? 52.0 : 40.0`
     * `GlassSurface`:
       * `tier: isExpanded ? FtGlassTier.glassFloating : FtGlassTier.glass2`
       * `radius: 20.0`
       * `borderTint: isExpanded ? context.ftPrimary.withValues(alpha: 0.25) : null`
     * `AnimatedSwitcher(duration: 220ms)`:
       * If collapsed: renders the 40×40 resting bell with `Icons.notifications_outlined` and unread dot badge.
       * If expanded: renders `_buildExpandedIslandContent()` containing the swinging bell, title, body, and depleting 2.2px progress bar.

---

## 3. Screen-by-Screen Integration Guide

Wrap each screen's header with `FtDynamicHeader`. Every screen retains its custom typography, back buttons, and layout while acquiring the dynamic island:

### 3.1 Dashboard ([dashboard_header.dart](file:///c:/Users/dinet/Documents/Projects/FitTrack/fittrack/lib/presentation/screens/dashboard/widgets/dashboard_header.dart))
```dart
return FtDynamicHeader(
  leftChild: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset('assets/images/dashboard/brand_mark.webp', width: 32, height: 32),
      ),
      const SizedBox(width: 10),
      Text('FitTrack', style: FtText.headline22),
    ],
  ),
  trailing: const FtHeaderAvatar(),
);
```

### 3.2 Workouts ([workouts_screen.dart](file:///c:/Users/dinet/Documents/Projects/FitTrack/fittrack/lib/presentation/screens/workouts_screen.dart) — `_WorkoutsHeader`)
```dart
return FtDynamicHeader(
  leftChild: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Workouts', style: TextStyle(fontFamily: FtText.fontFamily, fontSize: 24, fontWeight: FontWeight.w800, color: context.ftInk)),
      const SizedBox(height: 2),
      Text('Explore splits, routines & programs', style: TextStyle(fontFamily: FtText.fontFamily, fontSize: 12, color: context.ftMuted)),
    ],
  ),
  trailing: const FtHeaderAvatar(),
);
```

### 3.3 History ([workout_history_header.dart](file:///c:/Users/dinet/Documents/Projects/FitTrack/fittrack/lib/presentation/screens/workout_history/widgets/workout_history_header.dart))
```dart
return FtDynamicHeader(
  leftChild: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('History', style: TextStyle(fontFamily: FtText.fontFamily, fontSize: 26, fontWeight: FontWeight.w800, color: context.ftInk)),
      const SizedBox(height: 2),
      Text('Track your past sessions & milestones', style: TextStyle(fontFamily: FtText.fontFamily, fontSize: 14, color: context.ftMuted)),
    ],
  ),
  trailing: const FtHeaderAvatar(),
);
```

### 3.4 Settings ([settings_header.dart](file:///c:/Users/dinet/Documents/Projects/FitTrack/fittrack/lib/presentation/screens/settings/widgets/settings_header.dart))
```dart
return FtDynamicHeader(
  leftChild: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Settings', style: TextStyle(fontFamily: FtText.fontFamily, fontSize: 24, fontWeight: FontWeight.w800, color: context.ftInk)),
      const SizedBox(height: 3),
      Text('Manage your account, preferences & hardware', style: TextStyle(fontFamily: FtText.fontFamily, fontSize: 12, color: context.ftMuted)),
    ],
  ),
  trailing: const FtHeaderAvatar(),
);
```

### 3.5 Flow Screens with Back Buttons
For `CreateScheduleHeader`, `CreateExerciseHeader`, `WorkoutSearchScreen`, and `WorkoutDetailHeader`:
```dart
return FtDynamicHeader(
  leftChild: Row(
    children: [
      FtBackButton(onTap: onBackTap),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: FtText.title20),
            if (subtitle != null) Text(subtitle, style: FtText.caption11),
          ],
        ),
      ),
    ],
  ),
  trailing: const FtHeaderAvatar(),
);
```

### 3.6 Screens Without Bells (Unchanged)
The following screens do not carry notification bells and are **never wrapped** with `FtDynamicHeader`:
* `ActiveWorkoutHeader` (Active workout: timer and pause controls only).
* `WorkoutDetails` (Library preview: back button and more menu).
* Appearance and Settings sub-screens (simple back button + title).

---

## 4. Performance, Motion & Accessibility Guardrails

1. **Reduced Motion:** If `MediaQuery.disableAnimationsOf(context)` is true, jump instantly to expanded/collapsed state (zero duration, no rotation on bell).
2. **Ticker Lifecycle:** `TickerMode.of(context)` pauses controllers when the screen is hidden in background tabs. Both controllers must be cleanly disposed in `dispose()`.
3. **Accessibility:**
   * Full tap target $\ge 48\times 48$ dp in collapsed state.
   * Full header width tappable in expanded state (opens the notification shade).
   * `Semantics(liveRegion: true)` announces incoming notifications via screen readers.

---

## 5. Verification Checklist

- [ ] Triggering any notification preset ('Hydrate', 'PR', 'Strain') smoothly expands the Dynamic Island in:
  - [ ] Dashboard
  - [ ] Workouts
  - [ ] History
  - [ ] Settings
  - [ ] Create Schedule / Exercise / Workout Search
- [ ] During expansion, each screen's custom title/back button and avatar smoothly fade out.
- [ ] The bell swings, the message displays cleanly, and the progress line smoothly depletes over 3.2s.
- [ ] On completion, the island smoothly collapses back into the 40×40 bell icon, and the screen's title and avatar restore.
- [ ] Tapping the expanded island opens the global Notification Shade.
- [ ] `flutter analyze` reports **0 errors and 0 warnings**.
- [ ] All 127+ unit and widget tests pass (`flutter test`).
