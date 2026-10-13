import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/schedule_editor_notifier.dart';
import '../providers/theme_provider.dart';
import '../theme/ft_glass.dart';
import '../widgets/exercise_picker/add_exercise_picker_sheet.dart';
import '../widgets/ft_background_painter.dart';
import 'create_schedule/widgets/create_schedule_header.dart';
import 'create_schedule/widgets/schedule_cover_image_card.dart';
import 'create_schedule/widgets/schedule_details_card.dart';
import 'create_schedule/widgets/schedule_exercises_section.dart';
import 'create_schedule/widgets/schedule_save_bar.dart';
import 'create_schedule/widgets/schedule_summary_strip.dart';
import 'create_schedule/widgets/schedule_target_muscles_card.dart';
import 'create_schedule/widgets/schedule_weekly_card.dart';
import 'create_schedule/widgets/schedule_discard_dialog.dart';

/// Completely redesigned FitTrack Create Schedule Screen.
/// Adheres strictly to Stitch Screen ID `378f56a0b632436289e53841eb67b6fb` and AGENTS.md.
///
/// Features:
/// - Frosted glass card designs and dynamic theming set by Appearance settings.
/// - Top header with Back button, title, notification bell, and profile avatar
///   aligned with Workout Library Search for UI consistency.
/// - 3-metric summary strip (duration, sets, energy).
/// - Name & description inputs.
/// - Optional cover image upload with preview and gallery picker.
/// - Target muscles selection (0 by default, up to 3 max).
/// - Weekly schedule (up to 3 days max).
/// - Exercises list (minimum 3, up to 12 max) with 6-dots drag to reorder.
/// - Steppers for Sets, Reps, Weight (+/- 2.5kg with direct typing), and Rest (+/- 15s).
/// - Add Exercise launches the redesigned Add Exercises Picker sheet.
/// - Sticky bottom save dock and clearance for the bottom navigation dock.
class CreateScheduleScreen extends ConsumerStatefulWidget {
  const CreateScheduleScreen({super.key});

  @override
  ConsumerState<CreateScheduleScreen> createState() =>
      _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends ConsumerState<CreateScheduleScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  int? _expandedExerciseIndex = 0;

  @override
  void initState() {
    super.initState();
    final state = ref.read(scheduleEditorProvider);
    _nameController = TextEditingController(text: state.name);
    _descController = TextEditingController(text: state.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _onBackTap() async {
    final shouldDiscard = await ScheduleDiscardDialog.show(context);
    if (!mounted) return;
    if (shouldDiscard) {
      ref.read(scheduleEditorProvider.notifier).reset();
      _popOrGo();
    }
  }

  void _navigateBackAfterSave() {
    ref.read(scheduleEditorProvider.notifier).reset();
    _popOrGo();
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

  void _showAddExercisePicker(BuildContext context, ScheduleEditorNotifier notifier, int currentCount) {
    if (currentCount >= 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Schedule is full (maximum 12 exercises reached)',
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

    final themeSettings = ref.read(themeNotifierProvider);
    final enableTransparency = themeSettings.enableGlassTransparency;
    final blurIntensity = themeSettings.blurIntensity;
    final double t = ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0);
    final double scrimSigma = enableTransparency ? (6.0 + 10.0 * t) : 0.0;

    final sheet = AddExercisePickerSheet(
      currentExercisesCount: currentCount,
      existingExerciseIds: ref
          .read(scheduleEditorProvider)
          .exercises
          .map((e) => e.exerciseId)
          .toSet(),
      onExercisesAdded: (selected) {
        notifier.addExercises(selected);
      },
      onCreateNew: () => context.push('/exercises/create-custom'),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.45),
      builder: (_) => enableTransparency && scrimSigma > 0
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: scrimSigma, sigmaY: scrimSigma),
              child: sheet,
            )
          : sheet,
    );
  }

  Future<void> _handleSave(ScheduleEditorNotifier notifier) async {
    final messenger = ScaffoldMessenger.of(context);
    final primary = context.ftPrimary;

    final success = await notifier.save();
    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Schedule created successfully!',
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
      _navigateBackAfterSave();
    } else {
      final error = ref.read(scheduleEditorProvider).saveError ?? 'Failed to save schedule';
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
    final themeSettings = ref.watch(themeNotifierProvider);
    final state = ref.watch(scheduleEditorProvider);
    final notifier = ref.read(scheduleEditorProvider.notifier);

    // Dock clearance padding: save bar clearance
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
                            // Header with Back, Title, Notification Bell & Avatar
                            CreateScheduleHeader(onBackTap: _onBackTap),
                            const SizedBox(height: 12),

                            // 1. Summary Strip Card
                            ScheduleSummaryStrip(
                              durationFormatted: state.totalDurationFormatted,
                              totalSets: state.totalSets,
                              estimatedCalories: state.estimatedCalories,
                              settings: themeSettings,
                            ),
                            const SizedBox(height: 16),

                            // 2. Details Card (Name & Description)
                            ScheduleDetailsCard(
                              nameController: _nameController,
                              descController: _descController,
                              settings: themeSettings,
                              onNameChanged: notifier.setName,
                              onDescChanged: notifier.setDescription,
                            ),
                            const SizedBox(height: 16),

                            // 2b. Cover Image Card (Optional)
                            ScheduleCoverImageCard(
                              coverImagePath: state.coverImagePath,
                              settings: themeSettings,
                              onImageSelected: notifier.setCoverImagePath,
                              onImageRemoved: () => notifier.setCoverImagePath(null),
                            ),
                            const SizedBox(height: 16),

                            // 3. Target Muscles Card (0 default, up to 3 max)
                            ScheduleTargetMusclesCard(
                              selectedMuscles: state.targetMuscles,
                              settings: themeSettings,
                              onToggleMuscle: notifier.toggleMuscle,
                            ),
                            const SizedBox(height: 16),

                            // 4. Weekly Schedule Card (up to 3 days max)
                            ScheduleWeeklyCard(
                              assignedWeekdays: state.assignedWeekdays,
                              settings: themeSettings,
                              onToggleWeekday: notifier.toggleWeekday,
                            ),
                            const SizedBox(height: 16),

                            // 5. Exercises Section (min 3, max 12)
                            ScheduleExercisesSection(
                              exercises: state.exercises,
                              expandedIndex: _expandedExerciseIndex,
                              settings: themeSettings,
                              onToggleExpand: (idx) {
                                setState(() {
                                  _expandedExerciseIndex =
                                      _expandedExerciseIndex == idx ? null : idx;
                                });
                              },
                              onAddExerciseTap: () => _showAddExercisePicker(
                                context,
                                notifier,
                                state.exercises.length,
                              ),
                              onRemoveExercise: notifier.removeExercise,
                              onReorderExercises: notifier.reorderExercises,
                              onUpdateSets: (idx, sets) =>
                                  notifier.updateExerciseParam(idx, sets: sets),
                              onUpdateReps: (idx, reps) =>
                                  notifier.updateExerciseParam(idx, reps: reps),
                              onUpdateWeight: (idx, weight) =>
                                  notifier.updateExerciseParam(idx, weightKg: weight),
                              onUpdateRest: (idx, rest) =>
                                  notifier.updateExerciseParam(idx, restSeconds: rest),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Sticky Save Schedule Button Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: (MediaQuery.paddingOf(context).bottom > 0)
                  ? MediaQuery.paddingOf(context).bottom + 12.0
                  : 20.0,
              child: ScheduleSaveBar(
                isValid: state.isValid,
                isSaving: state.isSaving,
                validationMessage: state.validationMessage,
                settings: themeSettings,
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
