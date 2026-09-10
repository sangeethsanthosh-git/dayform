import 'package:uuid/uuid.dart';
import '../../domain/models/bill_item.dart';
import '../../domain/models/birthday_item.dart';
import '../../domain/models/event_item.dart';
import '../../domain/models/habit_item.dart';
import '../../domain/models/task_item.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../domain/repositories/birthday_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/repositories/task_repository.dart';

class SampleDataSeeder {
  static Future<void> seedIfEmpty({
    required ScheduleRepository scheduleRepo,
    required TaskRepository taskRepo,
    required BillRepository billRepo,
    required BirthdayRepository birthdayRepo,
    required HabitRepository habitRepo,
  }) async {
    final existingEvents = await scheduleRepo.getAllEvents();
    if (existingEvents.isNotEmpty) return; // already seeded or user has data

    const uuid = Uuid();
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // 1. Seed Events (Matching Reference media_1788962478418.jpg)
    final handoffStart = DateTime(now.year, now.month, now.day, 18, 30);
    final handoffEnd = handoffStart.add(const Duration(minutes: 45));
    await scheduleRepo.insertEvent(EventItem(
      id: uuid.v4(),
      title: 'Developer handoff',
      notes: 'Handoff design specs with Tommy Carter',
      startDateTime: handoffStart,
      endDateTime: handoffEnd,
      dateOnly: todayStr,
      category: 'work',
      location: 'Google Meet',
      createdAt: now,
      updatedAt: now,
    ));

    final syncStart = DateTime(now.year, now.month, now.day, 23, 15);
    final syncEnd = syncStart.add(const Duration(minutes: 30));
    await scheduleRepo.insertEvent(EventItem(
      id: uuid.v4(),
      title: 'Weekly design sync',
      notes: 'Sync with Marissa Sanchez on Dayform design',
      startDateTime: syncStart,
      endDateTime: syncEnd,
      dateOnly: todayStr,
      category: 'study',
      location: 'Studio Room A',
      createdAt: now,
      updatedAt: now,
    ));

    // Tomorrow event
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStr = "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";
    await scheduleRepo.insertEvent(EventItem(
      id: uuid.v4(),
      title: 'Mobile Architecture Review',
      notes: 'Review database migrations and offline sync',
      startDateTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
      endDateTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 30),
      dateOnly: tomorrowStr,
      category: 'work',
      createdAt: now,
      updatedAt: now,
    ));

    // 2. Seed Tasks
    await taskRepo.insertTask(TaskItem(
      id: uuid.v4(),
      title: 'Submit quarterly project roadmap',
      notes: 'Finalize slides and export PDF',
      dueDate: todayStr,
      dueTime: '17:00',
      priority: 3, // High
      category: 'work',
      tags: ['Work', 'Q3'],
      estimatedDurationMinutes: 45,
      subtasks: [
        TaskSubtask(id: uuid.v4(), taskId: 't1', title: 'Export presentation to PDF', isCompleted: true),
        TaskSubtask(id: uuid.v4(), taskId: 't1', title: 'Send email summary to team', isCompleted: false),
      ],
      createdAt: now,
      updatedAt: now,
    ));

    await taskRepo.insertTask(TaskItem(
      id: uuid.v4(),
      title: 'Review travel itinerary & booking',
      notes: 'Check connected train tickets and hotel reservation',
      dueDate: todayStr,
      priority: 2, // Medium
      category: 'personal',
      tags: ['Travel'],
      createdAt: now,
      updatedAt: now,
    ));

    await taskRepo.insertTask(TaskItem(
      id: uuid.v4(),
      title: 'Read 20 pages of Interaction Design',
      category: 'study',
      priority: 1, // Low
      tags: ['Reading'],
      createdAt: now,
      updatedAt: now,
    ));

