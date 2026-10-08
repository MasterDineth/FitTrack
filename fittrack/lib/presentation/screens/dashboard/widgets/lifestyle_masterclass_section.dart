import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/lifestyle_article.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../providers/dashboard_providers.dart';

class LifestyleMasterclassSection extends ConsumerWidget {
  const LifestyleMasterclassSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(lifestyleContentProvider);
    final articles = contentAsync.value ?? const [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Lifestyle & Masterclass',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.ftInk,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Navigate to lifestyle catalog
                  },
                  child: Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.ftPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2-Column Row (No shrinkWrap GridView)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: articles.isNotEmpty
                    ? _LifestyleCard(article: articles[0])
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: articles.length > 1
                    ? _LifestyleCard(article: articles[1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifestyleCard extends StatefulWidget {
  final LifestyleArticle article;

  const _LifestyleCard({required this.article});

  @override
  State<_LifestyleCard> createState() => _LifestyleCardState();
}

class _LifestyleCardState extends State<_LifestyleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final isPrimaryCategory = article.category.toLowerCase() == 'coaching';
    final tagTextColor = isPrimaryCategory ? context.ftPrimary : context.ftInk;

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: FtGlassTheme.radiusCards,
      borderTint: context.isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.white.withValues(alpha: 0.80),
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Area (Height 112 with 300ms press-and-hold zoom)
          GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: SizedBox(
              height: 112,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(FtGlassTheme.radiusCards),
                      topRight: Radius.circular(FtGlassTheme.radiusCards),
                    ),
                    child: AnimatedScale(
                      scale: _isPressed ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: Image.asset(
                        article.imagePath,
                        fit: BoxFit.cover,
                        cacheWidth: 340,
                      ),
                    ),
                  ),

                  // Top-Left Category Chip at 8
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? Colors.black.withValues(alpha: 0.60)
                            : Colors.white.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                        border: Border.all(
                          color: context.isDark
                              ? Colors.white.withValues(alpha: 0.20)
                              : Colors.white.withValues(alpha: 0.60),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        article.category.toUpperCase(),
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.45, // 0.05em
                          color: tagTextColor,
                        ),
                      ),
                    ),
                  ),

                  // Bottom-Right Duration Chip at 8
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        article.duration,
                        style: const TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Card Body (padding: 12)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title (2 lines max)
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: context.ftInk,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  article.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: context.ftMuted,
                  ),
                ),

                // Footer (mt 10 pt 8 with top hairline primary@10%)
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: const EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: context.ftPrimary.withValues(alpha: 0.10),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.actionLabel,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.ftPrimary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 12,
                        color: context.ftPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
