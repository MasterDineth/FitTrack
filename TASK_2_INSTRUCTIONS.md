# FitTrack — TASK 2: Centralized Notification State & Global Shade Host

> **STATUS:** Specification & Implementation Guide (Updated with Owner Constraints)  
> **PREREQUISITES:** Read `AGENTS.md` completely. Follow Clean Architecture and Riverpod 3 `@riverpod` / `Notifier` conventions.

---

## 1. Objective & Scope

Establish a single, app-wide notification state architecture in `presentation/providers/notifications_provider.dart` and provide a global host for the **Notification Shade**, while strictly preserving:
1. **Dynamic Island In-Header Choreography:** The signature in-place 40×40 bell morph, oscillating bell swing animation (`_bellSwingController`), depleting 3.2s progress line (`_progressController`), and brand logo / avatar fade-scale in `DashboardHeader` must remain fully intact.
2. **Cascade Dismiss Haptics:** The staggered per-card haptic feedback (`HapticFeedback.selectionClick()` on every card) and `HapticFeedback.mediumImpact()` on close during "Dismiss All" must be preserved.
3. **Visible Test Controls:** Keep `_NotificationTestStrip` visible at the top of the Dashboard. Do **not** hide it behind long-press gestures on titles or logos (which fail on HyperOS / MIUI gesture interceptors).
4. **App-Wide Island State (`notificationIslandProvider`):** The active notification item and auto-collapse timer are managed at the app level so the Dynamic Island state is available to the Dashboard now, and across all header-equipped screens in Task 4.
5. **Zero Visual Regressions:** Maintain all existing frosted glass tiers (`FtGlassTier.glassFloating`, `FtGlassTier.glass2`), box shadows, border tints, and backdrop blur.

---

## 2. State Architecture (`notifications_provider.dart`)

Create `presentation/providers/notifications_provider.dart` (keep-alive, strictly decoupled):

### 2.1 Domain & State Models
```dart
enum FtNotificationType {
  hydration,
  pr,
  strain,
  habit,
}

class FtNotificationItem {
  final String id;
  final FtNotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;

  const FtNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
  });
}

class NotificationShadeState {
  final bool isOpen;
  final Offset? origin; // Global center of the bell icon that triggered open

  const NotificationShadeState({
    this.isOpen = false,
    this.origin,
  });

  NotificationShadeState copyWith({
    bool? isOpen,
    Offset? origin,
    bool clearOrigin = false,
  }) {
    return NotificationShadeState(
      isOpen: isOpen ?? this.isOpen,
      origin: clearOrigin ? null : (origin ?? this.origin),
    );
  }
}
```

### 2.2 Providers Specification

| Provider | Type | Responsibilities |
| :--- | :--- | :--- |
| `notificationFeedProvider` | `Notifier<List<FtNotificationItem>>` | Holds all active notification items. Methods: `push(...)`, `dismiss(id)`, `clearAll()`, `resetDemo()`. |
| `notificationIslandProvider` | `Notifier<FtNotificationItem?>` | Holds the active notification item for the in-header Dynamic Island morph. Drives the 3.2s auto-collapse countdown (`Timer`). Cancel timer in `ref.onDispose`. Cleared on user dismissal or shade open. |
| `notificationShadeProvider` | `Notifier<NotificationShadeState>` | Manages global shade visibility and origin. Methods: `open({Offset? origin})`, `close()`, `toggle({Offset? origin})`. |
| `unreadNotificationCountProvider` | `Provider<int>` | Returns `ref.watch(notificationFeedProvider).length`. |
| `hydrationProgressProvider` | `Notifier<double>` | Holds `loggedWaterLiters` (defaults to 1.8L), cleanly separating hydration telemetry from notifications. |

### 2.3 Provider Behavioral Rules
1. **Pushing While Shade is Open:** When a notification is pushed while `notificationShadeProvider.isOpen` is true, add the item to `notificationFeedProvider` but do **not** close the shade, and do **not** trigger the island timer.
2. **Notification Suppression:** When router location is in an active workout or flow (`/workouts/active/*`, `/workout/execute/*`, `/splash`, `/welcome`, `/auth`), update feed and badge count, but suppress island expansion.
3. **Haptics Setting Gate:** In new notification actions, gate haptic feedback through `notificationSettingsProvider.hapticsEnabled`.

---

## 3. Global Notification Shade Mount & Back-Button Handling

Mount the `NotificationShadeOverlay` so it can be invoked from any screen's bell, while correctly prioritizing Android back gestures:

1. **Host Placement:**
   * Place the global shade overlay at the root navigation level (e.g., in `BottomNavShell` or `MaterialApp.router.builder`).
   * Wrap with `Material(type: MaterialType.transparency)` to ensure correct accessibility and gesture dispatching without breaking router semantics.
2. **Android Back-Button Handling:**
   * Implement `WidgetsBindingObserver` with `didPopRoute()`.
   * If `notificationShadeProvider.isOpen` is true, close the shade and return `true` (intercepting the back button).
   * Otherwise, return `false` to preserve the "Press back again to exit" double-tap flow in `BottomNavShell`.
3. **Retain Staggered Dismiss-All Haptics:**
   * In `NotificationShadeOverlay`, when `_handleClearAllAnimated()` executes:
     * Preserve `HapticFeedback.selectionClick()` on every individual card removal (staggered by ~65ms).
     * Trigger `HapticFeedback.mediumImpact()` when the state is cleared and the shade collapses.

---

## 4. Preservation of Dashboard Components

1. **DashboardHeader:**
   * Retain `_bellSwingController` and `_progressController`.
   * Retain the 40×40 circle $\leftrightarrow$ full-width pill `AnimatedPositioned` morphing logic.
   * Retain the fading and scaling of the Brand Mark ("FitTrack") and User Avatar during expansion.
   * Update `DashboardHeader` to read from `notificationIslandProvider` and `notificationShadeProvider`.
2. **DashboardScreen Test Strip:**
   * Keep `_NotificationTestStrip` mounted as the first item in the Dashboard scroll view.
   * Do **not** replace it with a long-press gesture on the title/logo.

---

## 5. Verification Checklist

- [ ] `dart run build_runner build --delete-conflicting-outputs` completes cleanly.
- [ ] `flutter analyze` reports **0 issues and 0 warnings**.
- [ ] Tapping any test chip ('Hydrate', 'PR', 'Strain') expands the Dynamic Island in `DashboardHeader` with full animations.
- [ ] Tapping the bell opens the frosted `NotificationShadeOverlay`.
- [ ] Pressing the Android back button when the shade is open closes the shade without popping the screen.
- [ ] Tapping "Dismiss all" plays the staggered card slide animation with per-card haptic clicks and final impact.
- [ ] All existing widget and unit tests pass (`flutter test`).
