import 'package:flutter/material.dart';

import 'ft_header_avatar.dart';
import 'ft_header_tokens.dart';
import 'ft_notification_bell.dart';

/// Standard modular header actions cluster combining optional extra actions,
/// notification bell, and profile avatar.
class FtHeaderActions extends StatelessWidget {
  final bool showBell;
  final bool showAvatar;
  final List<Widget> extraActions;

  const FtHeaderActions({
    super.key,
    this.showBell = true,
    this.showAvatar = true,
    this.extraActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...extraActions,
        if (extraActions.isNotEmpty && (showBell || showAvatar))
          const SizedBox(width: FtHeaderTokens.clusterGap),
        if (showBell) ...[
          const FtNotificationBell(),
          if (showAvatar) const SizedBox(width: FtHeaderTokens.clusterGap),
        ],
        if (showAvatar) const FtHeaderAvatar(),
      ],
    );
  }
}
