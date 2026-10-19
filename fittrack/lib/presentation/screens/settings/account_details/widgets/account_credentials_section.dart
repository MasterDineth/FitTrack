import 'package:flutter/material.dart';
import 'package:fittrack/domain/entities/user_profile.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';

/// Locked Credentials Section for Account Details screen.
///
/// Displays immutable username and verified email address with support link.
class AccountCredentialsSection extends StatelessWidget {
  final UserProfile profile;

  const AccountCredentialsSection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final primary = context.ftPrimary;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    final rawName = profile.name.trim().isNotEmpty ? profile.name : 'athlete';
    final handle =
        '@${rawName.toLowerCase().replaceAll(RegExp(r'\s+'), '')}.fit';
    final email = profile.email?.isNotEmpty == true
        ? profile.email!
        : '${rawName.toLowerCase().replaceAll(RegExp(r'\s+'), '')}@fittrack.io';

    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.60);

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
                'LOCKED CREDENTIALS',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: muted,
                ),
              ),
              Icon(
                Icons.shield_rounded,
                size: 15,
                color: muted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Frosted Card Container ─────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: FtGlassTheme.cardDecoration(
            context,
            radius: 24,
            settings: settings,
          ),
          child: Column(
            children: [
              // ── Row 1: Username ──────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'USERNAME',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          handle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.black12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'FIXED',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Divider(height: 1, thickness: 1, color: dividerColor),
              const SizedBox(height: 12),

              // ── Row 2: Email ─────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6)
                          .withValues(alpha: isDark ? 0.20 : 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      size: 18,
                      color: Color(0xFF14B8A6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'EMAIL',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x2010B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF059669),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Verified',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Contact Support Footnote ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'To change these credentials, ',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: muted,
                ),
              ),
              FtPressable(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Contacting support at support@fittrack.io',
                        style: TextStyle(fontFamily: FtText.fontFamily),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: Text(
                  'contact support',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primary,
                    decoration: TextDecoration.underline,
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
