import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/ambient_mesh_background.dart';
import 'appearance/appearance_actions_section.dart';
import 'appearance/appearance_color_accent_section.dart';
import 'appearance/appearance_dynamic_accent_section.dart';
import 'appearance/appearance_ergonomics_section.dart';
import 'appearance/appearance_header.dart';
import 'appearance/appearance_live_preview.dart';
import 'appearance/appearance_theme_mode_section.dart';

/// Redesigned FitTrack Appearance Settings Screen.
///
/// Built strictly following the Stitch Mobile Design System (Screen ID: 5b62927f342e4cadb26c33a1cc33fd91).
/// Features:
/// - Real-time frosted glass interactive telemetry canvas preview
/// - Segmented Theme Mode selection (Light, Dark, System)
/// - OS Dynamic Accent Wallpaper Extraction toggle
/// - 4x2 Athletic Accent Swatches with Custom Color spectrum launcher
/// - Frosted Glass Transparency & tactile Blur Intensity controls
/// - Pure Black OLED, High Contrast Text, and workout display ergonomics
/// - System defaults reset and appearance save actions
/// - Consistent dashboard header layout (Profile avatar + unread notifications bell)
/// - Bottom navigation shell integration
class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 24.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientMeshBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 393),
            child: CustomScrollView(
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
                      bottom: bottomPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed(
                        const [
                          // 1. Header (Back button, Title, Notifications & Profile Avatar)
                          AppearanceHeader(),
                          SizedBox(height: 14),

                          // 2. Real-time Live Preview Canvas
                          AppearanceLivePreview(),
                          SizedBox(height: 20),

                          // 3. Theme Mode Selection (Light, Dark, System)
                          AppearanceThemeModeSection(),
                          SizedBox(height: 20),

                          // 4. Dynamic Accent Banner
                          AppearanceDynamicAccentSection(),
                          SizedBox(height: 20),

                          // 5. Color Accent Palette Grid & Custom Color trigger
                          AppearanceColorAccentSection(),
                          SizedBox(height: 20),

                          // 6. Ergonomics & Accessibility (Frosted Glass, Blur, OLED, Awake)
                          AppearanceErgonomicsSection(),
                          SizedBox(height: 22),

                          // 7. Save & Reset Action Buttons
                          AppearanceActionsSection(),
                          SizedBox(height: 12),
                        ],
                      ),
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
