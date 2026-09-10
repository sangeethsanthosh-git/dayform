import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  final String? _customPath;

  AppDatabase._internal([this._customPath]);

  factory AppDatabase.inMemory() => AppDatabase._internal(inMemoryDatabasePath);

  Database? _db;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop (Windows, Linux, macOS) or unit tests
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (_customPath != null) {
      dbPath = _customPath;
    } else if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final docDir = await getApplicationSupportDirectory();
      dbPath = p.join(docDir.path, AppConstants.databaseName);
    } else {
      final defaultDatabasesPath = await getDatabasesPath();
      dbPath = p.join(defaultDatabasesPath, AppConstants.databaseName);
    }

    return await openDatabase(
      dbPath,
      version: AppConstants.databaseVersion,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
      onOpen: (db) async {
        try {
          await db.execute("ALTER TABLE bills ADD COLUMN custom_image_path TEXT;");
        } catch (_) {}
        try {
          await db.execute("ALTER TABLE birthdays ADD COLUMN custom_image_path TEXT;");
        } catch (_) {}
      },
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // 1. Events Table
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        notes TEXT,
        start_date_time TEXT NOT NULL,
        end_date_time TEXT NOT NULL,
        is_all_day INTEGER NOT NULL DEFAULT 0,
        date_only TEXT NOT NULL,
        category TEXT NOT NULL,
        location TEXT,
        recurrence_rule_id TEXT,
        color_value INTEGER,
        reminder_minutes_before INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Tasks Table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        notes TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        due_date TEXT,
        due_time TEXT,
        priority INTEGER NOT NULL DEFAULT 0,
        tags TEXT,
        category TEXT NOT NULL,
        estimated_duration_minutes INTEGER,
        reminder_minutes_before INTEGER,
        recurrence_rule_id TEXT,
        planned_event_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 3. Task Subtasks Table
    await db.execute('''
      CREATE TABLE task_subtasks (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // 4. Recurrence Rules Table
    await db.execute('''
      CREATE TABLE recurrence_rules (
        id TEXT PRIMARY KEY,
        frequency TEXT NOT NULL,
        interval INTEGER NOT NULL DEFAULT 1,
        days_of_week TEXT,
        month_day INTEGER,
        end_date TEXT,
        occurrence_count INTEGER,
        parent_entity_type TEXT NOT NULL,
        parent_entity_id TEXT NOT NULL
      )
    ''');

    // 5. Recurrence Exceptions Table
    await db.execute('''
      CREATE TABLE recurrence_exceptions (
        id TEXT PRIMARY KEY,
        recurrence_rule_id TEXT NOT NULL,
        original_date TEXT NOT NULL,
        is_cancelled INTEGER NOT NULL DEFAULT 0,
        modified_title TEXT,
        modified_start_date_time TEXT,
        modified_end_date_time TEXT,
        FOREIGN KEY (recurrence_rule_id) REFERENCES recurrence_rules (id) ON DELETE CASCADE
      )
    ''');

    // 6. Bills & Subscriptions Table
    await db.execute('''
      CREATE TABLE bills (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        renewal_date TEXT NOT NULL,
        recurrence TEXT NOT NULL,
        category TEXT NOT NULL,
        brand_logo TEXT NOT NULL,
        custom_image_path TEXT,
        reminder_days_before INTEGER NOT NULL DEFAULT 1,
        is_paused INTEGER NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 7. Bill Payment Records Table
    await db.execute('''
      CREATE TABLE bill_payments (
        id TEXT PRIMARY KEY,
        bill_id TEXT NOT NULL,
        paid_date TEXT NOT NULL,
        amount_paid REAL NOT NULL,
        currency TEXT NOT NULL,
        FOREIGN KEY (bill_id) REFERENCES bills (id) ON DELETE CASCADE
      )
    ''');

    // 8. Birthdays & Milestones Table
    await db.execute('''
      CREATE TABLE birthdays (
        id TEXT PRIMARY KEY,
        person_name TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        birth_year INTEGER,
        relationship TEXT NOT NULL,
        avatar_preset_index INTEGER NOT NULL DEFAULT 0,
        custom_image_path TEXT,
        gift_ideas TEXT,
        notes TEXT,
        reminder_days_before INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // 9. Habits Table
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        scheduled_days TEXT NOT NULL,
        reminder_time TEXT,
        icon_code INTEGER NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 10. Habit Completion Logs Table
    await db.execute('''
      CREATE TABLE habit_logs (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        date TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // 11. Focus Sessions Table
    await db.execute('''
      CREATE TABLE focus_sessions (
        id TEXT PRIMARY KEY,
        linked_task_id TEXT,
        task_title TEXT,
        duration_minutes INTEGER NOT NULL,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        was_interrupted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 12. User Settings Key-Value Table
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    // Migrations handled here as schema evolves
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('habit_logs');
      await txn.delete('habits');
      await txn.delete('bill_payments');
      await txn.delete('bills');
      await txn.delete('birthdays');
      await txn.delete('focus_sessions');
      await txn.delete('recurrence_exceptions');
      await txn.delete('recurrence_rules');
      await txn.delete('task_subtasks');
      await txn.delete('tasks');
      await txn.delete('events');
      await txn.delete('user_settings');
    });
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
