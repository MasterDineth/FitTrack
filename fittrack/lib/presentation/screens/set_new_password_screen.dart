import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
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

  Color get _strengthColor {
    return switch (_strengthScore) {
      0 || 1 => AppColors.errorRed,
      2 => const Color(0xFFD97706),
      3 => const Color(0xFF2563EB),
      _ => AppColors.kineticMint,
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
    return Scaffold(
      backgroundColor: AppColors.surface,
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
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.slateDark.withValues(alpha: 0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.slate700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                          color: const Color(0xFFD1FAE5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.kineticMint,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'SECURITY VERIFIED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: const Icon(Icons.help_outline_rounded,
                        size: 18, color: AppColors.slate500),
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
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF005B41),
                                      Color(0xFF00AA72),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.kineticMint
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.white,
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
                                color: AppColors.kineticMint,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.check,
                                  size: 11, color: AppColors.slateDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Create New Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppColors.slateDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Your identity has been verified. Choose a strong, unique '
                        'password to secure your workout profile.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate500,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── New Password ──────────────────────────────────
                    _PasswordLabel('New Password'),
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
                          const Text(
                            'Strength:',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _strengthColor,
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
                                    ? _strengthColor
                                    : AppColors.slate200,
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
                    _PasswordLabel('Confirm New Password'),
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
                                ? AppColors.kineticMint
                                : AppColors.errorRed,
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
                                  ? const Color(0xFF047857)
                                  : AppColors.errorRed,
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
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.slate200),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.slateDark.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SECURITY CRITERIA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: AppColors.slate400,
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
                            activeColor: AppColors.kineticMint,
                            checkColor: AppColors.slateDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (v) =>
                                setState(() => _signOutDevices = v ?? true),
                          ),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                'Sign out of all other active sessions and devices',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.slate600,
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
                    AppColors.surface.withValues(alpha: 0),
                    AppColors.surface,
                  ],
                ),
              ),
              child: Column(
                children: [
                  FtPrimaryButton(
                    label: 'Save & Update Password',
                    isLoading: _isLoading,
                    trailingIcon: const Icon(Icons.arrow_forward_rounded,
                        color: AppColors.slateDark, size: 18),
                    onPressed: (_has8Chars && _passwordsMatch && !_isLoading)
                        ? _save
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Changed your mind?",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.go('/auth'),
                        child: const Text(
                          'Return to Sign In',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slateDark,
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppColors.slate700,
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
    return TextField(
      controller: controller,
      obscureText: !show,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.slateDark,
      ),
      decoration: InputDecoration(
        hintText: 'Enter password',
        hintStyle: const TextStyle(color: AppColors.slate300),
        prefixIcon: Icon(prefixIcon, size: 18, color: AppColors.slate400),
        suffixIcon: IconButton(
          icon: Icon(
            show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: AppColors.slate400,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kineticMint, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.kineticMint, width: 2),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 14,
            color: met ? AppColors.kineticMint : AppColors.slate300,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: met ? const Color(0xFF065F46) : AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}
