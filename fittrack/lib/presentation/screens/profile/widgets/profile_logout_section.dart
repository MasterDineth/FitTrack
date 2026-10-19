import 'package:flutter/material.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';
import 'package:fittrack/presentation/widgets/modals/discard_changes_dialog.dart';

/// Bottom Actions & Version Footer for the Profile Screen.
///
/// Features:
/// - Frosted Rose Log out button with confirmation dialog
/// - Version brand footer ("FitTrack v1.4.2")
class ProfileLogoutSection extends StatelessWidget {
  const ProfileLogoutSection({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await DiscardChangesDialog.show(
      context,
      title: 'Sign out?',
      message: 'Are you sure you want to sign out of your FitTrack account?',
      confirmLabel: 'Sign out',
      cancelLabel: 'Stay signed in',
      icon: Icons.logout_rounded,
    );

    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Signed out of FitTrack session.',
            style: TextStyle(fontFamily: FtText.fontFamily),
          ),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final muted = context.ftMuted;

    final roseColor = const Color(0xFFF43F5E);
    final buttonBg = isDark
        ? const Color(0x28F43F5E)
        : const Color(0xFFFFF1F2).withValues(alpha: 0.85);
    final buttonBorder = isDark
        ? const Color(0x40F43F5E)
        : const Color(0xFFFECDD3).withValues(alpha: 0.70);

    return Column(
      children: [
        // ── Log Out Button ─────────────────────────────────────────────
        FtPressable(
          onTap: () => _handleLogout(context),
          pressedScale: 0.98,
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: buttonBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: buttonBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: roseColor.withValues(alpha: isDark ? 0.20 : 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 19,
                  color: roseColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Log out',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: roseColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // ── App Version ────────────────────────────────────────────────
        Text(
          'FitTrack v1.4.2',
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: muted.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
