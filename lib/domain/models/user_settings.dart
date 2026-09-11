import 'dart:convert';

class UserSettings {
  final String userName;
  final String? profileImagePath;
  final String? userBirthDate; // YYYY-MM-DD
  final bool hasCompletedOnboarding;
  final String themeMode; // 'system', 'light', 'dark'
  final int accentColorIndex;
  final int? customAccentColorValue;
  final int firstDayOfWeek; // 1 = Mon, 7 = Sun
  final bool is24Hour;
  final String dateFormat; // 'd MMM yyyy', 'MMM d, yyyy', 'yyyy-MM-dd'
  final String timezone; // e.g. 'Asia/Kolkata'
  final String currency; // 'INR', 'USD', 'GBP', 'EUR'
  final int defaultEventDurationMinutes;
  final int defaultReminderMinutesBefore;
  final bool quietHoursEnabled;
  final String quietHoursStart; // "22:00"
  final String quietHoursEnd; // "07:00"
  final bool isCompactDensity;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final String defaultCalendarView; // 'month', 'week', 'day', 'agenda'
  final String defaultOpeningScreen; // 'today', 'calendar', 'tasks', 'myspace'
  final String notificationTone; // 'chime', 'bell', 'marimba', 'electronic', 'zen', 'system'
  final List<String> visibleTodayModules; // ['up_next', 'agenda', 'tasks', 'habits', 'payments', 'birthdays']
  final List<String> todayModuleOrder;

  const UserSettings({
    this.userName = '',
    this.profileImagePath,
    this.userBirthDate,
    this.hasCompletedOnboarding = false,
    this.themeMode = 'system',
    this.accentColorIndex = 0,
    this.customAccentColorValue,
    this.firstDayOfWeek = 1, // Default Monday
    this.is24Hour = false,
    this.dateFormat = 'd MMM yyyy',
    this.timezone = 'Asia/Kolkata',
    this.currency = 'INR',
    this.defaultEventDurationMinutes = 60,
    this.defaultReminderMinutesBefore = 15,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
    this.isCompactDensity = false,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.defaultCalendarView = 'month',
    this.defaultOpeningScreen = 'today',
    this.notificationTone = 'chime',
    this.visibleTodayModules = const [
      'up_next',
      'agenda',
      'tasks',
      'habits',
      'payments',
    ],
    this.todayModuleOrder = const [
      'up_next',
      'agenda',
      'tasks',
      'habits',
      'payments',
    ],
  });

