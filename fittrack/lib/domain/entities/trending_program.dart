import 'package:flutter/foundation.dart';

/// Represents a trending workout program featured in the library carousel.
@immutable
class TrendingProgram {
  final String id;
  final String title;
  final String description;
  final String categoryTag; // e.g. 'HYPERTROPHY PRO', 'STRENGTH ELITE'
  final double rating; // e.g. 4.9
  final String reviewCount; // e.g. '1.4k'
  final int durationWeeks; // e.g. 4
  final int daysPerWeek; // e.g. 4
  final String equipment; // e.g. 'Full Gym'
  final List<String> tags; // e.g. ['Full Gym', 'Barbell', 'Deadlift Wave']
  final String intensityLabel; // e.g. 'High Intensity'
  final String? imageAsset;
  final bool isBookmarked;

  const TrendingProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryTag,
    required this.rating,
    required this.reviewCount,
    required this.durationWeeks,
    required this.daysPerWeek,
    required this.equipment,
    required this.tags,
    required this.intensityLabel,
    this.imageAsset,
    this.isBookmarked = false,
  });

  TrendingProgram copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryTag,
    double? rating,
    String? reviewCount,
    int? durationWeeks,
    int? daysPerWeek,
    String? equipment,
    List<String>? tags,
    String? intensityLabel,
    String? imageAsset,
    bool? isBookmarked,
  }) {
    return TrendingProgram(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryTag: categoryTag ?? this.categoryTag,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      equipment: equipment ?? this.equipment,
      tags: tags ?? this.tags,
      intensityLabel: intensityLabel ?? this.intensityLabel,
      imageAsset: imageAsset ?? this.imageAsset,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
