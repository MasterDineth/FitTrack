import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/data_management_provider.dart';
import '../../../providers/notification_settings_provider.dart';
import '../../../providers/security_settings_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/workout_settings_provider.dart';
import '../../../theme/ft_glass.dart';
import 'settings_group_card.dart';
import 'settings_rating_sheet.dart';
import 'settings_tile_row.dart';

/// Renders the 4 grouped Settings sections with real-time reactive quick previews and search filtering.
class SettingsSectionsList extends StatelessWidget {
  final String searchQuery;

  const SettingsSectionsList({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final hasScope = context.findAncestorWidgetOfExactType<ProviderScope>() != null ||
        context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() != null;

    if (hasScope) {
      return _ReactiveSettingsSectionsList(searchQuery: searchQuery);
    }
    return _StaticSettingsSectionsList(
      searchQuery: searchQuery,
      isSecurityOn: true,
      restTimer: '01:30',
      weightUnit: 'kg',
      themePreview: 'System',
      notifsOn: true,
      isAutoBackup: true,
    );
  }
}

class _ReactiveSettingsSectionsList extends ConsumerWidget {
  final String searchQuery;

  const _ReactiveSettingsSectionsList({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Reactive slice for Security (App Lock / Biometrics)
    final securityAsync = ref.watch(securitySettingsNotifierProvider);
    final isSecurityOn = securityAsync.value?.isAppLockEnabled == true ||
        securityAsync.value?.isBiometricEnabled == true;

    // 2. Reactive slice for Workout Preferences (Rest Timer, Weight Unit)
    final restTimer = ref.watch(
      workoutSettingsNotifierProvider.select((s) => s.defaultRestTimer),
    );
    final weightUnit = ref.watch(
      workoutSettingsNotifierProvider.select((s) => s.weightUnit),
    );

    // 3. Reactive slice for Appearance (Theme Mode)
    final themeMode = ref.watch(
      themeNotifierProvider.select((s) => s.themeMode),
    );
    final themePreview = switch (themeMode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };

    // 4. Reactive slice for Notifications
    final notifsOn = ref.watch(
      notificationSettingsNotifierProvider.select((s) => s.systemNotifications),
    );

    // 5. Reactive slice for Data Backup
    final isAutoBackup = ref.watch(
      dataManagementNotifierProvider.select((s) => s.isAutoBackupEnabled),
    );

    return _StaticSettingsSectionsList(
      searchQuery: searchQuery,
      isSecurityOn: isSecurityOn,
      restTimer: restTimer,
      weightUnit: weightUnit,
      themePreview: themePreview,
      notifsOn: notifsOn,
      isAutoBackup: isAutoBackup,
    );
  }
}

class _StaticSettingsSectionsList extends StatelessWidget {
  final String searchQuery;
  final bool isSecurityOn;
  final String restTimer;
  final String weightUnit;
  final String themePreview;
  final bool notifsOn;
  final bool isAutoBackup;

  const _StaticSettingsSectionsList({
    required this.searchQuery,
    required this.isSecurityOn,
    required this.restTimer,
    required this.weightUnit,
    required this.themePreview,
    required this.notifsOn,
    required this.isAutoBackup,
  });

  @override
  Widget build(BuildContext context) {
    final isMetric = weightUnit.toLowerCase() == 'kg';
    final q = searchQuery.trim().toLowerCase();

    bool matches(String title, String subtitle) {
      if (q.isEmpty) return true;
      return title.toLowerCase().contains(q) || subtitle.toLowerCase().contains(q);
    }

    // ── Group 1: ACCOUNT & SECURITY ─────────────────────────────────────────
    final group1Items = <Widget>[
      if (matches('Account Details', 'Name, email, phone'))
        SettingsTileRow(
          icon: Icons.person_outline_rounded,
          iconBgColor: const Color(0xFFEDE9FE),
          iconColor: context.ftPrimary,
          title: 'Account Details',
          subtitle: 'Name, email, phone',
          onTap: () => context.push('/settings/account'),
        ),
      if (matches('Security & Privacy', 'App Lock & Biometrics'))
        SettingsTileRow(
          icon: Icons.shield_outlined,
          iconBgColor: const Color(0xFFE0E7FF),
          iconColor: const Color(0xFF4F46E5),
          title: 'Security & Privacy',
          subtitle: 'App Lock & Biometrics',
          trailingPreview: isSecurityOn ? 'On' : 'Off',
          trailingPreviewColor: isSecurityOn ? context.ftPrimary : context.ftMuted,
          onTap: () => context.push('/settings/security'),
        ),
      if (matches('Password & Authentication', 'Change password, sessions'))
        SettingsTileRow(
          icon: Icons.lock_outline_rounded,
          iconBgColor: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF9333EA),
          title: 'Password & Authentication',
          subtitle: 'Change password, sessions',
          onTap: () => context.push('/settings/password'),
        ),
    ];

