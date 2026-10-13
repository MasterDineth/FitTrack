import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Dashed border painter for the upload zone.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  static const double strokeWidth = 1.5;
  static const double dashWidth = 6.0;
  static const double dashSpace = 4.0;

  const _DashedBorderPainter({
    required this.color,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance > metric.length ? metric.length : nextDistance,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

/// Cover Image Section Card matching Stitch Screen ID 378f56a0b632436289e53841eb67b6fb.
class ScheduleCoverImageCard extends StatelessWidget {
  const ScheduleCoverImageCard({
    super.key,
    required this.coverImagePath,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  final String? coverImagePath;
  final ValueChanged<String?> onImageSelected;
  final VoidCallback onImageRemoved;

  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (photo != null) {
        onImageSelected(photo.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not select image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final bool hasImage = coverImagePath != null &&
        coverImagePath!.isNotEmpty &&
        File(coverImagePath!).existsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0x331E1838)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0x26FFFFFF)
              : Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0x22FFFFFF)
                            : const Color(0xFFE6DEFF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 20,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cover image',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                          Text(
                            'Optional preview thumbnail',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x1AFFFFFF)
                      : const Color(0xFFF2EBFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'OPTIONAL',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Upload or Preview Zone
          if (hasImage)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(coverImagePath!),
                    width: double.infinity,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      FtPressable(
                        onTap: () => _pickImage(context),
                        pressedScale: 0.90,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Change',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      FtPressable(
                        onTap: onImageRemoved,
                        pressedScale: 0.90,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            CustomPaint(
              painter: _DashedBorderPainter(
                color: primary.withValues(alpha: 0.35),
                radius: 16,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x14FFFFFF)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 24,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to upload cover photo',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PNG, JPG or WebP up to 5MB',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FtPressable(
                      onTap: () => _pickImage(context),
                      pressedScale: 0.95,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0x22FFFFFF)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 16,
                              color: primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Browse image',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
