import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/exercise_details_provider.dart';
import '../../theme/ft_glass.dart';
import '../../widgets/ft_background_painter.dart';
import '../../widgets/glass_surface.dart';
import 'widgets/exercise_details_dock.dart';
import 'widgets/exercise_details_header.dart';
import 'widgets/exercise_hero_card.dart';
import 'widgets/execution_steps_section.dart';
import 'widgets/form_cues_section.dart';
import 'widgets/muscles_worked_section.dart';

/// Exercise Details screen.
///
/// Opened from the info icon of the active exercise inside the Active
/// Workout screen. It renders every detail recorded for the exercise — name,
/// description, cover image, YouTube guide, execution steps, form cues and
/// muscle activation — and hides any section that has no recorded data.
class ExerciseDetailsScreen extends ConsumerWidget {
  const ExerciseDetailsScreen({
    super.key,
    required this.exerciseId,
  });

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(exerciseDetailsProvider(exerciseId));
    final details = detailsAsync.value;

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomPadding = 118.0 + bottomInset;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Dynamic mesh gradient background driven by the active accent.
          const Positioned.fill(child: FtMeshBackground()),

          // 2. Scrollable content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 393),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverSafeArea(
                    top: true,
                    bottom: false,
                    sliver: SliverPadding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: bottomPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          ExerciseDetailsHeader(
                            onBackTap: () => _goBack(context),
                            exerciseName: details?.exercise.name ?? '',
                          ),
                          const SizedBox(height: 12),
                          ..._buildContent(context, ref, detailsAsync),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating bottom action dock
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ExerciseDetailsDock(
              onBackToWorkout: () => _goBack(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<ExerciseDetails> detailsAsync,
  ) {
    // An error is checked before the value because a provider that failed can
    // still report a pending state while it is being retried.
    if (detailsAsync.hasError) {
      return [
        _StatusCard(
          icon: Icons.error_outline_rounded,
          message: 'We could not load this exercise right now.',
          isError: true,
          actionLabel: 'Try again',
          onAction: () =>
              ref.invalidate(exerciseDetailsProvider(exerciseId)),
        ),
      ];
    }

    final details = detailsAsync.value;
    if (details == null) {
      return const [
        _StatusCard(
          icon: Icons.hourglass_empty_rounded,
          message: 'Loading exercise details…',
        ),
      ];
    }

    final widgets = <Widget>[];

    widgets.add(
      ExerciseHeroCard(
        exercise: details.exercise,
        primaryActivation: details.primaryActivation,
        stepCount: details.steps.length,
        description: details.description,
        youtubeUrl: details.youtubeLink,
      ),
    );

    if (details.steps.isNotEmpty) {
      widgets
        ..add(const SizedBox(height: 16))
        ..add(ExecutionStepsSection(steps: details.steps));
    }

    if (details.cues.isNotEmpty) {
      widgets
        ..add(const SizedBox(height: 16))
        ..add(FormCuesSection(cues: details.cues));
    }

    if (details.activations.isNotEmpty) {
      widgets
        ..add(const SizedBox(height: 16))
        ..add(MusclesWorkedSection(activations: details.activations));
    }

    return widgets;
  }

  void _goBack(BuildContext context) {
    try {
      if (context.canPop()) {
        context.pop();
        return;
      }
      context.go('/workouts');
    } catch (_) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

/// Loading / error placeholder card.
class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.message,
    this.isError = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final muted = context.ftMuted;
    final accent = isError ? const Color(0xFFF43F5E) : context.ftPrimary;

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: FtGlassTheme.radiusHero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: accent),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: muted,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
