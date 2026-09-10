class TaskSubtask {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;

  const TaskSubtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory TaskSubtask.fromMap(Map<String, dynamic> map) {
    return TaskSubtask(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      title: map['title'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  TaskSubtask copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
  }) {
    return TaskSubtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TaskItem {
  final String id;
  final String title;
  final String? notes;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? dueDate; // YYYY-MM-DD
  final String? dueTime; // HH:mm
  final int priority; // 0: None, 1: Low, 2: Medium, 3: High
  final List<String> tags;
  final String category;
  final int? estimatedDurationMinutes;
  final int? reminderMinutesBefore;
  final String? recurrenceRuleId;
  final String? plannedEventId; // linked calendar time block
  final List<TaskSubtask> subtasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskItem({
    required this.id,
    required this.title,
    this.notes,
    this.isCompleted = false,
    this.completedAt,
    this.dueDate,
    this.dueTime,
    this.priority = 0,
    this.tags = const [],
    this.category = 'personal',
    this.estimatedDurationMinutes,
    this.reminderMinutesBefore,
    this.recurrenceRuleId,
    this.plannedEventId,
    this.subtasks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? notes,
    bool? isCompleted,
    DateTime? completedAt,
    String? dueDate,
    String? dueTime,
    int? priority,
    List<String>? tags,
    String? category,
    int? estimatedDurationMinutes,
    int? reminderMinutesBefore,
    String? recurrenceRuleId,
    String? plannedEventId,
    List<TaskSubtask>? subtasks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      plannedEventId: plannedEventId ?? this.plannedEventId,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'due_date': dueDate,
      'due_time': dueTime,
      'priority': priority,
      'tags': tags.join(','),
      'category': category,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'reminder_minutes_before': reminderMinutesBefore,
      'recurrence_rule_id': recurrenceRuleId,
      'planned_event_id': plannedEventId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map, {List<TaskSubtask> subtasks = const []}) {
    final rawTags = map['tags'] as String?;
    final List<String> parsedTags = (rawTags != null && rawTags.isNotEmpty)
        ? rawTags.split(',').map((t) => t.trim()).toList()
        : [];

    return TaskItem(
      id: map['id'] as String,
      title: map['title'] as String,
      notes: map['notes'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
      dueDate: map['due_date'] as String?,
      dueTime: map['due_time'] as String?,
      priority: map['priority'] as int? ?? 0,
      tags: parsedTags,
      category: map['category'] as String? ?? 'personal',
      estimatedDurationMinutes: map['estimated_duration_minutes'] as int?,
      reminderMinutesBefore: map['reminder_minutes_before'] as int?,
      recurrenceRuleId: map['recurrence_rule_id'] as String?,
      plannedEventId: map['planned_event_id'] as String?,
      subtasks: subtasks,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
