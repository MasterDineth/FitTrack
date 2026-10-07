import '../entities/lifestyle_article.dart';

abstract interface class ILifestyleContentRepository {
  Future<List<LifestyleArticle>> getFeaturedContent();
}
