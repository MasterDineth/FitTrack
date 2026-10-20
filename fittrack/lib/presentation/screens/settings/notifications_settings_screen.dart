import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/services/notification_service.dart';
import '../../providers/notification_permission_provider.dart';
import '../../providers/notification_service_provider.dart';
import '../../providers/notification_settings_provider.dart';
import '../../widgets/ambient_mesh_background.dart';
import 'notifications/widgets/device_notifications_section.dart';
import 'notifications/widgets/dynamic_island_preview_card.dart';
import 'notifications/widgets/live_notification_preview_card.dart';
import 'notifications/widgets/notifications_header.dart';
import 'notifications/widgets/notifications_status_card.dart';
import 'notifications/widgets/quiet_hours_and_sound_section.dart';

/// Redesigned FitTrack Notifications & Alerts Screen.
///
/// Built strictly following the Stitch Mobile Design System and `AGENTS.md`:
/// - Flushed Category A header with back navigation and in-header dynamic island bell
/// - Top permission status pill with live simulation toggle (Allowed / Blocked)
/// - Interactive live notification preview card (Workout, Rest countdown, Done states)
/// - Android Live Notification Dynamic Island preview (Banner, Live, Rest)
/// - In-app banner stay timer control (1s, 2s, 3s)
/// - Expandable device notification sections with repeat day chips and time pickers
/// - Quiet hours range selection and haptic/audio controls
/// - Bottom test notification trigger and system settings launcher
/// - Frosted glass aesthetic connected to Appearance Screen theme settings
class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends ConsumerState<NotificationsSettingsScreen>
    with WidgetsBindingObserver {
  bool? _simulatedBlocked;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationPermissionProvider.notifier).refresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationPermissionProvider.notifier).refresh().then((_) {
        if (mounted &&
            ref.read(notificationPermissionProvider).value ==
                NotificationPermissionStatus.granted) {
          setState(() {
            _simulatedBlocked = null;
          });
        }
      });
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _handleEnablePermission() async {
    final status =
        await ref.read(notificationPermissionProvider.notifier).request();
    if (status == NotificationPermissionStatus.granted ||
        status == NotificationPermissionStatus.unknown) {
      if (mounted) {
        setState(() {
          _simulatedBlocked = false;
        });
      }
      ref
          .read(notificationSettingsNotifierProvider.notifier)
          .toggleSystemNotifications(true);
    } else {
      await ref.read(notificationServiceProvider).openSystemSettings();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 32.0;
    final permissionAsync = ref.watch(notificationPermissionProvider);
    final status =
        permissionAsync.value ?? NotificationPermissionStatus.unknown;
    final isRealBlocked = status == NotificationPermissionStatus.denied ||
        status == NotificationPermissionStatus.blocked;
    final isBlocked = _simulatedBlocked ?? isRealBlocked;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientMeshBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 393),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverSafeArea(
                  top: true,
                  bottom: false,
                  sliver: SliverPadding(
                    padding: EdgeInsets.only(
                      left: 18.0,
                      right: 18.0,
                      top: 4.0,
                      bottom: bottomInset,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        // 1. Category A Header
                        const NotificationsHeader(),
                        const SizedBox(height: 12),

                        // 2. Permission Status Pill & Simulation Segmented Switch
                        NotificationsStatusCard(
                          isBlocked: isBlocked,
                          onPermissionSimulationChanged: (blocked) {
                            setState(() {
                              _simulatedBlocked = blocked;
                            });
                            ref
                                .read(
                                  notificationSettingsNotifierProvider.notifier,
                                )
                                .toggleSystemNotifications(!blocked);
                          },
                          onEnableTap: _handleEnablePermission,
                        ),
                        const SizedBox(height: 14),

                        // 3. Main Configuration Content (Dimmed and disabled if blocked)
                        IgnorePointer(
                          ignoring: isBlocked,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            opacity: isBlocked ? 0.38 : 1.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 3.1 Live Workout Notification Preview Card
                                const LiveNotificationPreviewCard(),
                                const SizedBox(height: 14),

                                // 3.2 Android Dynamic Island Preview Card
                                const DynamicIslandPreviewCard(),
                                const SizedBox(height: 14),

                                // 3.3 Device Notifications Section
                                const DeviceNotificationsSection(),
                                const SizedBox(height: 14),

                                // 3.4 Quiet Hours and Sound / Actions Section
                                QuietHoursAndSoundSection(
                                  onScrollToTop: _scrollToTop,
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
