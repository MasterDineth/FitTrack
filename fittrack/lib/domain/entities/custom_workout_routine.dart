import 'package:flutter/material.dart';

/// Represents a user saved/custom routine in the "My Saved & Custom" section.
@immutable
class CustomWorkoutRoutine {
  final String id;
  final String title;
  final String subtitle;
  final String badgeText; // 'ACTIVE', 'SAVED'
  final Color? badgeColor;
  final double progressPercent; // 0.0 - 1.0
  final String progressLabel; // '70% done', 'Week 2/6'
  final int drillCount;
  final int durationMinutes;
  final String muscleFocus;
  final String? imageAsset;
  final bool isBookmarked;

  const CustomWorkoutRoutine({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    this.badgeColor,
    required this.progressPercent,
    required this.progressLabel,
    required this.drillCount,
    required this.durationMinutes,
    required this.muscleFocus,
    this.imageAsset,
    this.isBookmarked = true,
  });

  CustomWorkoutRoutine copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? badgeText,
    Color? badgeColor,
    double? progressPercent,
    String? progressLabel,
    int? drillCount,
    int? durationMinutes,
    String? muscleFocus,
    String? imageAsset,
    bool? isBookmarked,
  }) {
    return CustomWorkoutRoutine(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      badgeText: badgeText ?? this.badgeText,
      badgeColor: badgeColor ?? this.badgeColor,
      progressPercent: progressPercent ?? this.progressPercent,
      progressLabel: progressLabel ?? this.progressLabel,
      drillCount: drillCount ?? this.drillCount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      muscleFocus: muscleFocus ?? this.muscleFocus,
      imageAsset: imageAsset ?? this.imageAsset,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
