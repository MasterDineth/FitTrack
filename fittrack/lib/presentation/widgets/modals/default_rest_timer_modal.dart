import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/workout_settings_provider.dart';
import 'modal_backdrop_helper.dart';

/// Shows the redesigned Default Rest Timer Custom Editor Modal matching Stitch ID: 5cd20eedda454e3a9b5d58d5f14d9383.
///
/// Features:
/// - Smooth full-screen backdrop blur and dark scrim via [showBlurBottomSheet]
/// - Dynamic theming linked to [themeNotifierProvider] & [Theme.of(context).colorScheme.primary]
/// - Live circular ring gauge with total seconds readout
/// - Minute (+/- 1m) & Second (+/- 5s) ergonomic stepper controls
/// - Quick +/-15s and +/-30s nudge chips
/// - 8 Quick Presets in compact rows with active state highlight and glowing dot
/// - Contextual hypertrophy/strength coaching science card
/// - Sticky primary Save and Cancel actions
Future<void> showDefaultRestTimerModal(BuildContext context) async {
  await showBlurBottomSheet<void>(
    context: context,
    child: const _DefaultRestTimerSheet(),
  );
}

class _DefaultRestTimerSheet extends ConsumerStatefulWidget {
  const _DefaultRestTimerSheet();

  @override
  ConsumerState<_DefaultRestTimerSheet> createState() =>
      _DefaultRestTimerSheetState();
}

