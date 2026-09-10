import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Glassmorphic floating bottom navigation dock.
///
/// Renders a pill-shaped translucent dock fixed above the bottom of the screen
/// with four navigation tabs: Dashboard, Workouts, History, and Settings. The
/// active tab is highlighted with a mint-green ([Color(0xFF00d68f)]) accent pill
/// and smooth [AnimatedContainer] transitions.
class BottomNavShell extends StatelessWidget {
  const BottomNavShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    HapticFeedback.lightImpact();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf7f9fb),
      body: navigationShell,
      bottomNavigationBar: _FloatingDock(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
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
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0f172a).withOpacity(0.10),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFF0f172a).withOpacity(0.04),
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
                          width: 48,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF00d68f).withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            size: 20,
                            color: isActive
                                ? const Color(0xFF00d68f)
                                : const Color(0xFF64748b),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? const Color(0xFF00d68f)
                                : const Color(0xFF64748b),
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
