import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/ft_primary_button.dart';
import '../widgets/ft_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/ft_exit_confirmation.dart';
/// FitTrack Auth – Sign In & Sign Up Screen.
///
/// Uses a segmented tab switcher to toggle between Create Account and Sign In.
/// Calls [AuthNotifier.signIn] / [AuthNotifier.signUp] on submit.
/// GoRouter's redirect will handle navigation on successful auth.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignUp = true; // defaults to Create Account tab (from Stitch)

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
      return;
    }

    final notifier = ref.read(authProvider.notifier);

    if (_isSignUp) {
      if (_nameCtrl.text.trim().isEmpty) {
        setState(() => _errorMessage = 'Full name is required.');
        return;
      }
      if (password.length < 8) {
        setState(() => _errorMessage = 'Password must be at least 8 characters.');
        return;
      }
      if (password != _confirmPwdCtrl.text) {
        setState(() => _errorMessage = 'Passwords do not match.');
        return;
      }
      await notifier.signUp(email, password);
    } else {
      await notifier.signIn(email, password);
    }

    final authState = ref.read(authProvider);
    if (authState.hasError && mounted) {
      setState(() {
        _errorMessage = authState.error?.toString() ?? 'Authentication failed.';
      });
    }
    // GoRouter redirect will handle successful auth navigation.
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return FtExitConfirmation(
      child: Scaffold(
        backgroundColor: AppColors.cardWhite,
        body: SafeArea(
        child: Column(
          children: [
            // ── Navigation Bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.slate800),
                    onPressed: () => context.go('/welcome'),
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 8,
                        height: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.kineticMint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Step 2 of 4',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Help',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.slate400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // ── Brand header ──────────────────────────────────────
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00B87A),
                            Color(0xFF00F5A0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.kineticMint.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_run_rounded,
                        color: AppColors.slateDark,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Welcome to FitTrack',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.slateDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Sign in or create your profile to synchronize routines, '
                        'sets, and precision biometrics.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate600,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Tab switcher ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _Tab(
                            label: 'Create Account',
                            isActive: _isSignUp,
                            onTap: () => setState(() => _isSignUp = true),
                          ),
                          _Tab(
                            label: 'Sign In',
                            isActive: !_isSignUp,
                            onTap: () => setState(() => _isSignUp = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Social auth ───────────────────────────────────────
                    _SocialButton(
                      label: 'Continue with Apple',
                      backgroundColor: AppColors.slateDark,
                      textColor: Colors.white,
                      icon: const Icon(Icons.apple, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 10),
                    _SocialButton(
                      label: 'Continue with Google',
                      backgroundColor: AppColors.cardWhite,
                      textColor: AppColors.slate800,
                      borderColor: AppColors.slate200,
                      icon: _GoogleIcon(),
                    ),
                    const SizedBox(height: 16),

                    // ── Divider ───────────────────────────────────────────
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Divider(color: AppColors.slate200, thickness: 1),
                        Container(
                          color: AppColors.cardWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: const Text(
                            'or with email',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.slate400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Form ──────────────────────────────────────────────
                    if (_isSignUp) ...[
                      FtTextField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        placeholder: 'e.g. Dineth Jay',
                        prefixIcon: const Icon(Icons.person_outline_rounded,
                            size: 18, color: AppColors.slate400),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                    ],
                    FtTextField(
                      controller: _emailCtrl,
                      label: 'Email Address',
                      placeholder: 'you@fittrack.io',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline_rounded,
                          size: 18, color: AppColors.slate400),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    FtTextField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      placeholder: '••••••••',
                      obscureText: !_showPassword,
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          size: 18, color: AppColors.slate400),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.slate400,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                      helperText: 'Must be at least 8 characters long',
                      textInputAction: _isSignUp
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onSubmitted: _isSignUp ? null : (_) => _submit(),
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: 14),
                      FtTextField(
                        controller: _confirmPwdCtrl,
                        label: 'Confirm Password',
                        placeholder: 'Re-enter password',
                        obscureText: !_showConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            size: 18, color: AppColors.slate400),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.slate400,
                          ),
                          onPressed: () => setState(
                              () => _showConfirmPassword = !_showConfirmPassword),
                        ),
                        helperText: 'Passwords must match',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                    ],
                    if (!_isSignUp) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.push('/reset/verify'),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slateDark,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.slateDark,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // ── Error message ─────────────────────────────────────
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDED),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.errorRed.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // ── Submit ────────────────────────────────────────────
                    FtPrimaryButton(
                      label: _isSignUp ? 'Create Account' : 'Sign In',
                      isLoading: isLoading,
                      trailingIcon: isLoading
                          ? null
                          : const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.slateDark, size: 18),
                      onPressed: isLoading ? null : _submit,
                    ),
                    const SizedBox(height: 16),

                    // ── Guest / Terms ─────────────────────────────────────
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Explore first without account →',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "By continuing, you agree to FitTrack's Terms of Service & Privacy Policy.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.slate400,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? AppColors.cardWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.slateDark.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? AppColors.slateDark : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Widget icon;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor ?? Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: borderColor != null ? 0 : 1,
        ),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 22);
  }
}
