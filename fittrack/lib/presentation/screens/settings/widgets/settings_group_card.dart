import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import 'ft_settings_card.dart';

/// Grouped Settings section card containing a title and a frosted glass card of items.
class SettingsGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroupCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final dividerColor = context.isDark
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFF1F5F9);

    final List<Widget> itemsWithDividers = [];
    for (int i = 0; i < children.length; i++) {
      itemsWithDividers.add(children[i]);
      if (i < children.length - 1) {
        itemsWithDividers.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: 62,
            endIndent: 12,
            color: dividerColor,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section header label: uppercase, tracked, bold
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.55,
                color: context.ftMuted,
              ),
            ),
          ),

          // Frosted Glass card wrapper
          FtSettingsCard(
            radius: 20,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: itemsWithDividers,
            ),
          ),
        ],
      ),
    );
  }
}
