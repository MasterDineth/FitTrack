import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ft_primary_button.dart';

/// FitTrack – Set New Password Screen.
///
/// Provides new password + confirm with a strength meter and requirements checklist.
/// On success, navigates back to [AuthScreen].
class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  bool _showNew = false;
  bool _showConfirm = false;
  bool _signOutDevices = true;
  bool _isLoading = false;

  // Password validation criteria
  bool get _has8Chars => _newPwdCtrl.text.length >= 8;
  bool get _hasUpperLower =>
      _newPwdCtrl.text.contains(RegExp(r'[A-Z]')) &&
      _newPwdCtrl.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _newPwdCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _newPwdCtrl.text.contains(RegExp(r'[!@#\$&*~%^]'));
  bool get _passwordsMatch =>
      _newPwdCtrl.text.isNotEmpty &&
      _newPwdCtrl.text == _confirmPwdCtrl.text;

  int get _strengthScore => [
        _has8Chars,
        _hasUpperLower,
        _hasNumber,
        _hasSpecial,
      ].where((e) => e).length;

  String get _strengthLabel {
    return switch (_strengthScore) {
      0 || 1 => 'Weak',
      2 => 'Fair',
      3 => 'Good',
      _ => 'Strong',
    };
  }

  Color _getStrengthColor(ColorScheme colorScheme) {
    return switch (_strengthScore) {
      0 || 1 => colorScheme.error,
      2 => const Color(0xFFD97706),
      3 => const Color(0xFF2563EB),
      _ => colorScheme.primary,
    };
  }

  @override
  void dispose() {
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_has8Chars || !_passwordsMatch) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strengthColor = _getStrengthColor(colorScheme);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Nav bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SECURITY VERIFIED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ── Lock icon header ──────────────────────────────
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary,
                                      colorScheme.primary.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  color: colorScheme.onPrimary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: colorScheme.surface, width: 2),
                              ),
                              child: Icon(Icons.check,
                                  size: 11, color: colorScheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Create New Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Your identity has been verified. Choose a strong, unique '
                        'password to secure your workout profile.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── New Password ──────────────────────────────────
                    const _PasswordLabel('New Password'),
                    const SizedBox(height: 6),
                    _PwdField(
                      controller: _newPwdCtrl,
                      show: _showNew,
                      onToggle: () =>
                          setState(() => _showNew = !_showNew),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    // Strength meter
                    if (_newPwdCtrl.text.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Strength:',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: strengthColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(4, (i) {
                          return Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 5,
                              margin: EdgeInsets.only(right: i < 3 ? 5 : 0),
                              decoration: BoxDecoration(
                                color: i < _strengthScore
                                    ? strengthColor
                                    : colorScheme.outlineVariant,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                    ] else
                      const SizedBox(height: 14),

                    // ── Confirm Password ──────────────────────────────
                    const _PasswordLabel('Confirm New Password'),
                    const SizedBox(height: 6),
                    _PwdField(
                      controller: _confirmPwdCtrl,
                      show: _showConfirm,
                      onToggle: () =>
                          setState(() => _showConfirm = !_showConfirm),
                      onChanged: (_) => setState(() {}),
                      prefixIcon: Icons.security_rounded,
                    ),
                    if (_confirmPwdCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            _passwordsMatch
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 14,
                            color: _passwordsMatch
                                ? colorScheme.primary
                                : colorScheme.error,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _passwordsMatch
                                ? 'Passwords match perfectly'
                                : 'Passwords do not match',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _passwordsMatch
                                  ? colorScheme.primary
                                  : colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    // ── Requirements checklist ────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colorScheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SECURITY CRITERIA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _RequirementRow(
                              met: _has8Chars, label: '8+ characters'),
                          _RequirementRow(
                              met: _hasUpperLower,
                              label: 'Uppercase & lowercase'),
                          _RequirementRow(
                              met: _hasNumber, label: 'At least 1 number'),
                          _RequirementRow(
                              met: _hasSpecial,
                              label: 'Special character (!@#)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Sign out checkbox ─────────────────────────────
                    GestureDetector(
                      onTap: () =>
                          setState(() => _signOutDevices = !_signOutDevices),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _signOutDevices,
                            activeColor: colorScheme.primary,
                            checkColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (v) =>
                                setState(() => _signOutDevices = v ?? true),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Sign out of all other active sessions and devices',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
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
            ),

            // ── Sticky bottom CTA ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor.withValues(alpha: 0),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: Column(
                children: [
                  FtPrimaryButton(
                    label: 'Save & Update Password',
                    isLoading: _isLoading,
                    trailingIcon: Icon(
                      Icons.arrow_forward_rounded,
                      color: colorScheme.onPrimary,
                      size: 18,
                    ),
                    onPressed: (_has8Chars && _passwordsMatch && !_isLoading)
                        ? _save
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Changed your mind?",
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.go('/auth'),
                        child: Text(
                          'Return to Sign In',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordLabel extends StatelessWidget {
  const _PasswordLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _PwdField extends StatelessWidget {
  const _PwdField({
    required this.controller,
    required this.show,
    required this.onToggle,
    required this.onChanged,
    this.prefixIcon = Icons.lock_outline_rounded,
  });

  final TextEditingController controller;
  final bool show;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: !show,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Enter password',
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 18,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.label});
  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 14,
            color: met ? colorScheme.primary : colorScheme.outlineVariant,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: met
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
