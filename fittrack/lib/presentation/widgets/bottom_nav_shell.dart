import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'ft_exit_confirmation.dart';

/// Glassmorphic floating bottom navigation dock.
///
/// Renders a pill-shaped translucent dock fixed above the bottom of the screen
/// with four navigation tabs: Dashboard, Workouts, History, and Settings. The
/// active tab is highlighted with a mint-green ([Color(0xFF00d68f)]) accent pill
/// and smooth [AnimatedContainer] transitions.
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
    HapticFeedback.lightImpact();
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: widget.navigationShell,
        bottomNavigationBar: _FloatingDock(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _goBranch,
        ),
      ),
    );
  }
}

class _FloatingDock extends StatelessWidget {
  const _FloatingDock({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    _NavTab(
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      activeIcon: Icons.dashboard_rounded,
    ),
    _NavTab(
      label: 'Workouts',
      icon: Icons.fitness_center_outlined,
      activeIcon: Icons.fitness_center_rounded,
    ),
    _NavTab(
      label: 'History',
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
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
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding + 12,
        top: 0,
      ),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          // Glassmorphic background
          color: colorScheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : Colors.white.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.35 : 0.10),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.20 : 0.04),
              blurRadius: 12,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isActive = currentIndex == index;
              final unselectedColor = isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? primary.withValues(alpha: 0.14)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            size: 20,
                            color: isActive ? primary : unselectedColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive ? primary : unselectedColor,
                            letterSpacing: -0.2,
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
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
