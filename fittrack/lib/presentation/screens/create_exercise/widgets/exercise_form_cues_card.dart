import 'package:flutter/material.dart';
import '../../../providers/custom_exercise_notifier.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Form Cues Section Card for Create Exercise Screen.
/// Matches Stitch Screen ID de3d4ad0debd49a9905572984fbbde63.
///
/// Features:
/// - List of added Form Cues (max 3).
/// - Distinct check mark (teal) for DO and cross mark (rose) for DON'T.
/// - Remove cue action button.
/// - "Add Form Cue" button launching [AddFormCueDialog].
class ExerciseFormCuesCard extends StatefulWidget {
  const ExerciseFormCuesCard({
    super.key,
    required this.cues,
    required this.onAddCueTap,
    required this.onRemoveCue,
  });

  final List<FormCueDraft> cues;
  final VoidCallback onAddCueTap;
  final ValueChanged<int> onRemoveCue;

  @override
  State<ExerciseFormCuesCard> createState() => _ExerciseFormCuesCardState();
}

class _ExerciseFormCuesCardState extends State<ExerciseFormCuesCard> {
  bool _isExpanded = true;

  static const List<IconData> _cueIcons = [
    Icons.sync_rounded,
    Icons.directions_walk_rounded,
    Icons.lock_rounded,
  ];

  static const List<Color> _iconBgColors = [
    Color(0xFFEDE9FE), // violet-100
    Color(0xFFCCFBF1), // teal-100
    Color(0xFFFEF3C7), // amber-100
  ];

  static const List<Color> _iconFgColors = [
    Color(0xFF5F3BDC), // primary
    Color(0xFF0F766E), // teal-700
    Color(0xFFB45309), // amber-700
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    final cueCount = widget.cues.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FtGlassTheme.cardDecoration(
        context,
        radius: 24,
        settings: settings,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.verified_rounded,
                        color: primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Form Cues',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                          Text(
                            'Mental anchors for peak tension',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$cueCount cue${cueCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    icon: Icon(
                      _isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (_isExpanded) ...[
            const SizedBox(height: 14),

            if (widget.cues.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No form cues added yet. Add DO and DON\'T movement cues (up to 3 max).',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              )
            else
              Column(
                children: widget.cues.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cue = entry.value;
                  final icon = _cueIcons[index % _cueIcons.length];
                  final iconBg = _iconBgColors[index % _iconBgColors.length];
                  final iconFg = _iconFgColors[index % _iconFgColors.length];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0x1F1E1838)
                            : Colors.white.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? const Color(0x33FFFFFF)
                              : Colors.white.withValues(alpha: 0.90),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left Category Icon Container
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isDark ? iconFg.withValues(alpha: 0.20) : iconBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              icon,
                              size: 18,
                              color: isDark ? Colors.white : iconFg,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Middle: Text & Classification badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cue.isPositive
                                            ? const Color(0xFF2DD4BF).withValues(alpha: 0.15)
                                            : const Color(0xFFF43F5E).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        cue.isPositive ? 'DO' : "DON'T",
                                        style: TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: cue.isPositive
                                              ? const Color(0xFF0F766E)
                                              : const Color(0xFFF43F5E),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        cue.description,
                                        style: TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: ink,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Right: Check/Cross Mark Icon
                          Icon(
                            cue.isPositive
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 20,
                            color: cue.isPositive
                                ? const Color(0xFF2DD4BF)
                                : const Color(0xFFF43F5E),
                          ),
                          const SizedBox(width: 6),

                          // Delete Action
                          FtPressable(
                            onTap: () => widget.onRemoveCue(index),
                            pressedScale: 0.88,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            // Add Cue Action Button (Max 3)
            if (widget.cues.length < 3) ...[
              const SizedBox(height: 4),
              FtPressable(
                onTap: widget.onAddCueTap,
                pressedScale: 0.98,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x1F1E1838)
                        : Colors.white.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.40),
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                        color: primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Form Cue',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
