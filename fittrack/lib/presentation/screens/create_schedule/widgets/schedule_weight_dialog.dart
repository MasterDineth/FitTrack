import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';

/// Shows an alert dialog allowing the user to type in a target weight in kg.
Future<void> showScheduleWeightDialog({
  required BuildContext context,
  required double currentWeight,
  required ValueChanged<double> onWeightSet,
}) async {
  String formatWeight(double w) {
    if (w % 1 == 0) return w.toInt().toString();
    return w.toStringAsFixed(1);
  }

  final controller = TextEditingController(text: formatWeight(currentWeight));

  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        title: Text(
          'Set Weight (kg)',
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: ctx.ftInk,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter target weight in kilograms (0 = bodyweight):',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 13,
                color: ctx.ftMuted,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ctx.ftInk,
              ),
              decoration: InputDecoration(
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontWeight: FontWeight.w600,
                color: ctx.ftMuted,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ctx.ftPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed != null && parsed >= 0) {
                onWeightSet(parsed);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