    // 3. Seed Bills (Matching Reference media_1788962478434.jpg)
    final billDate1 = now.add(const Duration(days: 1));
    final billDate2 = now.add(const Duration(days: 3));
    final billDate3 = now.add(const Duration(days: 11));
    final billDate4 = now.add(const Duration(days: 11));

    String fmtDate(DateTime dt) => "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

    await billRepo.insertBill(BillItem(
      id: uuid.v4(),
      name: 'Spotify',
      amount: 19.99,
      currency: 'GBP',
      renewalDate: fmtDate(billDate1),
      recurrence: 'monthly',
      category: 'entertainment',
      brandLogo: 'spotify',
      createdAt: now,
    ));

    await billRepo.insertBill(BillItem(
      id: uuid.v4(),
      name: 'YouTube Premium',
      amount: 14.99,
      currency: 'GBP',
      renewalDate: fmtDate(billDate2),
      recurrence: 'monthly',
      category: 'entertainment',
      brandLogo: 'youtube',
      createdAt: now,
    ));

    await billRepo.insertBill(BillItem(
      id: uuid.v4(),
      name: 'ChatGPT Plus',
      amount: 14.75,
      currency: 'GBP',
      renewalDate: fmtDate(billDate3),
      recurrence: 'monthly',
      category: 'productivity',
      brandLogo: 'chatgpt',
      createdAt: now,
    ));

    await billRepo.insertBill(BillItem(
      id: uuid.v4(),
      name: 'Athlytic Pro',
      amount: 26.99,
      currency: 'GBP',
      renewalDate: fmtDate(billDate4),
      recurrence: 'monthly',
      category: 'fitness',
      brandLogo: 'athlytic',
      createdAt: now,
    ));

    // 4. Seed Birthdays (Matching Reference media_1788962478438.jpg)
    await birthdayRepo.insertBirthday(BirthdayItem(
      id: uuid.v4(),
      personName: 'Elena Rostova',
      birthDate: "${now.year}-${now.month.toString().padLeft(2, '0')}-08",
      birthYear: 1997,
      relationship: 'friend',
      avatarPresetIndex: 1,
      giftIdeas: 'Ceramic coffee cup or design notebook',
      createdAt: now,
    ));

    await birthdayRepo.insertBirthday(BirthdayItem(
      id: uuid.v4(),
      personName: 'Marcus Sterling',
      birthDate: "${now.year}-${now.month.toString().padLeft(2, '0')}-14",
      birthYear: 1995,
      relationship: 'family',
      avatarPresetIndex: 2,
      notes: 'Loves hiking and specialty coffee',
      createdAt: now,
    ));

    await birthdayRepo.insertBirthday(BirthdayItem(
      id: uuid.v4(),
      personName: 'Devon Miles',
      birthDate: "${now.year}-${now.month.toString().padLeft(2, '0')}-28",
      birthYear: 1999,
      relationship: 'friend',
      avatarPresetIndex: 3,
      createdAt: now,
    ));

    // 5. Seed Habits
    await habitRepo.insertHabit(HabitItem(
      id: uuid.v4(),
      title: 'Morning Sunlight & Hydration',
      category: 'health',
      scheduledDays: [1, 2, 3, 4, 5, 6, 7],
      reminderTime: '07:30',
      iconCode: 0xe6bb, // wb_sunny
      createdAt: now,
    ));

    await habitRepo.insertHabit(HabitItem(
      id: uuid.v4(),
      title: 'Deep Focus Study (45m)',
      category: 'study',
      scheduledDays: [1, 2, 3, 4, 5],
      reminderTime: '09:00',
      iconCode: 0xe3e3, // menu_book
      createdAt: now,
    ));

    await habitRepo.insertHabit(HabitItem(
      id: uuid.v4(),
      title: 'Evening Reflection & Review',
      category: 'personal',
      scheduledDays: [1, 2, 3, 4, 5, 6, 7],
      reminderTime: '21:00',
      iconCode: 0xe425, // nights_stay
      createdAt: now,
    ));
  }
}
