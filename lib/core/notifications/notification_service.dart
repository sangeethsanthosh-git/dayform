import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';

typedef NotificationInteractionCallback =
    Future<void> Function(String? payload, String? actionId);

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  NotificationInteractionCallback? _onNotificationInteraction;
  String _activeToneKey = 'chime';

  String get activeToneKey => _activeToneKey;

  void setActiveTone(String toneKey) {
    _activeToneKey = toneKey;
  }

  static const String _snoozeActionId = 'action_snooze';
  static const String _completeActionId = 'action_complete';
  static const String _payloadMarker = 'dayform_notification_v1';
  static const List<String> _legacyAndroidChannelIds = [
    'dayform_reminders',
    'dayform_reminders_tune',
    'dayform_reminders_chime_v2',
    'dayform_alarms_v4',
    'dayform_alarms_v5',
    'dayform_tone_chime_v1',
    'dayform_tone_bell_v1',
    'dayform_tone_marimba_v1',
    'dayform_tone_electronic_v1',
    'dayform_tone_zen_v1',
    'dayform_tone_system_v1',
  ];

  Future<void> initialize({
    NotificationInteractionCallback? onNotificationInteraction,
  }) async {
    if (onNotificationInteraction != null) {
      _onNotificationInteraction = onNotificationInteraction;
    }
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
      debugPrint(
        'Could not set system timezone ($e), matching by device offset.',
      );
      final offset = DateTime.now().timeZoneOffset;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == offset) {
          tz.setLocalLocation(loc);
          break;
        }
      }
    }

    // Android Setup
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Darwin / iOS Setup
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const WindowsInitializationSettings windowsSettings =
        WindowsInitializationSettings(
          appName: AppConstants.appName,
          appUserModelId: 'Dayform.Calendar.Desktop',
          guid: '5d669a47-b4c1-4f43-bf72-612c8f27b68b',
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      windows: windowsSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await _handleNotificationResponse(response);
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        // Retire only old channel versions. Deleting the active channel on every
        // launch would also discard the user's current channel preferences.
        for (final channelId in _legacyAndroidChannelIds) {
          try {
            await androidImpl.deleteNotificationChannel(channelId: channelId);
          } catch (_) {}
        }

        // Register default reminder channel
        final AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
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
          // Use the notification-volume stream. Several OEM builds keep alarm
          // volume muted independently, which made otherwise valid tones silent.
          audioAttributesUsage: AudioAttributesUsage.notification,
        );
        await androidImpl.createNotificationChannel(defaultChannel);

        // Register all selectable sound channels
        for (final tone in AppConstants.notificationTones) {
          final AndroidNotificationChannel toneChannel = AndroidNotificationChannel(
            tone.channelId,
            'Dayform: ${tone.title}',
            description: tone.description,
            importance: Importance.max,
            playSound: true,
            sound: tone.rawSoundName != null
                ? RawResourceAndroidNotificationSound(tone.rawSoundName!)
                : null,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
            enableLights: true,
            showBadge: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
          );
          await androidImpl.createNotificationChannel(toneChannel);
        }
      }
    }

    // The exact-alarm settings screen should only be opened after an explicit
    // reminder action. At startup we request just the ordinary alert permission.
    await requestPermissions(requestExactAlarm: false);

    _isInitialized = true;

    // The regular response callback is not invoked when a notification launches
    // a terminated app, so process that response explicitly as well.
    final launchDetails = await _notificationsPlugin
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails?.notificationResponse;
      if (response != null) {
        await _handleNotificationResponse(response);
      }
    }
  }

  Future<bool> requestPermissions({bool requestExactAlarm = true}) async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        final notificationsGranted =
            await androidImpl.requestNotificationsPermission() ?? false;
        if (!requestExactAlarm) return notificationsGranted;

        var exactAlarmGranted =
            await androidImpl.canScheduleExactNotifications() ?? false;
        if (!exactAlarmGranted) {
          exactAlarmGranted =
              await androidImpl.requestExactAlarmsPermission() ?? false;
        }
        return notificationsGranted && exactAlarmGranted;
      }
    } else if (Platform.isIOS) {
      final iosImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImpl != null) {
        final granted = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } else if (Platform.isMacOS) {
      final macOSImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      if (macOSImpl != null) {
        final granted = await macOSImpl.requestPermissions(
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
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImpl?.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    final notificationData = _decodePayload(response.payload);
    final originalPayload = notificationData['payload'] as String?;

    if (response.actionId == _snoozeActionId) {
      await scheduleNotification(
        id: response.id ?? 0,
        title: notificationData['title'] as String? ?? 'Snoozed reminder',
        body:
            notificationData['body'] as String? ??
            'Your reminder is due again.',
        scheduledDate: DateTime.now().add(const Duration(minutes: 10)),
        payload: originalPayload,
      );
      return;
    }

    await _onNotificationInteraction?.call(originalPayload, response.actionId);
  }

  String _encodePayload({
    required String title,
    required String body,
    String? payload,
  }) {
    return jsonEncode({
      'marker': _payloadMarker,
      'payload': payload,
      'title': title,
      'body': body,
    });
  }

  Map<String, Object?> _decodePayload(String? encodedPayload) {
    if (encodedPayload == null || encodedPayload.isEmpty) {
      return const <String, Object?>{};
    }
    try {
      final decoded = jsonDecode(encodedPayload);
      if (decoded is Map && decoded['marker'] == _payloadMarker) {
        return Map<String, Object?>.from(decoded);
      }
    } catch (_) {
      // Notifications scheduled by earlier app versions contain a plain payload.
    }
    return <String, Object?>{'payload': encodedPayload};
  }

  // Schedule a notification at exact local time
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String? toneKey,
  }) async {
    if (kIsWeb) return false;

    if (!_isInitialized) {
      await initialize();
    }

    final now = DateTime.now();
    DateTime effectiveDate = scheduledDate;

    // Do not schedule notifications for times already in the past
    if (!effectiveDate.isAfter(now)) {
      return false;
    }

    final tzNow = tz.TZDateTime.now(tz.local);
    final tzScheduledDate = tz.TZDateTime.from(effectiveDate, tz.local);

    // Exact alarms on Android MUST be strictly in the future
    if (tzScheduledDate.isBefore(tzNow) ||
        tzScheduledDate.difference(tzNow).inSeconds < 1) {
      return false;
    }

    final notificationPayload = _encodePayload(
      title: title,
      body: body,
      payload: payload,
    );

    final actions = <AndroidNotificationAction>[
      const AndroidNotificationAction(
        _snoozeActionId,
        'Snooze 10m',
        showsUserInterface: true,
      ),
      if (payload?.startsWith('task_') ?? false)
        const AndroidNotificationAction(
          _completeActionId,
          'Complete',
          showsUserInterface: true,
        ),
    ];

    final selectedTone = AppConstants.getToneOption(toneKey ?? _activeToneKey);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          selectedTone.channelId,
          'Dayform: ${selectedTone.title}',
          channelDescription: selectedTone.description,
          importance: Importance.max,
          priority: Priority.max,
          showWhen: true,
          playSound: true,
          sound: selectedTone.rawSoundName != null
              ? RawResourceAndroidNotificationSound(selectedTone.rawSoundName!)
              : null,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
          audioAttributesUsage: AudioAttributesUsage.notification,
          category: AndroidNotificationCategory.reminder,
          ticker: title,
          actions: actions,
        );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      windows: WindowsNotificationDetails(
        audio: WindowsNotificationAudio.preset(
          sound: WindowsNotificationSound.reminder,
        ),
        duration: WindowsNotificationDuration.long,
      ),
    );

    var androidScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    if (!kIsWeb && Platform.isAndroid) {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final canScheduleExact =
          await androidImpl?.canScheduleExactNotifications() ?? false;
      if (canScheduleExact) {
        androidScheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: androidScheduleMode,
        payload: notificationPayload,
      );
      return true;
    } catch (e) {
      if (androidScheduleMode == AndroidScheduleMode.exactAllowWhileIdle) {
        debugPrint(
          'Exact notification scheduling failed ($e); using inexact delivery.',
        );
        try {
          await _notificationsPlugin.zonedSchedule(
            id: id,
            title: title,
            body: body,
            scheduledDate: tzScheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: notificationPayload,
          );
          return true;
        } catch (err) {
          debugPrint('Notification scheduling failed: $err');
          return false;
        }
      }
      debugPrint('Notification scheduling failed: $e');
      return false;
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

  // Diagnostic Test Notification with Selected Tone (Immediate)
  Future<void> sendImmediateTestNotification({String? toneKey}) async {
    if (kIsWeb) return;

    if (!_isInitialized) {
      await initialize();
    }
    await requestPermissions();

    final selectedTone = AppConstants.getToneOption(toneKey ?? _activeToneKey);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          selectedTone.channelId,
          'Dayform: ${selectedTone.title}',
          channelDescription: selectedTone.description,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: selectedTone.rawSoundName != null
              ? RawResourceAndroidNotificationSound(selectedTone.rawSoundName!)
              : null,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
          audioAttributesUsage: AudioAttributesUsage.notification,
          category: AndroidNotificationCategory.reminder,
        );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      windows: WindowsNotificationDetails(
        audio: WindowsNotificationAudio.preset(
          sound: WindowsNotificationSound.reminder,
        ),
        duration: WindowsNotificationDuration.long,
      ),
    );

    try {
      await _notificationsPlugin.show(
        id: 99999,
        title: 'Dayform: ${selectedTone.title} 🔔',
        body:
            'Testing "${selectedTone.title}" tone with custom vibration alert!',
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Error showing immediate test notification: $e');
    }
  }

  // Diagnostic Scheduled Test Notification (e.g. 5 seconds delay)
  Future<void> scheduleTestNotification({
    int delaySeconds = 5,
    String? toneKey,
  }) async {
    if (kIsWeb) return;

    if (!_isInitialized) {
      await initialize();
    }
    await requestPermissions();

    final scheduledDate = DateTime.now().add(Duration(seconds: delaySeconds));
    final selectedTone = AppConstants.getToneOption(toneKey ?? _activeToneKey);
    await scheduleNotification(
      id: 88888,
      title: '⏰ Test Alert: ${selectedTone.title} ($delaySeconds sec)',
      body:
          'Success! Scheduled alarm, vibration and ${selectedTone.title} triggered right on time!',
      scheduledDate: scheduledDate,
      payload: 'test_alarm_payload',
      toneKey: selectedTone.id,
    );
  }

  // Play audible tone preview in-app and trigger test notification
  Future<void> playTonePreview(String toneKey) async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.heavyImpact();
      await sendImmediateTestNotification(toneKey: toneKey);
    } catch (e) {
      debugPrint('Tone preview error: $e');
    }
  }

  // Backwards-compatible chime preview
  Future<void> playChimePreview() async {
    await playTonePreview(_activeToneKey);
  }
}
