import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Lifter Reflection & Notes card for recording workout reflections,
/// biomechanics notes, PRs, and fatigue logs.
class WorkoutSummaryNotesCard extends StatefulWidget {
  const WorkoutSummaryNotesCard({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<WorkoutSummaryNotesCard> createState() => _WorkoutSummaryNotesCardState();
}

class _WorkoutSummaryNotesCardState extends State<WorkoutSummaryNotesCard> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final isDark = context.isDark;

    final charCount = widget.controller.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Row ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          child: Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 20,
                color: primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Lifter Reflection & Notes',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: ink,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Notes Glass Card ──────────────────────────────────────────────────
        GlassSurface(
          tier: FtGlassTier.glass1,
          radius: 24,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Area Container
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.8),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: TextField(
                  controller: widget.controller,
                  maxLines: 4,
                  minLines: 3,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: ink,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Felt strong today — smooth bar path on bench press. Increase bench to 105 kg on next cycle...',
                    hintStyle: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: muted.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Footer Character Count (Guaranteed single line)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$charCount characters',
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: muted.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
