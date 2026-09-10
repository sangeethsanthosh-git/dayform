import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/event_item.dart';
import '../models/recurrence_rule.dart';

class ScheduleRepository {
  final AppDatabase _appDb;

  ScheduleRepository([AppDatabase? appDb]) : _appDb = appDb ?? AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  Future<void> insertEvent(EventItem event, {RecurrenceRule? recurrenceRule}) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert(
        'events',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (recurrenceRule != null) {
        await txn.insert(
          'recurrence_rules',
          recurrenceRule.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> updateEvent(EventItem event) async {
    final db = await _db;
    await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> deleteEvent(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      final eventRows = await txn.query(
        'events',
        columns: ['recurrence_rule_id'],
        where: 'id = ?',
        whereArgs: [id],
      );

      if (eventRows.isNotEmpty) {
        final ruleId = eventRows.first['recurrence_rule_id'] as String?;
        if (ruleId != null) {
          await txn.delete('recurrence_exceptions', where: 'recurrence_rule_id = ?', whereArgs: [ruleId]);
          await txn.delete('recurrence_rules', where: 'id = ?', whereArgs: [ruleId]);
        }
      }

      await txn.delete('events', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<EventItem?> getEventById(String id) async {
    final db = await _db;
    final rows = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return EventItem.fromMap(rows.first);
  }

  Future<List<EventItem>> getAllEvents() async {
    final db = await _db;
    final rows = await db.query(
      'events',
      orderBy: 'start_date_time ASC',
    );
    return rows.map((r) => EventItem.fromMap(r)).toList();
  }

  Future<List<EventItem>> getEventsForDate(String dateOnly) async {
    final db = await _db;
    final rows = await db.query(
      'events',
      where: 'date_only = ?',
      whereArgs: [dateOnly],
      orderBy: 'is_all_day DESC, start_date_time ASC',
    );
    return rows.map((r) => EventItem.fromMap(r)).toList();
  }

  Future<List<EventItem>> getEventsInRange(DateTime start, DateTime end) async {
    final db = await _db;
    final rows = await db.query(
      'events',
      where: 'start_date_time <= ? AND end_date_time >= ?',
      whereArgs: [end.toIso8601String(), start.toIso8601String()],
      orderBy: 'is_all_day DESC, start_date_time ASC',
    );
    return rows.map((r) => EventItem.fromMap(r)).toList();
  }

  // Recurrence rule access
  Future<RecurrenceRule?> getRecurrenceRule(String ruleId) async {
    final db = await _db;
    final rows = await db.query(
      'recurrence_rules',
      where: 'id = ?',
      whereArgs: [ruleId],
    );
    if (rows.isEmpty) return null;
    return RecurrenceRule.fromMap(rows.first);
  }

  Future<List<RecurrenceException>> getExceptionsForRule(String ruleId) async {
    final db = await _db;
    final rows = await db.query(
      'recurrence_exceptions',
      where: 'recurrence_rule_id = ?',
      whereArgs: [ruleId],
    );
    return rows.map((r) => RecurrenceException.fromMap(r)).toList();
  }

  Future<void> addRecurrenceException(RecurrenceException exception) async {
    final db = await _db;
    await db.insert(
      'recurrence_exceptions',
      exception.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
