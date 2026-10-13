import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../providers/schedule_editor_notifier.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';
import 'schedule_exercise_card.dart';

/// Wraps [ScheduleExerciseCard] with a smooth, haptic-enabled swipe-to-discard gesture.
/// Solves the sharp clipping issue in standard Dismissible by rendering the discard card
/// as an autonomous rounded card with dynamic width and 8dp separation, wrapping around
/// the workout card's rounded geometry without sharp corner leaks.
class ScheduleExerciseDismissible extends StatefulWidget {
  const ScheduleExerciseDismissible({
    super.key,
    required this.index,
    required this.entry,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onRemove,
    required this.onUpdateSets,
    required this.onUpdateReps,
    required this.onUpdateWeight,
    required this.onUpdateRest,
    this.settings,
  });

  final int index;
  final ScheduleExerciseEntry entry;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onRemove;
  final ValueChanged<int> onUpdateSets;
  final ValueChanged<int> onUpdateReps;
  final ValueChanged<double> onUpdateWeight;
  final ValueChanged<int> onUpdateRest;
  final ThemeSettings? settings;

  @override
  State<ScheduleExerciseDismissible> createState() =>
      _ScheduleExerciseDismissibleState();
}

class _ScheduleExerciseDismissibleState
    extends State<ScheduleExerciseDismissible> {
  double _progress = 0.0;
  bool _hapticFired = false;

  Widget _buildBackground({
    required bool alignLeft,
    required double totalWidth,
  }) {
    // Determine card width so it ends 8dp before the sliding card,
    // preserving its full 24dp rounded corners on all edges.
    final currentDx = _progress * totalWidth;
    final double cardWidth;
    if (_progress > 0) {
      cardWidth = (currentDx - 8.0).clamp(0.0, totalWidth);
    } else {
      cardWidth = totalWidth;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: cardWidth,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFBA1A1A),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33BA1A1A),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_rounded,
                color: Colors.white,
                size: 22,
              ),
              if (cardWidth > 80) ...[
                const SizedBox(width: 6),
                const Text(
                  'Discard',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) {
        // Reset progress after gesture ends and card snaps back
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            setState(() {
              _progress = 0.0;
              _hapticFired = false;
            });
          }
        });
      },
      onPointerCancel: (_) {
        if (mounted) {
          setState(() {
            _progress = 0.0;
            _hapticFired = false;
          });
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;

          return Dismissible(
            key: ValueKey('dismiss_${widget.entry.exerciseId}_${widget.index}'),
            direction: DismissDirection.horizontal,
            onUpdate: (details) {
              setState(() {
                _progress = details.progress;
              });
              if (details.reached && !_hapticFired) {
                _hapticFired = true;
                HapticFeedback.mediumImpact();
              } else if (!details.reached) {
                _hapticFired = false;
              }
            },
            confirmDismiss: (direction) async {
              HapticFeedback.heavyImpact();
              return true;
            },
            onDismissed: (_) {
              widget.onRemove();
            },
            background: _buildBackground(
              alignLeft: true,
              totalWidth: totalWidth,
            ),
            secondaryBackground: _buildBackground(
              alignLeft: false,
              totalWidth: totalWidth,
            ),
            child: ScheduleExerciseCard(
              key: ValueKey('${widget.entry.exerciseId}_${widget.index}'),
              index: widget.index,
              entry: widget.entry,
              isExpanded: widget.isExpanded,
              settings: widget.settings,
              onToggleExpand: widget.onToggleExpand,
              onRemove: widget.onRemove,
              onUpdateSets: widget.onUpdateSets,
              onUpdateReps: widget.onUpdateReps,
              onUpdateWeight: widget.onUpdateWeight,
              onUpdateRest: widget.onUpdateRest,
            ),
          );
        },
      ),
    );
  }
}
