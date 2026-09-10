import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/focus_session.dart';

class FocusRepository {
  final AppDatabase _appDb;

  FocusRepository([AppDatabase? appDb]) : _appDb = appDb ?? AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  Future<void> logSession(FocusSession session) async {
    final db = await _db;
    await db.insert('focus_sessions', session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FocusSession>> getRecentSessions({int limit = 20}) async {
    final db = await _db;
    final rows = await db.query(
      'focus_sessions',
      orderBy: 'started_at DESC',
      limit: limit,
    );
    return rows.map((r) => FocusSession.fromMap(r)).toList();
  }

  Future<int> getTotalFocusMinutesToday() async {
    final db = await _db;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    final rows = await db.query(
      'focus_sessions',
      where: 'started_at >= ? AND was_interrupted = 0',
      whereArgs: [startOfDay],
    );

    int totalMinutes = 0;
    for (final r in rows) {
      totalMinutes += (r['duration_minutes'] as int? ?? 0);
    }
    return totalMinutes;
  }
}