class _DefaultRestTimerSheetState extends ConsumerState<_DefaultRestTimerSheet>
    with SingleTickerProviderStateMixin {
  late int _minutes;
  late int _seconds;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  static const List<String> _presets = [
    '00:30',
    '00:45',
    '01:00',
    '01:30',
    '02:00',
    '02:30',
    '03:00',
    '05:00',
  ];

  @override
  void initState() {
    super.initState();
    final currentState = ref.read(workoutSettingsProvider);
    _parseTimer(currentState.defaultRestTimer);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _parseTimer(String timer) {
    final parts = timer.split(':');
    if (parts.length == 2) {
      _minutes = int.tryParse(parts[0]) ?? 1;
      _seconds = int.tryParse(parts[1]) ?? 30;
    } else {
      _minutes = 1;
      _seconds = 30;
    }
  }

  String get _formattedTime {
    final m = _minutes.toString().padLeft(2, '0');
    final s = _seconds.toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _totalSeconds => (_minutes * 60) + _seconds;

  void _setTotalSeconds(int totalSecs) {
    final clamped = totalSecs.clamp(5, 900); // 5s to 15m
    setState(() {
      _minutes = clamped ~/ 60;
      _seconds = clamped % 60;
    });
  }

  void _adjustMinutes(int delta) {
    _setTotalSeconds(_totalSeconds + (delta * 60));
  }

  void _adjustSeconds(int delta) {
    _setTotalSeconds(_totalSeconds + delta);
  }

  void _selectPreset(String preset) {
    final parts = preset.split(':');
    if (parts.length == 2) {
      setState(() {
        _minutes = int.tryParse(parts[0]) ?? 1;
        _seconds = int.tryParse(parts[1]) ?? 30;
      });
    }
  }

  void _resetToDefault() {
    setState(() {
      _minutes = 1;
      _seconds = 30;
    });
  }

  Future<void> _handleSave() async {
    final formatted = _formattedTime;
    await ref
        .read(workoutSettingsProvider.notifier)
        .setDefaultRestTimer(formatted);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            'Default rest timer updated to $formatted',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final themeSettings = ref.watch(themeNotifierProvider);
    final isOled = themeSettings.useOledBlack && !isLight;

    // Design tokens matching Stitch Kinetic Slate & App Theme
    final sheetBg = isLight
        ? const Color(0xFFF7F9FB)
        : (isOled ? const Color(0xFF000000) : const Color(0xFF161C24));

    final cardBg = isLight
        ? Colors.white
        : (isOled ? const Color(0xFF0C1017) : const Color(0xFF1E2633));

    final subCardBg = isLight
        ? const Color(0xFFF1F5F9)
        : (isOled ? const Color(0xFF141A24) : const Color(0xFF161C24));

    final buttonBg = isLight
        ? Colors.white
        : (isOled ? const Color(0xFF1C2430) : const Color(0xFF263140));

    final borderColor = isLight
        ? const Color(0xFFE2E8F0)
        : Colors.white.withValues(alpha: 0.1);

    final currentSavedTimer = ref.watch(
      workoutSettingsProvider.select((s) => s.defaultRestTimer),
    );

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: 480,
        maxHeight: screenHeight * 0.92,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: isLight
                ? const Color(0xFFE2E8F0)
                : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.4),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle & Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 20, 14),
            child: Column(
              children: [
                // Top drag bar
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF3A4452),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Default Rest Timer',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Live current indicator pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: isLight ? 0.12 : 0.18,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FadeTransition(
                                      opacity: _pulseAnimation,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Current: $currentSavedTimer',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.primary,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Customize automatic recovery countdown between sets.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Close 'X' Button
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isLight
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF222B38),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: borderColor,
          ),

          // ── Scrollable Body ───────────────────────────────────────────────
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                // ── 1. Custom Timer Hero Card ───────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor),
                    boxShadow: isLight
                        ? const [
                            BoxShadow(
                              color: Color(0x080F172A),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Ambient corner accent glow
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Upper Row: Circular gauge, Digital Readout, Reset
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Circular Gauge
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CustomPaint(
                                    painter: _TimerGaugePainter(
                                      progress: (_totalSeconds / 180.0)
                                          .clamp(0.0, 1.0),
                                      trackColor: isLight
                                          ? const Color(0xFFF1F5F9)
                                          : const Color(0xFF2A3444),
                                      progressColor: colorScheme.primary,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            '${_totalSeconds}s',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Big Digital Readout Display
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Minutes
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _minutes.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 42,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -1,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          'MIN',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 6,
                                        right: 6,
                                        bottom: 14,
                                      ),
                                      child: Text(
                                        ':',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 34,
                                          fontWeight: FontWeight.w800,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    // Seconds
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _seconds.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 42,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -1,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          'SEC',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Reset to default button
                                Tooltip(
                                  message: 'Reset to 01:30',
                                  child: InkWell(
                                    onTap: _resetToDefault,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: isLight
                                            ? const Color(0xFFF1F5F9)
                                            : const Color(0xFF263140),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: borderColor,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.rotate_left_rounded,
                                        size: 18,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: borderColor,
                            ),
                            const SizedBox(height: 14),

                            // Middle Row: Dedicated Steppers
                            Row(
                              children: [
                                // Minutes Stepper
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: subCardBg,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'MINUTES',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.6,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                '+/- 1m',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme
                                                      .onSurfaceVariant
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStepperButton(
                                                context: context,
                                                icon: Icons.remove_rounded,
                                                buttonBg: buttonBg,
                                                borderColor: borderColor,
                                                onTap: () => _adjustMinutes(-1),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: _buildStepperButton(
                                                context: context,
                                                icon: Icons.add_rounded,
                                                buttonBg: buttonBg,
                                                borderColor: borderColor,
                                                onTap: () => _adjustMinutes(1),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Seconds Stepper (+/- 5s)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: subCardBg,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'SECONDS',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.6,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                '+/- 5s',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStepperButton(
                                                context: context,
                                                icon: Icons.remove_rounded,
                                                buttonBg: buttonBg,
                                                borderColor: borderColor,
                                                onTap: () =>
                                                    _adjustSeconds(-5),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: _buildStepperButton(
                                                context: context,
                                                icon: Icons.add_rounded,
                                                buttonBg: buttonBg,
                                                borderColor: borderColor,
                                                onTap: () =>
                                                    _adjustSeconds(5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Lower Row: Quick Delta Nudge Chips
                            Container(
                              padding: const EdgeInsets.only(top: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: borderColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildNudgeChip(
                                      context: context,
                                      label: '-30s',
                                      isPositive: false,
                                      subCardBg: subCardBg,
                                      borderColor: borderColor,
                                      onTap: () => _adjustSeconds(-30),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildNudgeChip(
                                      context: context,
                                      label: '-15s',
                                      isPositive: false,
                                      subCardBg: subCardBg,
                                      borderColor: borderColor,
                                      onTap: () => _adjustSeconds(-15),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildNudgeChip(
                                      context: context,
                                      label: '+15s',
                                      isPositive: true,
                                      subCardBg: subCardBg,
                                      borderColor: borderColor,
                                      onTap: () => _adjustSeconds(15),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildNudgeChip(
                                      context: context,
                                      label: '+30s',
                                      isPositive: true,
                                      subCardBg: subCardBg,
                                      borderColor: borderColor,
                                      onTap: () => _adjustSeconds(30),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 2. Quick Presets Grid ───────────────────────────────────
                Row(
                  children: [
                    Text(
                      'QUICK PRESETS',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isLight
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFF222B38),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '8',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Compact Presets: Row 1
                Row(
                  children: [
                    for (int i = 0; i < 4; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _buildPresetCard(
                          preset: _presets[i],
                          cardBg: cardBg,
                          borderColor: borderColor,
                          colorScheme: colorScheme,
                          isLight: isLight,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Compact Presets: Row 2
                Row(
                  children: [
                    for (int i = 4; i < 8; i++) ...[
                      if (i > 4) const SizedBox(width: 8),
                      Expanded(
                        child: _buildPresetCard(
                          preset: _presets[i],
                          cardBg: cardBg,
                          borderColor: borderColor,
                          colorScheme: colorScheme,
                          isLight: isLight,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 18),

                // ── 3. Science Note Card ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: isLight ? 0.08 : 0.14,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb_rounded,
                          size: 13,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              height: 1.45,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                text: 'Science Note: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '60–90s maximizes metabolic stress & hypertrophy, while heavy multi-joint lifts (Squat, Deadlift) benefit from 2–3+ mins for central nervous recovery.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Sticky Action Buttons ──────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: sheetBg,
              border: Border(
                top: BorderSide(
                  color: borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _handleSave,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Save Rest Timer ($_formattedTime)',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Cancel and Keep Existing',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard({
    required String preset,
    required Color cardBg,
    required Color borderColor,
    required ColorScheme colorScheme,
    required bool isLight,
  }) {
    final isSelected = preset == _formattedTime;
    return InkWell(
      onTap: () => _selectPreset(preset),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(
                  alpha: isLight ? 0.12 : 0.18,
                )
              : cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                      alpha: 0.25,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Center(
              child: Text(
                preset,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w800 : FontWeight.w600,
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperButton({
    required BuildContext context,
    required IconData icon,
    required Color buttonBg,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: buttonBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Icon(
          icon,
          size: 18,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildNudgeChip({
    required BuildContext context,
    required String label,
    required bool isPositive,
    required Color subCardBg,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPositive
              ? colorScheme.primary.withValues(alpha: 0.12)
              : subCardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPositive
                ? colorScheme.primary.withValues(alpha: 0.3)
                : borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isPositive ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Custom circular timer gauge painter.
class _TimerGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _TimerGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
