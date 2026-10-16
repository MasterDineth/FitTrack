# FitTrack — TASK 3: Modular Header Actions (Bell & Avatar) Across All Screens

> **STATUS:** Specification & Implementation Guide (Updated with Owner Constraints)  
> **PREREQUISITES:** Read `AGENTS.md` completely. Task 2 must be complete and passing all tests.

---

## 1. Objective & Philosophy

Standardize the notification bell and profile avatar actions across the application without breaking any screen's unique header design, layout, titles, subtitles, or custom animations:
1. **Preserve Custom Screen Headers:** Screens in FitTrack have unique headers designed specifically for their context (e.g., Dashboard brand lockup, Workouts large typography and subtitle, Settings account subtitle, Create Schedule back button navigation). Do **not** replace these with a single rigid widget that wipes out their distinct layouts.
2. **Modular Right-Hand Actions:** Provide self-contained, reusable action components (`FtNotificationBell`, `FtHeaderAvatar`, and `FtHeaderActions`) that plug into each screen's existing header row.
3. **App-Wide Notification Connectivity:** Tapping the notification bell on *any* screen calculates the bell's global position and opens the global `NotificationShadeOverlay` anchored from that bell, displaying the live badge dot when unread items exist.
4. **Remove All No-Op Stubs:** Eliminate all empty `onTap: () {}` handlers and `// TODO(notifications)` comments on header buttons.
5. **Accessibility & Touch Targets:** Ensure all bell and avatar buttons have at least 48×48 dp tappable areas while preserving their exact visual 40 dp / 36 dp footprint.
6. **Foundation for Task 4:** This modular header structure prepares every screen to adopt the unified in-header Dynamic Island Morphing Engine in Task 4.

---

## 2. Reusable Header Components (`lib/presentation/widgets/header/`)

Create the following modular components under `presentation/widgets/header/`:

### 2.1 `ft_header_tokens.dart`
Contains exact sizing, padding, and layout constants:
```dart
class FtHeaderTokens {
  const FtHeaderTokens._();

  static const double topPadding = 12.0;
  static const double horizontalMargin = 20.0;
  static const double bellVisualSize = 40.0;
  static const double avatarVisualSize = 36.0;
  static const double clusterGap = 8.0;
  static const double minTouchTarget = 48.0;
  static const double badgeSize = 8.0;
  static const double badgeRingWidth = 1.8;
}
```

### 2.2 `ft_notification_bell.dart`
* **Visual Presentation:** 40×40 circular frosted glass button (`GlassSurface(tier: FtGlassTier.glass2, radius: 20)`).
* **Icon:** `Icons.notifications_outlined` (20 dp, themed to `context.ftInk`).
* **Unread Badge:** Watches `unreadNotificationCountProvider`. When count > 0, renders an 8×8 dp badge dot in `context.ftPrimary` with a 1.8 dp white border ring at top: 8, right: 8.
* **Interaction:**
  * Uses `RenderBox` to obtain global coordinates on tap.
  * Calls `ref.read(notificationShadeProvider.notifier).open(origin: globalCenter)`.
  * Triggers `HapticFeedback.lightImpact()`.
* **Accessibility:** Wraps with `Semantics(button: true, label: 'Notifications, $unreadCount unread')` and expands hit-test area to $\ge 48\times 48$ dp.

### 2.3 `ft_header_avatar.dart`
* **Visual Presentation:** 36×36 circular avatar with a 2 dp white border and subtle shadow (`BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))`).
* **Image Caching:** Watches `userProfileProvider`. Reads `profile?.profileImagePath`. If present, renders `Image.file` using `ResizeImage` with `cacheWidth = (36 * devicePixelRatio).ceil()`.
* **Fallback:** Renders `assets/images/dashboard/sample_avatar.webp` (or initials) when no custom image is selected.
* **Interaction:** Tapping triggers `HapticFeedback.lightImpact()` and navigates via `context.push('/settings/profile')`.
* **Accessibility:** `Semantics(button: true, label: 'Profile settings')` with $\ge 48\times 48$ dp hit area.