    // ── Group 2: WORKOUT & TIMERS ───────────────────────────────────────────
    final group2Items = <Widget>[
      if (matches('Workout Preferences', 'Rest timer, auto-start, haptics'))
        SettingsTileRow(
          icon: Icons.timer_outlined,
          iconBgColor: const Color(0xFFCCFBF1),
          iconColor: const Color(0xFF0D9488),
          title: 'Workout Preferences',
          subtitle: 'Rest timer, auto-start, haptics',
          trailingPreview: _formatRestTimer(restTimer),
          onTap: () => context.push('/settings/workout-preferences'),
        ),
      if (matches('Units & Equipment', '${isMetric ? "Metric" : "Imperial"} barbell'))
        SettingsTileRow(
          icon: Icons.fitness_center_outlined,
          iconBgColor: const Color(0xFFCFFAFE),
          iconColor: const Color(0xFF0891B2),
          title: 'Units & Equipment',
          subtitle: '${isMetric ? "Metric" : "Imperial"} barbell',
          trailingPreview: isMetric ? 'Metric' : 'Imperial',
          onTap: () => context.push('/settings/units-equipment'),
        ),
    ];

    // ── Group 3: APP PREFERENCES ────────────────────────────────────────────
    final group3Items = <Widget>[
      if (matches('Appearance & Display', 'Theme, accent colour'))
        SettingsTileRow(
          icon: Icons.palette_outlined,
          iconBgColor: const Color(0xFFFCE7F3),
          iconColor: const Color(0xFFDB2777),
          title: 'Appearance & Display',
          subtitle: 'Theme, accent colour',
          trailingPreview: themePreview,
          onTap: () => context.push('/settings/appearance'),
        ),
      if (matches('Notifications & Reminders', 'Workout reminders, streaks'))
        SettingsTileRow(
          icon: Icons.notifications_none_rounded,
          iconBgColor: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF2563EB),
          title: 'Notifications & Reminders',
          subtitle: 'Workout reminders, streaks',
          trailingPreview: notifsOn ? 'On' : 'Off',
          trailingPreviewColor: notifsOn ? const Color(0xFF2563EB) : context.ftMuted,
          onTap: () => context.push('/settings/notifications'),
        ),
      if (matches('Data & Integrations', 'Health Connect, Google Fit, cloud backup'))
        SettingsTileRow(
          icon: Icons.sync_alt_rounded,
          iconBgColor: const Color(0xFFD1FAE5),
          iconColor: const Color(0xFF059669),
          title: 'Data & Integrations',
          subtitle: 'Health Connect, Google Fit, cloud backup',
          trailingPreview: isAutoBackup ? 'Synced' : 'Local',
          trailingPreviewColor: const Color(0xFF059669),
          onTap: () => context.push('/settings/data'),
        ),
    ];

    // ── Group 4: SUPPORT & ABOUT ────────────────────────────────────────────
    final group4Items = <Widget>[
      if (matches('Help Center & FAQs', 'Guides, tutorials, contact support'))
        SettingsTileRow(
          icon: Icons.help_outline_rounded,
          iconBgColor: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          title: 'Help Center & FAQs',
          subtitle: 'Guides, tutorials, contact support',
          onTap: () => context.push('/settings/help'),
        ),
      if (matches('Share & Rate FitTrack', 'Support our development with a review'))
        SettingsTileRow(
          icon: Icons.star_outline_rounded,
          iconBgColor: const Color(0xFFFFE4E6),
          iconColor: const Color(0xFFE11D48),
          title: 'Share & Rate FitTrack',
          subtitle: 'Support our development with a review',
          onTap: () => showFitTrackRatingSheet(context),
        ),
      if (matches('About FitTrack', 'Version information, terms & privacy'))
        SettingsTileRow(
          icon: Icons.info_outline_rounded,
          iconBgColor: const Color(0xFFF1F5F9),
          iconColor: const Color(0xFF475569),
          title: 'About FitTrack',
          subtitle: 'Version information, terms & privacy',
          trailingPreview: 'v1.4.2',
          onTap: () => context.push('/settings/about'),
        ),
    ];

    final totalVisible = group1Items.length +
        group2Items.length +
        group3Items.length +
        group4Items.length;

    if (totalVisible == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 40,
                color: context.ftMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No settings found for "$searchQuery"',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.ftMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (group1Items.isNotEmpty)
          SettingsGroupCard(
            title: 'ACCOUNT & SECURITY',
            children: group1Items,
          ),
        if (group2Items.isNotEmpty)
          SettingsGroupCard(
            title: 'WORKOUT & TIMERS',
            children: group2Items,
          ),
        if (group3Items.isNotEmpty)
          SettingsGroupCard(
            title: 'APP PREFERENCES',
            children: group3Items,
          ),
        if (group4Items.isNotEmpty)
          SettingsGroupCard(
            title: 'SUPPORT & ABOUT',
            children: group4Items,
          ),
      ],
    );
  }

  String _formatRestTimer(String raw) {
    if (raw.startsWith('0') && raw.length == 5 && raw.contains(':')) {
      return raw.substring(1); // "01:30" -> "1:30"
    }
    return raw;
  }
}
