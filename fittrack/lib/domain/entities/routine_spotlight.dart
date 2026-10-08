import 'package:flutter/foundation.dart';

@immutable
class SpotlightDrill {
  final int stepNumber; // 1, 2, 3
  final String exerciseName;
  final String prescription; // e.g. '4 x 20 reps'

  const SpotlightDrill({
    required this.stepNumber,
    required this.exerciseName,
    required this.prescription,
  });
}

/// Represents Today's Routine Spotlight featured card.
@immutable
class RoutineSpotlight {
  final String id;
  final String scheduleId;
  final String title;
  final String subtitle;
  final String categoryTag; // e.g. 'METABOLIC HIIT'
  final int dayNumber; // e.g. 14
  final int durationMinutes; // e.g. 32
  final int estimatedCalories; // e.g. 460
  final int intensityLevel; // 1-5 (e.g. 4)
  final List<SpotlightDrill> drills;
  final String? heroImage;

  const RoutineSpotlight({
    required this.id,
    required this.scheduleId,
    required this.title,
    required this.subtitle,
    required this.categoryTag,
    required this.dayNumber,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.intensityLevel,
    required this.drills,
    this.heroImage,
  });

  RoutineSpotlight copyWith({
    String? id,
    String? scheduleId,
    String? title,
    String? subtitle,
    String? categoryTag,
    int? dayNumber,
    int? durationMinutes,
    int? estimatedCalories,
    int? intensityLevel,
    List<SpotlightDrill>? drills,
    String? heroImage,
  }) {
    return RoutineSpotlight(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      categoryTag: categoryTag ?? this.categoryTag,
      dayNumber: dayNumber ?? this.dayNumber,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      intensityLevel: intensityLevel ?? this.intensityLevel,
      drills: drills ?? this.drills,
      heroImage: heroImage ?? this.heroImage,
    );
  }
}
