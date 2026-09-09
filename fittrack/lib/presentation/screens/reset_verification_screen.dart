import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/ft_primary_button.dart';

/// FitTrack – Reset Password Verification Screen.
///
/// User enters their email to request a reset code, then inputs the 6-digit OTP.
/// Navigates to [SetNewPasswordScreen] on successful verification.
class ResetVerificationScreen extends StatefulWidget {
  const ResetVerificationScreen({super.key});

  @override
  State<ResetVerificationScreen> createState() =>
      _ResetVerificationScreenState();
}

class _ResetVerificationScreenState extends State<ResetVerificationScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _codeSent = false;
  bool _isLoading = false;

  // Countdown timer state
  int _expirySeconds = 9 * 60 + 15; // 09:15
  int _resendSeconds = 45;
  Timer? _expiryTimer;
  Timer? _resendTimer;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _expiryTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startTimers() {
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_expirySeconds > 0) {
        setState(() => _expirySeconds--);
      } else {
        _expiryTimer?.cancel();
      }
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  void _sendCode() {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() {
      _codeSent = true;
      _expirySeconds = 9 * 60 + 15;
      _resendSeconds = 45;
    });
    _startTimers();
  }

  Future<void> _verify() async {
    if (_codeCtrl.text.length != 6) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) context.push('/reset/new-password');
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Nav bar ────────────────────────────────────────────────
              Row(
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
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.slateDark.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.slate800),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          AppColors.kineticMint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
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
                          'SECURE CHANNEL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: AppColors.slate600,
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
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.slateDark.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.help_outline_rounded,
                        size: 18, color: AppColors.slate500),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Shield icon header ────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.slateDark.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF006C46),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.kineticMint
                                        .withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: _PingBadge(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Verify Reset Code',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: AppColors.slateDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "We've sent a 6-digit verification code to your registered email address.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.slate500,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Email + Send Code ─────────────────────────────────────
              const Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slateDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. alex.trainer@fittrack.io',
                        hintStyle: const TextStyle(
                          color: AppColors.slate400,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(Icons.mail_outline_rounded,
                            size: 18, color: AppColors.slate400),
                        filled: true,
                        fillColor: AppColors.cardWhite,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.slate200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.slate200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.kineticMint, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendCode,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006C46),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.kineticMint.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Send Code',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── 6-Digit OTP ───────────────────────────────────────────
              if (_codeSent) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '6-Digit Code',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slateDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 13, color: AppColors.kineticMint),
                          const SizedBox(width: 4),
                          Text(
                            'Expires in ${_formatTime(_expirySeconds)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _OtpField(controller: _codeCtrl),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Didn't receive code?",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                      ),
                    ),
                    GestureDetector(
                      onTap: _resendSeconds == 0 ? _sendCode : null,
                      child: Text(
                        _resendSeconds > 0
                            ? 'Resend Code (${_resendSeconds}s)'
                            : 'Resend Code',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _resendSeconds > 0
                              ? AppColors.slate400
                              : AppColors.kineticMint,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Verify CTA
                FtPrimaryButton(
                  label: 'Reset Password',
                  isLoading: _isLoading,
                  trailingIcon: const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.slateDark, size: 18),
                  onPressed: _isLoading ? null : _verify,
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/auth'),
                      child: const Text(
                        'Return to Sign In',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.slate300,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Contact Support',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Prompt to send code
                Center(
                  child: Text(
                    'Enter your email above and tap "Send Code"',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.slate400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => context.go('/auth'),
                  child: const Center(
                    child: Text(
                      '← Return to Sign In',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.slate600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpField extends StatefulWidget {
  const _OtpField({required this.controller});
  final TextEditingController controller;

  @override
  State<_OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<_OtpField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: 14,
        color: AppColors.slateDark,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: '——————',
        hintStyle: const TextStyle(
          color: AppColors.slate300,
          letterSpacing: 10,
          fontSize: 20,
        ),
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.kineticMint, width: 2),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}

class _PingBadge extends StatefulWidget {
  @override
  State<_PingBadge> createState() => _PingBadgeState();
}

class _PingBadgeState extends State<_PingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Transform.scale(
              scale: 1 + _c.value,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kineticMint
                      .withValues(alpha: 0.75 * (1 - _c.value)),
                ),
              ),
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kineticMint,
            ),
          ),
        ],
      ),
    );
  }
}
