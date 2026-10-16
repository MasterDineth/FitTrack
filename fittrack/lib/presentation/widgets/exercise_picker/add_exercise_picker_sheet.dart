import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/exercise_catalog.dart';
import '../../providers/repository_providers.dart';
import '../../providers/schedule_editor_notifier.dart';
import '../../providers/theme_provider.dart';
import '../../theme/ft_glass.dart';
import 'widgets/exercise_picker_category_chips.dart';
import 'widgets/exercise_picker_footer.dart';
import 'widgets/exercise_picker_list.dart';
import 'widgets/exercise_picker_search_bar.dart';

final _allExercisesProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(exerciseRepositoryProvider).getAllExercises();
});

/// Redesigned FitTrack Add Exercises Picker Modal Sheet.
/// Matches Stitch Screen ID 5c82f20a73eb45e9a4f95de877d5b4f9.
///
/// Features:
/// - 88% screen height anchored bottom sheet with frosted glass styling and 12px margins.
/// - Top grabber pill and header with pulsating selection badge.
/// - Live search field with instant clear.
/// - Category choice chips: "All", "Chest", "Back", "Shoulders", "Arms", "Core", "Legs", "Glutes".
/// - Multi-selection capped at min(4, 12 - currentExercisesCount).
/// - 44x44 exercise cover thumbnail with default placeholder.
/// - Equipment and movement type tags with animated circular checkbox indicators.
/// - Glass bottom tray with "Create new" and "Add X exercises" buttons.
class AddExercisePickerSheet extends ConsumerStatefulWidget {
  const AddExercisePickerSheet({
    super.key,
    required this.onExercisesAdded,
    this.onCreateNew,
    this.currentExercisesCount = 0,
    this.existingExerciseIds = const <String>{},
  });

  final void Function(List<ScheduleExerciseEntry> selected) onExercisesAdded;
  final VoidCallback? onCreateNew;
  final int currentExercisesCount;
  final Set<String> existingExerciseIds;

  @override
  ConsumerState<AddExercisePickerSheet> createState() =>
      _AddExercisePickerSheetState();
}

