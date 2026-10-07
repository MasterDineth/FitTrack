enum HabitChipStatus {
  done,
  pending,
  tonight,
}

class DailyHabit {
  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final HabitChipStatus status;
  final int orderIndex;

  const DailyHabit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.status,
    required this.orderIndex,
  });

  DailyHabit copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isCompleted,
    HabitChipStatus? status,
    int? orderIndex,
  }) {
    return DailyHabit(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
