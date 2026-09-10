import 'package:flutter/services.dart';

class WidgetService {
  static const _channel = MethodChannel('com.dayform.app/widget');

  /// Requests the Android OS to pin the 1x1 dynamic live-date calendar icon to the user's home screen.
  static Future<bool> requestPinWidget() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPinWidget');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Triggers a refresh on the live date widget.
  static Future<void> updateWidget() async {
    try {
      await _channel.invokeMethod('updateWidget');
    } catch (_) {}
  }
}
