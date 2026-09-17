import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/security_settings.dart';
import '../../providers/security_settings_provider.dart';

/// Security & App Lock Screen implemented to match Stitch specifications.
///
/// Provides master toggle, biometric unlock settings, hardware verification test,
/// auto-timeout options, privacy guards, and scrolling save action.
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
    final message = notifier.lastAuthMessage ??
        (success
            ? 'Hardware Token Authenticated: Sub-millisecond response confirmed.'
            : 'Biometric unlock cancelled or unavailable on this device.');

    if (!mounted) return;
    setState(() => _isTestingBiometrics = false);

    final colorScheme = Theme.of(context).colorScheme;
    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: success ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: success ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: success ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
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

    final colorScheme = Theme.of(context).colorScheme;
    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.verified_user_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Security preferences saved securely',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onInverseSurface,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.inverseSurface,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(context, settings),
              const SizedBox(height: 16),
              _buildScreenHeading(context),
              const SizedBox(height: 20),
              _buildMasterLockCard(context, settings, notifier),
              const SizedBox(height: 24),
              _buildBiometricsSection(context, settings, notifier),
              const SizedBox(height: 24),
              _buildRequireLockSection(context, settings, notifier),
              const SizedBox(height: 24),
              _buildPrivacyDataGuardSection(context, settings, notifier),
              const SizedBox(height: 28),
              _buildSaveAndComplianceCard(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, SecuritySettings settings) {
    final isLocked = settings.isAppLockEnabled;
    final colorScheme = Theme.of(context).colorScheme;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 6),
                Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isLocked ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isLocked
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLocked)
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                isLocked ? 'PROTECTED' : 'UNLOCKED',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isLocked ? colorScheme.onPrimaryContainer : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreenHeading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security & App Lock',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Guard your training data, body telemetry, and logs.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMasterLockCard(
    BuildContext context,
    SecuritySettings settings,
    SecuritySettingsNotifier notifier,
  ) {
    final isEnabled = settings.isAppLockEnabled;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: isEnabled
              ? [
                  colorScheme.primaryContainer.withValues(alpha: 0.25),
                  colorScheme.surface,
                ]
              : [
                  colorScheme.surface,
                  colorScheme.surface,
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
              color: isEnabled ? colorScheme.primary : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isEnabled ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: isEnabled ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use Wrap to eliminate horizontal layout overflow on narrow displays
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Enable App Lock',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isEnabled ? 'Active' : 'Disabled',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isEnabled
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Require biometric authentication every time FitTrack is opened or resumed from background.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    height: 1.4,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: settings.isAppLockEnabled,
            activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
            activeThumbColor: colorScheme.primary,
            onChanged: (val) => notifier.toggleAppLock(val),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricsSection(
    BuildContext context,
    SecuritySettings settings,
    SecuritySettingsNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BIOMETRICS',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 13,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hardware Secured',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Card 1: Two switches
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                context: context,
                icon: Icons.fingerprint_rounded,
                iconColor: colorScheme.primary,
                title: 'Biometric Unlock',
                subtitle:
                    'Authenticate using device biometrics (Face ID or Fingerprint) to unlock FitTrack quickly.',
                value: settings.isBiometricEnabled,
                onChanged: (val) => notifier.toggleBiometric(val),
              ),
              Divider(
                height: 1,
                indent: 56,
                endIndent: 16,
                color: colorScheme.outlineVariant,
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.pin_rounded,
                iconColor: colorScheme.onSurface.withValues(alpha: 0.7),
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
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.fingerprint_rounded,
                  size: 30,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Biometric Hardware Verification',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Test the scanner handoff to verify instantaneous zero-latency unlock.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isTestingBiometrics ? null : _handleTestBiometrics,
                  icon: _isTestingBiometrics
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.verified_user_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                  label: Text(
                    _isTestingBiometrics
                        ? 'Verifying...'
                        : 'Test Biometric Unlock',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
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
    BuildContext context,
    SecuritySettings settings,
    SecuritySettingsNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'REQUIRE LOCK',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              'Auto-Timeout',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: LockTimeout.values.map((timeout) {
            final isSelected = settings.lockTimeout == timeout;
            return _buildTimeoutOptionTile(
              context: context,
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
    required BuildContext context,
    required LockTimeout timeout,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.shadow.withValues(alpha: 0.04),
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
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            timeout.title,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (timeout.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                timeout.badge!,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        timeout.subtitle,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: colorScheme.onPrimary,
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
    BuildContext context,
    SecuritySettings settings,
    SecuritySettingsNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIVACY & DATA GUARD',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                context: context,
                icon: Icons.visibility_off_rounded,
                iconColor: colorScheme.onSurface.withValues(alpha: 0.8),
                title: 'Hide Content in App Switcher',
                subtitle:
                    'Blur workout logs, body weight, and heart rate telemetry when toggling between apps.',
                value: settings.hideContent,
                onChanged: (val) => notifier.toggleHideContent(val),
              ),
              Divider(
                height: 1,
                indent: 56,
                endIndent: 16,
                color: colorScheme.outlineVariant,
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.lock_reset_rounded,
                iconColor: colorScheme.onSurface.withValues(alpha: 0.8),
                title: 'Biometrics for Sensitive Actions',
                subtitle:
                    'Require credential confirmation before exporting telemetry CSVs or deleting routine templates.',
                value: settings.requireForSensitive,
                onChanged: (val) => notifier.toggleRequireForSensitive(val),
              ),
              Divider(
                height: 1,
                indent: 56,
                endIndent: 16,
                color: colorScheme.outlineVariant,
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.timer_outlined,
                iconColor: colorScheme.onSurface.withValues(alpha: 0.8),
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
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
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
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    height: 1.35,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
            activeThumbColor: colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveAndComplianceCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSavingPreferences ? null : _handleSavePreferences,
            icon: _isSavingPreferences
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
            label: Text(
              _isSavingPreferences
                  ? 'Saved Securely'
                  : 'Save Security Preferences',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              elevation: 2,
              shadowColor: colorScheme.primary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Device credentials and biometric templates are managed exclusively by Secure Enclave / Android KeyStore. FitTrack never transmits, logs, or stores raw biometric telemetry.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  height: 1.35,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
