# FitTrack — Modular Header, Dynamic Island & Notification Shade Guide

> **PURPOSE:** Authoritative specification and implementation standard for AI agents and developers when building new screens or rebuilding existing UI across FitTrack.  
> **PREREQUISITES:** Read `AGENTS.md`. All UI must strictly adhere to the Clean Architecture, Riverpod 3, and Frosted Glass design token directives.

---

## 1. System Overview & Philosophy

FitTrack utilizes a unified, modular header and notification architecture composed of three interconnected layers:

1. **Standardized Modular Action Elements (`presentation/widgets/header/`):**
   * Decoupled action components (`FtNotificationBell`, `FtHeaderAvatar`, and cluster `FtHeaderActions`) built with rigid token-driven sizing, touch targets, and frosted glass tiering.
2. **Universal In-Header Dynamic Island Morph (`FtDynamicHeader`):**
   * In-place header morphing where the 40×40 circular bell button expands into a full-width floating frosted notification pill upon notification arrival.
   * Screen-specific titles and avatars cross-fade and scale down seamlessly without disrupting navigation state, back buttons, or screen layout trees.
3. **Global Origin-Aware Notification Shade (`NotificationShadeHost`):**
   * A full-screen frosted overlay rendered at the root app level, opening with a fluid circular reveal anchored at the exact global tap origin of the bell icon.

---

## 2. Design Tokens (`FtHeaderTokens`)

All header layout dimensions, icon sizes, and touch target rules are defined in `lib/presentation/widgets/header/ft_header_tokens.dart`. **NEVER hardcode raw numbers for header dimensions.**

| Token | Value | Purpose |
| :--- | :--- | :--- |
| `FtHeaderTokens.bellVisualSize` | `40.0` dp | Exact visual width/height of the circular glass notification bell |
| `FtHeaderTokens.avatarVisualSize` | `36.0` dp | Exact visual width/height of the circular profile avatar |
| `FtHeaderTokens.clusterGap` | `8.0` dp | **MANDATORY exact spacing** between the notification bell and profile avatar |
| `FtHeaderTokens.minTouchTarget` | `48.0` dp | Minimum accessible hit-test area (`HitTestBehavior.opaque`) for buttons |
| `FtHeaderTokens.topPadding` | `12.0` dp | Standard top inset for main screen headers |
| `FtHeaderTokens.horizontalMargin` | `20.0` dp | Standard left/right screen content margin |
| `FtHeaderTokens.badgeSize` | `8.0` dp | Diameter of the unread notification dot badge |
| `FtHeaderTokens.badgeRingWidth` | `1.8` dp | Outer border ring of the unread notification badge |

---

## 3. Screen Categorization: When to Use What

Every screen in FitTrack falls into one of two categories:

### Category A: Screens WITH Notification Bells (MUST Use `FtDynamicHeader`)
Any screen featuring notifications, navigation actions, or user avatars **MUST** wrap its header row with `FtDynamicHeader`:
* **Main Tab / Dashboard Screens:** `DashboardHeader`, `_WorkoutsHeader`, `WorkoutHistoryHeader`, `SettingsHeader`.
* **Flow / Creation Screens:** `CreateScheduleHeader`, `CreateExerciseHeader`, `WorkoutSearchScreen` header, `WorkoutDetailHeader`.

### Category B: Screens WITHOUT Notification Bells (NEVER Use `FtDynamicHeader`)
The following screens do not carry notification bells and **MUST NOT** be wrapped with `FtDynamicHeader`:
* `ActiveWorkoutHeader` (Active workout: timer, stopwatch, and pause controls only).
* `WorkoutDetails` preview screen (Library preview: back button and 3-dot context menu only).
* Appearance and Settings sub-screens (Simple back button + section title).

---

## 4. Reusable Header Component: `FtDynamicHeader`

Located at `lib/presentation/widgets/header/ft_dynamic_header.dart`.

### 4.1 Component Signature
```dart
class FtDynamicHeader extends ConsumerStatefulWidget {
  /// The screen's custom title, lockup, or back-button row.
  final Widget leftChild;

  /// The trailing action element, typically `const FtHeaderAvatar()`.
  /// If null, the bell anchors to the far right.
  final Widget? trailing;

  /// Baseline height of the header row (default: 54.0).
  final double height;

  /// Outer padding applied to the header container (default: top: 12.0).
  final EdgeInsetsGeometry padding;

  const FtDynamicHeader({
    super.key,
    required this.leftChild,
    this.trailing,
    this.height = 54.0,
    this.padding = const EdgeInsets.only(top: FtHeaderTokens.topPadding),
  });
}
```

