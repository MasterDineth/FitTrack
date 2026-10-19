import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';
import 'package:fittrack/presentation/widgets/glass_surface.dart';
import 'package:fittrack/presentation/widgets/modals/modal_backdrop_helper.dart';

/// Modern reusable selection modal with frosted-glass backdrop,
/// selectable option tiles with dynamic accent, and a full-width confirm button.
class SelectionModal extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> options;
  final String selectedOption;

  const SelectionModal({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    required this.selectedOption,
  });

  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<String> options,
    required String selectedOption,
  }) {
    return showBlurBottomSheet<String>(
      context: context,
      child: SelectionModal(
        title: title,
        subtitle: subtitle,
        options: options,
        selectedOption: selectedOption,
      ),
    );
  }

  @override
  State<SelectionModal> createState() => _SelectionModalState();
}

class _SelectionModalState extends State<SelectionModal> {
  late String _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedOption;
  }

  void _submit() {
    Navigator.of(context).pop(_currentSelection);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final primary = context.ftPrimary;
    final settings = FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;
    final blurIntensity = settings?.blurIntensity ?? 16.0;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final double t = enableTransparency
        ? ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0)
        : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: GlassSurface(
        tier: FtGlassTier.glass1,
        radius: 32,
        backdrop: GlassBackdrop.live,
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top Drag Handle ──────────────────────────────────────────
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: !enableTransparency
                      ? (isDark ? Colors.white38 : Colors.black26)
                      : (isDark ? Colors.white24 : Colors.black12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

          // ── Header Row ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: ink,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FtPressable(
                onTap: () => Navigator.of(context).pop(),
                pressedScale: 0.90,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Scrollable Option Tiles ──────────────────────────────────
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final option = widget.options[index];
                final isSelected = _currentSelection == option;

                return FtPressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _currentSelection = option);
                  },
                  pressedScale: 0.985,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withValues(
                              alpha: isDark ? (0.20 + 0.12 * t) : (0.10 + 0.08 * t),
                            )
                          : (!enableTransparency
                              ? (isDark
                                  ? const Color(0xFF241D3B)
                                  : const Color(0xFFF1F5F9))
                              : (isDark
                                  ? Colors.white.withValues(
                                      alpha: (0.04 + 0.04 * t).clamp(0.03, 0.10),
                                    )
                                  : Colors.white.withValues(
                                      alpha: (0.45 + 0.35 * t).clamp(0.40, 0.85),
                                    ))),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? primary
                            : (!enableTransparency
                                ? (isDark ? Colors.white24 : const Color(0xFFE2E8F0))
                                : (isDark
                                    ? Colors.white.withValues(
                                        alpha: (0.08 + 0.08 * t).clamp(0.06, 0.18),
                                      )
                                    : const Color(0xFFE2E8F0))),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primary
                                    .withValues(alpha: isDark ? 0.25 : 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 14.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? Colors.white : primary)
                                  : ink,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (isSelected)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          )
                        else
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white30
                                    : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // ── Full-Width Confirm Button ────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FtPressable(
              onTap: () {
                HapticFeedback.mediumImpact();
                _submit();
              },
              pressedScale: 0.98,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: isDark ? 0.40 : 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Confirm Selection',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
