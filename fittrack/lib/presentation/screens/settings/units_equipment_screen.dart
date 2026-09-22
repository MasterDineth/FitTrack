// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/workout_settings_provider.dart';

/// Units & Equipment Screen for FitTrack.
///
/// Implemented to strictly match the Stitch design specifications across
/// Light, Slate Dark, and Pure OLED Dark modes:
/// - Section 1: Measurements (Weight, Distance, and Body Measurement SegmentedButtons)
/// - Section 2: Hardware Defaults (Standard Barbell Weight, EZ Curl Bar Weight dropdowns)
/// - Section 3: Available Equipment (Gym Profile RadioListTiles with active color)
/// - Transient exit SnackBar via PopScope ("Changes synced to workout logs")
class UnitsEquipmentScreen extends ConsumerWidget {
  const UnitsEquipmentScreen({super.key});

  /// Private card decoration helper strictly conforming to design system guardrails:
  /// - Light mode: pure surface color with subtle ambient drop shadow, no border.
  /// - Dark/OLED mode: pure surface color with crisp outline border, no shadow.
  BoxDecoration _buildCardDecoration(BuildContext context, {double radius = 16}) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colorScheme = Theme.of(context).colorScheme;

    if (isLight) {
      return BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
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
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),
      );
    }
  }

  void _showExitSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: const Text(
          'Changes synced to workout logs',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final state = ref.watch(workoutSettingsNotifierProvider);
    final notifier = ref.read(workoutSettingsNotifierProvider.notifier);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _showExitSnackBar(context);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 24,
              color: colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Units & Equipment',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
            children: [
              // ── Section 1: Measurements ──────────────────────────────────────
              _buildSectionHeader(
                context: context,
                icon: Icons.straighten_rounded,
                title: 'MEASUREMENTS',
              ),
              Container(
                decoration: _buildCardDecoration(context),
                child: Column(
                  children: [
                    // Weight Units
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weight Units',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Used for exercise logs and body weight',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildSegmentedButton<String>(
                            context: context,
                            selected: state.weightUnit,
                            segments: const [
                              ButtonSegment(
                                value: 'kg',
                                label: Text('kg'),
                              ),
                              ButtonSegment(
                                value: 'lbs',
                                label: Text('lbs'),
                              ),
                            ],
                            onSelectionChanged: (value) =>
                                notifier.setWeightUnit(value),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(context, isLight),

                    // Distance Units
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Distance Units',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Used for cardio tracking and runs',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildSegmentedButton<String>(
                            context: context,
                            selected: state.distanceUnit,
                            segments: const [
                              ButtonSegment(
                                value: 'km',
                                label: Text('km'),
                              ),
                              ButtonSegment(
                                value: 'mi',
                                label: Text('mi'),
                              ),
                            ],
                            onSelectionChanged: (value) =>
                                notifier.setDistanceUnit(value),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(context, isLight),

                    // Body Measurements
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Body Measurements',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Circumference and height logs',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildSegmentedButton<String>(
                            context: context,
                            selected: state.bodyUnit,
                            segments: const [
                              ButtonSegment(
                                value: 'cm',
                                label: Text('cm'),
                              ),
                              ButtonSegment(
                                value: 'in',
                                label: Text('in'),
                              ),
                            ],
                            onSelectionChanged: (value) =>
                                notifier.setBodyUnit(value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Section 2: Hardware Defaults ─────────────────────────────────
              _buildSectionHeader(
                context: context,
                icon: Icons.fitness_center_rounded,
                title: 'HARDWARE DEFAULTS',
              ),
              Container(
                decoration: _buildCardDecoration(context),
                child: Column(
                  children: [
                    // Standard Barbell Weight
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Standard Barbell Weight',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Olympic barbell base weight calculation',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildDropdownPill<double>(
                            context: context,
                            value: state.barbellWeight,
                            items: const [
                              DropdownMenuItem(
                                value: 20.0,
                                child: Text('20.0 kg / 45.0 lbs'),
                              ),
                              DropdownMenuItem(
                                value: 15.0,
                                child: Text('15.0 kg / 35.0 lbs'),
                              ),
                              DropdownMenuItem(
                                value: 25.0,
                                child: Text('25.0 kg / 55.0 lbs'),
                              ),
                              DropdownMenuItem(
                                value: 10.0,
                                child: Text('10.0 kg / 22.0 lbs'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                notifier.setBarbellWeight(val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(context, isLight),

                    // EZ Curl Bar Weight
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EZ Curl Bar Weight',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Curved bar base weight calculation',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildDropdownPill<double>(
                            context: context,
                            value: state.ezBarWeight,
                            items: const [
                              DropdownMenuItem(
                                value: 10.0,
                                child: Text('10.0 kg / 25.0 lbs'),
                              ),
                              DropdownMenuItem(
                                value: 7.5,
                                child: Text('7.5 kg / 15.0 lbs'),
                              ),
                              DropdownMenuItem(
                                value: 12.5,
                                child: Text('12.5 kg / 30.0 lbs'),
                              ),
                              DropdownMenuItem(
                                value: 5.0,
                                child: Text('5.0 kg / 10.0 lbs'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                notifier.setEzBarWeight(val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Section 3: Available Equipment ───────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.domain_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AVAILABLE EQUIPMENT',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'WORKOUT FILTER',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: _buildCardDecoration(context),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gym Profile Sub-header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gym Profile',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Filter routines and exercise substitutes based on your gear.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Gym Profile Options
                    _buildGymProfileTile(
                      context: context,
                      title: 'Full Commercial Gym',
                      subtitle: 'Barbells, cables, machines, dumbbells',
                      value: 'Full Commercial Gym',
                      groupValue: state.gymProfile,
                      onChanged: (val) => notifier.setGymProfile(val),
                    ),
                    _buildGymProfileTile(
                      context: context,
                      title: 'Dumbbells & Benches Only',
                      subtitle: 'Adjustable bench and dumbbell pairs',
                      value: 'Dumbbells & Benches Only',
                      groupValue: state.gymProfile,
                      onChanged: (val) => notifier.setGymProfile(val),
                    ),
                    _buildGymProfileTile(
                      context: context,
                      title: 'Home Gym / Power Rack',
                      subtitle: 'Squat rack, pull-up bar, and barbell setup',
                      value: 'Home Gym / Power Rack',
                      groupValue: state.gymProfile,
                      onChanged: (val) => notifier.setGymProfile(val),
                    ),
                    _buildGymProfileTile(
                      context: context,
                      title: 'Bodyweight Only',
                      subtitle: 'Calisthenics, bands, and floor movements',
                      value: 'Bodyweight Only',
                      groupValue: state.gymProfile,
                      onChanged: (val) => notifier.setGymProfile(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Footer: Profile Synced Indicator & Reset Defaults ────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Profile synced to Cloud',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        await notifier.resetToDefaults();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              content: const Text(
                                'Workout settings reset to defaults',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Reset Defaults',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context, bool isLight) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      color: isLight
          ? const Color(0xFFF1F5F9)
          : colorScheme.outline.withValues(alpha: 0.15),
    );
  }

  Widget _buildSegmentedButton<T>({
    required BuildContext context,
    required T selected,
    required List<ButtonSegment<T>> segments,
    required ValueChanged<T> onSelectionChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return SegmentedButton<T>(
      segments: segments,
      selected: {selected},
      onSelectionChanged: (newSelection) {
        if (newSelection.isNotEmpty) {
          onSelectionChanged(newSelection.first);
        }
      },
      showSelectedIcon: false,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return isLight
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerHigh;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        side: const WidgetStatePropertyAll(BorderSide.none),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownPill<T>({
    required BuildContext context,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isLight
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: Icon(
            Icons.expand_more_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          dropdownColor: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          isDense: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGymProfileTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = value == groupValue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: RadioListTile<String>(
          value: value,
          groupValue: groupValue,
          activeColor: colorScheme.primary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          onChanged: (val) {
            if (val != null) {
              onChanged(val);
            }
          },
        ),
      ),
    );
  }
}
