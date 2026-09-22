import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/data_management_provider.dart';

/// Data Management Settings screen for FitTrack.
///
/// Implements the full cloud & local backup lifecycle, automatic sync schedules,
/// snapshot rollback history, third-party data import, and the danger zone gateway.
/// Strict visual parity across Light, Slate Dark, and Pure OLED Dark modes.
class DataManagementScreen extends ConsumerWidget {
  const DataManagementScreen({super.key});

  /// Private card decoration helper strictly conforming to FitTrack theme guidelines:
  /// - Light mode: soft elevation shadow, transparent or faint-tinted border if danger.
  /// - Dark/OLED mode: solid surface container, crisp outline border, zero shadows.
  BoxDecoration _buildCardDecoration(
    BuildContext context, {
    double radius = 16,
    bool isDanger = false,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    if (isLight) {
      return BoxDecoration(
        color: isDanger
            ? colorScheme.error.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: isDanger
            ? Border.all(
                color: colorScheme.error.withValues(alpha: 0.25),
                width: 1,
              )
            : null,
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
        color: isDanger
            ? colorScheme.error.withValues(alpha: 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDanger ? colorScheme.error : colorScheme.outline,
          width: 1,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;
    final state = ref.watch(dataManagementNotifierProvider);
    final notifier = ref.read(dataManagementNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Data Management',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Data Vault Information',
            icon: Icon(
              Icons.info_outline_rounded,
              size: 22,
              color: isLight
                  ? const Color(0xFF64748B)
                  : colorScheme.onSurfaceVariant,
            ),
            onPressed: () => _showVaultInfoDialog(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // ── 1. CLOUD & LOCAL BACKUP SECTION ─────────────────────────────
            _buildSectionHeader(
              context,
              title: 'CLOUD & LOCAL BACKUP',
              trailing: _buildSyncStatusBadge(context),
            ),
            const SizedBox(height: 8),

            // Primary Vault Card
            Container(
              decoration: _buildCardDecoration(context),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isLight
                              ? const Color(0xFFECFDF5)
                              : colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.cloud_done_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FitTrack Cloud Vault',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Last snapshot: Today at 2:15 PM',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: isLight
                                    ? const Color(0xFF64748B)
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildDataPill(
                                  context,
                                  label: '842 Workouts',
                                ),
                                _buildDataPill(
                                  context,
                                  label: '14 Templates',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isLight
                        ? const Color(0xFFF1F5F9)
                        : colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: FilledButton.icon(
                            onPressed: state.isBackingUp
                                ? null
                                : () async {
                                    await notifier.createBackup();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Snapshot created and synced to Cloud Vault.',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                          backgroundColor:
                                              colorScheme.primary,
                                        ),
                                      );
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.primary.computeLuminance() > 0.55
                                  ? const Color(0xFF002112)
                                  : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: state.isBackingUp
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.primary.computeLuminance() > 0.55
                                            ? const Color(0xFF002112)
                                            : Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.cloud_upload_rounded,
                                    size: 18),
                            label: Text(
                              state.isBackingUp
                                  ? 'Backing Up...'
                                  : 'Back Up Now',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 42,
                        child: OutlinedButton(
                          onPressed: () => _handleExportArchive(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurface,
                            backgroundColor: isLight
                                ? const Color(0xFFF8FAFC)
                                : colorScheme.surfaceContainer,
                            side: BorderSide(
                              color: isLight
                                  ? const Color(0xFFE2E8F0)
                                  : colorScheme.outline,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                          ),
                          child: const Text(
                            'Export',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Auto-Backup Card
            Container(
              decoration: _buildCardDecoration(context),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFF1F5F9)
                          : colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sync_rounded,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Auto-Backup',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sync workout logs automatically over Wi-Fi',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11.5,
                            color: isLight
                                ? const Color(0xFF64748B)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: state.isAutoBackupEnabled,
                    activeTrackColor: colorScheme.primary,
                    onChanged: (val) => notifier.toggleAutoBackup(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 2. SAVED BACKUPS SECTION ────────────────────────────────────
            _buildSectionHeader(
              context,
              title: 'SAVED BACKUPS (${state.snapshots.length})',
              trailing: TextButton(
                onPressed: () => notifier.refreshBackups(),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Refresh',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: _buildCardDecoration(context),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.snapshots.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: isLight
                      ? const Color(0xFFF1F5F9)
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
                itemBuilder: (context, index) {
                  final snapshot = state.snapshots[index];
                  return _buildBackupItem(
                    context,
                    snapshot: snapshot,
                    onRestore: () => _handleRestoreSnapshot(context, ref, snapshot),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── 3. RESTORE & TRANSFER SECTION ───────────────────────────────
            _buildSectionHeader(
              context,
              title: 'RESTORE & TRANSFER',
            ),
            const SizedBox(height: 8),

            // Restore from External File Card
            Container(
              decoration: _buildCardDecoration(context),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isLight
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFF78350F).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.restore_page_rounded,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Restore from File',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  height: 1.4,
                                  color: isLight
                                      ? const Color(0xFF64748B)
                                      : colorScheme.onSurfaceVariant,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Import a previously downloaded ',
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isLight
                                            ? const Color(0xFFF1F5F9)
                                            : colorScheme.surfaceContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '.fittrack',
                                        style: TextStyle(
                                          fontFamily: 'Courier',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        ' snapshot file. Current unsaved data will be superseded.',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleChooseBackupFile(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        backgroundColor: isLight
                            ? const Color(0xFFF8FAFC)
                            : colorScheme.surfaceContainer,
                        side: BorderSide(
                          color: isLight
                              ? const Color(0xFFE2E8F0)
                              : colorScheme.outline,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.file_open_rounded, size: 16),
                      label: const Text(
                        'Choose Backup File...',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Import from Other Ecosystems Card
            Container(
              decoration: _buildCardDecoration(context),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFF1E3A8A).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.cloud_download_rounded,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import Workout Template',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hevy, Strong, CSV logs',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: isLight
                                ? const Color(0xFF64748B)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _handleImportThirdParty(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: isLight
                          ? const Color(0xFFECFDF5)
                          : colorScheme.primary.withValues(alpha: 0.18),
                      foregroundColor: isLight
                          ? const Color(0xFF047857)
                          : colorScheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Import',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── 4. DANGER ZONE SECTION ──────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: colorScheme.error,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'DANGER ZONE',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Danger Zone Card
            Container(
              decoration: _buildCardDecoration(context, isDanger: true),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erase Data',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isLight
                          ? const Color(0xFF881337)
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Permanently delete all routines, exercise sets, personal records, and measurements from this phone. This cannot be undone.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      height: 1.45,
                      color: isLight
                          ? const Color(0xFFBE123C)
                          : const Color(0xFFFDA4AF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: () {
                        context.push('/settings/data/erase');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                      label: const Text(
                        'Clear Data',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: isLight
                ? const Color(0xFF64748B)
                : colorScheme.onSurfaceVariant,
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildSyncStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isLight
            ? const Color(0xFFECFDF5)
            : colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Cloud Synced',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isLight
                  ? const Color(0xFF047857)
                  : colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPill(BuildContext context, {required String label}) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isLight
            ? const Color(0xFFF1F5F9)
            : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isLight
              ? const Color(0xFF475569)
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildBackupItem(
    BuildContext context, {
    required BackupSnapshot snapshot,
    required VoidCallback onRestore,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    IconData itemIcon;
    if (snapshot.isLatest) {
      itemIcon = Icons.check_circle_rounded;
    } else if (snapshot.title.contains('Update')) {
      itemIcon = Icons.update_rounded;
    } else {
      itemIcon = Icons.archive_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: snapshot.isLatest
                  ? (isLight
                      ? const Color(0xFFECFDF5)
                      : colorScheme.primary.withValues(alpha: 0.15))
                  : (isLight
                      ? const Color(0xFFF1F5F9)
                      : colorScheme.surfaceContainer),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              itemIcon,
              color: snapshot.isLatest
                  ? colorScheme.primary
                  : (isLight
                      ? const Color(0xFF64748B)
                      : colorScheme.onSurfaceVariant),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      snapshot.title,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (snapshot.isLatest) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isLight
                              ? const Color(0xFFD1FAE5)
                              : colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Latest',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isLight
                                ? const Color(0xFF065F46)
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${snapshot.date} · ${snapshot.time} · ${snapshot.size}',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: isLight
                        ? const Color(0xFF94A3B8)
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onRestore,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              backgroundColor: isLight
                  ? const Color(0xFFF8FAFC)
                  : colorScheme.surfaceContainer,
              side: BorderSide(
                color: isLight
                    ? const Color(0xFFE2E8F0)
                    : colorScheme.outline.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Restore',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVaultInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'FitTrack Cloud Vault',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
        content: const Text(
          'Your workout telemetry, exercise modifications, personal records, and schedule templates are encrypted locally before being backed up to your personal vault.\n\nAutomatic daily syncs occur over Wi-Fi when the app enters background state.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Understood',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleExportArchive(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Exporting fit_track_archive.fittrack to Downloads...',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
    );
  }

  void _handleChooseBackupFile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'File Picker: Select a valid .fittrack database snapshot to restore.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
    );
  }

  void _handleImportThirdParty(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Template Importer: Ready to parse Hevy, Strong, and CSV workout formats.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
    );
  }

  Future<void> _handleRestoreSnapshot(
    BuildContext context,
    WidgetRef ref,
    BackupSnapshot snapshot,
  ) async {
    final notifier = ref.read(dataManagementNotifierProvider.notifier);
    await notifier.restoreBackup(snapshot.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Restored successfully from ${snapshot.title} (${snapshot.date}).',
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
          ),
        ),
      );
    }
  }
}
