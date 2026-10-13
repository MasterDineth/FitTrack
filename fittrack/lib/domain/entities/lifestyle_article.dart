class LifestyleArticle {
  final String id;
  final String category;
  final String tagColor;
  final String duration;
  final String title;
  final String description;
  final String actionLabel;
  final String imagePath;
  final bool isVideo;

  const LifestyleArticle({
    required this.id,
    required this.category,
    required this.tagColor,
    required this.duration,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.imagePath,
    required this.isVideo,
  });

  factory LifestyleArticle.fromJson(Map<String, dynamic> json) {
    return LifestyleArticle(
      id: json['id'] as String,
      category: json['category'] as String,
      tagColor: json['tagColor'] as String? ?? 'ink',
      duration: json['duration'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      actionLabel: json['actionLabel'] as String,
      imagePath: json['imagePath'] as String,
      isVideo: json['isVideo'] as bool? ?? false,
    );
  }
}
