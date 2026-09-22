import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/security_provider.dart';
import '../../widgets/security_modals.dart';

/// Local private card decoration helper matching Stitch specifications.
BoxDecoration _buildCardDecoration(BuildContext context, {double radius = 16}) {
  final isLight = Theme.of(context).brightness == Brightness.light;
  final colorScheme = Theme.of(context).colorScheme;

  if (isLight) {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );
  } else {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: colorScheme.outline,
      ),
    );
  }
}

/// Change Password & Security History screen matching Stitch specifications.
///
/// Features live password strength analysis, interactive requirements checklist,
/// recent audit logs, and confirmation/success/failed bottom sheet flows.
class PasswordSecurityScreen extends ConsumerStatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  ConsumerState<PasswordSecurityScreen> createState() =>
      _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState
    extends ConsumerState<PasswordSecurityScreen> {
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _auditLogKey = GlobalKey();

  bool _showForgotHelper = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(securityNotifierProvider);
    _currentPasswordController =
        TextEditingController(text: state.currentPassword);
    _newPasswordController = TextEditingController(text: state.newPassword);
    _confirmPasswordController =
        TextEditingController(text: state.confirmPassword);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToAuditLog() {
    final context = _auditLogKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handleUpdatePassword() {
    final state = ref.read(securityNotifierProvider);
    final notifier = ref.read(securityNotifierProvider.notifier);

    // If current password is set to 'wrong', immediately demo the failed modal
    if (state.currentPassword.trim().toLowerCase() == 'wrong') {
      showPasswordFailedModal(
        context: context,
        onTryAgain: () {
          _currentPasswordController.clear();
          notifier.updateCurrentPassword('');
        },
        onForgotPassword: () {
          setState(() => _showForgotHelper = true);
        },
      );
      return;
    }

    // Open confirmation modal
    showPasswordConfirmationModal(
      context: context,
      targetAccount: 'dineth@fittrack.io',
      strengthScore: state.passwordStrength,
      onConfirm: () {
        // Record change and trigger success modal
        notifier.recordSuccessfulChange();
        showPasswordSuccessModal(
          context: context,
          onViewActivityLog: _scrollToAuditLog,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;
    final state = ref.watch(securityNotifierProvider);
    final notifier = ref.read(securityNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 56,
        titleSpacing: 12,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ACCOUNT SETTINGS',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Password & Security',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Card: "Strengthen Your Defense" ─────────────────────────
            Container(
              decoration: _buildCardDecoration(context, radius: 16),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Strengthen Your Defense',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Lightweight pulsing primary-colored dot
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.35, end: 1.0),
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeInOut,
                              builder: (context, opacity, child) {
                                return Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary
                                        .withValues(alpha: opacity),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep your workout milestones and biometric sync encrypted by refreshing your credentials regularly.',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Form Section: Current, New, Confirm Fields ──────────────────
            // 1. Current Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Password',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _showForgotHelper = !_showForgotHelper);
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _currentPasswordController,
                      obscureText: state.obscureCurrent,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter current password',
                        hintStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: notifier.updateCurrentPassword,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      state.obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: notifier.toggleObscureCurrent,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            if (_showForgotHelper) ...[
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'A recovery code will be dispatched to your registered primary email address.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // 2. New Password
            Text(
              'New Password',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.key_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _newPasswordController,
                      obscureText: state.obscureNew,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Create new password',
                        hintStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: notifier.updateNewPassword,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      state.obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: notifier.toggleObscureNew,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Password Strength Meter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Password Strength',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      if (state.passwordStrength >= 4) ...[
                        Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        state.strengthLabel,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: state.passwordStrength >= 3
                              ? colorScheme.primary
                              : (state.passwordStrength >= 2
                                  ? const Color(0xFFD97706)
                                  : (state.newPassword.isEmpty
                                      ? colorScheme.onSurfaceVariant
                                      : const Color(0xFFE11D48))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // 4-segment strength bar
            Row(
              children: List.generate(4, (index) {
                final isFilled = index < state.passwordStrength;
                return Expanded(
                  child: Container(
                    height: 5,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 3,
                      right: index == 3 ? 0 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: isFilled
                          ? (state.passwordStrength >= 4
                              ? colorScheme.primary
                              : (state.passwordStrength >= 2
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFF43F5E)))
                          : (isLight
                              ? const Color(0xFFE2E8F0)
                              : colorScheme.surfaceContainerHighest),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // 3. Confirm New Password
            Text(
              'Confirm New Password',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: state.obscureConfirm,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Re-enter new password',
                        hintStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: notifier.updateConfirmPassword,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      state.obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: notifier.toggleObscureConfirm,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            if (state.newPassword.isNotEmpty &&
                state.confirmPassword.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: state.passwordsMatch
                            ? colorScheme.primary
                            : const Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.passwordsMatch
                          ? '✓ Passwords match perfectly'
                          : 'Passwords do not match',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: state.passwordsMatch
                            ? colorScheme.primary
                            : const Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),

            // ── Live Security Standard Checklist Card ───────────────────────
            Container(
              decoration: _buildCardDecoration(context, radius: 16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Security Standard Checklist',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${state.passwordStrength} of 4 Met',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildChecklistItem(
                    context,
                    label: '8+ characters required',
                    isMet: state.hasMinLength,
                  ),
                  const SizedBox(height: 10),
                  _buildChecklistItem(
                    context,
                    label: 'Uppercase & lowercase letters',
                    isMet: state.hasUpperAndLower,
                  ),
                  const SizedBox(height: 10),
                  _buildChecklistItem(
                    context,
                    label: 'At least 1 numerical digit (0–9)',
                    isMet: state.hasNumber,
                  ),
                  const SizedBox(height: 10),
                  _buildChecklistItem(
                    context,
                    label: 'Special symbol (!@#\$%^&*)',
                    isMet: state.hasSymbol,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Primary Action Button ─────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _handleUpdatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.primary.computeLuminance() > 0.55
                      ? const Color(0xFF002112)
                      : Colors.white,
                  elevation: isLight ? 4 : 0,
                  shadowColor: isLight
                      ? colorScheme.primary.withValues(alpha: 0.4)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.published_with_changes_rounded,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Update Password',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Recent Security Activity (Audit Log) ─────────────────────────
            Container(
              key: _auditLogKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.manage_history_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recent Security Activity',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'AUDIT LOG',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Audit log list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.activities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final activity = state.activities[index];
                return _buildActivityCard(context, activity);
              },
            ),
            const SizedBox(height: 16),

            // ── Security Assistance / Help Footnote ───────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surface,
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Notice suspicious activity? ',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: 'Contact Support ↗',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(
    BuildContext context, {
    required String label,
    required bool isMet,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              size: 13,
              color: isMet
                  ? (colorScheme.primary.computeLuminance() > 0.55
                      ? const Color(0xFF002112)
                      : Colors.white)
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w500,
              color: isMet ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, dynamic activity) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    final isSuccess = activity.statusBadge == 'Successful';
    final isVerified = activity.statusBadge == 'Verified';

    final Color badgeBg;
    final Color badgeText;
    if (isSuccess) {
      badgeBg = colorScheme.primary.withValues(alpha: isLight ? 0.12 : 0.18);
      badgeText = colorScheme.primary;
    } else if (isVerified) {
      badgeBg = isLight
          ? const Color(0xFFEFF6FF)
          : const Color(0xFF1E3A8A).withValues(alpha: 0.35);
      badgeText =
          isLight ? const Color(0xFF1D4ED8) : const Color(0xFF93C5FD);
    } else {
      badgeBg = isLight
          ? const Color(0xFFF1F5F9)
          : colorScheme.surfaceContainer;
      badgeText = colorScheme.onSurfaceVariant;
    }

    final IconData eventIcon;
    if (activity.title.toString().contains('Reset')) {
      eventIcon = Icons.mark_email_read_rounded;
    } else if (activity.title.toString().contains('Two-Factor')) {
      eventIcon = Icons.shield_rounded;
    } else {
      eventIcon = Icons.password_rounded;
    }

    return Container(
      decoration: _buildCardDecoration(context, radius: 16),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  eventIcon,
                  size: 18,
                  color: isSuccess
                      ? colorScheme.primary
                      : (isVerified
                          ? const Color(0xFF2563EB)
                          : colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.timestamp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  activity.statusBadge,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  activity.deviceInfo.toString().contains('Chrome')
                      ? Icons.laptop_mac_rounded
                      : (activity.deviceInfo.toString().contains('Key')
                          ? Icons.phonelink_lock_rounded
                          : Icons.phone_iphone_rounded),
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    activity.location.toString().isEmpty
                        ? activity.deviceInfo
                        : '${activity.deviceInfo} • ${activity.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11.5,
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
}
