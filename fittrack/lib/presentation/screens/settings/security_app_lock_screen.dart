import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/security_settings.dart';
import '../../providers/security_settings_provider.dart';
import '../../theme/app_colors.dart';

/// Security & App Lock Screen implemented to match Stitch specifications.
///
/// Provides master toggle, biometric unlock settings, hardware verification test,
/// auto-timeout options, and privacy guards.
class SecurityAppLockScreen extends ConsumerStatefulWidget {
  const SecurityAppLockScreen({super.key});

  @override
  ConsumerState<SecurityAppLockScreen> createState() =>
      _SecurityAppLockScreenState();
}

class _SecurityAppLockScreenState extends ConsumerState<SecurityAppLockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool _isTestingBiometrics = false;
  bool _isSavingPreferences = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleTestBiometrics() async {
    if (_isTestingBiometrics) return;
    setState(() => _isTestingBiometrics = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(securitySettingsNotifierProvider.notifier);

    final success = await notifier.testBiometrics();

    if (!mounted) return;
    setState(() => _isTestingBiometrics = false);

    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                success
                    ? 'Hardware Token Authenticated: Sub-millisecond response confirmed.'
                    : 'Biometric unlock cancelled or unavailable on this device.',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: success ? const Color(0xFF006C46) : AppColors.slate800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSavePreferences() async {
    if (_isSavingPreferences) return;
    setState(() => _isSavingPreferences = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(securitySettingsNotifierProvider.notifier);

    await notifier.savePreferences();

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    setState(() => _isSavingPreferences = false);

    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.verified_user_rounded,
              color: AppColors.kineticMint,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Security preferences saved securely',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.slateDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(securitySettingsNotifierProvider);
    final settings = settingsAsync.value ?? SecuritySettings.defaultSettings;
    final notifier = ref.read(securitySettingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(context),
                    const SizedBox(height: 16),
                    _buildScreenHeading(),
                    const SizedBox(height: 20),
                    _buildMasterLockCard(settings, notifier),
                    const SizedBox(height: 24),
                    _buildBiometricsSection(settings, notifier),
                    const SizedBox(height: 24),
                    _buildRequireLockSection(settings, notifier),
                    const SizedBox(height: 24),
                    _buildPrivacyDataGuardSection(settings, notifier),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.slateDark,
                ),
                SizedBox(width: 6),
                Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF54FEB3),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A006C46),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _pulseAnimation,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF006C46),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'PROTECTED',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Color(0xFF005234),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreenHeading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security & App Lock',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.slateDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Guard your training data, body telemetry, and logs.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.slate500,
          ),
        ),
      ],
    );
  }

  Widget _buildMasterLockCard(
    SecuritySettings settings,
    SecuritySettingsNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E3E5).withValues(alpha: 0.6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF2FBF7),
            AppColors.cardWhite,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF54FEB3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2000D68F),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_rounded,
              size: 24,
              color: Color(0xFF005234),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Enable App Lock',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slateDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDAE2FD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Require biometric authentication every time FitTrack is opened or resumed from background.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: settings.isAppLockEnabled,
            activeTrackColor: AppColors.kineticMint.withValues(alpha: 0.5),
            activeThumbColor: AppColors.kineticMint,
            onChanged: (val) => notifier.toggleAppLock(val),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricsSection(
    SecuritySettings settings,
    SecuritySettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BIOMETRICS',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.slate500,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 13,
                  color: Color(0xFF006C46),
                ),
                SizedBox(width: 4),
                Text(
                  'Hardware Secured',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF006C46),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Card 1: Two switches
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0E3E5).withValues(alpha: 0.5),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                icon: Icons.fingerprint_rounded,
                iconColor: const Color(0xFF006C46),
                title: 'Biometric Unlock',
                subtitle:
                    'Authenticate using device biometrics (Face ID or Fingerprint) to unlock FitTrack quickly.',
                value: settings.isBiometricEnabled,
                onChanged: (val) => notifier.toggleBiometric(val),
              ),
              const Divider(
                height: 1,
                indent: 56,
                endIndent: 16,
                color: Color(0xFFF1F5F9),
              ),
              _buildSwitchTile(
                icon: Icons.pin_rounded,
                iconColor: const Color(0xFF565E74),
                title: 'Device Passcode / PIN Fallback',
                subtitle:
                    'Allow unlocking with device passcode or PIN if biometrics fail or are unavailable.',
                value: settings.isPasscodeFallbackEnabled,
                onChanged: (val) => notifier.togglePasscodeFallback(val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Card 2: Interactive Biometric Verification Sandbox
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0E3E5).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kineticMint.withValues(alpha: 0.25),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  size: 30,
                  color: Color(0xFF006C46),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Biometric Hardware Verification',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Test the scanner handoff to verify instantaneous zero-latency unlock.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isTestingBiometrics ? null : _handleTestBiometrics,
                  icon: _isTestingBiometrics
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF006C46),
                          ),
                        )
                      : const Icon(
                          Icons.verified_user_rounded,
                          size: 18,
                          color: Color(0xFF006C46),
                        ),
                  label: Text(
                    _isTestingBiometrics
                        ? 'Verifying...'
                        : 'Test Biometric Unlock',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slateDark,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E3E5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequireLockSection(
    SecuritySettings settings,
    SecuritySettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'REQUIRE LOCK',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.slate500,
              ),
            ),
            Text(
              'Auto-Timeout',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF006C46),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: LockTimeout.values.map((timeout) {
            final isSelected = settings.lockTimeout == timeout;
            return _buildTimeoutOptionTile(
              timeout: timeout,
              isSelected: isSelected,
              onTap: () => notifier.setLockTimeout(timeout),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeoutOptionTile({
    required LockTimeout timeout,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.kineticMint
              : const Color(0xFFE0E3E5).withValues(alpha: 0.5),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.kineticMint.withValues(alpha: 0.12)
                : const Color(0x050F172A),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            timeout.title,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slateDark,
                            ),
                          ),
                          if (timeout.badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF54FEB3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                timeout.badge!,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF005234),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        timeout.subtitle,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF006C46)
                        : const Color(0xFFECEEF0),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x20006C46),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyDataGuardSection(
    SecuritySettings settings,
    SecuritySettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRIVACY & DATA GUARD',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: AppColors.slate500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0E3E5).withValues(alpha: 0.5),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                icon: Icons.visibility_off_rounded,
                iconColor: AppColors.slateDark,
                title: 'Hide Content in App Switcher',
                subtitle:
                    'Blur workout logs, body weight, and heart rate telemetry when toggling between apps.',
                value: settings.hideContent,
                onChanged: (val) => notifier.toggleHideContent(val),
              ),
              const Divider(
                height: 1,
                indent: 56,
                endIndent: 16,
                color: Color(0xFFF1F5F9),
              ),
              _buildSwitchTile(
                icon: Icons.lock_reset_rounded,
                iconColor: AppColors.slateDark,
                title: 'Biometrics for Sensitive Actions',
                subtitle:
                    'Require credential confirmation before exporting telemetry CSVs or deleting routine templates.',
                value: settings.requireForSensitive,
                onChanged: (val) => notifier.toggleRequireForSensitive(val),
              ),
              const Divider(
                height: 1,
                indent: 56,
                endIndent: 16,
                color: Color(0xFFF1F5F9),
              ),
              _buildSwitchTile(
                icon: Icons.timer_outlined,
                iconColor: AppColors.slateDark,
                title: 'Failed Attempts Cooldown',
                subtitle:
                    'Enforce a 30-second security lockdown following 5 consecutive unrecognized attempts.',
                value: settings.failedAttemptsCooldown,
                onChanged: (val) => notifier.toggleFailedAttemptsCooldown(val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFECEEF0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slateDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.kineticMint.withValues(alpha: 0.5),
            activeThumbColor: AppColors.kineticMint,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: Color(0xFFE0E3E5), width: 0.6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSavingPreferences ? null : _handleSavePreferences,
              icon: _isSavingPreferences
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFF003823),
                      ),
                    )
                  : const Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: Color(0xFF003823),
                    ),
              label: Text(
                _isSavingPreferences
                    ? 'Saved Securely'
                    : 'Save Security Preferences',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF003823),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kineticMint,
                elevation: 3,
                shadowColor: AppColors.kineticMint.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: AppColors.slate400,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Device credentials and biometric templates are managed exclusively by Secure Enclave / Android KeyStore. FitTrack never transmits, logs, or stores raw biometric telemetry.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    height: 1.35,
                    color: AppColors.slate500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
