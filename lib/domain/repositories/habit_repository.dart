import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/habit_item.dart';

class HabitRepository {
  final AppDatabase _appDb;

  HabitRepository([AppDatabase? appDb]) : _appDb = appDb ?? AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  Future<void> insertHabit(HabitItem habit) async {
    final db = await _db;
    await db.insert('habits', habit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateHabit(HabitItem habit) async {
    final db = await _db;
    await db.update('habits', habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }

  Future<void> deleteHabit(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
      await txn.delete('habits', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<HabitItem>> getActiveHabits() async {
    final db = await _db;
    final rows = await db.query(
      'habits',
      where: 'is_archived = 0',
      orderBy: 'created_at ASC',
    );
    return rows.map((r) => HabitItem.fromMap(r)).toList();
  }

  Future<void> toggleCheckIn(String habitId, String dateOnly) async {
    final db = await _db;
    final existing = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateOnly],
    );

    if (existing.isNotEmpty) {
      await db.delete(
        'habit_logs',
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitId, dateOnly],
      );
    } else {
      await db.insert('habit_logs', {
        'id': '${habitId}_$dateOnly',
        'habit_id': habitId,
        'date': dateOnly,
        'completed_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<bool> isHabitCompletedOnDate(String habitId, String dateOnly) async {
    final db = await _db;
    final existing = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateOnly],
    );
    return existing.isNotEmpty;
  }

  Future<Set<String>> getCompletedDatesForHabit(String habitId) async {
    final db = await _db;
    final rows = await db.query(
      'habit_logs',
      columns: ['date'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return rows.map((r) => r['date'] as String).toSet();
  }

  // Calculate streak based strictly on scheduled days
  Future<int> calculateStreak(HabitItem habit) async {
    final completedDates = await getCompletedDatesForHabit(habit.id);
    final now = DateTime.now();
    int streak = 0;

    // Check back up to 365 days
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    // If today is scheduled and not completed, check if yesterday was completed
    final todayStr = _formatDate(checkDate);
    if (habit.isScheduledForDay(checkDate.weekday) && !completedDates.contains(todayStr)) {
      // Step back to yesterday to see if current streak is still alive
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      if (habit.isScheduledForDay(checkDate.weekday)) {
        final dateStr = _formatDate(checkDate);
        if (completedDates.contains(dateStr)) {
          streak++;
        } else {
          break; // streak ended
        }
      }
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (streak > 365) break; // safety bound
    }

    return streak;
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }
}
