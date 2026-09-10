import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/category_definitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/event_item.dart';
import '../../../domain/models/task_item.dart';

class AgendaView extends StatelessWidget {
  final List<EventItem> events;
  final List<TaskItem> tasks;
  final Function(EventItem) onEventTapped;
  final Function(TaskItem) onTaskTapped;

  const AgendaView({
    super.key,
    required this.events,
    required this.tasks,
    required this.onEventTapped,
    required this.onTaskTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group events by dateOnly
    final Map<String, List<EventItem>> groupedEvents = {};
    for (final e in events) {
      groupedEvents.putIfAbsent(e.dateOnly, () => []).add(e);
    }

    final sortedDates = groupedEvents.keys.toList()..sort();

    if (sortedDates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text('No upcoming schedule items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Add events or deadlines to see them in your agenda.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateStr = sortedDates[index];
        final dayEvents = groupedEvents[dateStr]!;
        final parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();

        final now = DateTime.now();
        final isToday = parsedDate.year == now.year && parsedDate.month == now.month && parsedDate.day == now.day;
        final isTomorrow = parsedDate.difference(DateTime(now.year, now.month, now.day)).inDays == 1;

        String dayTitle = DateFormat('EEEE, d MMMM').format(parsedDate);
        if (isToday) dayTitle = 'Today • $dayTitle';
        if (isTomorrow) dayTitle = 'Tomorrow • $dayTitle';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                dayTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isToday ? AppColors.warmAmberForeground : (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText),
                ),
              ),
            ),

            // Event Cards for this date
            ...dayEvents.map((event) {
              final cat = CategoryDefinitions.getById(event.category);
              return GestureDetector(
                onTap: () => onEventTapped(event),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
                    borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cat.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                              ),
                            ),
                            Text(
                              event.isAllDay
                                  ? 'All day'
                                  : "${DateFormat('h:mm a').format(event.startDateTime)} - ${DateFormat('h:mm a').format(event.endDateTime)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.withOpacity(0.5)),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
