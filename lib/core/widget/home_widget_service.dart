import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../../domain/models/event_item.dart';
import '../../domain/models/task_item.dart';

class HomeWidgetService {
  static const String appGroupId = 'group.com.dayform.app';
  static const String androidWidgetName = 'DayformTodayWidget';

  static Future<void> updateTodayWidget({
    required EventItem? upNextEvent,
    required List<TaskItem> topTasks,
  }) async {
    if (kIsWeb) return;

    try {
      await HomeWidget.saveWidgetData<String>(
        'up_next_title',
        upNextEvent?.title ?? 'No upcoming commitments',
      );

      final timeStr = upNextEvent != null
          ? "${upNextEvent.startDateTime.hour.toString().padLeft(2, '0')}:${upNextEvent.startDateTime.minute.toString().padLeft(2, '0')}"
          : '';
      await HomeWidget.saveWidgetData<String>('up_next_time', timeStr);

      final taskCount = topTasks.length;
      await HomeWidget.saveWidgetData<String>(
        'tasks_summary',
        taskCount > 0 ? '$taskCount tasks for today' : 'All tasks completed',
      );

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
      );
    } catch (_) {
      // Graceful fallback if widget platform provider is not configured
    }
  }
}
