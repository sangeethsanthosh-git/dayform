import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/category_definitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/event_item.dart';

class DayView extends StatelessWidget {
  final DateTime selectedDate;
  final List<EventItem> events;
  final Function(EventItem) onEventTapped;
  final Function(DateTime) onSlotLongPressed;

  const DayView({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onEventTapped,
    required this.onSlotLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    final allDayEvents = events.where((e) => e.isAllDay).toList();
    final timedEvents = events.where((e) => !e.isAllDay).toList();

    const double hourHeight = 64.0;
    const int startHour = 0;
    const int endHour = 24;

    return SingleChildScrollView(
      child: Column(
        children: [
          // All day events bar
          if (allDayEvents.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted,
              child: Row(
                children: [
                  const Text('ALL DAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: allDayEvents.map((e) {
                        final cat = CategoryDefinitions.getById(e.category);
                        return GestureDetector(
                          onTap: () => onEventTapped(e),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cat.color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              e.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cat.foregroundColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

          // 24 Hour Slots
          SizedBox(
            height: (endHour - startHour) * hourHeight,
            child: Stack(
              children: [
                // Hour lines & labels
                ...List.generate(endHour - startHour, (index) {
                  final hour = startHour + index;
                  final hourLabel = DateFormat('h a').format(DateTime(2026, 1, 1, hour));

                  return Positioned(
                    top: index * hourHeight,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onLongPress: () {
                        onSlotLongPressed(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, hour));
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                hourLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Live Red/Amber Current Time Line Indicator
                if (isToday)
                  Positioned(
                    top: (now.hour + now.minute / 60.0) * hourHeight,
                    left: 54,
                    right: 0,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.warmAmber,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: AppColors.warmAmber,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Timed Event Cards
                Positioned.fill(
                  left: 64,
                  right: 16,
                  child: Stack(
                    children: timedEvents.map((event) {
                      final startH = event.startDateTime.hour + event.startDateTime.minute / 60.0;
                      final endH = event.endDateTime.hour + event.endDateTime.minute / 60.0;
                      final top = startH * hourHeight;
                      final height = ((endH - startH) * hourHeight).clamp(32.0, 400.0);
                      final cat = CategoryDefinitions.getById(event.category);

                      return Positioned(
                        top: top,
                        left: 4,
                        right: 4,
                        height: height,
                        child: GestureDetector(
                          onTap: () => onEventTapped(event),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cat.color.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: cat.foregroundColor.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: cat.foregroundColor,
                                  ),
                                ),
                                Text(
                                  "${DateFormat('h:mm a').format(event.startDateTime)} - ${DateFormat('h:mm a').format(event.endDateTime)}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cat.foregroundColor.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
