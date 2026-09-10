import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../domain/repositories/birthday_repository.dart';
import '../../domain/repositories/focus_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../database/app_database.dart';

class BackupService {
  final AppDatabase _appDb;
  final ScheduleRepository _scheduleRepo;
  final TaskRepository _taskRepo;
  final BillRepository _billRepo;
  final BirthdayRepository _birthdayRepo;
  final HabitRepository _habitRepo;
  final FocusRepository _focusRepo;
  final SettingsRepository _settingsRepo;

  BackupService({
    AppDatabase? appDb,
    ScheduleRepository? scheduleRepo,
    TaskRepository? taskRepo,
    BillRepository? billRepo,
    BirthdayRepository? birthdayRepo,
    HabitRepository? habitRepo,
    FocusRepository? focusRepo,
    SettingsRepository? settingsRepo,
  })  : _appDb = appDb ?? AppDatabase.instance,
        _scheduleRepo = scheduleRepo ?? ScheduleRepository(appDb),
        _taskRepo = taskRepo ?? TaskRepository(appDb),
        _billRepo = billRepo ?? BillRepository(appDb),
        _birthdayRepo = birthdayRepo ?? BirthdayRepository(appDb),
        _habitRepo = habitRepo ?? HabitRepository(appDb),
        _focusRepo = focusRepo ?? FocusRepository(appDb),
        _settingsRepo = settingsRepo ?? SettingsRepository(appDb);

  // Generates complete versioned JSON backup
  Future<String> exportBackupJson() async {
    final events = await _scheduleRepo.getAllEvents();
    final tasks = await _taskRepo.getAllTasks();
    final bills = await _billRepo.getAllActiveBills();
    final birthdays = await _birthdayRepo.getAllBirthdays();
    final habits = await _habitRepo.getActiveHabits();
    final focusSessions = await _focusRepo.getRecentSessions(limit: 100);
    final settings = await _settingsRepo.getSettings();

    final backupMap = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'app': 'Dayform',
      'settings': settings.toMap(),
      'events': events.map((e) => e.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'bills': bills.map((b) => b.toMap()).toList(),
      'birthdays': birthdays.map((b) => b.toMap()).toList(),
      'habits': habits.map((h) => h.toMap()).toList(),
      'focus_sessions': focusSessions.map((f) => f.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backupMap);
  }

  // Validates and imports JSON backup with option: isReplace (wipe existing) vs merge
  Future<bool> importBackupJson(String jsonString, {required bool isReplace}) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return false;

      // Validate required keys
      if (!decoded.containsKey('version') || !decoded.containsKey('events')) {
        return false;
      }

      final db = await _appDb.database;

      await db.transaction((txn) async {
        if (isReplace) {
          // Destructive replace - clear all tables safely inside transaction
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
        }

        // 1. Restore Events
        final rawEvents = decoded['events'] as List<dynamic>? ?? [];
        for (final item in rawEvents) {
          final map = Map<String, dynamic>.from(item as Map);
          await txn.insert('events', map, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // 2. Restore Tasks
        final rawTasks = decoded['tasks'] as List<dynamic>? ?? [];
        for (final item in rawTasks) {
          final map = Map<String, dynamic>.from(item as Map);
          await txn.insert('tasks', map, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // 3. Restore Bills
        final rawBills = decoded['bills'] as List<dynamic>? ?? [];
        for (final item in rawBills) {
          final map = Map<String, dynamic>.from(item as Map);
          await txn.insert('bills', map, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // 4. Restore Birthdays
        final rawBirthdays = decoded['birthdays'] as List<dynamic>? ?? [];
        for (final item in rawBirthdays) {
          final map = Map<String, dynamic>.from(item as Map);
          await txn.insert('birthdays', map, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // 5. Restore Habits
        final rawHabits = decoded['habits'] as List<dynamic>? ?? [];
        for (final item in rawHabits) {
          final map = Map<String, dynamic>.from(item as Map);
          await txn.insert('habits', map, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // 6. Restore Focus Sessions
        final rawFocus = decoded['focus_sessions'] as List<dynamic>? ?? [];
        for (final item in rawFocus) {
          final map = Map<String, dynamic>.from(item as Map);
          await txn.insert('focus_sessions', map, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // 7. Restore Settings if present
        if (decoded.containsKey('settings')) {
          final rawSettings = Map<String, dynamic>.from(decoded['settings'] as Map);
          for (final entry in rawSettings.entries) {
            await txn.insert(
              'user_settings',
              {'key': entry.key, 'value': entry.value?.toString() ?? ''},
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });

      return true;
    } catch (_) {
      return false;
    }
  }
}
