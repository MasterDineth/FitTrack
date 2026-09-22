import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_management_provider.dart';
import '../../widgets/data_modals.dart';

/// Erase Data settings screen for granular and master device purging.
///
/// Strictly adheres to the Stitch specification and system architectural directives:
/// - Irreversible action warning with rapid rollback navigation
/// - Segmented multi-colored local flash storage visualization
/// - Categorical granular purge cards (Workouts, Schedules, Exercises, Bookmarks)
/// - Master danger zone erase sequence triggering interactive modal confirmation
class EraseDataScreen extends ConsumerWidget {
  const EraseDataScreen({super.key});

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
          'Erase Data',
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: colorScheme.primary.computeLuminance() > 0.55
                    ? const Color(0xFF002112)
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
          children: [
            // ── 1. TOP WARNING CARD ─────────────────────────────────────────
            Container(
              decoration: _buildCardDecoration(context, isDanger: true),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLight
                          ? Colors.white
                          : colorScheme.surfaceContainerHigh,
                      boxShadow: isLight
                          ? const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: colorScheme.error,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Irreversible Action',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isLight
                                    ? const Color(0xFF991B1B)
                                    : const Color(0xFFFCA5A5),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'WARNING',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: colorScheme.onError,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Erasing local data removes your synced offline records and configurations. Back up your data in Data Management before proceeding.',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            height: 1.4,
                            color: isLight
                                ? const Color(0xFF7F1D1D)
                                : const Color(0xFFF87171),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => Navigator.of(context).maybePop(),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? Colors.white
                                  : colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: isLight
                                  ? const [
                                      BoxShadow(
                                        color: Color(0x0F000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Check Backups',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.error,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: colorScheme.error,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 2. STORAGE BAR CARD ─────────────────────────────────────────
            Container(
              decoration: _buildCardDecoration(context),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.storage_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Local Device Storage',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '1.85 MB Total',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? const Color(0xFF64748B)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Guardrail 2: Clean row of Expanded containers in ClipRRect(16px)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 10,
                      color: isLight
                          ? const Color(0xFFE2E8F0)
                          : colorScheme.surfaceContainer,
                      child: Row(
                        children: [
                          // Workouts (65%)
                          Expanded(
                            flex: 65,
                            child: Container(color: colorScheme.primary),
                          ),
                          const SizedBox(width: 2),
                          // Custom Exercises (22%)
                          Expanded(
                            flex: 22,
                            child: Container(
                              color: const Color(0xFF0284C7), // sky/tertiary
                            ),
                          ),
                          const SizedBox(width: 2),
                          // Custom Schedules (10%)
                          Expanded(
                            flex: 10,
                            child: Container(
                              color: const Color(0xFF8B5CF6), // violet/secondary
                            ),
                          ),
                          const SizedBox(width: 2),
                          // Other / Bookmarks (3%)
                          Expanded(
                            flex: 3,
                            child: Container(
                              color: const Color(0xFF10B981), // emerald
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStorageLegendItem(
                        context,
                        label: 'Workouts',
                        color: colorScheme.primary,
                      ),
                      _buildStorageLegendItem(
                        context,
                        label: 'Exercises',
                        color: const Color(0xFF0284C7),
                      ),
                      _buildStorageLegendItem(
                        context,
                        label: 'Schedules',
                        color: const Color(0xFF8B5CF6),
                      ),
                      _buildStorageLegendItem(
                        context,
                        label: 'Other',
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 3. DATA BY CATEGORY SECTION ─────────────────────────────────
            Row(
              children: [
                Text(
                  'DATA BY CATEGORY',
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
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFF1F5F9)
                        : colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '4 Available',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isLight
                          ? const Color(0xFF475569)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Choose specific categories to wipe without affecting the rest of your FitTrack profile.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: isLight
                    ? const Color(0xFF64748B)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Category 1: Workout History
            _buildCategoryCard(
              context,
              icon: Icons.fitness_center_rounded,
              title: 'Workout History',
              badgeText: '842 Completed Workouts',
              sizeText: '1.2 MB',
              description:
                  'All completed workout logs, set logs, reps, personal bests, and workout notes.',
              buttonLabel: 'Clear Workouts',
              onClear: () {
                showEraseDataConfirmationModal(
                  context: context,
                  title: 'Erase Workout History?',
                  description:
                      'This will permanently remove 842 completed workout logs and telemetry from this device. This action cannot be reversed.',
                  onConfirm: () async {
                    await notifier.clearCategoryData('Workout History');
                    if (context.mounted) {
                      _showPurgeToast(context, 'Workout History cleared.');
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            // Category 2: Custom Schedules
            _buildCategoryCard(
              context,
              icon: Icons.calendar_month_rounded,
              title: 'Custom Schedules',
              badgeText: '6 Custom Routines',
              sizeText: '180 KB',
              description:
                  'Push-Pull-Legs, Upper/Lower, and custom weekly training schedules you created.',
              buttonLabel: 'Clear Schedules',
              onClear: () {
                showEraseDataConfirmationModal(
                  context: context,
                  title: 'Erase Custom Schedules?',
                  description:
                      'This will delete all your tailored workout schedules and progression templates. Built-in defaults will remain intact.',
                  onConfirm: () async {
                    await notifier.clearCategoryData('Custom Schedules');
                    if (context.mounted) {
                      _showPurgeToast(context, 'Custom Schedules cleared.');
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            // Category 3: Custom Exercises
            _buildCategoryCard(
              context,
              icon: Icons.directions_run_rounded,
              title: 'Custom Exercises',
              badgeText: '14 Custom Exercises',
              sizeText: '420 KB',
              description:
                  'User-defined movements, custom form cues, execution steps, and muscle activation maps.',
              buttonLabel: 'Clear Exercises',
              onClear: () {
                showEraseDataConfirmationModal(
                  context: context,
                  title: 'Erase Custom Exercises?',
                  description:
                      'This will delete 14 custom exercises and cues you authored. Standard FitTrack library exercises are preserved.',
                  onConfirm: () async {
                    await notifier.clearCategoryData('Custom Exercises');
                    if (context.mounted) {
                      _showPurgeToast(context, 'Custom Exercises cleared.');
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            // Category 4: Favourites & Bookmarks
            _buildCategoryCard(
              context,
              icon: Icons.bookmark_rounded,
              title: 'Favourites & Bookmarks',
              badgeText: '28 Saved Items',
              sizeText: '45 KB',
              description:
                  'Bookmarked exercises from the library, pinned routine templates, and starred guides.',
              buttonLabel: 'Clear Bookmarks',
              onClear: () {
                showEraseDataConfirmationModal(
                  context: context,
                  title: 'Erase Favourites & Bookmarks?',
                  description:
                      'This unpins all starred exercise guides, bookmarks, and favorite routine shortcuts.',
                  onConfirm: () async {
                    await notifier.clearCategoryData('Bookmarks');
                    if (context.mounted) {
                      _showPurgeToast(
                          context, 'Favourites & Bookmarks cleared.');
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 28),

            // ── 4. MASTER DANGER ZONE ───────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: colorScheme.error,
                  size: 18,
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

            // Master Erase Card
            Container(
              decoration: _buildCardDecoration(context, isDanger: true),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.delete_forever_rounded,
                        color: colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Erase All FitTrack Data',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isLight
                              ? const Color(0xFF881337)
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Permanently delete everything across all categories: workout logs, custom schedules, exercises, telemetry, and cached preferences from this device.',
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
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {
                        showEraseDataConfirmationModal(
                          context: context,
                          title: 'Erase All FitTrack Data?',
                          description:
                              'This will permanently wipe ALL workout logs, schedules, custom exercises, bookmarks, and telemetry from this device. This action cannot be undone.',
                          confirmButtonText: 'Yes, Wipe Everything',
                          onConfirm: () async {
                            await notifier.clearAllData();
                            if (context.mounted) {
                              _showPurgeToast(
                                  context, 'All FitTrack local data erased.');
                            }
                          },
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                      label: const Text(
                        'Clear All Data',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_reset_rounded,
                        size: 14,
                        color: isLight
                            ? const Color(0xFFE11D48)
                            : const Color(0xFFFCA5A5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Requires confirmation step',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isLight
                              ? const Color(0xFFE11D48)
                              : const Color(0xFFFCA5A5),
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

  Widget _buildStorageLegendItem(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isLight
                ? const Color(0xFF64748B)
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String badgeText,
    required String sizeText,
    required String description,
    required String buttonLabel,
    required VoidCallback onClear,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: _buildCardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLight
                      ? const Color(0xFFF1F5F9)
                      : colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
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
                      title,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFFCBD5E1)
                                  : colorScheme.outline,
                            ),
                          ),
                        ),
                        Text(
                          sizeText,
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
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        height: 1.4,
                        color: isLight
                            ? const Color(0xFF64748B)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                backgroundColor: isLight
                    ? colorScheme.error.withValues(alpha: 0.06)
                    : colorScheme.error.withValues(alpha: 0.12),
                side: BorderSide(
                  color: colorScheme.error.withValues(alpha: 0.35),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 34),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 16),
              label: Text(
                buttonLabel,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurgeToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
