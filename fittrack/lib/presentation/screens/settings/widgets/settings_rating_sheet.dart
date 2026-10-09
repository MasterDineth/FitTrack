import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/modals/modal_backdrop_helper.dart';

/// Rating bottom sheet allowing athletes to submit reviews on the App Store / Play Store.
void showFitTrackRatingSheet(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showBlurBottomSheet<void>(
    context: context,
    child: Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: context.ftMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // 5 Golden Stars
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, size: 30, color: Color(0xFFF59E0B)),
                  Icon(Icons.star_rounded, size: 30, color: Color(0xFFF59E0B)),
                  Icon(Icons.star_rounded, size: 30, color: Color(0xFFF59E0B)),
                  Icon(Icons.star_rounded, size: 30, color: Color(0xFFF59E0B)),
                  Icon(Icons.star_rounded, size: 30, color: Color(0xFFF59E0B)),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                'Enjoying FitTrack?',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.ftInk,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                'Your feedback helps us continuously improve the lifting and tracking experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: context.ftMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),

              // Rate button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.ftPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Thank you for rating FitTrack!',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: context.ftPrimary,
                      ),
                    );
                  },
                  child: const Text(
                    'Rate on App Store',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
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
    ),
  );
}
