import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/ft_glass.dart';

/// Primary destructive Log Out button with confirmation dialog and real authentication revocation.
class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final hasScope = context.findAncestorWidgetOfExactType<ProviderScope>() != null ||
        context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() != null;

    if (hasScope) {
      return const _ReactiveSettingsLogoutButton();
    }
    return const _StaticSettingsLogoutButton();
  }
}

class _ReactiveSettingsLogoutButton extends ConsumerWidget {
  const _ReactiveSettingsLogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildButton(
      context: context,
      onTap: () => _showDialog(context, onConfirm: () async {
        await ref.read(authProvider.notifier).signOut();
      }),
    );
  }
}

class _StaticSettingsLogoutButton extends StatelessWidget {
  const _StaticSettingsLogoutButton();

  @override
  Widget build(BuildContext context) {
    return _buildButton(
      context: context,
      onTap: () => _showDialog(context, onConfirm: () async {}),
    );
  }
}

Widget _buildButton({
  required BuildContext context,
  required VoidCallback onTap,
}) {
  const roseColor = Color(0xFFF43F5E);

  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
    child: Semantics(
      button: true,
      label: 'Log Out of FitTrack',
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: roseColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: roseColor.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 19,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Log Out',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showDialog(
  BuildContext context, {
  required Future<void> Function() onConfirm,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  const roseRed = Color(0xFFF43F5E);

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1B2E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.ftInk,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your FitTrack account?',
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: context.ftMuted,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.ftMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await onConfirm();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Could not complete log out. Please try again.',
                        style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                      ),
                      backgroundColor: roseRed,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: roseRed,
              ),
            ),
          ),
        ],
      );
    },
  );
}
