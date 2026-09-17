import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ft_primary_button.dart';
import '../widgets/ft_step_indicator.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../../domain/entities/body_telemetry.dart';

/// FitTrack Onboarding – Body Telemetry Setup Screen (Step 3 of 4).
///
/// Collects age, weight, height, biological sex, and activity level.
/// Calculates BMI and BMR in real-time, then saves via [UserProfileNotifier].
class TelemetrySetupScreen extends ConsumerStatefulWidget {
  const TelemetrySetupScreen({super.key});

  @override
  ConsumerState<TelemetrySetupScreen> createState() =>
      _TelemetrySetupScreenState();
}

class _TelemetrySetupScreenState extends ConsumerState<TelemetrySetupScreen> {
  // State
  bool _isMetric = true;
  BiologicalSex _sex = BiologicalSex.male;
  int _age = 24;
  double _weight = 76.5; // kg
  double _height = 178.0; // cm
  String _activityLevel = 'Moderate';
  bool _isSaving = false;

  // Computed telemetry
  double get _bmi {
    final hm = _height / 100;
    return _weight / (hm * hm);
  }

  String get _bmiStatus {
    final b = _bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Optimal';
    if (b < 30) return 'Moderate';
    return 'High';
  }

  Color _getBmiColor(ColorScheme colorScheme) {
    final b = _bmi;
    if (b < 18.5) return Colors.blueAccent;
    if (b < 25) return colorScheme.primary;
    if (b < 30) return const Color(0xFFF59E0B);
    return colorScheme.error;
  }

  int get _bmr {
    final base = 10 * _weight + 6.25 * _height - 5 * _age;
    if (_sex == BiologicalSex.female) {
      return (base - 161).round();
    } else {
      return (base + 5).round(); // Male / Other
    }
  }

  double get _hydration {
    final bmrWater = _bmr / 1000.0; // 1L per 1000 kcal
    final bmiFactor = _bmi > 22 ? (_bmi - 22) * 0.05 : 0; // Extra water for higher BMI
    return bmrWater + bmiFactor;
  }

  // Display helpers
  String get _weightDisplay =>
      _isMetric ? _weight.toStringAsFixed(1) : (_weight * 2.20462).toStringAsFixed(1);
  String get _weightUnit => _isMetric ? 'kg' : 'lbs';
  String get _heightDisplay => _isMetric
      ? _height.round().toString()
      : '${(_height / 30.48).floor()}\' ${((_height / 2.54) % 12).round()}"';
  String get _heightUnit => _isMetric ? 'cm' : '';

  Future<void> _continue() async {
    setState(() => _isSaving = true);
    final userAsync = ref.read(authProvider);
    final userId = userAsync.value?.id ?? 'local';

    final telemetry = BodyTelemetry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      unitSystem: _isMetric ? UnitSystem.metric : UnitSystem.imperial,
      biologicalSex: _sex,
      age: _age,
      weight: _weight,
      height: _height,
      recordedAt: DateTime.now(),
    );

    await ref
        .read(userProfileProvider.notifier)
        .saveTelemetry(telemetry);

