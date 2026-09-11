import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/bill_item.dart';
import '../../domain/models/birthday_item.dart';
import '../../domain/models/event_item.dart';
import '../../domain/models/habit_item.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../domain/repositories/birthday_repository.dart';
import '../../domain/repositories/focus_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../database/app_database.dart';
import '../notifications/notification_service.dart';
import '../theme/app_colors.dart';
import '../widget/home_widget_service.dart';

class AppState extends ChangeNotifier {
  final ScheduleRepository scheduleRepo;
  final TaskRepository taskRepo;
  final BillRepository billRepo;
  final BirthdayRepository birthdayRepo;
  final HabitRepository habitRepo;
  final FocusRepository focusRepo;
  final SettingsRepository settingsRepo;

  AppState({
    required this.scheduleRepo,
    required this.taskRepo,
    required this.billRepo,
    required this.birthdayRepo,
    required this.habitRepo,
    required this.focusRepo,
    required this.settingsRepo,
  });

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  UserSettings _settings = const UserSettings();
  UserSettings get settings => _settings;

  List<EventItem> _selectedDateEvents = [];
  List<EventItem> get selectedDateEvents => _selectedDateEvents;

  List<EventItem> _allEvents = [];
  List<EventItem> get allEvents => _allEvents;

  List<TaskItem> _todayTasks = [];
  List<TaskItem> get todayTasks => _todayTasks;

  List<TaskItem> _inboxTasks = [];
  List<TaskItem> get inboxTasks => _inboxTasks;

  List<TaskItem> _overdueTasks = [];
  List<TaskItem> get overdueTasks => _overdueTasks;

  List<TaskItem> _upcomingTasks = [];
  List<TaskItem> get upcomingTasks => _upcomingTasks;

  List<TaskItem> _completedTasks = [];
  List<TaskItem> get completedTasks => _completedTasks;

  List<BillItem> _bills = [];
  List<BillItem> get bills => _bills;

  Map<String, double> _currencyTotals = {};
  Map<String, double> get currencyTotals => _currencyTotals;

  List<BirthdayItem> _birthdays = [];
  List<BirthdayItem> get birthdays => _birthdays;

  List<HabitItem> _habits = [];
  List<HabitItem> get habits => _habits;

  final Map<String, int> _habitStreaks = {};
  Map<String, int> get habitStreaks => _habitStreaks;

  final Set<String> _todayCompletedHabits = {};
  Set<String> get todayCompletedHabits => _todayCompletedHabits;

  EventItem? _upNextEvent;
  EventItem? get upNextEvent => _upNextEvent;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String get todayDateOnly => _formatDate(DateTime.now());
  String get selectedDateOnly => _formatDate(_selectedDate);

  static String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // 1. Load user settings
    _settings = await settingsRepo.getSettings();
    AppColors.applyAccentFromSettings(_settings);
    NotificationService.instance.setActiveTone(_settings.notificationTone);

    // 2. Refresh all domain data (starts clean for fresh install)
    await refreshAll();

