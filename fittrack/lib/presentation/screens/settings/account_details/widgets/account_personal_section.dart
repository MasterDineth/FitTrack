import 'package:flutter/material.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';
import 'package:fittrack/presentation/widgets/modals/dob_picker_modal.dart';

/// Personal Information Section for Account Details.
///
/// Features:
/// - Editable Full Name input field with badge icon
/// - Date of Birth input field with dynamic Max HR zone calculation
///   and custom cylinder roller date picker (`DobPickerModal`).
class AccountPersonalSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dobController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<DateTime> onDobChanged;

  const AccountPersonalSection({
    super.key,
    required this.nameController,
    required this.dobController,
    required this.onNameChanged,
    required this.onDobChanged,
  });

  Future<void> _openDatePicker(BuildContext context) async {
    final parsed = DobPickerModal.parseDate(dobController.text);
    final picked = await DobPickerModal.show(
      context: context,
      initialDate: parsed,
    );

    if (picked != null) {
      final formatted = DobPickerModal.formatDate(picked);
      dobController.text = formatted;
      onDobChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final primary = context.ftPrimary;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    final roseColor = const Color(0xFFF43F5E);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.60);

    // Calculate Max HR Zone
    final parsedDob = DobPickerModal.parseDate(dobController.text);
    final maxHr = parsedDob != null
        ? DobPickerModal.calculateMaxHeartRate(parsedDob)
        : 198;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERSONAL',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: muted,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Required fields',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '*',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: roseColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Frosted Card Container ─────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: FtGlassTheme.cardDecoration(
            context,
            radius: 24,
            settings: settings,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Field 1: Full Name ───────────────────────────────────
              Row(
                children: [
                  Text(
                    'Full name',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '*',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: roseColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        onChanged: onNameChanged,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: muted.withValues(alpha: 0.5),
                          ),
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.badge_rounded,
                      size: 19,
                      color: muted.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Shown on your public profile & leaderboard',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: muted,
                ),
              ),
              const SizedBox(height: 14),

              Divider(height: 1, thickness: 1, color: dividerColor),
              const SizedBox(height: 14),

              // ── Field 2: Date of Birth ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Date of birth',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '*',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: roseColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Max HR Zone: $maxHr bpm',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FtPressable(
                onTap: () => _openDatePicker(context),
                pressedScale: 0.99,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dobController.text.isNotEmpty
                              ? dobController.text
                              : 'Select date of birth',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: dobController.text.isNotEmpty
                                ? ink
                                : muted.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 20,
                        color: primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Used to calculate target cardiovascular zones',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
