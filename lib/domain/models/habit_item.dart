import 'package:flutter/material.dart';

class HabitItem {
  final String id;
  final String title;
  final String category;
  final List<int> scheduledDays; // 1=Mon .. 7=Sun
  final String? reminderTime; // HH:mm
  final int iconCode;
  final bool isArchived;
  final DateTime createdAt;

  const HabitItem({
    required this.id,
    required this.title,
    this.category = 'health',
    this.scheduledDays = const [1, 2, 3, 4, 5, 6, 7],
    this.reminderTime,
    this.iconCode = 0xe25a, // default fitness / heart
    this.isArchived = false,
    required this.createdAt,
  });

  IconData get icon {
    switch (iconCode) {
      case 0xe25a:
        return Icons.fitness_center_rounded;
      case 0xe3ab:
        return Icons.local_drink_rounded;
      case 0xe113:
        return Icons.menu_book_rounded;
      case 0xe57a:
        return Icons.self_improvement_rounded;
      case 0xe3e3:
        return Icons.nightlight_round;
      case 0xe51c:
        return Icons.directions_run_rounded;
      case 0xe405:
        return Icons.music_note_rounded;
      case 0xe6a4:
        return Icons.edit_note_rounded;
      case 0xe59c:
        return Icons.favorite_rounded;
      case 0xe8e5:
        return Icons.wb_sunny_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  bool isScheduledForDay(int weekday) {
    return scheduledDays.contains(weekday);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'scheduled_days': scheduledDays.join(','),
      'reminder_time': reminderTime,
      'icon_code': iconCode,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HabitItem.fromMap(Map<String, dynamic> map) {
    final rawDays = map['scheduled_days'] as String?;
    final days = (rawDays != null && rawDays.isNotEmpty)
        ? rawDays.split(',').map((d) => int.tryParse(d.trim()) ?? 1).toList()
        : [1, 2, 3, 4, 5, 6, 7];

    return HabitItem(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String? ?? 'health',
      scheduledDays: days,
      reminderTime: map['reminder_time'] as String?,
      iconCode: map['icon_code'] as int? ?? 0xe25a,
      isArchived: (map['is_archived'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  HabitItem copyWith({
    String? id,
    String? title,
    String? category,
    List<int>? scheduledDays,
    String? reminderTime,
    int? iconCode,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return HabitItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reminderTime: reminderTime ?? this.reminderTime,
      iconCode: iconCode ?? this.iconCode,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class HabitLog {
  final String id;
  final String habitId;
  final String date; // YYYY-MM-DD
  final DateTime completedAt;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      date: map['date'] as String,
      completedAt: DateTime.parse(map['completed_at'] as String),
    );
  }
}
