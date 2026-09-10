class EventItem {
  final String id;
  final String title;
  final String? notes;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool isAllDay;
  final String dateOnly; // YYYY-MM-DD
  final String category;
  final String? location;
  final String? recurrenceRuleId;
  final int? colorValue;
  final int? reminderMinutesBefore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventItem({
    required this.id,
    required this.title,
    this.notes,
    required this.startDateTime,
    required this.endDateTime,
    this.isAllDay = false,
    required this.dateOnly,
    this.category = 'personal',
    this.location,
    this.recurrenceRuleId,
    this.colorValue,
    this.reminderMinutesBefore,
    required this.createdAt,
    required this.updatedAt,
  });

  EventItem copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? isAllDay,
    String? dateOnly,
    String? category,
    String? location,
    String? recurrenceRuleId,
    int? colorValue,
    int? reminderMinutesBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventItem(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isAllDay: isAllDay ?? this.isAllDay,
      dateOnly: dateOnly ?? this.dateOnly,
      category: category ?? this.category,
      location: location ?? this.location,
      recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      colorValue: colorValue ?? this.colorValue,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'start_date_time': startDateTime.toIso8601String(),
      'end_date_time': endDateTime.toIso8601String(),
      'is_all_day': isAllDay ? 1 : 0,
      'date_only': dateOnly,
      'category': category,
      'location': location,
      'recurrence_rule_id': recurrenceRuleId,
      'color_value': colorValue,
      'reminder_minutes_before': reminderMinutesBefore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory EventItem.fromMap(Map<String, dynamic> map) {
    return EventItem(
      id: map['id'] as String,
      title: map['title'] as String,
      notes: map['notes'] as String?,
      startDateTime: DateTime.parse(map['start_date_time'] as String),
      endDateTime: DateTime.parse(map['end_date_time'] as String),
      isAllDay: (map['is_all_day'] as int) == 1,
      dateOnly: map['date_only'] as String,
      category: map['category'] as String? ?? 'personal',
      location: map['location'] as String?,
      recurrenceRuleId: map['recurrence_rule_id'] as String?,
      colorValue: map['color_value'] as int?,
      reminderMinutesBefore: map['reminder_minutes_before'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
