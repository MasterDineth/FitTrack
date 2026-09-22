import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_management_provider.dart';

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

/// Displays the interactive erase confirmation modal matching the Stitch specification.
///
/// Features:
/// - Glassmorphic blur backdrop
/// - Pulsing warning badge
/// - Dynamic category/workout title and destructive summary
/// - Warning callout: "Cloud sync will be paused..."
/// - "Export local backup first" switch mapped to [DataManagementNotifier]
/// - Solid red `colorScheme.error` "Yes, Delete Data" button and "Cancel" button
Future<bool?> showEraseDataConfirmationModal({
  required BuildContext context,
  required VoidCallback onConfirm,
  String title = 'Erase Workout History?',
  String? description,
  String confirmButtonText = 'Yes, Delete Data',
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    isScrollControlled: true,
    useSafeArea: true,
    builder: (modalContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: _EraseConfirmationModalSheet(
          title: title,
          description: description ??
              'This will permanently remove 842 completed workouts and all historical telemetry from this device. This action cannot be reversed.',
          confirmButtonText: confirmButtonText,
          onConfirm: () {
            Navigator.of(modalContext).pop(true);
            onConfirm();
          },
        ),
      );
    },
  );
}

class _EraseConfirmationModalSheet extends ConsumerStatefulWidget {
  const _EraseConfirmationModalSheet({
    required this.title,
    required this.description,
    required this.confirmButtonText,
    required this.onConfirm,
  });

  final String title;
  final String description;
  final String confirmButtonText;
  final VoidCallback onConfirm;

  @override
  ConsumerState<_EraseConfirmationModalSheet> createState() =>
      _EraseConfirmationModalSheetState();
}

class _EraseConfirmationModalSheetState
    extends ConsumerState<_EraseConfirmationModalSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;
    final dataState = ref.watch(dataManagementNotifierProvider);
    final notifier = ref.read(dataManagementNotifierProvider.notifier);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 24,
        ),
        decoration: _buildCardDecoration(context, radius: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtle Drag Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isLight
                      ? const Color(0xFFCBD5E1)
                      : colorScheme.outline.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),

              // Animated Pulsing Red Warning Graphic Badge
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 68 * _pulseAnimation.value,
                        height: 68 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.error.withValues(alpha: 0.12),
                        ),
                      ),
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLight
                              ? colorScheme.error.withValues(alpha: 0.14)
                              : const Color(0xFF450A0A),
                          border: Border.all(
                            color: colorScheme.error.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: colorScheme.error,
                          size: 28,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Dialog Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Dialog Descriptive Copy
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: isLight
                      ? const Color(0xFF64748B)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Red Warning Callout Container: "Cloud sync will be paused..."
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLight
                      ? colorScheme.error.withValues(alpha: 0.08)
                      : const Color(0xFF330909),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.sync_disabled_rounded,
                      color: colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cloud sync will be paused until your next manual backup to prevent corrupted cloud states.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: isLight
                              ? const Color(0xFF991B1B)
                              : const Color(0xFFFCA5A5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Toggle: "Export local backup first"
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isLight
                      ? const Color(0xFFF1F5F9)
                      : colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: isLight
                      ? null
                      : Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.4),
                        ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export local backup first',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Save a .fittrack archive to phone storage',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: isLight
                                  ? const Color(0xFF64748B)
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: dataState.exportBackupBeforeDelete,
                      activeTrackColor: colorScheme.primary,
                      onChanged: (value) {
                        notifier.toggleExportBackupBeforeDelete(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Actions: Solid Red Erase Button & Secondary Cancel Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          setState(() => _isProcessing = true);
                          await Future<void>.delayed(
                              const Duration(milliseconds: 300));
                          if (mounted) {
                            widget.onConfirm();
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isProcessing
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onError,
                            ),
                          ),
                        )
                      : const Icon(Icons.delete_forever_rounded, size: 20),
                  label: Text(
                    _isProcessing ? 'Purging Data...' : widget.confirmButtonText,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    backgroundColor: isLight
                        ? const Color(0xFFF1F5F9)
                        : colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Dismiss Hint
              Text(
                'Tap outside or press Cancel to keep your data.',
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
      ),
    );
  }
}
