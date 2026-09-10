import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/task_item.dart';

class TaskRepository {
  final AppDatabase _appDb;

  TaskRepository([AppDatabase? appDb]) : _appDb = appDb ?? AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  Future<void> insertTask(TaskItem task) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final subtask in task.subtasks) {
        await txn.insert(
          'task_subtasks',
          subtask.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> updateTask(TaskItem task) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );

      // Re-sync subtasks
      await txn.delete('task_subtasks', where: 'task_id = ?', whereArgs: [task.id]);
      for (final subtask in task.subtasks) {
        await txn.insert(
          'task_subtasks',
          subtask.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> deleteTask(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('task_subtasks', where: 'task_id = ?', whereArgs: [id]);
      await txn.delete('tasks', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    final db = await _db;
    await db.update(
      'tasks',
      {
        'is_completed': isCompleted ? 1 : 0,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> linkPlannedEvent(String taskId, String? eventId) async {
    final db = await _db;
    await db.update(
      'tasks',
      {
        'planned_event_id': eventId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<TaskItem?> getTaskById(String id) async {
    final db = await _db;
    final rows = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;

    final subtaskRows = await db.query('task_subtasks', where: 'task_id = ?', whereArgs: [id]);
    final subtasks = subtaskRows.map((r) => TaskSubtask.fromMap(r)).toList();

    return TaskItem.fromMap(rows.first, subtasks: subtasks);
  }

  Future<List<TaskItem>> getAllTasks() async {
    final db = await _db;
    final rows = await db.query('tasks', orderBy: 'is_completed ASC, priority DESC, due_date ASC');
    return _populateSubtasks(db, rows);
  }

  Future<List<TaskItem>> getInboxTasks() async {
    final db = await _db;
    final rows = await db.query(
      'tasks',
      where: "is_completed = 0 AND (due_date IS NULL OR due_date = '')",
      orderBy: 'priority DESC, created_at DESC',
    );
    return _populateSubtasks(db, rows);
  }

  Future<List<TaskItem>> getTodayTasks(String dateOnly) async {
    final db = await _db;
    final rows = await db.query(
      'tasks',
      where: 'due_date = ?',
      whereArgs: [dateOnly],
      orderBy: 'is_completed ASC, priority DESC, due_time ASC',
    );
    return _populateSubtasks(db, rows);
  }

  Future<List<TaskItem>> getUpcomingTasks(String fromDateOnly) async {
    final db = await _db;
    final rows = await db.query(
      'tasks',
      where: 'is_completed = 0 AND due_date > ?',
      whereArgs: [fromDateOnly],
      orderBy: 'due_date ASC, priority DESC',
    );
    return _populateSubtasks(db, rows);
  }

  Future<List<TaskItem>> getOverdueTasks(String currentDateOnly) async {
    final db = await _db;
    final rows = await db.query(
      'tasks',
      where: "is_completed = 0 AND due_date IS NOT NULL AND due_date != '' AND due_date < ?",
      whereArgs: [currentDateOnly],
      orderBy: 'due_date ASC, priority DESC',
    );
    return _populateSubtasks(db, rows);
  }

  Future<List<TaskItem>> getCompletedTasks() async {
    final db = await _db;
    final rows = await db.query(
      'tasks',
      where: 'is_completed = 1',
      orderBy: 'completed_at DESC',
      limit: 100,
    );
    return _populateSubtasks(db, rows);
  }

  Future<List<TaskItem>> _populateSubtasks(Database db, List<Map<String, dynamic>> taskRows) async {
    if (taskRows.isEmpty) return [];
    final List<TaskItem> result = [];

    for (final r in taskRows) {
      final taskId = r['id'] as String;
      final subtaskRows = await db.query('task_subtasks', where: 'task_id = ?', whereArgs: [taskId]);
      final subtasks = subtaskRows.map((s) => TaskSubtask.fromMap(s)).toList();
      result.add(TaskItem.fromMap(r, subtasks: subtasks));
    }
    return result;
  }
}
