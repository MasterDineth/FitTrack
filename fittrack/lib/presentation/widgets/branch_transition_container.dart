import 'package:flutter/material.dart';

/// Container that hosts all StatefulNavigationShell branch navigators.
/// Cross-fades 220ms with a 12px horizontal slide in the direction of travel.
/// The outgoing branch fades out in 120ms and is then marked Offstage with TickerMode disabled.
/// The target branch is never rebuilt from scratch.
class BranchTransitionContainer extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const BranchTransitionContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  State<BranchTransitionContainer> createState() => _BranchTransitionContainerState();
}

class _BranchTransitionContainerState extends State<BranchTransitionContainer>
    with SingleTickerProviderStateMixin {
  late int _activeBranchIndex;
  int _previousBranchIndex = -1;
  late final AnimationController _controller;
  int _direction = 1; // +1 if moving right, -1 if moving left

  @override
  void initState() {
    super.initState();
    _activeBranchIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void didUpdateWidget(covariant BranchTransitionContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      final disableMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      _previousBranchIndex = oldWidget.currentIndex;
      _activeBranchIndex = widget.currentIndex;
      _direction = widget.currentIndex > oldWidget.currentIndex ? 1 : -1;

      if (disableMotion) {
        _previousBranchIndex = -1;
      } else {
        _controller.forward(from: 0.0).then((_) {
          if (mounted) {
            setState(() {
              _previousBranchIndex = -1;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Stack(
      fit: StackFit.expand,
      children: List.generate(widget.children.length, (index) {
        final isCurrent = index == _activeBranchIndex;
        final isPrevious = index == _previousBranchIndex;

        if (!isCurrent && !isPrevious) {
          return Offstage(
            offstage: true,
            child: TickerMode(
              enabled: false,
              child: widget.children[index],
            ),
          );
        }

        if (disableMotion || !isPrevious && !isCurrent) {
          return Offstage(
            offstage: !isCurrent,
            child: TickerMode(
              enabled: isCurrent,
              child: widget.children[index],
            ),
          );
        }

        if (isCurrent && _previousBranchIndex == -1) {
          // Stable state after transition
          return Offstage(
            offstage: false,
            child: TickerMode(
              enabled: true,
              child: widget.children[index],
            ),
          );
        }

        // Active transition
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (isCurrent) {
              // Incoming: 180ms fade in + 10px slide in direction of travel
              final fadeValue = _controller.value.clamp(0.0, 1.0);
              final slideValue = (1.0 - _controller.value) * 10.0 * _direction;
              return Transform.translate(
                offset: Offset(slideValue, 0),
                child: Opacity(
                  opacity: fadeValue,
                  child: child,
                ),
              );
            } else {
              // Outgoing: fades out in first 100ms
              final progress = (_controller.value / (100.0 / 180.0)).clamp(0.0, 1.0);
              if (progress >= 1.0) {
                return const SizedBox.shrink();
              }
              final fadeValue = 1.0 - progress;
              final slideValue = progress * -10.0 * _direction;
              return Transform.translate(
                offset: Offset(slideValue, 0),
                child: Opacity(
                  opacity: fadeValue,
                  child: child,
                ),
              );
            }
          },
          child: RepaintBoundary(
            child: widget.children[index],
          ),
        );
      }),
    );
  }
}
