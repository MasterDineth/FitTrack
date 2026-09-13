import 'package:flutter/material.dart';
import '../../providers/custom_exercise_notifier.dart';

/// A simple bottom-sheet dialog for adding a DO or DON'T form cue.
///
/// Returns a [FormCueDraft] via `Navigator.pop` when submitted.
class AddFormCueDialog extends StatefulWidget {
  const AddFormCueDialog({super.key});

  @override
  State<AddFormCueDialog> createState() => _AddFormCueDialogState();
}

class _AddFormCueDialogState extends State<AddFormCueDialog> {
  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

  bool _isPositive = true;
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Add Form Cue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Guide users with DO tips or warn with DON\'T mistakes.',
                style: TextStyle(
                  fontSize: 13,
                  color: _dark.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 20),

              // DO / DON'T toggle
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFf1f5f9),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildToggleChip('✓  DO', true),
                    _buildToggleChip('✗  DON\'T', false),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      _isPositive ? 'e.g. Keep chest up throughout the movement' : 'e.g. Don\'t flare elbows out',
                  hintStyle: TextStyle(color: _dark.withValues(alpha: 0.38)),
                  filled: true,
                  fillColor: const Color(0xFFf8fafc),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _mint, width: 1.5),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mint,
                    foregroundColor: _dark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Cue',
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
      ),
    );
  }

  Widget _buildToggleChip(String label, bool isPositiveValue) {
    final isSelected = _isPositive == isPositiveValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isPositive = isPositiveValue),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isPositiveValue ? _mint : const Color(0xFFef4444))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? _dark : const Color(0xFF64748b),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      FormCueDraft(
        isPositive: _isPositive,
        description: _controller.text.trim(),
      ),
    );
  }
}
