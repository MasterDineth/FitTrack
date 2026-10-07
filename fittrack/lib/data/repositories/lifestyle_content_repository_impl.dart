import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/lifestyle_article.dart';
import '../../domain/repositories/i_lifestyle_content_repository.dart';

class LifestyleContentRepositoryImpl implements ILifestyleContentRepository {
  const LifestyleContentRepositoryImpl();

  @override
  Future<List<LifestyleArticle>> getFeaturedContent() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/lifestyle_content.json');
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((item) => LifestyleArticle.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback defaults matching Stitch specification
      return const [
        LifestyleArticle(
          id: 'nutrition-1',
          category: 'Nutrition',
          tagColor: 'ink',
          duration: '4 min read',
          title: 'Optimizing Post-Workout Glycogen & Protein Synthesis',
          description: 'Evidence-based meal timing strategies to maximize muscle recovery within 90 minutes post-session.',
          actionLabel: 'Read Guide',
          imagePath: 'assets/images/dashboard/nutrition_bowl.webp',
          isVideo: false,
        ),
        LifestyleArticle(
          id: 'coaching-1',
          category: 'Coaching',
          tagColor: 'primary',
          duration: '7 min video',
          title: 'Hypertrophy Masterclass: Progressive Overload Mechanics',
          description: 'Deep-dive session on RPE tracking, mechanical tension, and periodized volume loading.',
          actionLabel: 'Watch Video',
          imagePath: 'assets/images/dashboard/coaching_bench.webp',
          isVideo: true,
        ),
      ];
    }
  }
}
