import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../theme/ft_glass.dart';
import '../../screens/dashboard/widgets/ft_pressable.dart';
import '../glass_surface.dart';
import 'modal_backdrop_helper.dart';

/// Custom Frosted Date Roller / Cylinder Picker Modal for Date of Birth.
///
/// Features:
/// - Smooth 3-column roller (Month, Day, Year) with haptic feedback
/// - Year range from 1920 to current year
/// - Dynamic day calculation (28, 29, 30, or 31 days) including accurate leap year detection
/// - Frosted glass container, highlight selection capsule, and top/bottom gradient vignettes
/// - Helper methods for formatted string display and age / cardio zone calculations
class DobPickerModal extends StatefulWidget {
  final DateTime initialDate;
  final int minYear;
  final int maxYear;

  const DobPickerModal({
    super.key,
    required this.initialDate,
    this.minYear = 1920,
    required this.maxYear,
  });

  /// Presents the frosted cylinder date picker modal.
  /// Returns the selected [DateTime] or null if canceled.
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    int minYear = 1920,
    int? maxYear,
  }) {
    final effectiveMaxYear = maxYear ?? DateTime.now().year;
    final fallbackDate = DateTime(2003, 10, 14);
    final effectiveInitial = initialDate ?? fallbackDate;

    final clampedInitial = effectiveInitial.isAfter(DateTime(effectiveMaxYear, 12, 31))
        ? DateTime(effectiveMaxYear, 12, 31)
        : (effectiveInitial.isBefore(DateTime(minYear, 1, 1))
            ? DateTime(minYear, 1, 1)
            : effectiveInitial);

    return showBlurBottomSheet<DateTime>(
      context: context,
      child: DobPickerModal(
        initialDate: clampedInitial,
        minYear: minYear,
        maxYear: effectiveMaxYear,
      ),
    );
  }

  /// Formats date to user-friendly string (e.g. "14 Oct 2003").
  static String formatDate(DateTime dt) {
    return DateFormat('d MMM yyyy').format(dt);
  }

  /// Calculates athlete age in full years from date of birth.
  static int calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age.clamp(0, 120);
  }

  /// Calculates max heart rate estimation (220 - age) bpm.
  static int calculateMaxHeartRate(DateTime dob) {
    final age = calculateAge(dob);
    return (220 - age).clamp(100, 220);
  }

  /// Parses date string into DateTime (supports "14 Oct 2003", "14 Mar 2004", ISO-8601).
  static DateTime? parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return DateFormat('d MMM yyyy').parse(raw.trim());
    } catch (_) {
      try {
        return DateTime.parse(raw.trim());
      } catch (_) {
        return null;
      }
    }
  }

  @override
  State<DobPickerModal> createState() => _DobPickerModalState();
}

class _DobPickerModalState extends State<DobPickerModal> {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late int _selectedYear;
  late int _selectedMonth; // 1-12
  late int _selectedDay; // 1-31

  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;

  static const double _itemExtent = 46.0;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;

    final initialMonthIndex = _selectedMonth - 1;
    final initialDayIndex = _selectedDay - 1;
    final initialYearIndex = _selectedYear - widget.minYear;