  UserSettings copyWith({
    String? userName,
    String? profileImagePath,
    String? userBirthDate,
    bool? hasCompletedOnboarding,
    String? themeMode,
    int? accentColorIndex,
    int? customAccentColorValue,
    bool clearCustomAccent = false,
    int? firstDayOfWeek,
    bool? is24Hour,
    String? dateFormat,
    String? timezone,
    String? currency,
    int? defaultEventDurationMinutes,
    int? defaultReminderMinutesBefore,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? isCompactDensity,
    bool? hapticsEnabled,
    bool? reducedMotion,
    String? defaultCalendarView,
    String? defaultOpeningScreen,
    String? notificationTone,
    List<String>? visibleTodayModules,
    List<String>? todayModuleOrder,
  }) {
    return UserSettings(
      userName: userName ?? this.userName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      userBirthDate: userBirthDate ?? this.userBirthDate,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      themeMode: themeMode ?? this.themeMode,
      accentColorIndex: accentColorIndex ?? this.accentColorIndex,
      customAccentColorValue: clearCustomAccent
          ? null
          : (customAccentColorValue ?? this.customAccentColorValue),
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      is24Hour: is24Hour ?? this.is24Hour,
      dateFormat: dateFormat ?? this.dateFormat,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      defaultEventDurationMinutes: defaultEventDurationMinutes ?? this.defaultEventDurationMinutes,
      defaultReminderMinutesBefore: defaultReminderMinutesBefore ?? this.defaultReminderMinutesBefore,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      isCompactDensity: isCompactDensity ?? this.isCompactDensity,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      defaultCalendarView: defaultCalendarView ?? this.defaultCalendarView,
      defaultOpeningScreen: defaultOpeningScreen ?? this.defaultOpeningScreen,
      notificationTone: notificationTone ?? this.notificationTone,
      visibleTodayModules: visibleTodayModules ?? this.visibleTodayModules,
      todayModuleOrder: todayModuleOrder ?? this.todayModuleOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_name': userName,
      'profile_image_path': profileImagePath,
      'user_birth_date': userBirthDate,
      'has_completed_onboarding': hasCompletedOnboarding ? 1 : 0,
      'theme_mode': themeMode,
      'accent_color_index': accentColorIndex,
      'custom_accent_color_value': customAccentColorValue,
      'first_day_of_week': firstDayOfWeek,
      'is_24_hour': is24Hour ? 1 : 0,
      'date_format': dateFormat,
      'timezone': timezone,
      'currency': currency,
      'default_event_duration_minutes': defaultEventDurationMinutes,
      'default_reminder_minutes_before': defaultReminderMinutesBefore,
      'quiet_hours_enabled': quietHoursEnabled ? 1 : 0,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'is_compact_density': isCompactDensity ? 1 : 0,
      'haptics_enabled': hapticsEnabled ? 1 : 0,
      'reduced_motion': reducedMotion ? 1 : 0,
      'default_calendar_view': defaultCalendarView,
      'default_opening_screen': defaultOpeningScreen,
      'notification_tone': notificationTone,
      'visible_today_modules': jsonEncode(visibleTodayModules),
      'today_module_order': jsonEncode(todayModuleOrder),
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    List<String> parseJsonList(dynamic val, List<String> fallback) {
      if (val == null) return fallback;
      try {
        final decoded = jsonDecode(val as String);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
      return fallback;
    }

    final rawName = map['user_name'] as String?;
    final hasOnboarded = map['has_completed_onboarding'];
    bool resolvedOnboarding = false;
    if (hasOnboarded != null) {
      resolvedOnboarding = (hasOnboarded as int? ?? 0) == 1;
    } else if (rawName != null && rawName.isNotEmpty && rawName != 'Alex') {
      resolvedOnboarding = true;
    }

    return UserSettings(
      userName: rawName ?? '',
      profileImagePath: map['profile_image_path'] as String?,
      userBirthDate: map['user_birth_date'] as String?,
      hasCompletedOnboarding: resolvedOnboarding,
      themeMode: map['theme_mode'] as String? ?? 'system',
      accentColorIndex: map['accent_color_index'] as int? ?? 0,
      customAccentColorValue: map['custom_accent_color_value'] as int?,
      firstDayOfWeek: map['first_day_of_week'] as int? ?? 1,
      is24Hour: (map['is_24_hour'] as int? ?? 0) == 1,
      dateFormat: map['date_format'] as String? ?? 'd MMM yyyy',
      timezone: map['timezone'] as String? ?? 'Asia/Kolkata',
      currency: map['currency'] as String? ?? 'INR',
      defaultEventDurationMinutes: map['default_event_duration_minutes'] as int? ?? 60,
      defaultReminderMinutesBefore: map['default_reminder_minutes_before'] as int? ?? 15,
      quietHoursEnabled: (map['quiet_hours_enabled'] as int? ?? 0) == 1,
      quietHoursStart: map['quiet_hours_start'] as String? ?? '22:00',
      quietHoursEnd: map['quiet_hours_end'] as String? ?? '07:00',
      isCompactDensity: (map['is_compact_density'] as int? ?? 0) == 1,
      hapticsEnabled: (map['haptics_enabled'] as int? ?? 1) == 1,
      reducedMotion: (map['reduced_motion'] as int? ?? 0) == 1,
      defaultCalendarView: map['default_calendar_view'] as String? ?? 'month',
      defaultOpeningScreen: map['default_opening_screen'] as String? ?? 'today',
      notificationTone: map['notification_tone'] as String? ?? 'chime',
      visibleTodayModules: parseJsonList(map['visible_today_modules'], [
        'up_next',
        'agenda',
        'tasks',
        'habits',
        'payments',
        'birthdays',
      ]),
      todayModuleOrder: parseJsonList(map['today_module_order'], [
        'up_next',
        'agenda',
        'tasks',
        'habits',
        'payments',
        'birthdays',
      ]),
    );
  }
}
