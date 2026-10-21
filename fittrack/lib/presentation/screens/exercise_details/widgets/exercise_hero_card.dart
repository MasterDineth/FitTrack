import 'package:flutter/material.dart';

import '../../../../domain/entities/exercise.dart';
import '../../../../domain/entities/muscle_activation.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import 'details_section_header.dart';
import 'exercise_media_hero.dart';
import 'exercise_spec_strip.dart';
import 'exercise_video_row.dart';

/// Top glass card of the Exercise Details screen.
///
/// Carries the exercise identity (badges, name, description), the cover media,
/// the recorded YouTube guide and the quick-spec strip. Sections without
/// recorded data are not rendered at all.
class ExerciseHeroCard extends StatelessWidget {
  const ExerciseHeroCard({
    super.key,
    required this.exercise,
    required this.primaryActivation,
    required this.stepCount,
    this.description,
    this.youtubeUrl,
  });

  final Exercise exercise;
  final MuscleActivation? primaryActivation;
  final int stepCount;
  final String? description;
  final String? youtubeUrl;

  @override
  Widget build(BuildContext context) {
    final ink = context.ftInk;
    final muted = context.ftMuted;

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: FtGlassTheme.radiusHero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Metadata badges ───────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DetailsPill(
                label: _equipmentLabel(exercise.equipment),
                icon: Icons.fitness_center_rounded,
                variant: DetailsPillVariant.solid,
              ),
              DetailsPill(
                label: _movementLabel(exercise.movementClassification),
                icon: Icons.layers_rounded,
                variant: DetailsPillVariant.outline,
              ),
              if (primaryActivation != null)
                DetailsPill(
                  label: primaryActivation!.muscleName,
                  leadingDot: const Color(0xFF2DD4BF),
                  variant: DetailsPillVariant.soft,
                ),
            ],
          ),

          // ── Name ──────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Text(
            exercise.name,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.15,
              color: ink,
            ),
          ),

          // ── Description (only when recorded) ─────────────────────────
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: muted,
              ),
            ),
          ],

          // ── Cover media ───────────────────────────────────────────────
          const SizedBox(height: 14),
          ExerciseMediaHero(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            mediaUrl: exercise.mediaUrl,
            isCustom: exercise.isCustom,
            primaryMuscle: primaryActivation?.muscleName,
            stepCount: stepCount,
          ),

          // ── YouTube guide (only when recorded) ────────────────────────
          if (youtubeUrl != null) ...[
            const SizedBox(height: 12),
            ExerciseVideoRow(youtubeUrl: youtubeUrl!),
          ],

          // ── Quick specs ───────────────────────────────────────────────
          const SizedBox(height: 12),
          ExerciseSpecStrip(
            exercise: exercise,
            primaryActivation: primaryActivation,
          ),
        ],
      ),
    );
  }

  static String _equipmentLabel(Equipment equipment) {
    switch (equipment) {
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.cable:
        return 'Cable';
      case Equipment.machine:
        return 'Machine';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.other:
        return 'Other';
    }
  }

  static String _movementLabel(MovementClassification classification) {
    switch (classification) {
      case MovementClassification.compound:
        return 'Compound';
      case MovementClassification.isolation:
        return 'Isolation';
      case MovementClassification.calisthenics:
        return 'Calisthenics';
      case MovementClassification.mobility:
        return 'Mobility';
      case MovementClassification.other:
        return 'Other';
    }
  }
}
