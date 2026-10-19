import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../theme/ft_glass.dart';
import '../../../dashboard/widgets/ft_pressable.dart';
import 'live_notification_box.dart';
import 'notification_segmented_control.dart';

/// Interactive live notification preview card.
///
/// Demonstrates the real-time Android notification drawer for:
/// - Active set exercise and set progress with quick controls
/// - Rest timer countdown with −15s / Skip / +15s adjustments
/// - Workout completed summary card
class LiveNotificationPreviewCard extends StatefulWidget {
  const LiveNotificationPreviewCard({super.key});

  @override
  State<LiveNotificationPreviewCard> createState() =>
      _LiveNotificationPreviewCardState();
}

class _LiveNotificationPreviewCardState
    extends State<LiveNotificationPreviewCard> {
  WorkoutNotificationMode _mode = WorkoutNotificationMode.workout;
  int _elapsedSeconds = 760; // 12:40
  int _restSeconds = 45;
  int _maxRestSeconds = 45;
  int _currentExercise = 2;
  final int _totalExercises = 10;
  int _currentSet = 3;
  final int _totalSets = 4;
  bool _isPaused = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_mode == WorkoutNotificationMode.workout && !_isPaused) {
        setState(() {
          _elapsedSeconds++;
        });
      } else if (_mode == WorkoutNotificationMode.rest) {
        setState(() {
          _restSeconds--;
          if (_restSeconds <= 0) {
            _advanceSet();
          }
        });
      }
    });
  }

  void _advanceSet() {
    _currentSet++;
    if (_currentSet > _totalSets) {
      _currentSet = 1;
      _currentExercise++;
    }
    if (_currentExercise > _totalExercises) {
      _mode = WorkoutNotificationMode.done;
    } else {
      _mode = WorkoutNotificationMode.workout;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _playDemo() {
    setState(() {
      _mode = WorkoutNotificationMode.workout;
      _currentSet = _totalSets;
      _isPaused = false;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _mode = WorkoutNotificationMode.rest;
        _restSeconds = 8;
        _maxRestSeconds = 8;
      });
    });
  }

  void _handlePauseResume() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _handleCompleteSet() {
    setState(() {
      _mode = WorkoutNotificationMode.rest;
      _restSeconds = 45;
      _maxRestSeconds = 45;
    });
  }

  void _handleAdjustRest(int delta) {
    setState(() {
      _restSeconds = (_restSeconds + delta).clamp(0, 600);
      if (_restSeconds > _maxRestSeconds) {
        _maxRestSeconds = _restSeconds;
      }
      if (_restSeconds <= 0) {
        _advanceSet();
      }
    });
  }

  void _handleSkipRest() {
    setState(() {
      _advanceSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;

    String stateLabel;
    switch (_mode) {
      case WorkoutNotificationMode.workout:
        stateLabel = 'State: Active Set';
      case WorkoutNotificationMode.rest:
        stateLabel = 'State: Rest Countdown';
      case WorkoutNotificationMode.done:
        stateLabel = 'State: Completed';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Section Header & "Play demo" action
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'LIVE WORKOUT NOTIFICATION',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.12 * 11.5,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FtPressable(
                onTap: _playDemo,
                pressedScale: 0.95,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_outline_rounded,
                      size: 15,
                      color: primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Play demo',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 2. Android Live Notification Box Sub-widget
        LiveNotificationBox(
          mode: _mode,
          elapsedSeconds: _elapsedSeconds,
          restSeconds: _restSeconds,
          maxRestSeconds: _maxRestSeconds,
          currentExercise: _currentExercise,
          totalExercises: _totalExercises,
          currentSet: _currentSet,
          totalSets: _totalSets,
          isPaused: _isPaused,
          onPauseResume: _handlePauseResume,
          onCompleteSet: _handleCompleteSet,
          onOpen: () {},
          onAdjustRest: _handleAdjustRest,
          onSkipRest: _handleSkipRest,
          onViewSummary: () {},
          onDismiss: () {
            setState(() {
              _mode = WorkoutNotificationMode.workout;
              _currentExercise = 2;
              _currentSet = 3;
            });
          },
        ),
        const SizedBox(height: 8),

        // 3. Mode selector segmented control & State Label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NotificationSegmentedControl<WorkoutNotificationMode>(
                selected: _mode,
                options: const {
                  WorkoutNotificationMode.workout: 'Workout',
                  WorkoutNotificationMode.rest: 'Rest',
                  WorkoutNotificationMode.done: 'Done',
                },
                onSelected: (m) {
                  setState(() {
                    _mode = m;
                    if (m == WorkoutNotificationMode.rest) {
                      _restSeconds = 45;
                      _maxRestSeconds = 45;
                    }
                  });
                },
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  stateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: context.ftMuted,
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