class _AddExercisePickerSheetState extends ConsumerState<AddExercisePickerSheet>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  String _query = '';
  String _selectedCategory = 'All';
  final Set<String> _selectedExerciseIds = {};

  static const _categoryChips = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Core',
    'Legs',
    'Glutes',
  ];

  int get _maxAllowedSelection {
    final remainingSlots = (12 - widget.currentExercisesCount).clamp(0, 12);
    return remainingSlots < 4 ? remainingSlots : 4;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool _isAlreadyInSchedule(Exercise exercise) {
    if (widget.existingExerciseIds.contains(exercise.id)) return true;

    final canonicalId = ExerciseCatalog.toCanonicalId(exercise.id);
    if (canonicalId != null && widget.existingExerciseIds.contains(canonicalId)) {
      return true;
    }
    final aliasId = ExerciseCatalog.toAliasId(exercise.id);
    if (aliasId != null && widget.existingExerciseIds.contains(aliasId)) {
      return true;
    }

    final exName = exercise.name.trim().toLowerCase();
    for (final existingId in widget.existingExerciseIds) {
      if (ExerciseCatalog.isSameExercise(exercise.id, existingId, name1: exercise.name)) {
        return true;
      }
      final existingName = ExerciseCatalog.resolveName(existingId).trim().toLowerCase();
      if (existingName.isNotEmpty &&
          (existingName == exName ||
              (existingName.contains('deadlift') &&
                  exName.contains('deadlift') &&
                  existingName.contains('romanian') == exName.contains('romanian')))) {
        return true;
      }
    }
    return false;
  }

  void _onToggleExercise(Exercise exercise) {
    if (_isAlreadyInSchedule(exercise)) return;
    setState(() {
      if (_selectedExerciseIds.contains(exercise.id)) {
        _selectedExerciseIds.remove(exercise.id);
      } else {
        if (_selectedExerciseIds.length >= _maxAllowedSelection) {
          final remainingSlots = 12 - widget.currentExercisesCount;
          final msg = remainingSlots <= 0
              ? 'Schedule is full (12 exercises max)'
              : (remainingSlots < 4
                  ? 'Only $remainingSlots more exercise${remainingSlots > 1 ? 's' : ''} can be added (12 max)'
                  : 'You can select up to 4 exercises at once');

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                msg,
                style: const TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              backgroundColor: context.ftPrimary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
          return;
        }
        _selectedExerciseIds.add(exercise.id);
      }
    });
  }

  bool _matchesCategory(Exercise ex, String category) {
    if (category == 'All') return true;
    final name = ex.name.toLowerCase();
    return switch (category) {
      'Chest' => name.contains('bench') || name.contains('chest') || name.contains('fly'),
      'Back' => name.contains('row') || name.contains('pull') || name.contains('lat') || name.contains('back') || name.contains('deadlift'),
      'Shoulders' => name.contains('overhead') || name.contains('press') || name.contains('shoulder') || name.contains('lateral'),
      'Arms' => name.contains('curl') || name.contains('bicep') || name.contains('tricep') || name.contains('pushdown') || name.contains('extension') || name.contains('arm'),
      'Core' => name.contains('crunch') || name.contains('plank') || name.contains('ab') || name.contains('core'),
      'Legs' => name.contains('squat') || name.contains('leg') || name.contains('quad') || name.contains('hamstring') || name.contains('calf'),
      'Glutes' => name.contains('glute') || name.contains('squat') || name.contains('deadlift') || name.contains('hip') || name.contains('thrust'),
      _ => true,
    };
  }

  List<Exercise> _filterExercises(List<Exercise> all) {
    final seen = <String>{};
    final deduplicated = <Exercise>[];
    for (final ex in all) {
      final key = ExerciseCatalog.toCanonicalId(ex.id) ?? ex.name.trim().toLowerCase();
      if (seen.add(key)) {
        final displayName = ExerciseCatalog.resolveName(ex.id, fallbackName: ex.name);
        deduplicated.add(ex.copyWith(name: displayName));
      }
    }

    return deduplicated.where((ex) {
      final q = _query.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          ex.name.toLowerCase().contains(q) ||
          ex.equipment.name.toLowerCase().contains(q) ||
          ex.movementClassification.name.toLowerCase().contains(q);
      final matchesCat = _matchesCategory(ex, _selectedCategory);
      return matchesSearch && matchesCat;
    }).toList();
  }

  void _submitSelection(List<Exercise> allExercises) {
    final entries = _selectedExerciseIds.map((id) {
      final ex = allExercises.firstWhere(
        (e) => e.id == id,
        orElse: () => Exercise(
          id: id,
          name: ExerciseCatalog.resolveName(id),
          equipment: Equipment.other,
          movementClassification: MovementClassification.other,
          isCustom: false,
        ),
      );
      final canonicalId = ExerciseCatalog.toCanonicalId(ex.id) ?? ex.id;
      final resolvedName = ExerciseCatalog.resolveName(ex.id, fallbackName: ex.name);
      return ScheduleExerciseEntry(
        exerciseId: canonicalId,
        exerciseName: resolvedName,
        equipment: ex.equipment.name,
        movementType: ex.movementClassification.name,
        mediaUrl: ex.mediaUrl ?? ExerciseCatalog.resolveImage(canonicalId),
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 0.0,
        restDurationSeconds: 90,
      );
    }).toList();

    widget.onExercisesAdded(entries);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(_allExercisesProvider);
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final settings = ref.watch(themeNotifierProvider);
    final enableTransparency = settings.enableGlassTransparency;
    final blurIntensity = settings.blurIntensity;
    final double t = ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0);
    final double effectiveSigma = enableTransparency ? (14.0 + 20.0 * t) : 0.0;

    final Color sheetFill;
    final Color sheetBorder;
    final List<BoxShadow> sheetShadow;

    if (!enableTransparency) {
      sheetFill = isDark ? const Color(0xFF161226) : Colors.white;
      sheetBorder = isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0);
      sheetShadow = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.10),
          blurRadius: 32,
          offset: const Offset(0, -8),
        ),
      ];
    } else {
      final double fillAlpha = isDark ? (0.52 + 0.20 * t) : (0.48 + 0.22 * t);
      sheetFill = isDark
          ? const Color(0xFF161226).withValues(alpha: fillAlpha)
          : Colors.white.withValues(alpha: fillAlpha);
      sheetBorder = isDark
          ? const Color(0x38FFFFFF)
          : Colors.white.withValues(alpha: 0.55 + 0.35 * t);
      sheetShadow = [
        BoxShadow(
          color: primary.withValues(alpha: isDark ? 0.30 : 0.16),
          blurRadius: 40,
          offset: const Offset(0, -10),
        ),
      ];
    }

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final Widget sheetContent = Column(
      children: [
        // ── Top Grabber Pill ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x4DFFFFFF)
                    : const Color(0xFFCAC4D7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),

        // ── Header Row (Title & Selected Badge) ─────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Add exercises',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _pulseAnimation,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_selectedExerciseIds.length} selected',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Search FormField ─────────────────────────────────────────
        ExercisePickerSearchBar(
          controller: _searchController,
          query: _query,
          settings: settings,
          onQueryChanged: (v) => setState(() => _query = v),
          onClear: () {
            _searchController.clear();
            setState(() => _query = '');
          },
        ),

        // ── Horizontal ChoiceChip Category Row ──────────────────────
        ExercisePickerCategoryChips(
          categories: _categoryChips,
          selectedCategory: _selectedCategory,
          settings: settings,
          onCategorySelected: (cat) =>
              setState(() => _selectedCategory = cat),
        ),

        // ── Selectable Exercise Rows List ────────────────────────────
        Expanded(
          child: exercisesAsync.when(
            data: (exercises) => ExercisePickerList(
              exercises: _filterExercises(exercises),
              selectedExerciseIds: _selectedExerciseIds,
              existingExerciseIds: widget.existingExerciseIds,
              settings: settings,
              onToggleExercise: _onToggleExercise,
            ),
            loading: () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
            error: (e, _) => Center(
              child: Text(
                'Failed to load exercises: $e',
                style: TextStyle(color: muted, fontSize: 13),
              ),
            ),
          ),
        ),

        // ── Floating Bottom Footer Tray ──────────────────────────────
        ExercisePickerFooter(
          selectedCount: _selectedExerciseIds.length,
          settings: settings,
          onCreateNew: () {
            Navigator.of(context).pop();
            widget.onCreateNew?.call();
          },
          onAddSelected: () {
            if (exercisesAsync.hasValue) {
              _submitSelection(exercisesAsync.value!);
            }
          },
        ),
      ],
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 393),
        child: Container(
          height: MediaQuery.sizeOf(context).height * 0.88,
          margin: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: bottomInset > 0 ? bottomInset : 12,
          ),
          decoration: BoxDecoration(
            color: sheetFill,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: sheetBorder,
              width: 1.2,
            ),
            boxShadow: sheetShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: enableTransparency && effectiveSigma > 0
                ? BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: effectiveSigma,
                      sigmaY: effectiveSigma,
                    ),
                    child: sheetContent,
                  )
                : sheetContent,
          ),
        ),
      ),
    );
  }
}
