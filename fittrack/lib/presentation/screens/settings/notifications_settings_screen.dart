import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_settings_provider.dart';

/// Notifications & Alerts Settings Screen for FitTrack.
///
/// Implemented to strictly match the Stitch design specifications across
/// Light, Slate Dark, and Pure OLED Dark modes:
/// - Standalone System Notifications card
/// - Live Activities section with persistent dark-slate Android preview drawer
/// - Standard notifications with modern pill-style hydration dropdown selector
/// - Haptic feedback section with indented hierarchy and disabled state guards
/// - Audio notifications section with indented hierarchy and disabled state guards
class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  /// Private card decoration helper strictly conforming to design system guardrails:
  /// - Light mode: pure surface color with subtle ambient drop shadow, no border.
  /// - Dark/OLED mode: pure surface color with crisp outline border, no shadow.
  BoxDecoration _buildCardDecoration(BuildContext context, {double radius = 16}) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colorScheme = Theme.of(context).colorScheme;

    if (isLight) {
      return BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      );
    } else {
      return BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(notificationSettingsNotifierProvider);
    final notifier = ref.read(notificationSettingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: 24,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Notifications & Alerts',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
          children: [
            // ── Section 1: Enable System Notifications (Standalone Card) ────────
            _buildStandaloneSystemCard(
              context: context,
              theme: theme,
              colorScheme: colorScheme,
              state: state,
              notifier: notifier,
            ),
            const SizedBox(height: 24),

            // ── Section 2: Live Activities ────────────────────────────────────
            _buildSectionHeader(
              context: context,
              title: 'LIVE ACTIVITIES',
              leadingIndicator: _buildLiveDot(colorScheme.primary),
            ),
            const SizedBox(height: 8),
            _buildLiveActivitiesCard(
              context: context,
              theme: theme,
              colorScheme: colorScheme,
              state: state,
              notifier: notifier,
            ),
            const SizedBox(height: 24),

            // ── Section 3: Standard Notifications ─────────────────────────────
            _buildSectionHeader(
              context: context,
              title: 'STANDARD NOTIFICATIONS',
            ),
            const SizedBox(height: 8),
            _buildStandardNotificationsCard(
              context: context,
              theme: theme,
              colorScheme: colorScheme,
              state: state,
              notifier: notifier,
            ),
            const SizedBox(height: 24),

            // ── Section 4: Haptic Feedback ────────────────────────────────────
            _buildSectionHeader(
              context: context,
              title: 'HAPTIC FEEDBACK',
              trailingBadge: _buildChipBadge(
                context: context,
                icon: Icons.vibration_rounded,
                label: 'Precision Actuator',
              ),
            ),
            const SizedBox(height: 8),
            _buildHapticsCard(
              context: context,
              theme: theme,
              colorScheme: colorScheme,
              state: state,
              notifier: notifier,
            ),
            const SizedBox(height: 24),

            // ── Section 5: Audio Notifications ────────────────────────────────
            _buildSectionHeader(
              context: context,
              title: 'AUDIO NOTIFICATIONS',
              trailingBadge: _buildChipBadge(
                context: context,
                icon: Icons.volume_up_rounded,
                label: 'System Level',
              ),
            ),
            const SizedBox(height: 8),
            _buildAudioCard(
              context: context,
              theme: theme,
              colorScheme: colorScheme,
              state: state,
              notifier: notifier,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Section Headers & Badges
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    Widget? leadingIndicator,
    Widget? trailingBadge,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (leadingIndicator != null) ...[
                leadingIndicator,
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          ?trailingBadge,
        ],
      ),
    );
  }

  Widget _buildLiveDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildChipBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Section 1: Standalone System Notifications Card
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildStandaloneSystemCard({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required NotificationSettingsState state,
    required NotificationSettingsNotifier notifier,
  }) {
    return Container(
      decoration: _buildCardDecoration(context, radius: 20),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable System Notifications',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Allow FitTrack to send notifications, workout alerts, and status updates on this device',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: state.systemNotifications,
            activeTrackColor: colorScheme.primary,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return null;
            }),
            onChanged: (val) => notifier.toggleSystemNotifications(val),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Section 2: Live Activities Card & Android Mock Drawer
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildLiveActivitiesCard({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required NotificationSettingsState state,
    required NotificationSettingsNotifier notifier,
  }) {
    return Container(
      decoration: _buildCardDecoration(context, radius: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Live Workout Status',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Show real-time set & rest progress on lock screen & notification shade',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: state.liveWorkoutStatus,
                activeTrackColor: colorScheme.primary,
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return null;
                }),
                onChanged: (val) => notifier.toggleLiveWorkoutStatus(val),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Android Live Notification Drawer Preview
          _buildAndroidDrawerPreview(context),
          const SizedBox(height: 16),

          // Sub-Toggles with Master Disable Opacity & Tap Guardrail
          IgnorePointer(
            ignoring: !state.liveWorkoutStatus,
            child: Opacity(
              opacity: state.liveWorkoutStatus ? 1.0 : 0.5,
              child: Column(
                children: [
                  _buildSubToggleTile(
                    context: context,
                    title: 'Show Schedule Progress',
                    value: state.showScheduleProgress,
                    onChanged: (val) => notifier.toggleShowScheduleProgress(val),
                  ),
                  const SizedBox(height: 8),
                  _buildSubToggleTile(
                    context: context,
                    title: 'Show Set Progress',
                    value: state.showSetProgress,
                    onChanged: (val) => notifier.toggleShowSetProgress(val),
                  ),
                  const SizedBox(height: 8),
                  _buildSubToggleTile(
                    context: context,
                    title: 'Show Rest Timer Controls',
                    value: state.showRestTimerControls,
                    onChanged: (val) => notifier.toggleShowRestTimerControls(val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Android Live Notification Mock Drawer Preview.
  ///
  /// CRITICAL GUARDRAIL: Hardcoded to dark slate `#111827` background with
  /// explicit white/white70 text and mint accents in BOTH Light and Dark modes.
  Widget _buildAndroidDrawerPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PREVIEW (NOTIFICATION DRAWER)',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 13,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // The Mockup Notification Card (Hardcoded Dark Slate Box)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drawer Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: 13,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'FitTrack',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '• Just now',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Workout Content Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incline DB Press',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Set 3 of 4',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            _LivePreviewPulsingDot(color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'RESTING',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '00:45',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                            letterSpacing: -0.5,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress Bar
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.75,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 4 Ghost Action Buttons
                Row(
                  children: [
                    _buildPreviewGhostButton('-15s'),
                    const SizedBox(width: 5),
                    _buildPreviewGhostButton('+15s'),
                    const SizedBox(width: 5),
                    _buildPreviewGhostButton('Skip'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Complete',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewGhostButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Text(
        label,
        textScaler: TextScaler.noScaling,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Section 3: Standard Notifications Card
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildStandardNotificationsCard({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required NotificationSettingsState state,
    required NotificationSettingsNotifier notifier,
  }) {
    return Container(
      decoration: _buildCardDecoration(context, radius: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // 1. Routine Workout Reminders
          _buildStandardToggleTile(
            context: context,
            title: 'Routine Workout Reminders',
            subtitle: 'Daily alert for scheduled workout routines',
            value: state.routineWorkoutReminders,
            onChanged: (val) => notifier.toggleRoutineWorkoutReminders(val),
          ),
          const SizedBox(height: 8),

          // 2. Hydration & Water Reminders with Dropdown Pill
          _buildHydrationTile(
            context: context,
            colorScheme: colorScheme,
            state: state,
            notifier: notifier,
          ),
          const SizedBox(height: 8),

          // 3. Schedule Start / Pause / Stop alerts
          _buildStandardToggleTile(
            context: context,
            title: 'Schedule Start / Pause / Stop alerts',
            subtitle: 'Foreground service status changes',
            value: state.scheduleStatusAlerts,
            onChanged: (val) => notifier.toggleScheduleStatusAlerts(val),
          ),
          const SizedBox(height: 8),

          // 4. Workout & Schedule Completion
          _buildStandardToggleTile(
            context: context,
            title: 'Workout & Schedule Completion',
            subtitle: 'Summary stats immediately after ending session',
            value: state.workoutScheduleCompletion,
            onChanged: (val) => notifier.toggleWorkoutScheduleCompletion(val),
          ),
          const SizedBox(height: 8),

          // 5. History Recorded & Saved
          _buildStandardToggleTile(
            context: context,
            title: 'History Recorded & Saved',
            subtitle: 'Confirmation toast & background sync status',
            value: state.historyRecordedSaved,
            onChanged: (val) => notifier.toggleHistoryRecordedSaved(val),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationTile({
    required BuildContext context,
    required ColorScheme colorScheme,
    required NotificationSettingsState state,
    required NotificationSettingsNotifier notifier,
  }) {
    const intervals = [
      'Every 1 hr',
      'Every 2 hrs',
      'Every 3 hrs',
      'Every 4 hrs',
    ];

    final currentInterval = intervals.contains(state.hydrationInterval)
        ? state.hydrationInterval
        : 'Every 2 hrs';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hydration & Water Reminders',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep optimal hydration balance',
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentInterval,
                      icon: Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      elevation: 4,
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: colorScheme.surface,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          notifier.setHydrationInterval(newValue);
                        }
                      },
                      items: intervals.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: state.hydrationReminders,
            activeTrackColor: colorScheme.primary,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return null;
            }),
            onChanged: (val) => notifier.toggleHydrationReminders(val),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Section 4: Haptic Feedback Card & Sub-Toggles
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildHapticsCard({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required NotificationSettingsState state,
    required NotificationSettingsNotifier notifier,
  }) {
    return Container(
      decoration: _buildCardDecoration(context, radius: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Toggle
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable System Haptics',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tactile feedback for app interactions & workout cues',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: state.hapticsEnabled,
                activeTrackColor: colorScheme.primary,
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return null;
                }),
                onChanged: (val) => notifier.toggleHapticsEnabled(val),
              ),
            ],
          ),

          // Low-opacity Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),

          // Heavily Indented Sub-Toggles with Disabled Guardrail
          IgnorePointer(
            ignoring: !state.hapticsEnabled,
            child: Opacity(
              opacity: state.hapticsEnabled ? 1.0 : 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Column(
                  children: [
                    _buildIndentedSubToggleTile(
                      context: context,
                      theme: theme,
                      colorScheme: colorScheme,
                      title: 'App Navigation (Light tap)',
                      subtitle: 'Tab bar, modal opening & card taps',
                      value: state.hapticAppNav,
                      onChanged: (val) => notifier.toggleHapticAppNav(val),
                    ),
                    const SizedBox(height: 10),
                    _buildIndentedSubToggleTile(
                      context: context,
                      theme: theme,
                      colorScheme: colorScheme,
                      title: 'Workout Status Updates',
                      subtitle: 'Distinct medium pulses for state transitions',
                      value: state.hapticWorkoutStatus,
                      onChanged: (val) => notifier.toggleHapticWorkoutStatus(val),
                    ),
                    const SizedBox(height: 10),
                    _buildIndentedSubToggleTile(
                      context: context,
                      theme: theme,
                      colorScheme: colorScheme,
                      title: 'Set Status Updates',
                      subtitle: 'Double buzz confirmation',
                      value: state.hapticSetStatus,
                      onChanged: (val) => notifier.toggleHapticSetStatus(val),
                    ),
                    const SizedBox(height: 10),
                    _buildIndentedSubToggleTile(
                      context: context,
                      theme: theme,
                      colorScheme: colorScheme,
                      title: 'Workout Completion',
                      subtitle: 'Celebratory rhythmic haptic pattern',
                      value: state.hapticWorkoutCompletion,
                      onChanged: (val) => notifier.toggleHapticWorkoutCompletion(val),
                    ),
                    const SizedBox(height: 10),
                    _buildIndentedSubToggleTile(
                      context: context,
                      theme: theme,
                      colorScheme: colorScheme,
                      title: 'Timer Countdowns',
                      subtitle: 'Pulses at 60s, 30s, 15s, 10s, and continuous last 5s',
                      value: state.hapticTimerCountdowns,
                      onChanged: (val) => notifier.toggleHapticTimerCountdowns(val),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Section 5: Audio Notifications Card & Sub-Toggles
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildAudioCard({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required NotificationSettingsState state,
    required NotificationSettingsNotifier notifier,
  }) {
    return Container(
      decoration: _buildCardDecoration(context, radius: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Toggle
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Audio Cues',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Audio chimes and sound effects through speakers or headphones',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: state.audioEnabled,
                activeTrackColor: colorScheme.primary,
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return null;
                }),
                onChanged: (val) => notifier.toggleAudioEnabled(val),
              ),
            ],
          ),

          // Low-opacity Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),

          // Heavily Indented Sub-Toggles with Disabled Guardrail
          IgnorePointer(
            ignoring: !state.audioEnabled,
            child: Opacity(
              opacity: state.audioEnabled ? 1.0 : 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Column(
                  children: [
                    _buildIndentedSubToggleTile(
                      context: context,
                      theme: theme,
                      colorScheme: colorScheme,
                      title: 'Schedule Status Update',
                      subtitle: 'Session lifecycle chime alerts',
                      value: state.audioScheduleStatus,
                      onChanged: (val) => notifier.toggleAudioScheduleStatus(val),
                    ),
                    const SizedBox(height: 10),
                    _buildIndentedSubToggleTile(
                      context: context,
                      theme: theme,
                      colorScheme: colorScheme,
                      title: 'Workout Start / Finish',
                      subtitle: 'Whistle or prompt chime',
                      value: state.audioWorkoutStartFinish,
                      onChanged: (val) => notifier.toggleAudioWorkoutStartFinish(val),
                    ),
                    const SizedBox(height: 10),
                    _buildIndentedSubToggleTile(
                      context: context,
                      theme: theme,
                      colorScheme: colorScheme,
                      title: 'Set Completion',
                      subtitle: 'Single beep on set completion',
                      value: state.audioSetCompletion,
                      onChanged: (val) => notifier.toggleAudioSetCompletion(val),
                    ),
                    const SizedBox(height: 10),
                    _buildIndentedSubToggleTile(
                      context: context,
                      theme: theme,
                      colorScheme: colorScheme,
                      title: 'Timer Countdown Status',
                      subtitle: 'Countdown finish buzzer and rest start chime',
                      value: state.audioTimerCountdown,
                      onChanged: (val) => notifier.toggleAudioTimerCountdown(val),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Shared List Tile Builders
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildStandardToggleTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            activeTrackColor: colorScheme.primary,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return null;
            }),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSubToggleTile({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeTrackColor: colorScheme.primary,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return null;
            }),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildIndentedSubToggleTile({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: 'Plus Jakarta Sans',
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          activeTrackColor: colorScheme.primary,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return null;
          }),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Animated pulsing dot indicator for the live notification preview drawer.
class _LivePreviewPulsingDot extends StatefulWidget {
  final Color color;
  const _LivePreviewPulsingDot({required this.color});

  @override
  State<_LivePreviewPulsingDot> createState() => _LivePreviewPulsingDotState();
}

class _LivePreviewPulsingDotState extends State<_LivePreviewPulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.8),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
