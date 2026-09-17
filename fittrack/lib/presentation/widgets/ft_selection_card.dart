import 'package:flutter/material.dart';

/// A selectable card for goal/experience/equipment options.
class FtSelectionCard extends StatelessWidget {
  const FtSelectionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.leadingIcon,
    this.trailingChips = const [],
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? leadingIcon;
  final List<String> trailingChips;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 18,
                  ),
                  child: Center(child: leadingIcon!),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (trailingChips.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: trailingChips
                          .map(
                            (chip) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                                border: isSelected
                                    ? Border.all(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.3),
                                      )
                                    : null,
                              ),
                              child: Text(
                                chip,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelected
                    ? null
                    : Border.all(color: colorScheme.outlineVariant, width: 1.5),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 13, color: colorScheme.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