### 2.4 `ft_header_actions.dart`
Combines optional leading actions, the notification bell, and the profile avatar into a unified cluster:
```dart
class FtHeaderActions extends StatelessWidget {
  final bool showBell;
  final bool showAvatar;
  final List<Widget> extraActions;

  const FtHeaderActions({
    super.key,
    this.showBell = true,
    this.showAvatar = true,
    this.extraActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...extraActions,
        if (showBell) ...[
          const FtNotificationBell(),
          if (showAvatar) const SizedBox(width: FtHeaderTokens.clusterGap),
        ],
        if (showAvatar) const FtHeaderAvatar(),
      ],
    );
  }
}
```

---

## 3. Non-Destructive Migration Matrix

Apply the modular action components to existing screens while **preserving each screen's custom header layout, typography, and animations**:

| Screen | File | Left-Hand Content (Keep Intact) | Action on Right-Hand Cluster |
| :--- | :--- | :--- | :--- |
| **Dashboard** | `screens/dashboard/widgets/dashboard_header.dart` | Brand Mark (`brand_mark.webp`) + "FitTrack" logo lockup with in-place Dynamic Island morph | Wire the existing morphing bell button to `notificationShadeProvider.open()`. Retain all internal controllers (`_bellSwingController`, `_progressController`). Use `FtHeaderAvatar` on the far right. |
| **Workouts** | `screens/workouts_screen.dart` (`_WorkoutsHeader`) | Title "Workouts" (24sp) + Subtitle "Explore splits, routines & programs" | Replace dummy bell (`onTap: () {}`) and avatar with `FtHeaderActions()`. |
| **History** | `screens/workout_history/widgets/workout_history_header.dart` | Title "History" (26sp) + Subtitle "Track your past sessions & milestones" | Replace dummy bell (`// TODO(notifications)`) and avatar with `FtHeaderActions()`. |
| **Settings** | `screens/settings/widgets/settings_header.dart` | Title "Settings" (24sp) + Subtitle "Manage your account, preferences & hardware" | Replace the bell (which previously opened `/settings/notifications`) with `FtNotificationBell()` so it opens the shade. Replace avatar with `FtHeaderAvatar()`. |
| **Create Schedule** | `screens/create_schedule/widgets/create_schedule_header.dart` | 40 dp Back Button + Title & Subtitle | Replace dummy bell (`onTap: () {}`) and avatar with `FtHeaderActions()`. Preserve `onBackTap`. |
| **Create Exercise** | `screens/create_exercise/widgets/create_exercise_header.dart` | 40 dp Back Button + Title & Subtitle | Replace dummy bell (`onTap: () {}`) and avatar with `FtHeaderActions()`. Preserve `onBackTap`. |
| **Workout Search** | `screens/workout_search_screen.dart` | 40 dp Back Button + "Search Workouts" | Replace dummy bell (`onTap: () {}`) and avatar with `FtHeaderActions()`. |
| **History Detail** | `screens/workout_history_detail/widgets/workout_detail_header.dart` | Back button + Title | Replace dummy bell and broken route with `FtHeaderActions()`. |
| **Workout Details** | `screens/workout_detail/widgets/workout_detail_header.dart` | Back button + Schedule Title | No bell by design (`FtHeaderActions(showBell: false, extraActions: [moreMenuButton])`). |
| **Active Workout** | `screens/active_workout/widgets/active_workout_header.dart` | Immersive timer + Pause/Discard controls | **Do not touch** (no bell or avatar). |
| **Settings Sub-screens**| `screens/settings/*` | Standard back button + screen title | **Do not touch** (no bell or avatar). |

---

## 4. Verification Checklist

- [ ] All 10 migrated headers display the correct title and layout without any visual distortion.
- [ ] Tapping the notification bell on Workouts, History, Settings, and Create Schedule opens the `NotificationShadeOverlay` with origin-based scaling.
- [ ] Tapping the avatar on any screen navigates to `/settings/profile`.
- [ ] No `onTap: () {}` or no-op notification stubs remain in the migrated files.
- [ ] `DashboardHeader` retains its complete Dynamic Island morphing animation and bell swing.
- [ ] Touch targets for the bell and avatar measure at least 48×48 dp in widget tests.
- [ ] `flutter analyze` reports **0 errors and 0 warnings**.
- [ ] All widget and regression tests pass (`flutter test`).