    setState(() => _isSaving = false);
    if (mounted) context.push('/onboarding/fitness');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bmiColor = _getBmiColor(colorScheme);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Status + Nav ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: colorScheme.onSurface),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'STEP 3 OF 4',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text(
                          'Why we ask',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(Icons.info_outline_rounded,
                            size: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ────────────────────────────────────────
                    Text(
                      'Tell us about yourself',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Calibrates your personalized calorie burn, metabolic baseline (BMR), and dynamic target load.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Unit toggle ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          _UnitToggleBtn(
                            label: 'Metric (kg · cm)',
                            isActive: _isMetric,
                            onTap: () => setState(() => _isMetric = true),
                          ),
                          _UnitToggleBtn(
                            label: 'Imperial (lbs · ft)',
                            isActive: !_isMetric,
                            onTap: () => setState(() => _isMetric = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Sex selector ─────────────────────────────────
                    _SectionCard(
                      label: 'BIOLOGICAL SEX',
                      child: Row(
                        children: [
                          _SexBtn(
                            label: 'Male',
                            isSelected: _sex == BiologicalSex.male,
                            onTap: () =>
                                setState(() => _sex = BiologicalSex.male),
                          ),
                          const SizedBox(width: 8),
                          _SexBtn(
                            label: 'Female',
                            isSelected: _sex == BiologicalSex.female,
                            onTap: () =>
                                setState(() => _sex = BiologicalSex.female),
                          ),
                          const SizedBox(width: 8),
                          _SexBtn(
                            label: 'Other',
                            isSelected: _sex == BiologicalSex.other,
                            onTap: () =>
                                setState(() => _sex = BiologicalSex.other),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Age + Weight ─────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _NumericCard(
                            label: 'AGE',
                            value: '$_age',
                            unit: 'years',
                            onMinus: () =>
                                setState(() => _age = max(14, _age - 1)),
                            onPlus: () =>
                                setState(() => _age = min(95, _age + 1)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NumericCard(
                            label: 'WEIGHT',
                            value: _weightDisplay,
                            unit: _weightUnit,
                            badge: 'Live',
                            onMinus: () => setState(
                              () => _weight =
                                  max(35, double.parse((_weight - 0.5).toStringAsFixed(1))),
                            ),
                            onPlus: () => setState(
                              () => _weight =
                                  min(250, double.parse((_weight + 0.5).toStringAsFixed(1))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Height slider ────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HEIGHT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.4,
                                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Standing stature',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _heightDisplay,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _heightUnit,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: colorScheme.primary,
                              inactiveTrackColor: colorScheme.outlineVariant,
                              thumbColor: colorScheme.primary,
                              overlayColor:
                                  colorScheme.primary.withValues(alpha: 0.15),
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 11),
                              trackHeight: 5,
                            ),
                            child: Slider(
                              value: _height,
                              min: 120,
                              max: 220,
                              onChanged: (v) =>
                                  setState(() => _height = v),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '120 cm',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Avg: 175',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              Text(
                                '220 cm',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Telemetry card ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: colorScheme.primary.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Icon(Icons.bolt_rounded,
                                        size: 14, color: colorScheme.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TELEMETRY ENGINE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  'REALTIME CALC',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: colorScheme.outlineVariant,
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _MetricTile(
                                  label: 'ESTIMATED BMI',
                                  value: _bmi.toStringAsFixed(1),
                                  subLabel: _bmiStatus,
                                  subColor: bmiColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MetricTile(
                                  label: 'BASAL BURN (BMR)',
                                  value: '$_bmr',
                                  unit: 'kcal',
                                  subLabel: 'Daily base metabolic rate',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Hydration Baseline:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_hydration.toStringAsFixed(1)} L / day',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Activity selector ────────────────────────────
                    _SectionCard(
                      label: 'FITNESS & ACTIVITY PROFILE',
                      child: Row(
                        children: ['Sedentary', 'Moderate', 'Athletic']
                            .map(
                              (level) => Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _activityLevel = level),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(
                                        right: level != 'Athletic' ? 8 : 0),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 9),
                                    decoration: BoxDecoration(
                                      color: _activityLevel == level
                                          ? colorScheme.primaryContainer
                                          : colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _activityLevel == level
                                            ? colorScheme.primary
                                            : colorScheme.outlineVariant,
                                        width: _activityLevel == level ? 2 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      level,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: _activityLevel == level
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: _activityLevel == level
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Sticky footer ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant, width: 1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FtStepIndicator(totalSteps: 4, currentStep: 2),
                      Text(
                        '75% completed',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FtPrimaryButton(
                          label: 'Continue',
                          isLoading: _isSaving,
                          trailingIcon: Icon(
                            Icons.arrow_forward_rounded,
                            color: colorScheme.onPrimary,
                            size: 18,
                          ),
                          onPressed: _isSaving ? null : _continue,
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

// ── Supporting widgets ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SexBtn extends StatelessWidget {
  const _SexBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumericCard extends StatelessWidget {
  const _NumericCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.onMinus,
    required this.onPlus,
    this.badge,
  });

  final String label;
  final String value;
  final String unit;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StepperBtn(label: '−', onTap: onMinus),
              Expanded(
                child: Center(
                  child: Text(
                    'adjust',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _StepperBtn(label: '+', onTap: onPlus),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.unit,
    this.subLabel,
    this.subColor,
  });

  final String label;
  final String value;
  final String? unit;
  final String? subLabel;
  final Color? subColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Text(
                  unit!,
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (subLabel != null && unit == null) ...[
                const SizedBox(width: 5),
                Text(
                  subLabel!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: subColor ?? colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
          if (subLabel != null && unit != null) ...[
            const SizedBox(height: 2),
            Text(
              subLabel!,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnitToggleBtn extends StatelessWidget {
  const _UnitToggleBtn({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 6,
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
              color: isActive
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
