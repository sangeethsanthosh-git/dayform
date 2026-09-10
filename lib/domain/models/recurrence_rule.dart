class RecurrenceRule {
  final String id;
  final String frequency; // 'daily', 'weekdays', 'weekly', 'monthly', 'yearly', 'interval'
  final int interval; // every N units
  final List<int> daysOfWeek; // 1=Mon, 7=Sun
  final int? monthDay; // day of month, e.g. 28, or -1 for last day
  final DateTime? endDate;
  final int? occurrenceCount;
  final String parentEntityType; // 'event', 'task', 'bill', 'habit'
  final String parentEntityId;

  const RecurrenceRule({
    required this.id,
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.monthDay,
    this.endDate,
    this.occurrenceCount,
    required this.parentEntityType,
    required this.parentEntityId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'frequency': frequency,
      'interval': interval,
      'days_of_week': daysOfWeek.join(','),
      'month_day': monthDay,
      'end_date': endDate?.toIso8601String(),
      'occurrence_count': occurrenceCount,
      'parent_entity_type': parentEntityType,
      'parent_entity_id': parentEntityId,
    };
  }

  factory RecurrenceRule.fromMap(Map<String, dynamic> map) {
    final rawDays = map['days_of_week'] as String?;
    final days = (rawDays != null && rawDays.isNotEmpty)
        ? rawDays.split(',').map((d) => int.tryParse(d.trim()) ?? 1).toList()
        : <int>[];

    return RecurrenceRule(
      id: map['id'] as String,
      frequency: map['frequency'] as String,
      interval: map['interval'] as int? ?? 1,
      daysOfWeek: days,
      monthDay: map['month_day'] as int?,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      occurrenceCount: map['occurrence_count'] as int?,
      parentEntityType: map['parent_entity_type'] as String,
      parentEntityId: map['parent_entity_id'] as String,
    );
  }
}

class RecurrenceException {
  final String id;
  final String recurrenceRuleId;
  final String originalDate; // YYYY-MM-DD
  final bool isCancelled;
  final String? modifiedTitle;
  final DateTime? modifiedStartDateTime;
  final DateTime? modifiedEndDateTime;

  const RecurrenceException({
    required this.id,
    required this.recurrenceRuleId,
    required this.originalDate,
    this.isCancelled = false,
    this.modifiedTitle,
    this.modifiedStartDateTime,
    this.modifiedEndDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recurrence_rule_id': recurrenceRuleId,
      'original_date': originalDate,
      'is_cancelled': isCancelled ? 1 : 0,
      'modified_title': modifiedTitle,
      'modified_start_date_time': modifiedStartDateTime?.toIso8601String(),
      'modified_end_date_time': modifiedEndDateTime?.toIso8601String(),
    };
  }

  factory RecurrenceException.fromMap(Map<String, dynamic> map) {
    return RecurrenceException(
      id: map['id'] as String,
      recurrenceRuleId: map['recurrence_rule_id'] as String,
      originalDate: map['original_date'] as String,
      isCancelled: (map['is_cancelled'] as int) == 1,
      modifiedTitle: map['modified_title'] as String?,
      modifiedStartDateTime: map['modified_start_date_time'] != null
          ? DateTime.parse(map['modified_start_date_time'] as String)
          : null,
      modifiedEndDateTime: map['modified_end_date_time'] != null
          ? DateTime.parse(map['modified_end_date_time'] as String)
          : null,
    );
  }
}
