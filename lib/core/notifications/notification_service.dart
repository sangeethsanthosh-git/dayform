import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize({Function(String? payload)? onNotificationTapped}) async {
    if (_isInitialized) return;

    // Initialize TimeZone database and detect device's local location
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final id = info.identifier;
      try {
        tz.setLocalLocation(tz.getLocation(id));
      } catch (_) {
        // Fallback matching by UTC offset
        final offset = DateTime.now().timeZoneOffset;
        for (final loc in tz.timeZoneDatabase.locations.values) {
          if (loc.currentTimeZone.offset == offset) {
            tz.setLocalLocation(loc);
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Could not set system timezone ($e), matching by device offset.');
      final offset = DateTime.now().timeZoneOffset;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == offset) {
          tz.setLocalLocation(loc);
          break;
        }
      }
    }

    // Android Setup
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Darwin / iOS Setup
    const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && onNotificationTapped != null) {
          onNotificationTapped(response.payload);
        }
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        // Clear any old or stale channels so fresh channel settings apply
        try {
          await androidImpl.deleteNotificationChannel(channelId: 'dayform_reminders_chime_v2');
          await androidImpl.deleteNotificationChannel(channelId: 'dayform_reminders_tune');
          await androidImpl.deleteNotificationChannel(channelId: 'dayform_reminders');
        } catch (_) {}

        final AndroidNotificationChannel channel = AndroidNotificationChannel(
          AppConstants.reminderChannelId,
          AppConstants.reminderChannelName,
          description: AppConstants.reminderChannelDesc,
          importance: Importance.max,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('reminder_chime'),
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
          enableLights: true,
          showBadge: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        await androidImpl.createNotificationChannel(channel);
      }
    }

    // Prompt for notification & exact alarm permissions
    await requestPermissions();

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        await androidImpl.requestExactAlarmsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      final iosImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final granted = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return true;
  }

  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidImpl?.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  // Schedule a notification at exact local time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (kIsWeb) return;

    if (!_isInitialized) {
      await initialize();
    }

    final now = DateTime.now();
    DateTime effectiveDate = scheduledDate;

    // Do not schedule notifications for times already in the past
    if (effectiveDate.isBefore(now)) {
      return;
    }

    final tzNow = tz.TZDateTime.now(tz.local);
    final tzScheduledDate = tz.TZDateTime.from(effectiveDate, tz.local);

    // Exact alarms on Android MUST be strictly in the future
    if (tzScheduledDate.isBefore(tzNow) || tzScheduledDate.difference(tzNow).inSeconds < 1) {
      return;
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      channelDescription: AppConstants.reminderChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('reminder_chime'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'action_snooze',
          'Snooze 10m',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'action_complete',
          'Complete',
          showsUserInterface: false,
        ),
      ],
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'reminder_chime.wav',
      ),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: payload,
      );
    } catch (e) {
      debugPrint('AlarmClock mode failed ($e), falling back to exactAllowWhileIdle');
      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzScheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } catch (e2) {
        debugPrint('Exact mode failed ($e2), falling back to inexact mode');
        try {
          await _notificationsPlugin.zonedSchedule(
            id: id,
            title: title,
            body: body,
            scheduledDate: tzScheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: payload,
          );
        } catch (err) {
          debugPrint('All notification schedule attempts failed: $err');
        }
      }
    }
  }

  // Schedule annual birthday reminder
  Future<void> scheduleBirthdayReminder({
    required int id,
    required String personName,
    required DateTime birthDate,
    int daysBefore = 0,
  }) async {
    if (kIsWeb) return;

    final now = DateTime.now();
    var targetYear = now.year;
    var nextBday = DateTime(targetYear, birthDate.month, birthDate.day, 9, 0);
    if (daysBefore > 0) {
      nextBday = nextBday.subtract(Duration(days: daysBefore));
    }
    if (nextBday.isBefore(now)) {
      targetYear++;
      nextBday = DateTime(targetYear, birthDate.month, birthDate.day, 9, 0);
      if (daysBefore > 0) {
        nextBday = nextBday.subtract(Duration(days: daysBefore));
      }
    }

    final title = daysBefore == 0
        ? '🎉 Happy Birthday! 🎂'
        : '🎂 Upcoming Birthday Reminder';
    final body = daysBefore == 0
        ? 'Today is $personName! Celebrate and have a wonderful day! ✨'
        : '$personName is coming up in $daysBefore day${daysBefore > 1 ? 's' : ''}!';

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextBday,
      payload: 'birthday_$id',
    );
  }

  // Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id: id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancelAll();
  }

  // Diagnostic Test Notification with Chime Tune (Immediate)
  Future<void> sendImmediateTestNotification() async {
    if (kIsWeb) return;

    if (!_isInitialized) {
      await initialize();
    }
    await requestPermissions();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      channelDescription: AppConstants.reminderChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('reminder_chime'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'reminder_chime.wav',
      ),
    );

    try {
      await _notificationsPlugin.show(
        id: 99999,
        title: 'Dayform Chime Reminder 🔔',
        body: 'Your reminder chime tune and triple-pulse vibration are active and loud!',
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Error showing immediate test notification: $e');
    }
  }

  // Diagnostic Scheduled Test Notification (e.g. 5 seconds delay)
  Future<void> scheduleTestNotification({int delaySeconds = 5}) async {
    if (kIsWeb) return;

    if (!_isInitialized) {
      await initialize();
    }
    await requestPermissions();

    final scheduledDate = DateTime.now().add(Duration(seconds: delaySeconds));
    await scheduleNotification(
      id: 88888,
      title: '⏰ Test Reminder Alarm ($delaySeconds sec)',
      body: 'Success! Scheduled alarm, vibration and chime triggered right on time!',
      scheduledDate: scheduledDate,
      payload: 'test_alarm_payload',
    );
  }

  // Play audible chime alert preview in-app and trigger test notification
  Future<void> playChimePreview() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.heavyImpact();
      await sendImmediateTestNotification();
    } catch (e) {
      debugPrint('Chime preview error: $e');
    }
  }
}
