import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../domain/entities/muscle_activation.dart';
import '../../providers/custom_exercise_notifier.dart';
import '../../screens/dashboard/widgets/ft_pressable.dart';
import '../../theme/ft_glass.dart';

/// Muscle metadata model for the picker.
class _MuscleInfo {
  final String name;
  final String category; // 'chest', 'shoulders', 'arms', 'back', 'legs', 'core'

  const _MuscleInfo(this.name, this.category);
}

/// Completely redesigned FitTrack Add Muscle Picker matching Stitch Screen ID d7ba2fb02dc84158bc0a51f7f0ef1d8a.
///
/// Features:
/// - Frosted glass styling adhering to Appearance settings.
/// - Top grabber pill and "Add muscle" title.
/// - Live frosted search field with instant clear.
/// - Category choice chips: "All", "Chest", "Shoulders", "Arms", "Back", "Legs", "Core".
/// - Single-select muscle list with clear radio checkmark.
/// - Docked configuration panel:
///   - Active muscle name with "Change" button.
///   - Role segmented control: "Prime mover", "Synergist", "Stabilizer", with descriptive caption.
///   - Activation control: dynamic recruitment badge, large percentage display, +/- stepper buttons, slider (5-100%), and step mark labels.
/// - Enforces maximum 3 muscles per exercise.
/// - Returns [MuscleActivationDraft] on submit, or `null` when dismissed.
class AddMusclePickerSheet extends StatefulWidget {
  const AddMusclePickerSheet({
    super.key,
    this.currentCount = 0,
    this.existingMuscles = const <String>{},
  });

  final int currentCount;
  final Set<String> existingMuscles;

  /// Convenience show method with frosted backdrop blur and themed container.
  static Future<MuscleActivationDraft?> show(
    BuildContext context, {
    int currentCount = 0,
    Set<String> existingMuscles = const <String>{},
  }) async {
    final settings = FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;
    final blurIntensity = settings?.blurIntensity ?? 16.0;

    final double t = ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0);
    final double scrimSigma = enableTransparency ? (6.0 + 10.0 * t) : 0.0;

    final sheet = AddMusclePickerSheet(
      currentCount: currentCount,
      existingMuscles: existingMuscles,
    );

    return showModalBottomSheet<MuscleActivationDraft>(
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

  @override
  State<AddMusclePickerSheet> createState() => _AddMusclePickerSheetState();
}

class _AddMusclePickerSheetState extends State<AddMusclePickerSheet> {
  static const List<_MuscleInfo> _allMuscles = [
    // Chest
    _MuscleInfo('Chest', 'chest'),
    _MuscleInfo('Upper chest', 'chest'),
    _MuscleInfo('Lower chest', 'chest'),
    // Shoulders
    _MuscleInfo('Front deltoid', 'shoulders'),
    _MuscleInfo('Side deltoid', 'shoulders'),
    _MuscleInfo('Rear deltoid', 'shoulders'),
    // Arms
    _MuscleInfo('Biceps', 'arms'),
    _MuscleInfo('Triceps', 'arms'),
    _MuscleInfo('Forearms', 'arms'),
    // Back
    _MuscleInfo('Upper back', 'back'),
    _MuscleInfo('Lats', 'back'),
    // Legs
    _MuscleInfo('Quadriceps', 'legs'),
    _MuscleInfo('Hamstrings', 'legs'),
    _MuscleInfo('Calves', 'legs'),
    // Core
    _MuscleInfo('Abs', 'core'),
    _MuscleInfo('Obliques', 'core'),
  ];

