import 'package:flutter/material.dart';

/// Interactive wrapper providing calibrated press feedback.
/// Scale .95 (buttons/avatar) or .98 (cards) for 100ms down / 160ms up.
class FtPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final HitTestBehavior behavior;

  const FtPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.95,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<FtPressable> createState() => _FtPressableState();
}

class _FtPressableState extends State<FtPressable> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null || widget.onLongPress != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = _isPressed
        ? const Duration(milliseconds: 100)
        : const Duration(milliseconds: 160);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: widget.behavior,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: effectiveDuration,
        curve: _isPressed ? Curves.easeIn : Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
