import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dayform/core/database/app_database.dart';
import 'package:dayform/domain/models/bill_item.dart';
import 'package:dayform/domain/models/birthday_item.dart';
import 'package:dayform/domain/models/event_item.dart';
import 'package:dayform/domain/models/habit_item.dart';
import 'package:dayform/domain/models/task_item.dart';
import 'package:dayform/domain/repositories/bill_repository.dart';
import 'package:dayform/domain/repositories/birthday_repository.dart';
import 'package:dayform/domain/repositories/habit_repository.dart';
import 'package:dayform/domain/repositories/schedule_repository.dart';
import 'package:dayform/domain/repositories/task_repository.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database & Repositories Unit Tests', () {
    late AppDatabase appDb;
    late ScheduleRepository scheduleRepo;
    late TaskRepository taskRepo;
    late BillRepository billRepo;
    late BirthdayRepository birthdayRepo;
    late HabitRepository habitRepo;

    setUp(() async {
      appDb = AppDatabase.inMemory();
      scheduleRepo = ScheduleRepository(appDb);
      taskRepo = TaskRepository(appDb);
      billRepo = BillRepository(appDb);
      birthdayRepo = BirthdayRepository(appDb);
      habitRepo = HabitRepository(appDb);
    });

    tearDown(() async {
      await appDb.close();
    });

    test('Events: insert, retrieve for date, and delete', () async {
      final now = DateTime(2026, 9, 9, 14, 0);
      final event = EventItem(
        id: 'ev_test_1',
        title: 'Design Review',
        startDateTime: now,
        endDateTime: now.add(const Duration(hours: 1)),
        dateOnly: '2026-09-09',
        category: 'work',
        createdAt: now,
        updatedAt: now,
      );

      await scheduleRepo.insertEvent(event);
      final retrieved = await scheduleRepo.getEventsForDate('2026-09-09');

      expect(retrieved.length, equals(1));
      expect(retrieved.first.title, equals('Design Review'));

      await scheduleRepo.deleteEvent('ev_test_1');
      final afterDelete = await scheduleRepo.getEventsForDate('2026-09-09');
      expect(afterDelete.isEmpty, isTrue);
    });

    test('Tasks: toggle completion and overdue querying', () async {
      final now = DateTime.now();
      final task = TaskItem(
        id: 'task_test_1',
        title: 'File Tax Return',
        dueDate: '2026-09-01',
        priority: 3,
        category: 'finance',
        createdAt: now,
        updatedAt: now,
      );

      await taskRepo.insertTask(task);

      // Check overdue
      final overdue = await taskRepo.getOverdueTasks('2026-09-09');
      expect(overdue.length, equals(1));
      expect(overdue.first.title, equals('File Tax Return'));

      // Toggle completed
      await taskRepo.toggleTaskCompletion('task_test_1', true);
      final overdueAfterComplete = await taskRepo.getOverdueTasks('2026-09-09');
      expect(overdueAfterComplete.isEmpty, isTrue);
    });

    test('Bills: record payment advances monthly renewal date', () async {
      final billWithDate = BillItem(
        id: 'bill_spotify',
        name: 'Spotify',
        amount: 19.99,
        currency: 'GBP',
        renewalDate: '2026-09-10',
        recurrence: 'monthly',
        brandLogo: 'spotify',
        createdAt: DateTime(2026, 9, 1),
      );

      await billRepo.insertBill(billWithDate);
      await billRepo.recordPayment('bill_spotify', '2026-09-10', 19.99, 'GBP');

      final activeBills = await billRepo.getAllActiveBills();
      expect(activeBills.first.renewalDate, equals('2026-10-10'));
    });

    test('Birthdays: milestone age calculation and repository insertion', () async {
      final bday = BirthdayItem(
        id: 'bday_1',
        personName: 'Elena',
        birthDate: '1998-05-12',
        birthYear: 1998,
        createdAt: DateTime(2026, 1, 1),
      );

      await birthdayRepo.insertBirthday(bday);
      final list = await birthdayRepo.getAllBirthdays();
      expect(list.length, equals(1));
      expect(bday.getAgeTurning(2026), equals(28));
    });

    test('Habits: streak calculation only counts scheduled days', () async {
      final habit = HabitItem(
        id: 'h_read',
        title: 'Daily Reading',
        scheduledDays: [1, 2, 3, 4, 5, 6, 7],
        createdAt: DateTime(2026, 9, 1),
      );

      await habitRepo.insertHabit(habit);

      final today = DateTime.now();
      String fmt(DateTime dt) => "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

      // Check in today and yesterday
      await habitRepo.toggleCheckIn('h_read', fmt(today));
      await habitRepo.toggleCheckIn('h_read', fmt(today.subtract(const Duration(days: 1))));

      final streak = await habitRepo.calculateStreak(habit);
      expect(streak, equals(2));
    });
  });
}
