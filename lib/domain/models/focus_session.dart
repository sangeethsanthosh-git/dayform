class FocusSession {
  final String id;
  final String? linkedTaskId;
  final String? taskTitle;
  final int durationMinutes;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool wasInterrupted;

  const FocusSession({
    required this.id,
    this.linkedTaskId,
    this.taskTitle,
    required this.durationMinutes,
    required this.startedAt,
    this.completedAt,
    this.wasInterrupted = false,
  });

  bool get isCompleted => completedAt != null && !wasInterrupted;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'linked_task_id': linkedTaskId,
      'task_title': taskTitle,
      'duration_minutes': durationMinutes,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'was_interrupted': wasInterrupted ? 1 : 0,
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] as String,
      linkedTaskId: map['linked_task_id'] as String?,
      taskTitle: map['task_title'] as String?,
      durationMinutes: map['duration_minutes'] as int,
      startedAt: DateTime.parse(map['started_at'] as String),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
      wasInterrupted: (map['was_interrupted'] as int) == 1,
    );
  }
}
