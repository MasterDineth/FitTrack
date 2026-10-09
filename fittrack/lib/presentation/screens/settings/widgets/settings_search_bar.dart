import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';

/// Frosted glass search bar for filtering settings options in real-time.
/// Features corner-following subtle glow when focused, vertically aligned layout,
/// and instant clearing.
class SettingsSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SettingsSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onClear,
  });

  @override
  State<SettingsSearchBar> createState() => _SettingsSearchBarState();
}

class _SettingsSearchBarState extends State<SettingsSearchBar> {
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(SettingsSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)
          ?.removeListener(_handleFocusChange);
      _effectiveFocusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    (widget.focusNode ?? _internalFocusNode)
        ?.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _effectiveFocusNode.hasFocus;
    final isDark = context.isDark;
    final spec = isDark ? FtGlassTheme.glass1Dark : FtGlassTheme.glass1;
    final borderRadius = BorderRadius.circular(16);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: spec.fill,
          borderRadius: borderRadius,
          border: Border.all(
            color: isFocused
                ? context.ftPrimary.withValues(alpha: isDark ? 0.65 : 0.45)
                : spec.border,
            width: isFocused ? 1.2 : 1.0,
          ),
          boxShadow: isFocused
              ? [
                  // Subtle ambient glow that precisely follows the rounded rectangle corners
                  BoxShadow(
                    color: context.ftPrimary
                        .withValues(alpha: isDark ? 0.32 : 0.20),
                    blurRadius: 16,
                    spreadRadius: 1.5,
                    offset: Offset.zero,
                  ),
                  BoxShadow(
                    color: context.ftPrimary
                        .withValues(alpha: isDark ? 0.16 : 0.08),
                    blurRadius: 28,
                    spreadRadius: 3.5,
                    offset: Offset.zero,
                  ),
                ]
              : spec.shadows,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 20,
              color: isFocused ? context.ftPrimary : context.ftMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _effectiveFocusNode,
                onChanged: widget.onChanged,
                cursorColor: context.ftPrimary,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.ftInk,
                ),
                decoration: InputDecoration(
                  hintText: 'Search settings...',
                  hintStyle: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.ftMuted,
                  ),
                  // Explicitly disable all inner borders to avoid solid inner outlines
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, _) {
                if (value.text.isNotEmpty) {
                  return IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: context.ftMuted,
                    ),
                    splashRadius: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onClear?.call();
                      widget.onChanged?.call('');
                    },
                  );
                }
                return const SizedBox(width: 4);
              },
            ),
          ],
        ),
      ),
    );
  }
}
