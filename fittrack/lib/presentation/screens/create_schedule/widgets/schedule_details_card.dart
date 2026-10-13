import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';

/// Details Section Card for Schedule Name and optional Description.
/// Matching Stitch Screen ID 378f56a0b632436289e53841eb67b6fb.
class ScheduleDetailsCard extends StatelessWidget {
  const ScheduleDetailsCard({
    super.key,
    required this.nameController,
    required this.descController,
    required this.onNameChanged,
    required this.onDescChanged,
  });

  final TextEditingController nameController;
  final TextEditingController descController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final settings = FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;

    final innerFill = enableTransparency
        ? (isDark ? const Color(0x18FFFFFF) : Colors.white.withValues(alpha: 0.60))
        : (isDark ? const Color(0xFF221C38) : const Color(0xFFF8F6FF));

    final innerBorder = enableTransparency
        ? (isDark ? const Color(0x22FFFFFF) : Colors.white.withValues(alpha: 0.85))
        : (isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: FtGlassTheme.cardDecoration(
        context,
        radius: 24,
        settings: settings,
        customShadows: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x22FFFFFF)
                      : const Color(0xFFE6DEFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  Text(
                    'Name and description',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Schedule Name Input Box (Stitch FormField style)
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: innerFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: innerBorder,
                width: 1,
              ),
              boxShadow: enableTransparency && !isDark
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SCHEDULE NAME',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: TextField(
                    controller: nameController,
                    onChanged: onNameChanged,
                    textInputAction: TextInputAction.next,
                    cursorColor: primary,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Push Hypertrophy A',
                      hintStyle: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: muted.withValues(alpha: 0.65),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Description Input Box (Stitch FormField style)
          Container(
            constraints: const BoxConstraints(minHeight: 96),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: innerFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: innerBorder,
                width: 1,
              ),
              boxShadow: enableTransparency && !isDark
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DESCRIPTION (OPTIONAL)',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: isDark ? const Color(0x99FFFFFF) : muted,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  onChanged: onDescChanged,
                  maxLines: 3,
                  minLines: 2,
                  cursorColor: primary,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ink,
                    height: 1.45,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Compound pressing followed by lateral deltoid work.',
                    hintStyle: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: muted.withValues(alpha: 0.65),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
