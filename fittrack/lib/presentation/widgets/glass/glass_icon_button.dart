import 'package:flutter/material.dart';

import '../../theme/glass_tokens.dart';
import 'frosted_glass_box.dart';

/// 44×44px circular glass icon button with [GlassTier.elevated] material,
/// tactile scale micro-interaction (0.95 on tap), and optional 8px unread indicator pip.
class GlassIconButton extends StatefulWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.showBadge = false,
    this.badgeColor,
    this.size = 44.0,
    this.tooltip,
    this.iconColor,
  });

  final Widget icon;
  final VoidCallback? onTap;
  final bool showBadge;
  final Color? badgeColor;
  final double size;
  final String? tooltip;
  final Color? iconColor;

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final pipColor = widget.badgeColor ?? primary;

    Widget button = AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          FrostedGlassBox(
            tier: GlassTier.elevated,
            width: widget.size,
            height: widget.size,
            borderRadius: BorderRadius.circular(widget.size / 2),
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                  color: widget.iconColor ?? theme.colorScheme.onSurface,
                  size: widget.size * 0.48,
                ),
                child: widget.icon,
              ),
            ),
          ),
          if (widget.showBadge)
            Positioned(
              top: widget.size * 0.18,
              right: widget.size * 0.18,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: pipColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: pipColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: button,
    );
  }
}
