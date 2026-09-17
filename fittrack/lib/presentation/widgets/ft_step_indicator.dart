import 'package:flutter/material.dart';

/// Onboarding step progress indicator — pill for active step, dots for others.
class FtStepIndicator extends StatelessWidget {
  const FtStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  final int totalSteps;

  /// 0-based current step index.
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
