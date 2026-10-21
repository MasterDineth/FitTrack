import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../domain/entities/exercise_catalog.dart';
import '../../../theme/ft_glass.dart';

/// Cinematic hero media for the Exercise Details screen.
///
/// Resolves the recorded cover image (bundled asset or a local file captured
/// by the Create Exercise screen) and falls back to the catalog default image
/// whenever no image is available.
class ExerciseMediaHero extends StatelessWidget {
  const ExerciseMediaHero({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.mediaUrl,
    required this.isCustom,
    this.primaryMuscle,
    this.stepCount = 0,
  });

  final String exerciseId;
  final String exerciseName;
  final String? mediaUrl;
  final bool isCustom;
  final String? primaryMuscle;
  final int stepCount;

  static const String _fallbackAsset =
      'assets/images/dashboard/coaching_bench.webp';

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth =
        (MediaQuery.sizeOf(context).width * dpr).round().clamp(320, 1400);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              image: true,
              label: '$exerciseName demonstration',
              child: _buildImage(context, cacheWidth),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x1A000000),
                    Color(0xB3000000),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OverlayPill(
                    icon: isCustom
                        ? Icons.person_rounded
                        : Icons.fitness_center_rounded,
                    label: isCustom ? 'Your exercise' : 'Library exercise',
                    iconColor: const Color(0xFF2DD4BF),
                  ),
                  if (stepCount > 0)
                    _OverlayPill(
                      icon: Icons.format_list_numbered_rounded,
                      label: '$stepCount ${stepCount == 1 ? 'step' : 'steps'}',
                      iconColor: const Color(0xFFFFC24B),
                    ),
                ],
              ),
            ),
            if (primaryMuscle != null)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2DD4BF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              primaryMuscle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildImage(BuildContext context, int cacheWidth) {
    final source = mediaUrl?.trim();
    if (source == null || source.isEmpty) {
      return Image.asset(
        ExerciseCatalog.resolveImage(exerciseId),
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => Image.asset(
          _fallbackAsset,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
        ),
      );
    }

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => Image.asset(
          _fallbackAsset,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
        ),
      );
    }

    return Image.file(
      File(source),
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      errorBuilder: (_, _, _) => Image.asset(
        ExerciseCatalog.resolveImage(exerciseId),
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => Image.asset(
          _fallbackAsset,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
        ),
      ),
    );
  }
}

/// Small dark translucent badge layered over the hero media.
class _OverlayPill extends StatelessWidget {
  const _OverlayPill({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
