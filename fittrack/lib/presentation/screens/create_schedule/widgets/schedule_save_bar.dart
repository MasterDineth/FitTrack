import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Floating Save Panel docked above the bottom navigation dock.
/// Matching Stitch Screen ID 378f56a0b632436289e53841eb67b6fb.
class ScheduleSaveBar extends StatelessWidget {
  const ScheduleSaveBar({
    super.key,
    required this.isValid,
    required this.isSaving,
    required this.validationMessage,
    required this.onSave,
  });

  final bool isValid;
  final bool isSaving;
  final String? validationMessage;
  final VoidCallback onSave;

  void _handleTap(BuildContext context) {
    if (isSaving) return;
    if (!isValid) {
      final msg = validationMessage ?? 'Please complete all required fields';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: const TextStyle(
              fontFamily: FtText.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: const Color(0xFFF43F5E),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }
    onSave();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 393),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xE61E1838)
                  : Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? const Color(0x33FFFFFF)
                    : Colors.white.withValues(alpha: 0.95),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: isDark ? 0.25 : 0.14),
                  blurRadius: 36,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: FtPressable(
              onTap: () => _handleTap(context),
              pressedScale: 0.98,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  gradient: isValid
                      ? LinearGradient(
                          colors: [
                            context.ftPrimaryLight,
                            primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isValid
                      ? null
                      : (isDark ? const Color(0x22FFFFFF) : const Color(0xFFECE4FF)),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isValid
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSaving)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else ...[
                      Icon(
                        Icons.check_circle_rounded,
                        size: 22,
                        color: isValid
                            ? Colors.white
                            : (isDark ? const Color(0x66FFFFFF) : const Color(0xFF797586)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Save schedule',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isValid
                              ? Colors.white
                              : (isDark ? const Color(0x66FFFFFF) : const Color(0xFF797586)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
