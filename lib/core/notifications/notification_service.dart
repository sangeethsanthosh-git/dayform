import 'dart:io';
import 'package:flutter/foundation.dart';
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
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Could not set system timezone ($e), falling back to default.');
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
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          AppConstants.reminderChannelId,
          AppConstants.reminderChannelName,
          description: AppConstants.reminderChannelDesc,
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('reminder_chime'),
          enableVibration: true,
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

    // If the scheduled date is slightly in the past (within 10 mins),
    // schedule it 3 seconds from now so the user receives the alert.
    if (effectiveDate.isBefore(now)) {
      if (effectiveDate.isAfter(now.subtract(const Duration(minutes: 10)))) {
        effectiveDate = now.add(const Duration(seconds: 3));
      } else {
        return; // Truly in the past, do not schedule
      }
    }

    final tzNow = tz.TZDateTime.now(tz.local);
    var tzScheduledDate = tz.TZDateTime.from(effectiveDate, tz.local);
    // Exact alarms on Android MUST be strictly in the future
    if (tzScheduledDate.isBefore(tzNow) || tzScheduledDate.difference(tzNow).inSeconds < 2) {
      tzScheduledDate = tzNow.add(const Duration(seconds: 3));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      channelDescription: AppConstants.reminderChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('reminder_chime'),
      enableVibration: true,
      actions: <AndroidNotificationAction>[
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

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Exact alarm failed ($e), falling back to inexact mode');
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
        debugPrint('Fallback notification schedule also failed: $err');
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

  // Diagnostic Test Notification with Chime Tune
  Future<void> sendImmediateTestNotification() async {
    if (kIsWeb) return;

    if (!_isInitialized) {
      await initialize();
    }
    await requestPermissions();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      channelDescription: AppConstants.reminderChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('reminder_chime'),
      enableVibration: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
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
        body: 'Your reminder chime tune is active and sounding crisp!',
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Error showing immediate test notification: $e');
    }
  }
}