    // 3. Ensure all upcoming reminders are synced with NotificationService
    await rescheduleAllUpcomingReminders();

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _loadEventsForSelectedDate();
    notifyListeners();
  }

  Future<void> rescheduleAllUpcomingReminders() async {
    final now = DateTime.now();

    // 1. Events & Reminders
    for (final event in _allEvents) {
      if (event.reminderMinutesBefore != null &&
          event.startDateTime.isAfter(now)) {
        var reminderTime = event.startDateTime.subtract(
          Duration(minutes: event.reminderMinutesBefore!),
        );
        if (reminderTime.isBefore(now)) {
          reminderTime = event.startDateTime;
        }
        if (reminderTime.isAfter(now)) {
          final isReminder = event.title.toLowerCase().startsWith('reminder');
          await NotificationService.instance.scheduleNotification(
            id: event.id.hashCode,
            title: isReminder ? event.title : 'Upcoming: ${event.title}',
            body: isReminder
                ? (event.notes ??
                      'Scheduled for ${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')}')
                : 'Starts at ${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')}${event.location != null ? ' • ${event.location}' : ''}',
            scheduledDate: reminderTime,
            payload: 'event_${event.id}',
          );
        }
      }
    }

    // 2. Tasks with due dates & reminders
    final allTasks = [..._todayTasks, ..._upcomingTasks, ..._inboxTasks];
    for (final task in allTasks) {
      if (!task.isCompleted &&
          task.dueDate != null &&
          task.reminderMinutesBefore != null) {
        final dueDateTime = DateTime.tryParse(
          "${task.dueDate} ${task.dueTime ?? '09:00'}:00",
        );
        if (dueDateTime != null && dueDateTime.isAfter(now)) {
          var reminderTime = dueDateTime.subtract(
            Duration(minutes: task.reminderMinutesBefore!),
          );
          if (reminderTime.isBefore(now)) {
            reminderTime = dueDateTime;
          }
          if (reminderTime.isAfter(now)) {
            await NotificationService.instance.scheduleNotification(
              id: task.id.hashCode,
              title: 'Task Reminder: ${task.title}',
              body: task.notes ?? 'Scheduled for ${task.dueTime ?? 'today'}',
              scheduledDate: reminderTime,
              payload: 'task_${task.id}',
            );
          }
        }
      }
    }

    // 3. Upcoming Bills
    for (final bill in _bills) {
      final due = DateTime.tryParse(bill.renewalDate);
      if (due != null) {
        final billReminder = DateTime(due.year, due.month, due.day, 9, 0);
        if (billReminder.isAfter(now)) {
          await NotificationService.instance.scheduleNotification(
            id: bill.id.hashCode,
            title: '💳 Upcoming Payment Due: ${bill.name}',
            body:
                'Payment of ${bill.currency} ${bill.amount.toStringAsFixed(2)} is due today.',
            scheduledDate: billReminder,
            payload: 'bill_${bill.id}',
          );
        }
      }
    }

    // 4. Upcoming Birthdays
    for (final bday in _birthdays) {
      final parts = bday.birthDate.split('-');
      if (parts.length >= 3) {
        final m = int.tryParse(parts[1]) ?? 1;
        final d = int.tryParse(parts[2]) ?? 1;
        var bdayDate = DateTime(now.year, m, d, 9, 0);
        if (bdayDate.isBefore(now)) {
          bdayDate = DateTime(now.year + 1, m, d, 9, 0);
        }
        await NotificationService.instance.scheduleNotification(
          id: bday.id.hashCode,
          title: '🎉 Birthday Today: ${bday.personName}!',
          body: 'Wish ${bday.personName} a happy birthday! 🎂✨',
          scheduledDate: bdayDate,
          payload: 'birthday_${bday.id}',
        );
      }
    }

    // 5. Habits
    for (final habit in _habits) {
      if (habit.reminderTime != null) {
        final timeParts = habit.reminderTime!.split(':');
        if (timeParts.length == 2) {
          final hour = int.tryParse(timeParts[0]) ?? 9;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          var habitTime = DateTime(now.year, now.month, now.day, hour, minute);
          if (habitTime.isBefore(now)) {
            habitTime = habitTime.add(const Duration(days: 1));
          }
          await NotificationService.instance.scheduleNotification(
            id: habit.id.hashCode,
            title: '✨ Habit Reminder: ${habit.title}',
            body: 'Time to check in on ${habit.title}!',
            scheduledDate: habitTime,
            payload: 'habit_${habit.id}',
          );
        }
      }
    }
  }

  Future<void> refreshAll() async {
    final todayStr = todayDateOnly;

    _allEvents = await scheduleRepo.getAllEvents();
    await _loadEventsForSelectedDate();

    // Tasks
    _todayTasks = await taskRepo.getTodayTasks(todayStr);
    _inboxTasks = await taskRepo.getInboxTasks();
    _overdueTasks = await taskRepo.getOverdueTasks(todayStr);
    _upcomingTasks = await taskRepo.getUpcomingTasks(todayStr);
    _completedTasks = await taskRepo.getCompletedTasks();

    // Bills
    _bills = await billRepo.getAllActiveBills();
    _currencyTotals = await billRepo.getUpcomingTotalsByCurrency();

    // Birthdays
    _birthdays = await birthdayRepo.getAllBirthdays();

    // Habits
    _habits = await habitRepo.getActiveHabits();
    _todayCompletedHabits.clear();
    for (final habit in _habits) {
      final isDone = await habitRepo.isHabitCompletedOnDate(habit.id, todayStr);
      if (isDone) _todayCompletedHabits.add(habit.id);
      final streak = await habitRepo.calculateStreak(habit);
      _habitStreaks[habit.id] = streak;
    }

    // Compute Up Next Event
    _computeUpNextEvent();

    // Update Home Screen Widget
    HomeWidgetService.updateTodayWidget(
      upNextEvent: _upNextEvent,
      topTasks: _todayTasks.where((t) => !t.isCompleted).toList(),
    );

    notifyListeners();
  }

  Future<void> _loadEventsForSelectedDate() async {
    _selectedDateEvents = await scheduleRepo.getEventsForDate(selectedDateOnly);
  }

  void _computeUpNextEvent() {
    final now = DateTime.now();
    final todayStr = todayDateOnly;

    final todayEvents = _allEvents
        .where((e) => e.dateOnly == todayStr)
        .toList();
    todayEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    _upNextEvent = null;
    for (final event in todayEvents) {
      if (event.endDateTime.isAfter(now)) {
        _upNextEvent = event;
        break;
      }
    }
  }

  // --- Events CRUD ---
  Future<void> addEvent(EventItem event) async {
    await scheduleRepo.insertEvent(event);
    if (event.reminderMinutesBefore != null) {
      final now = DateTime.now();
      var reminderTime = event.startDateTime.subtract(
        Duration(minutes: event.reminderMinutesBefore!),
      );
      if (reminderTime.isBefore(now) && event.startDateTime.isAfter(now)) {
        reminderTime = event.startDateTime;
      }
      if (reminderTime.isAfter(now)) {
        final isReminder = event.title.toLowerCase().startsWith('reminder');
        await NotificationService.instance.scheduleNotification(
          id: event.id.hashCode,
          title: isReminder ? event.title : 'Upcoming: ${event.title}',
          body: isReminder
              ? (event.notes ??
                    'Scheduled for ${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')}')
              : 'Starts at ${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')}${event.location != null ? ' • ${event.location}' : ''}',
          scheduledDate: reminderTime,
          payload: 'event_${event.id}',
        );
      }
    }
    await refreshAll();
  }

  Future<void> updateEvent(EventItem event) async {
    await scheduleRepo.updateEvent(event);
    await NotificationService.instance.cancelNotification(event.id.hashCode);
    if (event.reminderMinutesBefore != null) {
      final now = DateTime.now();
      var reminderTime = event.startDateTime.subtract(
        Duration(minutes: event.reminderMinutesBefore!),
      );
      if (reminderTime.isBefore(now) && event.startDateTime.isAfter(now)) {
        reminderTime = event.startDateTime;
      }
      if (reminderTime.isAfter(now)) {
        final isReminder = event.title.toLowerCase().startsWith('reminder');
        await NotificationService.instance.scheduleNotification(
          id: event.id.hashCode,
          title: isReminder ? event.title : 'Upcoming: ${event.title}',
          body: isReminder
              ? (event.notes ??
                    'Scheduled for ${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')}')
              : 'Starts at ${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')}${event.location != null ? ' • ${event.location}' : ''}',
          scheduledDate: reminderTime,
          payload: 'event_${event.id}',
        );
      }
    }
    await refreshAll();
  }

  Future<void> deleteEvent(String id) async {
    await NotificationService.instance.cancelNotification(id.hashCode);
    await scheduleRepo.deleteEvent(id);
    await refreshAll();
  }

  // Conflict Detection for Schedule Planning
  List<EventItem> checkEventConflicts(
    DateTime start,
    DateTime end, {
    String? excludeEventId,
  }) {
    return _allEvents.where((e) {
      if (excludeEventId != null && e.id == excludeEventId) return false;
      if (e.isAllDay) return false;
      // Overlap formula: start < existingEnd AND end > existingStart
      return start.isBefore(e.endDateTime) && end.isAfter(e.startDateTime);
    }).toList();
  }

  // --- Tasks CRUD ---
  Future<void> addTask(TaskItem task) async {
    await taskRepo.insertTask(task);
    if (task.dueDate != null && task.reminderMinutesBefore != null) {
      final dueDateTime = DateTime.tryParse(
        "${task.dueDate} ${task.dueTime ?? '09:00'}:00",
      );
      if (dueDateTime != null) {
        final now = DateTime.now();
        var reminderTime = dueDateTime.subtract(
          Duration(minutes: task.reminderMinutesBefore!),
        );
        if (reminderTime.isBefore(now) && dueDateTime.isAfter(now)) {
          reminderTime = dueDateTime;
        }
        if (reminderTime.isAfter(now)) {
          await NotificationService.instance.scheduleNotification(
            id: task.id.hashCode,
            title: 'Task Reminder: ${task.title}',
            body: task.notes ?? 'Scheduled for today',
            scheduledDate: reminderTime,
            payload: 'task_${task.id}',
          );
        }
      }
    }
    await refreshAll();
  }

  Future<void> toggleTask(String taskId, bool isCompleted) async {
    await taskRepo.toggleTaskCompletion(taskId, isCompleted);
    if (isCompleted) {
      await NotificationService.instance.cancelNotification(taskId.hashCode);
    }
    await refreshAll();
  }

  /// Handles actions from system notifications without requiring a new app UI.
  Future<void> completeItemFromNotification(String payload) async {
    if (!payload.startsWith('task_')) return;

    final taskId = payload.substring('task_'.length);
    if (taskId.isEmpty) return;

    await taskRepo.toggleTaskCompletion(taskId, true);
    await NotificationService.instance.cancelNotification(taskId.hashCode);
    await refreshAll();
  }

  Future<void> deleteTask(String id) async {
    await NotificationService.instance.cancelNotification(id.hashCode);
    await taskRepo.deleteTask(id);
    await refreshAll();
  }

  // Plan This Task into Calendar
  Future<void> planTaskIntoCalendar(
    TaskItem task,
    DateTime start,
    DateTime end,
  ) async {
    const uuid = Uuid();
    final eventId = uuid.v4();
    final dateOnly = _formatDate(start);

    final event = EventItem(
      id: eventId,
      title: task.title,
      notes: task.notes,
      startDateTime: start,
      endDateTime: end,
      dateOnly: dateOnly,
      category: task.category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await scheduleRepo.insertEvent(event);
    await taskRepo.linkPlannedEvent(task.id, eventId);
    await refreshAll();
  }

  // --- Bills CRUD ---
  Future<void> addBill(BillItem bill) async {
    await billRepo.insertBill(bill);
    final due = DateTime.tryParse(bill.renewalDate);
    if (due != null) {
      final billReminder = DateTime(due.year, due.month, due.day, 9, 0);
      if (billReminder.isAfter(DateTime.now())) {
        await NotificationService.instance.scheduleNotification(
          id: bill.id.hashCode,
          title: '💳 Upcoming Payment Due: ${bill.name}',
          body:
              'Payment of ${bill.currency} ${bill.amount.toStringAsFixed(2)} is due today.',
          scheduledDate: billReminder,
          payload: 'bill_${bill.id}',
        );
      }
    }
    await refreshAll();
  }

  Future<void> markBillPaid(
    String billId,
    double amount,
    String currency,
  ) async {
    final today = todayDateOnly;
    await billRepo.recordPayment(billId, today, amount, currency);
    await refreshAll();
  }

  Future<void> deleteBill(String id) async {
    await NotificationService.instance.cancelNotification(id.hashCode);
    await billRepo.deleteBill(id);
    await refreshAll();
  }

  // --- Birthdays CRUD ---
  Future<void> addBirthday(BirthdayItem bday) async {
    await birthdayRepo.insertBirthday(bday);
    final parts = bday.birthDate.split('-');
    if (parts.length >= 3) {
      final m = int.tryParse(parts[1]) ?? 1;
      final d = int.tryParse(parts[2]) ?? 1;
      final now = DateTime.now();
      var bdayDate = DateTime(now.year, m, d, 9, 0);
      if (bdayDate.isBefore(now)) {
        bdayDate = DateTime(now.year + 1, m, d, 9, 0);
      }
      await NotificationService.instance.scheduleNotification(
        id: bday.id.hashCode,
        title: '🎉 Birthday Today: ${bday.personName}!',
        body: 'Wish ${bday.personName} a happy birthday! 🎂✨',
        scheduledDate: bdayDate,
        payload: 'birthday_${bday.id}',
      );
    }
    await refreshAll();
  }

  Future<void> deleteBirthday(String id) async {
    await NotificationService.instance.cancelNotification(id.hashCode);
    await birthdayRepo.deleteBirthday(id);
    await refreshAll();
  }

  // --- Habits CRUD ---
  Future<void> addHabit(HabitItem habit) async {
    await habitRepo.insertHabit(habit);
    if (habit.reminderTime != null) {
      final timeParts = habit.reminderTime!.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? 9;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        final now = DateTime.now();
        var habitTime = DateTime(now.year, now.month, now.day, hour, minute);
        if (habitTime.isBefore(now)) {
          habitTime = habitTime.add(const Duration(days: 1));
        }
        await NotificationService.instance.scheduleNotification(
          id: habit.id.hashCode,
          title: '✨ Habit Reminder: ${habit.title}',
          body: 'Time to check in on ${habit.title}!',
          scheduledDate: habitTime,
          payload: 'habit_${habit.id}',
        );
      }
    }
    await refreshAll();
  }

  Future<void> toggleHabitCheckIn(String habitId, String dateOnly) async {
    await habitRepo.toggleCheckIn(habitId, dateOnly);
    await refreshAll();
  }

  Future<void> deleteHabit(String id) async {
    await NotificationService.instance.cancelNotification(id.hashCode);
    await habitRepo.deleteHabit(id);
    await refreshAll();
  }

  // --- Settings ---
  Future<void> updateSettings(UserSettings newSettings) async {
    final toneChanged = _settings.notificationTone != newSettings.notificationTone;
    _settings = newSettings;
    AppColors.applyAccentFromSettings(newSettings);
    NotificationService.instance.setActiveTone(newSettings.notificationTone);
    await settingsRepo.saveSettings(newSettings);
    if (toneChanged) {
      await rescheduleAllUpcomingReminders();
    }
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await AppDatabase.instance.clearAllData();
    await refreshAll();
  }
}
