import 'package:flutter/material.dart';
import '../../providers/custom_exercise_notifier.dart';
import '../../../domain/entities/muscle_activation.dart';

/// A bottom-sheet modal for searching and adding a [MuscleActivationDraft].
///
/// Returns a [MuscleActivationDraft] via `Navigator.pop` when submitted.
class AddMuscleActivationModal extends StatefulWidget {
  const AddMuscleActivationModal({super.key});

  @override
  State<AddMuscleActivationModal> createState() =>
      _AddMuscleActivationModalState();
}

class _AddMuscleActivationModalState extends State<AddMuscleActivationModal> {
  static const _allMuscles = [
    'Chest', 'Upper Chest', 'Lower Chest',
    'Front Deltoid', 'Side Deltoid', 'Rear Deltoid',
    'Biceps', 'Triceps', 'Forearms',
    'Upper Back', 'Lats', 'Rhomboids', 'Traps',
    'Core / Abs', 'Obliques', 'Lower Back',
    'Quads', 'Hamstrings', 'Glutes', 'Calves',
    'Hip Flexors', 'Adductors', 'IT Band',
  ];

  String _query = '';
  String? _selectedMuscle;
  MuscleRole _selectedRole = MuscleRole.agonist;
  int _intensity = 70;

  List<String> get _filtered => _allMuscles
      .where((m) => m.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  children: [
                    // Grab handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Add Muscle Activation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search muscles…',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Muscle list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: colorScheme.outlineVariant,
                  ),
                  itemBuilder: (context, i) {
                    final muscle = _filtered[i];
                    final isSelected = _selectedMuscle == muscle;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        muscle,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
                          : Icon(
                              Icons.circle_outlined,
                              color: colorScheme.outlineVariant,
                              size: 20,
                            ),
                      onTap: () => setState(() => _selectedMuscle = muscle),
                    );
                  },
                ),
              ),

              // Role + Intensity + CTA
              if (_selectedMuscle != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMuscle!,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Role pills
                      _buildRoleRow(colorScheme),
                      const SizedBox(height: 16),

                      // Intensity stepper
                      Row(
                        children: [
                          Text(
                            'Intensity',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          _StepperButton(
                            icon: Icons.remove,
                            onTap: () => setState(
                              () => _intensity = (_intensity - 5).clamp(5, 100),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '$_intensity%',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          _StepperButton(
                            icon: Icons.add,
                            onTap: () => setState(
                              () => _intensity = (_intensity + 5).clamp(5, 100),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Add button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add Muscle',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleRow(ColorScheme colorScheme) {
    return Row(
      children: MuscleRole.values.map((role) {
        final isSelected = _selectedRole == role;
        final label = role.name[0].toUpperCase() + role.name.substring(1);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRole = role),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(
                right: role != MuscleRole.values.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _submit() {
    if (_selectedMuscle == null) return;
    Navigator.of(context).pop(
      MuscleActivationDraft(
        muscleName: _selectedMuscle!,
        role: _selectedRole,
        intensityPercentage: _intensity,
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
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
        child: Icon(icon, size: 16, color: colorScheme.onSurface),
      ),
    );
  }
}
