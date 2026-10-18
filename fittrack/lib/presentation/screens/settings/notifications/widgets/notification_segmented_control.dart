import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/ft_glass.dart';

/// Reusable frosted glass segmented control matching the Stitch design system.
///
/// Features smooth animated selection pill with vibrant gradient accent,
/// clean typography, and tactile feedback.
class NotificationSegmentedControl<T> extends StatelessWidget {
  final T selected;
  final Map<T, String> options;
  final ValueChanged<T> onSelected;
  final double height;
  final bool fullWidth;

  const NotificationSegmentedControl({
    super.key,
    required this.selected,
    required this.options,
    required this.onSelected,
    this.height = 32.0,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final containerBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.65);
    final containerBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.90);

    Widget segmentedBody = Container(
      height: height,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: containerBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: context.ftPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: options.entries.map((entry) {
          final isSelected = entry.key == selected;
          final button = _SegmentButton(
            label: entry.value,
            isSelected: isSelected,
            height: height - 6.0,
            onTap: () {
              if (!isSelected) {
                HapticFeedback.selectionClick();
                onSelected(entry.key);
              }
            },
          );

          if (fullWidth) {
            return Expanded(child: button);
          }
          return button;
        }).toList(),
      ),
    );

    return segmentedBody;
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final double height;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;

    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      HSLColor.fromColor(primary)
                          .withLightness((HSLColor.fromColor(primary).lightness + 0.12).clamp(0.0, 1.0))
                          .toColor(),
                      primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : context.ftMuted,
            ),
          ),
        ),
      ),
    );
  }
}
