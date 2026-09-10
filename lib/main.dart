import 'package:flutter/material.dart';
import 'app.dart';
import 'core/database/app_database.dart';
import 'core/notifications/notification_service.dart';
import 'core/state/app_state.dart';
import 'domain/repositories/bill_repository.dart';
import 'domain/repositories/birthday_repository.dart';
import 'domain/repositories/focus_repository.dart';
import 'domain/repositories/habit_repository.dart';
import 'domain/repositories/schedule_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/repositories/task_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.instance.initialize();

  // Repositories
  final appDb = AppDatabase.instance;
  final scheduleRepo = ScheduleRepository(appDb);
  final taskRepo = TaskRepository(appDb);
  final billRepo = BillRepository(appDb);
  final birthdayRepo = BirthdayRepository(appDb);
  final habitRepo = HabitRepository(appDb);
  final focusRepo = FocusRepository(appDb);
  final settingsRepo = SettingsRepository(appDb);

  // AppState
  final appState = AppState(
    scheduleRepo: scheduleRepo,
    taskRepo: taskRepo,
    billRepo: billRepo,
    birthdayRepo: birthdayRepo,
    habitRepo: habitRepo,
    focusRepo: focusRepo,
    settingsRepo: settingsRepo,
  );

  // Initialize state and durable database
  await appState.initialize();

  runApp(DayformApp(appState: appState));
}