    _monthController =
        FixedExtentScrollController(initialItem: initialMonthIndex);
    _dayController = FixedExtentScrollController(initialItem: initialDayIndex);
    _yearController =
        FixedExtentScrollController(initialItem: initialYearIndex);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  /// Returns the maximum days in the given month and year (accurate for leap years).
  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      final isLeap =
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeap ? 29 : 28;
    }
    const thirtyDayMonths = [4, 6, 9, 11];
    if (thirtyDayMonths.contains(month)) {
      return 30;
    }
    return 31;
  }

  void _onMonthChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMonth = index + 1;
      final maxDays = _getDaysInMonth(_selectedYear, _selectedMonth);
      if (_selectedDay > maxDays) {
        _selectedDay = maxDays;
        _dayController.jumpToItem(maxDays - 1);
      }
    });
  }

  void _onYearChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedYear = widget.minYear + index;
      final maxDays = _getDaysInMonth(_selectedYear, _selectedMonth);
      if (_selectedDay > maxDays) {
        _selectedDay = maxDays;
        _dayController.jumpToItem(maxDays - 1);
      }
    });
  }

  void _onDayChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDay = index + 1;
    });
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    final result = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final primary = context.ftPrimary;
    final totalYears = (widget.maxYear - widget.minYear) + 1;
    final maxDays = _getDaysInMonth(_selectedYear, _selectedMonth);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final settings = FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;
    final blurIntensity = settings?.blurIntensity ?? 16.0;
    final double t = enableTransparency
        ? ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0)
        : 1.0;

    final vignetteColor = !enableTransparency
        ? (isDark ? const Color(0xFF241D3B) : const Color(0xFFF8FAFC))
        : (isDark
            ? const Color(0xFF161226).withValues(alpha: (0.60 + 0.20 * t).clamp(0.40, 0.90))
            : Colors.white.withValues(alpha: (0.60 + 0.25 * t).clamp(0.45, 0.90)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: GlassSurface(
        tier: FtGlassTier.glass1,
        radius: 32,
        backdrop: GlassBackdrop.live,
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag Handle ──────────────────────────────────────────────
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

              // ── Header Title & Subtitle ──────────────────────────────────
              Text(
                'Select Date of Birth',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Used to calculate personalized fitness metrics & HR zones.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: muted,
                ),
              ),
              const SizedBox(height: 18),

              // ── 3-Column Roller Cylinder Container ───────────────────────
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: !enableTransparency
                      ? (isDark ? const Color(0xFF241D3B) : const Color(0xFFF8FAFC))
                      : (isDark
                          ? Colors.white.withValues(
                              alpha: (0.04 + 0.04 * t).clamp(0.03, 0.10))
                          : Colors.black.withValues(
                              alpha: (0.03 + 0.03 * t).clamp(0.02, 0.08))),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: !enableTransparency
                        ? (isDark ? Colors.white12 : const Color(0xFFE2E8F0))
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06)),
                  ),
                ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection Highlight Capsule Bar
                Positioned(
                  left: 10,
                  right: 10,
                  child: Container(
                    height: _itemExtent,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: isDark ? 0.22 : 0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primary.withValues(alpha: isDark ? 0.40 : 0.25),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                // 3 Picker Columns: Month, Day, Year
                Row(
                  children: [
                    // Month Picker
                    Expanded(
                      flex: 4,
                      child: CupertinoPicker(
                        scrollController: _monthController,
                        itemExtent: _itemExtent,
                        selectionOverlay: const SizedBox.shrink(),
                        squeeze: 1.15,
                        diameterRatio: 1.25,
                        onSelectedItemChanged: _onMonthChanged,
                        children: List.generate(_months.length, (i) {
                          final isSelected = (i + 1) == _selectedMonth;
                          return Center(
                            child: Text(
                              _months[i],
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: isSelected ? 18 : 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isSelected
                                    ? primary
                                    : (isDark ? Colors.white60 : Colors.black54),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Day Picker
                    Expanded(
                      flex: 3,
                      child: CupertinoPicker(
                        scrollController: _dayController,
                        itemExtent: _itemExtent,
                        selectionOverlay: const SizedBox.shrink(),
                        squeeze: 1.15,
                        diameterRatio: 1.25,
                        onSelectedItemChanged: _onDayChanged,
                        children: List.generate(maxDays, (i) {
                          final dayNum = i + 1;
                          final isSelected = dayNum == _selectedDay;
                          return Center(
                            child: Text(
                              dayNum.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: isSelected ? 18 : 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isSelected
                                    ? primary
                                    : (isDark ? Colors.white60 : Colors.black54),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Year Picker
                    Expanded(
                      flex: 4,
                      child: CupertinoPicker(
                        scrollController: _yearController,
                        itemExtent: _itemExtent,
                        selectionOverlay: const SizedBox.shrink(),
                        squeeze: 1.15,
                        diameterRatio: 1.25,
                        onSelectedItemChanged: _onYearChanged,
                        children: List.generate(totalYears, (i) {
                          final year = widget.minYear + i;
                          final isSelected = year == _selectedYear;
                          return Center(
                            child: Text(
                              year.toString(),
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: isSelected ? 18 : 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isSelected
                                    ? primary
                                    : (isDark ? Colors.white60 : Colors.black54),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),

                // Top Vignette Mask
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 48,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            vignetteColor,
                            vignetteColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Vignette Mask
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 48,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            vignetteColor,
                            vignetteColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Action Buttons ───────────────────────────────────────────
          FtPressable(
            onTap: _confirm,
            pressedScale: 0.98,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary,
                    primary.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Confirm Date',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Cancel Ghost Button
          FtPressable(
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: muted,
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
