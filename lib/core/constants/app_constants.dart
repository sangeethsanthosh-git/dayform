class AppConstants {
  // Centralized branding token - easy to change
  static const String appName = 'Dayform';
  static const String appTagline = 'Your day, beautifully organized';

  // Storage & database
  static const String databaseName = 'dayform.db';
  static const int databaseVersion = 1;

  // Notification Channels
  static const String reminderChannelId = 'dayform_alarms_v4';
  static const String reminderChannelName = 'Dayform Reminders & Alarms';
  static const String reminderChannelDesc = 'Loud chime alert for time-sensitive reminders, tasks and calendar events';

  // Layout & Styling constants
  static const double cardRadiusLarge = 28.0;
  static const double cardRadiusMedium = 20.0;
  static const double cardRadiusSmall = 14.0;
  static const double pillRadius = 999.0;

  // Defaults
  static const int defaultEventDurationMinutes = 60;
  static const int defaultReminderMinutesBefore = 15;
  static const String defaultCurrency = 'INR';
  static const String defaultCurrencySymbol = '₹';
}