### 4.2 Behavior & Animation Specifications
* **Expansion Morph:** When `ref.watch(notificationIslandProvider)` emits an item:
  * Resting bell morphs from `40×40` to `width: maxHeaderWidth, height: 52.0` using `Curves.easeOutCubic` over **460ms**.
  * Glass tier transitions to `FtGlassTier.glassFloating` with border tint `context.ftPrimary.withValues(alpha: 0.25)`.
  * `leftChild` fades out (`opacity: 0.0` over **240ms**) and scales down (`scale: 0.92` over **280ms**).
  * `trailing` avatar fades out (`opacity: 0.0` over **220ms**) and scales down (`scale: 0.85` over **260ms**).
  * `IgnorePointer` disables interaction on hidden elements during island expansion.
* **Island Content Display:**
  * **Category Badge & Swinging Bell:** 32×32 glass container with `Icons.notifications_active_rounded`. Oscillates with a **700ms** reversing sine curve (`_bellSwingController`).
  * **Single-Line Toast:** Bold title (`FontWeight.w800`) followed by muted body text (`FontWeight.w500`), both with `maxLines: 1` and `TextOverflow.ellipsis`.
  * **Auto-Collapse Depletion Bar:** A 2.2px line at the bottom edge that smoothly depletes from right-to-left over exactly **2.0s** (`_progressController`).
* **Dismissal & Interactions:**
  * **Manual Dismiss Button:** Tapping the circular close icon (`Icons.close_rounded`) triggers `HapticFeedback.selectionClick()` and immediately collapses the island via `ref.read(notificationIslandProvider.notifier).collapse()`.
  * **Swipe-Up Dismissal:** Upward fling (`details.primaryVelocity! < -100`) on `onVerticalDragEnd` collapses the island.
  * **Open Shade:** Tapping the expanded island body captures its global coordinates and triggers `ref.read(notificationShadeProvider.notifier).open(origin: origin)`.
* **Reduced Motion:** When `MediaQuery.disableAnimationsOf(context)` is `true`:
  * Transition durations drop to `Duration.zero` (or 1ms micro-tick for switcher stability).
  * Bell oscillation rotation angle is clamped to `0.0`.
  * Controllers are not scheduled.
* **Lifecycle & State Protection:**
  * Pauses controllers when `TickerMode.valuesOf(context).enabled` is `false`.
  * Wraps provider watchers in `try-catch` to allow safe rendering in isolated widget test harnesses without a parent `ProviderScope`.

---

## 5. Implementation Templates & Code Patterns

### Pattern 1: Main Tab / Dashboard Screen Header
Used for root screens without back buttons (e.g., Dashboard, Workouts, History, Settings):

```dart
import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/header/header.dart';

class MyTabHeader extends StatelessWidget {
  const MyTabHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return FtDynamicHeader(
      padding: const EdgeInsets.only(top: FtHeaderTokens.topPadding),
      leftChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Screen Title',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: context.ftInk,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Descriptive subtitle or category caption',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.ftMuted,
            ),
          ),
        ],
      ),
      trailing: const FtHeaderAvatar(),
    );
  }
}
```

### Pattern 2: Sub-Flow Screen Header (With Back Button)
Used for flow and creation screens (e.g., Create Schedule, Create Exercise, Workout Search, History Detail):

```dart
import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../widgets/header/header.dart';
import '../../dashboard/widgets/ft_pressable.dart';

class MyFlowHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final String title;
  final String? subtitle;

  const MyFlowHeader({
    super.key,
    required this.onBackTap,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return FtDynamicHeader(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      leftChild: Row(
        children: [
          // 40x40 Frosted Back Button with >= 48x48 touch target
          FtPressable(
            onTap: onBackTap,
            pressedScale: 0.90,
            child: GlassSurface(
              tier: FtGlassTier.glass2,
              radius: 18,
              width: 40,
              height: 40,
              shadow: false,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: context.ftInk,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: context.ftInk,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: context.ftMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      trailing: const FtHeaderAvatar(),
    );
  }
}
```

---

## 6. Accessibility & Layout Guardrails

