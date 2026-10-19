import 'package:flutter/material.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';

/// Contact Details Section for Account Details screen.
///
/// Features:
/// - Mobile number with Country Code (+94 Sri Lanka), Verification badge, and Verify trigger
/// - Address with location pin action
class AccountContactSection extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final bool isPhoneVerified;
  final VoidCallback onVerifyPhone;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onAddressChanged;

  const AccountContactSection({
    super.key,
    required this.phoneController,
    required this.addressController,
    required this.isPhoneVerified,
    required this.onVerifyPhone,
    required this.onPhoneChanged,
    required this.onAddressChanged,
  });

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

    final badgeColor =
        isPhoneVerified ? const Color(0xFF059669) : const Color(0xFFD97706);
    final badgeBg =
        isPhoneVerified ? const Color(0x2010B981) : const Color(0x20F59E0B);
    final badgeLabel = isPhoneVerified ? 'Verified' : 'Unverified';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Text(
            'CONTACT',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: muted,
            ),
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
              // ── Field 1: Mobile Number ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Mobile number',
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: badgeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              badgeLabel,
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isPhoneVerified) ...[
                        const SizedBox(width: 8),
                        FtPressable(
                          onTap: onVerifyPhone,
                          child: Text(
                            'Verify',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Country Code + Phone Input Well
              // Country Code + Phone Input Field (Full Card)
              TextField(
                controller: phoneController,
                onChanged: onPhoneChanged,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.70),
                  hintText: '77 123 4567',
                  hintStyle: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: muted.withValues(alpha: 0.5),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇱🇰', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '+94',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: ink,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.expand_more_rounded,
                                size: 15,
                                color: muted,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 20,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ],
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Used for two-factor authentication and recovery',
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

              // ── Field 2: Address ─────────────────────────────────────
              Row(
                children: [
                  Text(
                    'Address',
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
              TextField(
                controller: addressController,
                onChanged: onAddressChanged,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.70),
                  hintText: 'Enter your residential address',
                  hintStyle: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: muted.withValues(alpha: 0.5),
                  ),
                  suffixIcon: Icon(
                    Icons.location_on_rounded,
                    size: 20,
                    color: primary,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Used for local gym and partner facility matching',
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
