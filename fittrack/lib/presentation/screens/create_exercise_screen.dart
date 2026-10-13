import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/custom_exercise_notifier.dart';
import '../providers/theme_provider.dart';
import '../theme/ft_glass.dart';
import '../widgets/ft_background_painter.dart';
import '../widgets/modals/add_form_cue_dialog.dart';
import '../widgets/modals/add_muscle_picker_sheet.dart';
import 'create_exercise/widgets/create_exercise_header.dart';
import 'create_exercise/widgets/exercise_basics_card.dart';
import 'create_exercise/widgets/exercise_discard_dialog.dart';
import 'create_exercise/widgets/exercise_execution_steps_card.dart';
import 'create_exercise/widgets/exercise_form_cues_card.dart';
import 'create_exercise/widgets/exercise_media_card.dart';
import 'create_exercise/widgets/exercise_muscles_worked_card.dart';
import 'create_exercise/widgets/exercise_save_bar.dart';

/// Completely redesigned FitTrack Create Exercise Screen.
/// Built strictly to Stitch Screen ID de3d4ad0debd49a9905572984fbbde63 and AGENTS.md.
///
/// Features:
/// - Frosted glass cards and dynamic mesh background respecting Appearance theming.
/// - Top header with Back, Title, notification bell, and profile avatar aligned with Workout Library Search.
/// - Basics card (exercise name required, 3x2 equipment grid, 2x2 movement type grid + other).
/// - Media card (upload cover photo, YouTube video link).
/// - Execution steps card with vertical track line (max 3 steps).
/// - Form cues card with DO (teal check) and DON'T (rose cross) cues (max 3 cues).
/// - Muscles worked card with activation shares and slider tracks (max 3 muscles).
/// - Sticky bottom floating save button dock.
/// - Unsaved changes discard confirmation dialog matching Create Schedule screen.
class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(customExerciseProvider);
    _nameController = TextEditingController(text: state.title);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onBackTap() async {
    final state = ref.read(customExerciseProvider);
    if (!state.hasChanges) {
      ref.read(customExerciseProvider.notifier).reset();
      _popOrGo();
      return;
    }

    final shouldDiscard = await ExerciseDiscardDialog.show(context);
    if (!mounted) return;
    if (shouldDiscard) {
      ref.read(customExerciseProvider.notifier).reset();
      _popOrGo();
    }
  }

  void _popOrGo() {
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

  Future<void> _showAddFormCueModal(CustomExerciseNotifier notifier) async {
    final state = ref.read(customExerciseProvider);
    if (state.formCues.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Maximum 3 form cues reached',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: context.ftPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final cue = await AddFormCueDialog.show(context);
    if (cue != null) {
      notifier.addFormCue(cue);
    }
  }

  Future<void> _showAddMusclePickerSheet(
    CustomExerciseNotifier notifier,
    int currentCount,
  ) async {
    if (currentCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Maximum 3 muscles reached',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: context.ftPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final existingMuscles = ref
        .read(customExerciseProvider)
        .muscleActivations
        .map((a) => a.muscleName.toLowerCase())
        .toSet();

    final result = await AddMusclePickerSheet.show(
      context,
      currentCount: currentCount,
      existingMuscles: existingMuscles,
    );

    if (result != null) {
      notifier.addMuscleActivation(result);
    }
  }

  Future<void> _handleSave(CustomExerciseNotifier notifier) async {
    final messenger = ScaffoldMessenger.of(context);
    final primary = context.ftPrimary;

    final success = await notifier.save();
    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Exercise created successfully!',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          backgroundColor: primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      ref.read(customExerciseProvider.notifier).reset();
      _popOrGo();
    } else {
      final error =
          ref.read(customExerciseProvider).saveError ?? 'Failed to save exercise';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: const TextStyle(
              fontFamily: FtText.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: const Color(0xFFF43F5E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeNotifierProvider);
    final state = ref.watch(customExerciseProvider);
    final notifier = ref.read(customExerciseProvider.notifier);

    final bottomPadding = (MediaQuery.paddingOf(context).bottom > 0)
        ? MediaQuery.paddingOf(context).bottom + 90.0
        : 100.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onBackTap();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // 1. Dynamic Mesh Gradient Background
              const Positioned.fill(
                child: FtMeshBackground(),
              ),

              // 2. Centered Scrollable Form Slivers
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
                              // Header
                              CreateExerciseHeader(onBackTap: _onBackTap),
                              const SizedBox(height: 12),

                              // 1. Basics Card (Name, Equipment, Movement Type)
                              ExerciseBasicsCard(
                                nameController: _nameController,
                                selectedEquipment: state.equipment,
                                selectedMovement: state.movementClassification,
                                onNameChanged: notifier.setTitle,
                                onEquipmentChanged: notifier.setEquipment,
                                onMovementChanged: notifier.setMovementClassification,
                              ),
                              const SizedBox(height: 16),

                              // 2. Media Card (Cover Photo & YouTube Video)
                              ExerciseMediaCard(
                                coverImagePath: state.mediaPath,
                                youtubeUrl: state.youtubeUrl,
                                onImageSelected: notifier.setMediaPath,
                                onImageRemoved: () => notifier.setMediaPath(null),
                                onYoutubeUrlChanged: notifier.setYoutubeUrl,
                              ),
                              const SizedBox(height: 16),

                              // 3. Execution Steps Card (Max 3)
                              ExerciseExecutionStepsCard(
                                steps: state.executionSteps,
                                onAddStep: notifier.addExecutionStep,
                                onUpdateStep: notifier.updateExecutionStep,
                                onRemoveStep: notifier.removeExecutionStep,
                              ),
                              const SizedBox(height: 16),

                              // 4. Form Cues Card (Max 3)
                              ExerciseFormCuesCard(
                                cues: state.formCues,
                                onAddCueTap: () => _showAddFormCueModal(notifier),
                                onRemoveCue: notifier.removeFormCue,
                              ),
                              const SizedBox(height: 16),

                              // 5. Muscles Worked Card (Max 3)
                              ExerciseMusclesWorkedCard(
                                activations: state.muscleActivations,
                                onAddMuscleTap: () => _showAddMusclePickerSheet(
                                  notifier,
                                  state.muscleActivations.length,
                                ),
                                onRemoveMuscle: notifier.removeMuscleActivation,
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Sticky Floating Save Exercise Button Dock
              Positioned(
                left: 0,
                right: 0,
                bottom: (MediaQuery.paddingOf(context).bottom > 0)
                    ? MediaQuery.paddingOf(context).bottom + 12.0
                    : 20.0,
                child: ExerciseSaveBar(
                  isValid: state.isValid,
                  isSaving: state.isSaving,
                  onSave: () => _handleSave(notifier),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