  static const List<String> _categories = [
    'All',
    'Chest',
    'Shoulders',
    'Arms',
    'Back',
    'Legs',
    'Core',
  ];

  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedMuscle = 'Hamstrings';
  MuscleRole _selectedRole = MuscleRole.agonist;
  int _activation = 70;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Default to first non-existing muscle if available
    for (final m in _allMuscles) {
      if (!widget.existingMuscles.contains(m.name.toLowerCase())) {
        _selectedMuscle = m.name;
        break;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_MuscleInfo> get _filteredMuscles {
    return _allMuscles.where((m) {
      final matchesCategory = _selectedCategory == 'All' ||
          m.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  String get _recruitmentBadgeText {
    if (_activation >= 75) return 'Maximum recruitment';
    if (_activation >= 45) return 'High recruitment';
    if (_activation >= 25) return 'Moderate support';
    return 'Minimal assistance';
  }

  Color _recruitmentBadgeColor(BuildContext context) {
    if (_activation >= 45) return context.ftPrimary;
    if (_activation >= 25) return const Color(0xFF006B5F);
    return context.ftMuted;
  }

  String get _roleDescription {
    switch (_selectedRole) {
      case MuscleRole.agonist:
        return 'The main muscle doing the work.';
      case MuscleRole.synergist:
        return 'Assists the prime mover with extra force.';
      case MuscleRole.stabilizer:
        return 'Fixates the joint to maintain clean form.';
    }
  }

  void _submit() {
    if (widget.currentCount >= 3) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Exercise already has 3 muscles (maximum reached)',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: const Color(0xFFF43F5E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (widget.existingMuscles.contains(_selectedMuscle.toLowerCase())) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_selectedMuscle is already added',
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
      return;
    }

    Navigator.of(context).pop(
      MuscleActivationDraft(
        muscleName: _selectedMuscle,
        role: _selectedRole,
        intensityPercentage: _activation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    final enableTransparency = settings?.enableGlassTransparency ?? true;
    final blurIntensity = settings?.blurIntensity ?? 16.0;
    final double t = enableTransparency
        ? ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0)
        : 1.0;

    final searchBarFill = isDark
        ? const Color(0x1F1E1838)
        : (enableTransparency
            ? Colors.white.withValues(alpha: 0.40 + 0.20 * t)
            : Colors.white.withValues(alpha: 0.85));
    final searchBarBorder = isDark
        ? const Color(0x33FFFFFF)
        : (enableTransparency
            ? Colors.white.withValues(alpha: 0.50 + 0.25 * t)
            : Colors.white.withValues(alpha: 0.90));
    final listContainerFill = isDark
        ? const Color(0x1F1E1838)
        : (enableTransparency
            ? Colors.white.withValues(alpha: 0.38 + 0.20 * t)
            : Colors.white.withValues(alpha: 0.75));
    final listContainerBorder = isDark
        ? const Color(0x33FFFFFF)
        : (enableTransparency
            ? Colors.white.withValues(alpha: 0.50 + 0.25 * t)
            : Colors.white.withValues(alpha: 0.85));
    final panelFill = isDark
        ? const Color(0x3D1E1838)
        : (enableTransparency
            ? Colors.white.withValues(alpha: 0.42 + 0.20 * t)
            : Colors.white.withValues(alpha: 0.88));
    final panelBorder = isDark
        ? const Color(0x33FFFFFF)
        : (enableTransparency
            ? Colors.white.withValues(alpha: 0.50 + 0.25 * t)
            : Colors.white.withValues(alpha: 0.95));

    final isMaxReached = widget.currentCount >= 3;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 393),
        child: Container(
          height: MediaQuery.sizeOf(context).height * 0.90,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: FtGlassTheme.cardDecoration(
            context,
            radius: 32,
            settings: settings,
            customShadows: [
              BoxShadow(
                color: primary.withValues(alpha: isDark ? 0.35 : 0.15),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── 1. Top Grab Handle ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x4DFFFFFF)
                        : const Color(0x331D1735),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),

              // ── 2. Header & Live Search ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add muscle',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: ink,
                          ),
                        ),
                        if (isMaxReached)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '3 of 3 max',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF43F5E),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Frosted Search Field
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: searchBarFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: searchBarBorder,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: muted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim();
                                });
                              },
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: false,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: 'Search muscles (e.g. Chest, Lats)',
                                hintStyle: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: muted.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.cancel_rounded,
                                  size: 18,
                                  color: muted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Category choice chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FtPressable(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              pressedScale: 0.94,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primary
                                      : (isDark
                                          ? const Color(0x1FFFFFFF)
                                          : (enableTransparency
                                              ? Colors.white.withValues(alpha: 0.45 + 0.20 * t)
                                              : Colors.white.withValues(alpha: 0.75))),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? primary
                                        : (isDark
                                            ? const Color(0x33FFFFFF)
                                            : (enableTransparency
                                                ? Colors.white.withValues(alpha: 0.55 + 0.25 * t)
                                                : Colors.white.withValues(alpha: 0.85))),
                                    width: 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: primary.withValues(alpha: 0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontFamily: FtText.fontFamily,
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : muted),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // ── 3. Scrollable Muscle Items List ─────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: listContainerFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: listContainerBorder,
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _filteredMuscles.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No muscles match "$_searchQuery"',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: muted,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            itemCount: _filteredMuscles.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              color: isDark
                                  ? const Color(0x1AFFFFFF)
                                  : const Color(0x1A1D1735),
                            ),
                            itemBuilder: (context, index) {
                              final muscle = _filteredMuscles[index];
                              final isSelected = _selectedMuscle == muscle.name;
                              final isAlreadyAdded = widget.existingMuscles
                                  .contains(muscle.name.toLowerCase());

                              return FtPressable(
                                onTap: isAlreadyAdded
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedMuscle = muscle.name;
                                        });
                                      },
                                pressedScale: 0.99,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  color: isSelected
                                      ? primary.withValues(alpha: isDark ? 0.22 : 0.10)
                                      : Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        muscle.name,
                                        style: TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isAlreadyAdded
                                              ? muted.withValues(alpha: 0.5)
                                              : (isSelected ? primary : ink),
                                        ),
                                      ),
                                      if (isAlreadyAdded)
                                        Text(
                                          'Added',
                                          style: TextStyle(
                                            fontFamily: FtText.fontFamily,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: muted.withValues(alpha: 0.6),
                                          ),
                                        )
                                      else if (isSelected)
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: primary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: primary.withValues(alpha: 0.35),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.check_rounded,
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0x33FFFFFF)
                                                : const Color(0xFFE2E8F0),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── 4. Compact Muscle Adjustment Panel ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  decoration: BoxDecoration(
                    color: panelFill,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: panelBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header: Selected muscle (expanded) + Change button
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedMuscle,
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          FtPressable(
                            onTap: () {
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                            pressedScale: 0.92,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'Change',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Role Segmented Control (Compact)
                      Row(
                        children: [
                          Text(
                            'ROLE',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: muted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0x1FFFFFFF)
                                    : const Color(0xFFF1EDFC).withValues(
                                        alpha: enableTransparency ? (0.60 + 0.20 * t) : 1.0,
                                      ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  _buildRoleButton('Prime mover', MuscleRole.agonist, primary),
                                  const SizedBox(width: 3),
                                  _buildRoleButton('Synergist', MuscleRole.synergist, primary),
                                  const SizedBox(width: 3),
                                  _buildRoleButton('Stabilizer', MuscleRole.stabilizer, primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _roleDescription,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Activation Row: ACTIVATION label + percentage badge + recruitment
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ACTIVATION',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: muted,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$_activation%',
                                  style: TextStyle(
                                    fontFamily: FtText.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: Text(
                              _recruitmentBadgeText,
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: _recruitmentBadgeColor(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Activation Slider Row
                      Row(
                        children: [
                          // Decrement (-)
                          FtPressable(
                            onTap: () {
                              setState(() {
                                _activation = (_activation - 5).clamp(5, 100);
                              });
                            },
                            pressedScale: 0.90,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0x26FFFFFF)
                                    : (enableTransparency
                                        ? Colors.white.withValues(alpha: 0.60 + 0.20 * t)
                                        : Colors.white),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0x33FFFFFF)
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.remove_rounded,
                                size: 16,
                                color: ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Slider
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                activeTrackColor: primary,
                                inactiveTrackColor: isDark
                                    ? const Color(0x26FFFFFF)
                                    : const Color(0xFFE2E8F0),
                                thumbColor: Colors.white,
                                overlayColor: primary.withValues(alpha: 0.15),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7,
                                  elevation: 2,
                                ),
                              ),
                              child: Slider(
                                value: _activation.toDouble(),
                                min: 5,
                                max: 100,
                                divisions: 19,
                                onChanged: (val) {
                                  setState(() {
                                    _activation = val.round();
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Increment (+)
                          FtPressable(
                            onTap: () {
                              setState(() {
                                _activation = (_activation + 5).clamp(5, 100);
                              });
                            },
                            pressedScale: 0.90,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0x26FFFFFF)
                                    : (enableTransparency
                                        ? Colors.white.withValues(alpha: 0.60 + 0.20 * t)
                                        : Colors.white),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0x33FFFFFF)
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: ink,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Step marks indicators
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 38),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStepMark('0%'),
                            _buildStepMark('25%'),
                            _buildStepMark('50%'),
                            _buildStepMark('75%'),
                            _buildStepMark('100%'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── 5. Primary CTA Action Button ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: FtPressable(
                  onTap: _submit,
                  pressedScale: 0.98,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isMaxReached
                            ? [Colors.grey.shade500, Colors.grey.shade600]
                            : [primary, primary.withValues(alpha: 0.88)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isMaxReached ? Colors.grey : primary)
                              .withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isMaxReached ? Icons.block_rounded : Icons.add_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isMaxReached
                              ? 'Max 3 muscles reached'
                              : 'Add $_selectedMuscle',
                          style: const TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String label, MuscleRole role, Color primary) {
    final isSelected = _selectedRole == role;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: FtPressable(
        onTap: () => setState(() => _selectedRole = role),
        pressedScale: 0.96,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 28,
          decoration: BoxDecoration(
            color: isSelected
                ? primary
                : (isDark ? const Color(0x1AFFFFFF) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : context.ftMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepMark(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: FtText.fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: context.ftMuted.withValues(alpha: 0.7),
      ),
    );
  }
}
