import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/ft_glass.dart';

class AnimatedGlassDock extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedGlassDock({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AnimatedGlassDock> createState() => _AnimatedGlassDockState();
}

class _AnimatedGlassDockState extends State<AnimatedGlassDock>
    with SingleTickerProviderStateMixin {
  late int _activeTabIndex;
  int _previousTabIndex = 0;
  late final AnimationController _moveController;
  late final Animation<double> _moveCurve;

  // Press down state per tab
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

  late final List<double> _measuredLabelWidths;
  late final List<double> _activeTabWidths;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.currentIndex;
    _previousTabIndex = widget.currentIndex;

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _moveCurve = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeOutCubic,
    );

    _measuredLabelWidths = _measureLabelWidths();
    // active tab = px 16 py 8 -> left padding 16 + icon 20 + gap 8 + label + right padding 16 = 60 + label
    _activeTabWidths = _measuredLabelWidths.map((w) => 60.0 + w).toList();
  }

  List<double> _measureLabelWidths() {
    return _tabs.map((tab) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: tab.label,
          style: const TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      return textPainter.width;
    }).toList();
  }

  @override
  void didUpdateWidget(covariant AnimatedGlassDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      final disableMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      _previousTabIndex = oldWidget.currentIndex;
      _activeTabIndex = widget.currentIndex;

      if (disableMotion) {
        _previousTabIndex = _activeTabIndex;
      } else {
        _moveController.forward(from: 0.0).then((_) {
          if (mounted) {
            setState(() {
              _previousTabIndex = _activeTabIndex;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.selectionClick();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dockWidth = math.min(screenWidth - 40, 353.0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 24.0 + bottomInset),
        child: RepaintBoundary(
          child: SizedBox(
            width: dockWidth,
            height: 64,
            child: Stack(
              children: [
                // 1. Floating Glass Pill (The ONLY BackdropFilter on this screen, sigma 28)
                ClipRRect(
                  borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 28.0, sigmaY: 28.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FtGlassTheme.glassFloating.fill, // white 68%
                        borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                        border: Border.all(
                          color: FtGlassTheme.glassFloating.border, // white 85%
                          width: 1.0,
                        ),
                        boxShadow: FtGlassTheme.glassFloating.shadows,
                      ),
                    ),
                  ),
                ),

                // Inset top highlight line
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  height: 1.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FtGlassTheme.glassFloating.highlight.withValues(alpha: 0.15),
                          FtGlassTheme.glassFloating.highlight,
                          FtGlassTheme.glassFloating.highlight.withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Sliding Highlight Pill & Tab Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      return _buildInteractiveTabRow(availableWidth);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveTabRow(double availableWidth) {
    // Calculate layout positions for each tab
    // When tab i is active, tabs are arranged:
    // Tab widths: active is _activeTabWidths[i], others are 48.
    // Remaining space is distributed equally among gaps.

    return AnimatedBuilder(
      animation: _moveCurve,
      builder: (context, _) {
        final progress = _moveController.value;

        // Interpolate active positions between _previousTabIndex and _activeTabIndex
        final oldPositions = _calculateTabPositions(
          activeIdx: _previousTabIndex,
          availableWidth: availableWidth,
        );
        final newPositions = _calculateTabPositions(
          activeIdx: _activeTabIndex,
          availableWidth: availableWidth,
        );

        // Highlight pill geometry
        final startLeft = oldPositions[_previousTabIndex].left;
        final startWidth = oldPositions[_previousTabIndex].width;
        final targetLeft = newPositions[_activeTabIndex].left;
        final targetWidth = newPositions[_activeTabIndex].width;

        final currentLeft = uiLerp(startLeft, targetLeft, progress);
        final currentWidth = uiLerp(startWidth, targetWidth, progress);

        // Liquid stretch: scaleX peaks at 1.06 mid-move
        final liquidScaleX = 1.0 + 0.06 * math.sin(progress * math.pi);

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Sliding Highlight Pill
            Positioned(
              left: currentLeft,
              width: currentWidth,
              top: 12,
              bottom: 12,
              child: Transform.scale(
                scaleX: liquidScaleX,
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: FtGlassTheme.glass2.fill, // white 65%
                    borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                    border: Border.all(
                      color: FtGlassTheme.primary.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),

            // Tab Items Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_tabs.length, (index) {
                final isCurrent = index == _activeTabIndex;
                final isPrev = index == _previousTabIndex;

                // Tab width interpolation
                final oldW = oldPositions[index].width;
                final newW = newPositions[index].width;
                final width = uiLerp(oldW, newW, progress);

                // Reveal progress: active fades in over last 60% (0.4 to 1.0)
                // outgoing fades out over first 40% (0.0 to 0.4)
                double labelProgress;
                if (_previousTabIndex == _activeTabIndex) {
                  labelProgress = isCurrent ? 1.0 : 0.0;
                } else if (isCurrent) {
                  labelProgress = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
                } else if (isPrev) {
                  labelProgress = (1.0 - (progress / 0.4)).clamp(0.0, 1.0);
                } else {
                  labelProgress = 0.0;
                }

                return _buildTabItem(
                  index: index,
                  width: width,
                  labelProgress: labelProgress,
                  isActive: isCurrent,
                );
              }),
            ),
          ],
        );
      },
    );
  }

  List<_TabSlot> _calculateTabPositions({
    required int activeIdx,
    required double availableWidth,
  }) {
    final widths = List.generate(_tabs.length, (i) {
      return i == activeIdx ? _activeTabWidths[i] : 48.0;
    });

    final totalContentWidth = widths.reduce((a, b) => a + b);
    final remainingSpace = availableWidth - totalContentWidth;
    final gap = remainingSpace / (_tabs.length - 1);

    final positions = <_TabSlot>[];
    double currentX = 0;

    for (int i = 0; i < _tabs.length; i++) {
      positions.add(_TabSlot(left: currentX, width: widths[i]));
      currentX += widths[i] + gap;
    }

    return positions;
  }

  Widget _buildTabItem({
    required int index,
    required double width,
    required double labelProgress,
    required bool isActive,
  }) {
    final tab = _tabs[index];
    final isPressed = _pressedTabIndex == index;

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
        child: AnimatedScale(
          scale: isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeIn,
          child: SizedBox(
            width: width,
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon crossfade outline -> filled (180ms), color muted -> primary
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 180),
                crossFadeState: isActive
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Icon(
                  tab.outlineIcon,
                  size: 20,
                  color: FtGlassTheme.muted,
                ),
                secondChild: Icon(
                  tab.filledIcon,
                  size: 20,
                  color: FtGlassTheme.primary,
                ),
              ),

              // Expanding & revealing label
              if (labelProgress > 0) ...[
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: labelProgress,
                    child: Opacity(
                      opacity: labelProgress,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8),
                          Text(
                            tab.label,
                            maxLines: 1,
                            style: const TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: FtGlassTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

  double uiLerp(double a, double b, double t) => a + (b - a) * t;
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

class _TabSlot {
  final double left;
  final double width;

  const _TabSlot({required this.left, required this.width});
}
