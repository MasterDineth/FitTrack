import 'package:flutter/material.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Basics Section Card for Create Exercise.
/// Matches Stitch Screen ID de3d4ad0debd49a9905572984fbbde63.
///
/// Features:
/// - Exercise name (required) input field.
/// - 3x2 Equipment selection grid (single select).
/// - 2x2 + full-width Movement type selection grid (single select).
class ExerciseBasicsCard extends StatelessWidget {
  const ExerciseBasicsCard({
    super.key,
    required this.nameController,
    required this.selectedEquipment,
    required this.selectedMovement,
    required this.onNameChanged,
    required this.onEquipmentChanged,
    required this.onMovementChanged,
  });

  final TextEditingController nameController;
  final Equipment selectedEquipment;
  final MovementClassification selectedMovement;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<Equipment> onEquipmentChanged;
  final ValueChanged<MovementClassification> onMovementChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FtGlassTheme.cardDecoration(
        context,
        radius: 24,
        settings: settings,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.edit_rounded,
                  color: primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Basics',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── FormField: Exercise Name (Required) ──────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x1F1E1838)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0x33FFFFFF)
                    : Colors.white.withValues(alpha: 0.90),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXERCISE NAME (REQUIRED)',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: nameController,
                  onChanged: onNameChanged,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'e.g. Incline Dumbbell Hammer Press',
                    hintStyle: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: muted.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Equipment Section (3x2 Grid) ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Equipment',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              Text(
                'Choose one',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3x2 Grid
          Row(
            children: [
              Expanded(child: _buildEquipmentTile(context, Equipment.barbell, 'Barbell', Icons.fitness_center_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildEquipmentTile(context, Equipment.dumbbell, 'Dumbbell', Icons.fitness_center_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildEquipmentTile(context, Equipment.cable, 'Cable', Icons.sync_alt_rounded)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildEquipmentTile(context, Equipment.machine, 'Machine', Icons.settings_accessibility_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildEquipmentTile(context, Equipment.bodyweight, 'Bodyweight', Icons.accessibility_new_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildEquipmentTile(context, Equipment.other, 'Other', Icons.more_horiz_rounded)),
            ],
          ),
          const SizedBox(height: 20),

          // ── Movement Type Section (2x2 Grid + Full-Width Other) ──────────
          Text(
            'Movement type',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
          const SizedBox(height: 10),

          // Row 1: Compound & Isolation
          Row(
            children: [
              Expanded(
                child: _buildMovementTile(
                  context,
                  MovementClassification.compound,
                  'Compound',
                  'Multi-joint movement',
                  Icons.layers_rounded,
                  hasTealDot: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMovementTile(
                  context,
                  MovementClassification.isolation,
                  'Isolation',
                  'Single-joint focus',
                  Icons.adjust_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Calisthenics & Mobility
          Row(
            children: [
              Expanded(
                child: _buildMovementTile(
                  context,
                  MovementClassification.calisthenics,
                  'Calisthenics',
                  'Bodyweight control',
                  Icons.sports_gymnastics_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMovementTile(
                  context,
                  MovementClassification.mobility,
                  'Mobility',
                  'Stretch and joint health',
                  Icons.self_improvement_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Full-Width Other Pattern Button
          _buildMovementOtherTile(context),
        ],
      ),
    );
  }

  Widget _buildEquipmentTile(
    BuildContext context,
    Equipment equipment,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedEquipment == equipment;
    final primary = context.ftPrimary;
    final isDark = context.isDark;

    return FtPressable(
      onTap: () => onEquipmentChanged(equipment),
      pressedScale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primary
              : (isDark
                  ? const Color(0x1F1E1838)
                  : Colors.white.withValues(alpha: 0.70)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark
                    ? const Color(0x33FFFFFF)
                    : Colors.white.withValues(alpha: 0.85)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : context.ftMuted,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : context.ftInk,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementTile(
    BuildContext context,
    MovementClassification movement,
    String title,
    String subtitle,
    IconData icon, {
    bool hasTealDot = false,
  }) {
    final isSelected = selectedMovement == movement;
    final primary = context.ftPrimary;
    final isDark = context.isDark;

    return FtPressable(
      onTap: () => onMovementChanged(movement),
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? primary
              : (isDark
                  ? const Color(0x1F1E1838)
                  : Colors.white.withValues(alpha: 0.70)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark
                    ? const Color(0x33FFFFFF)
                    : Colors.white.withValues(alpha: 0.85)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : context.ftMuted,
                ),
                if (hasTealDot && isSelected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2DD4BF),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : context.ftInk,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.88)
                    : context.ftMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementOtherTile(BuildContext context) {
    const movement = MovementClassification.other;
    final isSelected = selectedMovement == movement;
    final primary = context.ftPrimary;
    final isDark = context.isDark;

    return FtPressable(
      onTap: () => onMovementChanged(movement),
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? primary
              : (isDark
                  ? const Color(0x1F1E1838)
                  : Colors.white.withValues(alpha: 0.70)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark
                    ? const Color(0x33FFFFFF)
                    : Colors.white.withValues(alpha: 0.85)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.20)
                    : (isDark
                        ? const Color(0x26FFFFFF)
                        : const Color(0xFFF1EDFC)),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.alt_route_rounded,
                size: 18,
                color: isSelected ? Colors.white : context.ftMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Other',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : context.ftInk,
                    ),
                  ),
                  Text(
                    'Custom movement pattern',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.88)
                          : context.ftMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isSelected ? Colors.white : context.ftMuted,
            ),
          ],
        ),
      ),
    );
  }
}
