import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/execution_step.dart';
import '../../domain/entities/form_cue.dart';
import '../../domain/entities/muscle_activation.dart';
import '../providers/repository_providers.dart';

// ── Aggregate data class ──────────────────────────────────────────────────────

class _ExerciseGuideData {
  const _ExerciseGuideData({
    required this.exercise,
    required this.steps,
    required this.cues,
    required this.activations,
  });
  final Exercise exercise;
  final List<ExecutionStep> steps;
  final List<FormCue> cues;
  final List<MuscleActivation> activations;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final _exerciseGuideProvider = FutureProvider.autoDispose
    .family<_ExerciseGuideData, String>((ref, exerciseId) async {
  final repo = ref.read(exerciseRepositoryProvider);
  final exercise = await repo.getExerciseById(exerciseId);
  if (exercise == null) throw Exception('Exercise not found');
  final steps = await repo.getExecutionSteps(exerciseId);
  final cues = await repo.getFormCues(exerciseId);
  final activations = await repo.getMuscleActivations(exerciseId);
  return _ExerciseGuideData(
    exercise: exercise,
    steps: steps,
    cues: cues,
    activations: activations,
  );
});

// ── Screen ────────────────────────────────────────────────────────────────────

class ExerciseGuideDetailsScreen extends ConsumerStatefulWidget {
  const ExerciseGuideDetailsScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  ConsumerState<ExerciseGuideDetailsScreen> createState() =>
      _ExerciseGuideDetailsScreenState();
}

class _ExerciseGuideDetailsScreenState
    extends ConsumerState<ExerciseGuideDetailsScreen> {
  bool _fullscreenOpen = false;

  @override
  Widget build(BuildContext context) {
    final guideAsync =
        ref.watch(_exerciseGuideProvider(widget.exerciseId));

    return Scaffold(
      backgroundColor: const Color(0xFFf7f9fb),
      body: guideAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00d68f)),
        ),
        error: (e, _) => _ErrorBody(
          message: e.toString(),
          onBack: () => context.pop(),
        ),
        data: (data) => Stack(
          children: [
            _GuideBody(
              data: data,
              onFullscreen: () =>
                  setState(() => _fullscreenOpen = true),
              onBack: () => context.pop(),
            ),
            // Fullscreen modal overlay
            if (_fullscreenOpen)
              _FullscreenModal(
                exerciseName: data.exercise.name,
                onClose: () =>
                    setState(() => _fullscreenOpen = false),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Guide Body ────────────────────────────────────────────────────────────────

class _GuideBody extends StatelessWidget {
  const _GuideBody({
    required this.data,
    required this.onFullscreen,
    required this.onBack,
  });
  final _ExerciseGuideData data;
  final VoidCallback onFullscreen;
  final VoidCallback onBack;


  @override
  Widget build(BuildContext context) {
    final ex = data.exercise;

    return CustomScrollView(
      slivers: [
        // ── Sticky header ──────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFFf7f9fb),
          elevation: 0,
          scrolledUnderElevation: 1,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFe2e8f0)),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Color(0xFF475569), size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACTIVE WORKOUT GUIDE',
                      style: TextStyle(
                        color: Color(0xFF00875a),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    Text(
                      ex.name,
                      style: const TextStyle(
                        color: Color(0xFF0f172a),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Content ────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Tags row
              _TagsRow(exercise: ex),
              const SizedBox(height: 12),

              // Hero image
              _HeroMedia(
                exerciseName: ex.name,
                onFullscreen: onFullscreen,
              ),
              const SizedBox(height: 12),

              // YouTube launcher
              _YouTubeLauncher(exerciseName: ex.name),
              const SizedBox(height: 12),

              // Overview & Biomechanics
              _OverviewCard(exercise: ex),
              const SizedBox(height: 12),

              // Execution steps
              if (data.steps.isNotEmpty) ...[
                _ExecutionStepsCard(steps: data.steps),
                const SizedBox(height: 12),
              ],

              // Form cues
              if (data.cues.isNotEmpty) ...[
                _FormCuesCard(cues: data.cues),
                const SizedBox(height: 12),
              ],

              // Muscle activations
              if (data.activations.isNotEmpty) ...[
                _MuscleActivationCard(activations: data.activations),
                const SizedBox(height: 12),
              ],

              // Fallback muscle activation if DB is empty
              if (data.activations.isEmpty) ...[
                _StaticMuscleActivationCard(exerciseName: ex.name),
                const SizedBox(height: 12),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Tags Row ──────────────────────────────────────────────────────────────────

class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.exercise});
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Tag(
          label: exercise.equipment.name.toUpperCase(),
          bg: const Color(0xFFfff1f2),
          fg: const Color(0xFFe11d48),
          border: const Color(0xFFfecdd3),
        ),
        const SizedBox(width: 6),
        _Tag(
          label: exercise.movementClassification.name.toUpperCase(),
          bg: const Color(0xFFf1f5f9),
          fg: const Color(0xFF475569),
          border: const Color(0xFFe2e8f0),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFe6faf3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.bolt, color: Color(0xFF00875a), size: 13),
              SizedBox(width: 3),
              Text(
                'PRIMARY LIFT',
                style: TextStyle(
                  color: Color(0xFF00875a),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Hero Media ────────────────────────────────────────────────────────────────

class _HeroMedia extends StatelessWidget {
  const _HeroMedia(
      {required this.exerciseName, required this.onFullscreen});
  final String exerciseName;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder hero
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1e3a5f), Color(0xFF0f172a)],
                ),
              ),
              child: const Center(
                child: Icon(Icons.fitness_center,
                    color: Color(0xFF00d68f), size: 48),
              ),
            ),
            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),
            // Top overlays
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 7,
                      height: 7,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF00d68f),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'FORM FOCUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onFullscreen,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fullscreen,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            // Bottom badge
            const Positioned(
              bottom: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified,
                          color: Color(0xFF00d68f), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'GOLDEN RATIO SETUP',
                        style: TextStyle(
                          color: Color(0xFF00d68f),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Flat Bench • Arch Retained • 45° Elbow Tuck',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
}

// ── YouTube Launcher ──────────────────────────────────────────────────────────

class _YouTubeLauncher extends StatelessWidget {
  const _YouTubeLauncher({required this.exerciseName});
  final String exerciseName;

  Future<void> _launch() async {
    final query = Uri.encodeComponent(
        '$exerciseName proper form technique');
    final uri = Uri.parse(
        'https://www.youtube.com/results?search_query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launch,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFff0000).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.play_circle_filled,
                  color: Color(0xFFff0000), size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Watch on YouTube',
                        style: TextStyle(
                          color: Color(0xFF0f172a),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFff0000),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'HD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Search tutorials for "$exerciseName form"',
                    style: const TextStyle(
                      color: Color(0xFF64748b),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new,
                color: Color(0xFF94a3b8), size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Overview Card ─────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.exercise});
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final desc = exercise.biomechanicsNotes ??
        '${exercise.name} is a ${exercise.movementClassification.name} '
            '${exercise.equipment.name} exercise targeting multiple muscle groups. '
            'Focus on controlled form throughout the full range of motion.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_outlined,
                  color: Color(0xFF00d68f), size: 20),
              SizedBox(width: 8),
              Text(
                'Overview & Mechanics',
                style: TextStyle(
                  color: Color(0xFF0f172a),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Execution Steps Card ──────────────────────────────────────────────────────

class _ExecutionStepsCard extends StatelessWidget {
  const _ExecutionStepsCard({required this.steps});
  final List<ExecutionStep> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.checklist_outlined,
                      color: Color(0xFF00d68f), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Execution Steps',
                    style: TextStyle(
                      color: Color(0xFF0f172a),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Text(
                '${steps.length} Phases',
                style: const TextStyle(
                  color: Color(0xFF64748b),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StepCard(step: step),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});
  final ExecutionStep step;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF00d68f),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step.stepNumber}',
              style: const TextStyle(
                color: Color(0xFF0f172a),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  color: Color(0xFF0f172a),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                step.instructions,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Form Cues Card ────────────────────────────────────────────────────────────

class _FormCuesCard extends StatelessWidget {
  const _FormCuesCard({required this.cues});
  final List<FormCue> cues;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.balance_outlined,
                  color: Color(0xFF00d68f), size: 20),
              SizedBox(width: 8),
              Text(
                'Form Cues & Pitfalls',
                style: TextStyle(
                  color: Color(0xFF0f172a),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...cues.map(
            (cue) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CueTile(cue: cue),
            ),
          ),
        ],
      ),
    );
  }
}

class _CueTile extends StatelessWidget {
  const _CueTile({required this.cue});
  final FormCue cue;

  @override
  Widget build(BuildContext context) {
    final isPositive = cue.isPositive;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isPositive
            ? const Color(0xFFf0fdf4)
            : const Color(0xFFfef2f2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPositive ? Icons.check_circle : Icons.cancel,
            color: isPositive
                ? const Color(0xFF00d68f)
                : const Color(0xFFef4444),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPositive ? 'DO' : "DON'T",
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF00875a)
                        : const Color(0xFFdc2626),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cue.description,
                  style: const TextStyle(
                    color: Color(0xFF0f172a),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Muscle Activation Card (from DB) ─────────────────────────────────────────

class _MuscleActivationCard extends StatelessWidget {
  const _MuscleActivationCard({required this.activations});
  final List<MuscleActivation> activations;

  @override
  Widget build(BuildContext context) {
    return _ActivationCardShell(
      children: activations.map((a) {
        Color barColor;
        switch (a.role) {
          case MuscleRole.agonist:
            barColor = const Color(0xFF00d68f);
          case MuscleRole.synergist:
            barColor = const Color(0xFF0284c7);
          case MuscleRole.stabilizer:
            barColor = const Color(0xFF94a3b8);
        }
        return _ActivationBar(
          label: a.muscleName,
          percentage: a.intensityPercentage,
          barColor: barColor,
        );
      }).toList(),
    );
  }
}

// Fallback static card when DB has no activations
class _StaticMuscleActivationCard extends StatelessWidget {
  const _StaticMuscleActivationCard({required this.exerciseName});
  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    return _ActivationCardShell(
      children: const [
        _ActivationBar(
          label: 'Primary Muscles',
          percentage: 85,
          barColor: Color(0xFF00d68f),
        ),
        _ActivationBar(
          label: 'Secondary Muscles',
          percentage: 60,
          barColor: Color(0xFF0284c7),
        ),
        _ActivationBar(
          label: 'Stabilizers',
          percentage: 40,
          barColor: Color(0xFF94a3b8),
        ),
      ],
    );
  }
}

class _ActivationCardShell extends StatelessWidget {
  const _ActivationCardShell({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.fitness_center,
                      color: Color(0xFF00d68f), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Muscle Activation',
                    style: TextStyle(
                      color: Color(0xFF0f172a),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const Text(
                'Kinematic Load',
                style: TextStyle(
                  color: Color(0xFF64748b),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _ActivationBar extends StatelessWidget {
  const _ActivationBar({
    required this.label,
    required this.percentage,
    required this.barColor,
  });
  final String label;
  final int percentage;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0f172a),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: barColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  color: const Color(0xFFf1f5f9),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Back-to-workout sticky bar (handled by parent layout via bottom padding) ──
// Note: shown via the SliverPadding bottom=120 and Positioned in the parent

// ── Fullscreen Modal ──────────────────────────────────────────────────────────

class _FullscreenModal extends StatelessWidget {
  const _FullscreenModal(
      {required this.exerciseName, required this.onClose});
  final String exerciseName;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.95),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$exerciseName Cues',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1e3a5f), Color(0xFF0f172a)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center,
                            color: Color(0xFF00d68f), size: 64),
                        SizedBox(height: 16),
                        Text(
                          'Form Focus Preview',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Wrist stacked over elbows. Scapula pinned against the bench pad throughout the entire repetition.',
                            style: TextStyle(
                              color: Color(0xFF94a3b8),
                              fontSize: 13,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUICK CHECKPOINT',
                      style: TextStyle(
                        color: Color(0xFF00d68f),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Wrist stacked over elbows. Scapula pinned against the bench pad throughout entire repetition.',
                      style: TextStyle(
                        color: Color(0xFFcbd5e1),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error body ────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onBack});
  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748b)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onBack,
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable tag widget ───────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.bg,
    required this.fg,
    required this.border,
  });
  final String label;
  final Color bg;
  final Color fg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
