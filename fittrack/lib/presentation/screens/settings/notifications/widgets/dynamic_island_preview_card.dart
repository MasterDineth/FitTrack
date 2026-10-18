import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/notification_settings_provider.dart';
import '../../../../theme/ft_glass.dart';
import '../../../dashboard/widgets/ft_pressable.dart';
import '../../widgets/ft_settings_card.dart';
import 'dynamic_island_pill.dart';
import 'ft_switch_row.dart';
import 'notification_segmented_control.dart';

/// Dynamic Island preview card for Android live notifications (e.g. Xiaomi HyperOS).
///
/// Features:
/// - Replayable animation preview for Banner, Live, and Rest island pills
/// - In-app banners switch (enable/disable)
/// - "Banner stays for" segmented timer control customized to [1s, 2s, 3s]
/// - "Keep live workout pill in every screen" switch
class DynamicIslandPreviewCard extends ConsumerStatefulWidget {
  const DynamicIslandPreviewCard({super.key});

  @override
  ConsumerState<DynamicIslandPreviewCard> createState() =>
      _DynamicIslandPreviewCardState();
}

class _DynamicIslandPreviewCardState
    extends ConsumerState<DynamicIslandPreviewCard>
    with SingleTickerProviderStateMixin {
  IslandPreviewMode _islandMode = IslandPreviewMode.banner;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _replay() {
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;
    final notifState = ref.watch(notificationSettingsNotifierProvider);
    final notifier = ref.read(notificationSettingsNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Section Header & "Replay" action
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'DYNAMIC ISLAND',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.12 * 11.5,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FtPressable(
                onTap: _replay,
                pressedScale: 0.95,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 15,
                      color: primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Replay',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 2. Island Container Box
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0x0D1D1735),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              // Animated Dynamic Island Pill
              DynamicIslandPill(
                mode: _islandMode,
                scaleAnimation: _scaleAnimation,
                onTap: () {},
                onSkip: () {
                  setState(() {
                    _islandMode = IslandPreviewMode.live;
                  });
                  _replay();
                },
              ),
              const SizedBox(height: 10),

              // Segmented mode switcher
              NotificationSegmentedControl<IslandPreviewMode>(
                selected: _islandMode,
                fullWidth: true,
                options: const {
                  IslandPreviewMode.banner: 'Banner',
                  IslandPreviewMode.live: 'Live',
                  IslandPreviewMode.rest: 'Rest',
                },
                onSelected: (mode) {
                  setState(() {
                    _islandMode = mode;
                  });
                  _replay();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 3. Dynamic Island Settings Card
        FtSettingsCard(
          radius: 24,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Row 1: In-app banners toggle
              FtSettingSwitchRow(
                leading: FtLeadingIconTile(
                  icon: Icons.view_carousel_rounded,
                  color: primary,
                  backgroundColor: primary.withValues(alpha: 0.15),
                ),
                title: 'In-app banners',
                subtitle: 'Show the island while using FitTrack',
                value: notifState.inAppBanners,
                onChanged: (val) => notifier.toggleInAppBanners(val),
              ),
              const SizedBox(height: 12),
              Divider(
                color: context.ftPrimary.withValues(alpha: 0.08),
                height: 1,
              ),
              const SizedBox(height: 12),

              // Row 2: "Banner stays for" timer selector [1s, 2s, 3s]
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Banner stays for',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.ftInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  NotificationSegmentedControl<int>(
                    selected: notifState.bannerDurationSeconds,
                    options: const {
                      1: '1s',
                      2: '2s',
                      3: '3s',
                    },
                    onSelected: (sec) => notifier.setBannerDurationSeconds(sec),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                color: context.ftPrimary.withValues(alpha: 0.08),
                height: 1,
              ),
              const SizedBox(height: 12),

              // Row 3: Keep live workout pill in every screen
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Keep live workout pill in every screen',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.ftInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FtStitchSwitch(
                    value: notifState.keepLiveWorkoutPill,
                    onChanged: (val) => notifier.toggleKeepLiveWorkoutPill(val),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
