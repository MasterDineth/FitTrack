import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/ft_glass.dart';

/// Floating Bottom Navigation Bar rebuilt exactly according to the Google Stitch
/// "FitTrack Bottom Navigation Showcase - Light & Dark" design specification.
///
/// Features:
/// - Single [BackdropFilter] wrapped in [RepaintBoundary] (sigma 24 in light, 26 in dark, 28 in OLED).
/// - Exact Stitch dock geometry: 58px height, 353px max-width, floating 16px above navigation bar.
/// - Borderless luminous active tab pill (light: bg-violet-100/90, dark/OLED: bg-violet-500/20).
/// - Large, effortless 66x58px hit targets spanning the full height of the dock without dead zones.
/// - Crisp modern haptic tap feedback ([HapticFeedback.lightImpact]).
/// - Smooth 200ms kinetic spring expansion/collapse transitions without jank or layout lag.
class AnimatedGlassDock extends ConsumerStatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedGlassDock({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  ConsumerState<AnimatedGlassDock> createState() => _AnimatedGlassDockState();
}

class _AnimatedGlassDockState extends ConsumerState<AnimatedGlassDock> {
  int? _pressedTabIndex;

  static const List<_DockTabItem> _tabs = [
    _DockTabItem(
      label: 'Dashboard',
      outlineIcon: Icons.grid_view_outlined,
      filledIcon: Icons.grid_view_rounded,
    ),
    _DockTabItem(
      label: 'Workouts',
      outlineIcon: Icons.fitness_center_outlined,
      filledIcon: Icons.fitness_center_rounded,
    ),
    _DockTabItem(
      label: 'History',
      outlineIcon: Icons.schedule_outlined,
      filledIcon: Icons.schedule_rounded,
    ),
    _DockTabItem(
      label: 'Settings',
      outlineIcon: Icons.settings_outlined,
      filledIcon: Icons.settings_rounded,
    ),
  ];

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dockWidth = math.max(0.0, math.min(screenWidth - 32, 353.0));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOled = isDark &&
        (theme.scaffoldBackgroundColor == Colors.black ||
            theme.scaffoldBackgroundColor == const Color(0xFF000000));

    final primary = theme.colorScheme.primary;

    bool enableTransparency = true;
    double blurScale = 1.0;
    try {
      final themeSettings = ref.watch(themeNotifierProvider);
      enableTransparency = themeSettings.enableGlassTransparency;
      blurScale = (themeSettings.blurIntensity / 16.0).clamp(0.2, 2.5);
    } catch (_) {}

    // Resolved floating dock glass spec matching Stitch showcase
    final double blurSigma = !enableTransparency
        ? 0.0
        : ((isOled ? 28.0 : (isDark ? 26.0 : 24.0)) * blurScale);
    final Color dockFill = !enableTransparency
        ? (isOled
            ? const Color(0xFF0C0C12)
            : (isDark ? const Color(0xFF161226) : Colors.white))
        : (isOled
            ? const Color(0xD10C0C12) // rgba(12, 12, 18, 0.82)
            : (isDark
                ? const Color(0xC2120E22) // rgba(18, 14, 34, 0.76)
                : const Color(0xC7FFFFFF))); // rgba(255, 255, 255, 0.78)
    final Color dockBorder = isOled
        ? const Color(0x1FFFFFFF) // 1px solid rgba(255, 255, 255, 0.12)
        : (isDark
            ? const Color(0x24FFFFFF) // 1px solid rgba(255, 255, 255, 0.14)
            : const Color(0xE6FFFFFF)); // 1px solid rgba(255, 255, 255, 0.90)
    final List<BoxShadow> dockShadow = isOled
        ? const [
            BoxShadow(
              color: Color(0xCC000000), // 0 16px 40px rgba(0, 0, 0, 0.80)
              blurRadius: 40,
              offset: Offset(0, 16),
            ),
          ]
        : (isDark
            ? const [
                BoxShadow(
                  color: Color(0x99000000), // 0 16px 40px rgba(0, 0, 0, 0.60)
                  blurRadius: 40,
                  offset: Offset(0, 16),
                ),
              ]
            : [
                BoxShadow(
                  color: primary.withValues(alpha: 0.12), // 0 16px 36px primary@12%
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
              ]);

    final Color rimHighlight = isOled
        ? const Color(0x26FFFFFF)
        : (isDark ? const Color(0x29FFFFFF) : const Color(0xF2FFFFFF));

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1.0,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.0 + bottomInset),
        child: RepaintBoundary(
          child: SizedBox(
            width: dockWidth,
            height: 58.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Frosted Glass Floating Dock Shell (The ONLY BackdropFilter on this screen)
                ClipRRect(
                  borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                  child: blurSigma > 0
                      ? BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                          child: Container(
                            decoration: BoxDecoration(
                              color: dockFill,
                              borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                              border: Border.all(
                                color: dockBorder,
                                width: 1.0,
                              ),
                              boxShadow: dockShadow,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: dockFill,
                            borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                            border: Border.all(
                              color: dockBorder,
                              width: 1.0,
                            ),
                            boxShadow: dockShadow,
                          ),
                        ),
                ),

                // Inset specular rim highlight at the top edge
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  height: 1.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          rimHighlight.withValues(alpha: 0.15),
                          rimHighlight,
                          rimHighlight.withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Interactive Navigation Tabs Row spanning full 58px height
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(_tabs.length, (index) {
                        final tab = _tabs[index];
                        final isActive = index == widget.currentIndex;
                        final isPressed = _pressedTabIndex == index;

                        return Expanded(
                          flex: isActive ? 2 : 1,
                          child: _buildDockTab(
                            index: index,
                            tab: tab,
                            isActive: isActive,
                            isPressed: isPressed,
                            isDark: isDark,
                            primary: primary,
                          ),
                        );
                      }),
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

  Widget _buildDockTab({
    required int index,
    required _DockTabItem tab,
    required bool isActive,
    required bool isPressed,
    required bool isDark,
    required Color primary,
  }) {
    // Theme-adaptive colors derived from user's chosen accent color:
    // Light Active: primary@12% fill, text & icon primary
    // Dark Active: primary@20% fill, text & icon lightened primary
    // Inactive: slate-400 (#94A3B8 in dark, #64748B in light)
    final Color activePillBg = isDark
        ? primary.withValues(alpha: 0.20)
        : primary.withValues(alpha: 0.12);
    final Color activeTextColor = isDark
        ? HSLColor.fromColor(primary)
            .withLightness((HSLColor.fromColor(primary).lightness + 0.25).clamp(0.0, 1.0))
            .toColor()
        : primary;
    final Color activeIconColor = isDark
        ? HSLColor.fromColor(primary)
            .withLightness((HSLColor.fromColor(primary).lightness + 0.15).clamp(0.0, 1.0))
            .toColor()
        : primary;
    final Color inactiveColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final activeShadow = isDark
        ? [
            BoxShadow(
              color: primary.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ]
        : [
            BoxShadow(
              color: primary.withValues(alpha: 0.14),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    Widget iconWidget = Icon(
      isActive ? tab.filledIcon : tab.outlineIcon,
      size: isActive ? 20.0 : 22.0,
      color: isActive ? activeIconColor : inactiveColor,
    );

    // Workouts (index 1) uses subtle angle matching barbell Stitch icon
    if (index == 1) {
      iconWidget = Transform.rotate(
        angle: -math.pi / 4,
        child: iconWidget,
      );
    }

    return Semantics(
      label: tab.label,
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressedTabIndex = index),
        onTapUp: (_) => setState(() => _pressedTabIndex = null),
        onTapCancel: () => setState(() => _pressedTabIndex = null),
        onTap: () => _handleTap(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: Center(
            child: AnimatedScale(
              scale: isPressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.fastOutSlowIn,
                padding: isActive
                    ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0)
                    : const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isActive ? activePillBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                  boxShadow: isActive ? activeShadow : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    iconWidget,
                    if (isActive) ...[
                      const SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: activeTextColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockTabItem {
  final String label;
  final IconData outlineIcon;
  final IconData filledIcon;

  const _DockTabItem({
    required this.label,
    required this.outlineIcon,
    required this.filledIcon,
  });
}