To comply with **AGENTS.md Section 8 and Section 9**:

1. **No Fixed Heights on Text Containers:**
   * Text containers MUST survive large text scales (`TextScaler.linear(1.4)`+).
   * Do not constrain header text columns with hardcoded height boxes.
   * `FtDynamicHeader` centers `leftChild` vertically without constraining its vertical height via top/bottom clamps.
2. **Mandatory Single-Line Ellipsis on Header Titles:**
   * Header titles (`Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)`) and subtitles **MUST** have `maxLines: 1` and `TextOverflow.ellipsis` to prevent `RenderFlex` overflows in narrow viewports or large-font modes.
3. **Touch Targets ($\ge 48\times 48$ dp):**
   * Even though the bell is visually 40×40 and avatar is 36×36, their tap boundaries are padded to at least $48\times 48$ dp using `FtPressable` / `SizedBox`.
4. **Spacing Between Bell & Avatar:**
   * The spacing between bell and avatar **MUST ALWAYS** be `FtHeaderTokens.clusterGap` (`8.0` dp). Never use arbitrary margins or padding between them.
5. **Screen Reader Semantics:**
   * Notification items inside the dynamic island are announced via `Semantics(liveRegion: true)`.
   * Bell icon announced as `'Notifications, X unread'`.
   * Dismiss button announced as `'Dismiss notification'`.

---

## 7. Global Notification Shade Integration

* The Notification Shade is hosted at the application root via `GlobalNotificationShadeHost` (`presentation/widgets/notification_shade_overlay.dart`).
* **Origin-Aware Reveal:** Opening the shade captures the global center of the tapped bell icon (`renderBox.localToGlobal(...)`) and passes it to `notificationShadeProvider.notifier.open(origin: origin)`.
* **Back Gesture Handling:** The shade uses `PopScope(canPop: !isOpen, onPopInvokedWithResult: ...)` to intercept Android system back gestures and back button taps, closing the shade smoothly instead of exiting the screen.
* **Auto-Collapse Synergy:** Opening the notification shade automatically collapses any active dynamic island notification.

---

## 8. AI Agent Execution Checklist for UI Builds

When creating a new screen or refactoring an existing screen, verify the following before submitting:

- [ ] **Categorization:** Identified whether the screen is Category A (needs `FtDynamicHeader`) or Category B (no bell).
- [ ] **Import:** Imported `header.dart` (`lib/presentation/widgets/header/header.dart`).
- [ ] **Header Structure:** Used `FtDynamicHeader` with custom `leftChild` and `trailing: const FtHeaderAvatar()`.
- [ ] **Text Overflow Protection:** All `Text` widgets inside header columns specify `maxLines: 1` and `overflow: TextOverflow.ellipsis`.
- [ ] **Spacing Compliance:** Exact 8.0dp spacing between bell and avatar is maintained via `FtHeaderTokens.clusterGap`.
- [ ] **Touch Target Compliance:** All buttons and icons provide $\ge 48\times 48\text{dp}$ touch target.
- [ ] **Theme Consistency:** Colors derive from `context.ftInk`, `context.ftMuted`, `context.ftPrimary`, and `FtText.fontFamily` (Plus Jakarta Sans).
- [ ] **No Ad-Hoc Glass:** Used standard `GlassSurface` or `FtDynamicHeader` (no manual `BackdropFilter` or hex codes).
- [ ] **Verification:** Ran `flutter analyze` (0 errors, 0 warnings) and `flutter test` (all tests pass).

---

## 9. Prohibited Anti-Patterns

❌ **NEVER** build ad-hoc inline `Container` + `BackdropFilter` headers in screen files.  
❌ **NEVER** hardcode different spacing between bell and avatar (e.g. `SizedBox(width: 12)` or `SizedBox(width: 4)`). Always use `FtHeaderTokens.clusterGap` (8.0dp).  
❌ **NEVER** use `shrinkWrap: true` or fixed pixel heights on header text columns.  
❌ **NEVER** add `FtDynamicHeader` to screens that belong in Category B (`ActiveWorkoutHeader`, `WorkoutDetails` preview).  
❌ **NEVER** omit `maxLines: 1` and `overflow: TextOverflow.ellipsis` on header title strings.  
❌ **NEVER** create floating top toast overlays outside `FtDynamicHeader`. All ephemeral notifications morph directly within the screen's header.
