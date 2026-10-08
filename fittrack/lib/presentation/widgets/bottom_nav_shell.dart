import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/glass_tokens.dart';
import 'ambient_mesh_background.dart';
import 'animated_glass_dock.dart';
import 'ft_exit_confirmation.dart';
import 'glass/frosted_glass_box.dart';

/// Luminous Frosted Kinetic floating bottom navigation shell.
///
/// Features a detached 64px floating glass dock centered 24px above the bottom screen
/// edge with [FtGlassTier.glassFloating] blur, an animated pill for the active route,
/// minimal 48×48px icon buttons for inactive routes, and persistent ambient mesh canvas.
class BottomNavShell extends StatefulWidget {
  const BottomNavShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  DateTime? _lastPressedAt;

  void _goBranch(int index) {
    if (index == widget.navigationShell.currentIndex) return;
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        // If we are not on the dashboard (index 0), pop back to the dashboard.
        if (widget.navigationShell.currentIndex != 0) {
          _goBranch(0);
          return;
        }

        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning = _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > maxDuration;

        if (isWarning) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Press back again to exit'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            ),
          );
          return;
        }

        final confirmExit = await FtExitConfirmation.show(context);
        if (confirmExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: AmbientMeshBackground(
          child: widget.navigationShell,
        ),
        bottomNavigationBar: AnimatedGlassDock(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _goBranch,
        ),
      ),
    );
  }
}

class FloatingDock extends StatelessWidget {
  const FloatingDock({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    _NavTab(
      label: 'Dashboard',
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
    ),
    _NavTab(
      label: 'Workouts',
      icon: Icons.fitness_center_rounded,
      activeIcon: Icons.fitness_center_rounded,
    ),
    _NavTab(
      label: 'History',
      icon: Icons.schedule_rounded,
      activeIcon: Icons.schedule_rounded,
    ),
    _NavTab(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B6785);

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1.0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0, left: 20, right: 20),
          child: SizedBox(
            height: 64,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 353),
                child: RepaintBoundary(
                  child: FrostedGlassBox(
                    tier: GlassTier.floating,
                    enableBlur: true,
                    blur: 28.0,
                    height: 64,
                    borderRadius: BorderRadius.circular(9999),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_tabs.length, (index) {
                        final tab = _tabs[index];
                        final isActive = currentIndex == index;

                        if (isActive) {
                          return FrostedGlassBox(
                            tier: GlassTier.elevated,
                            enableBlur: false,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      onTap: () => onTap(index),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tab.activeIcon,
                            size: 20,
                            color: primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () => onTap(index),
                      icon: Icon(
                        tab.icon,
                        size: 20,
                        color: textMuted,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
  ),
);
  }
}

class _NavTab {
  const _NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
