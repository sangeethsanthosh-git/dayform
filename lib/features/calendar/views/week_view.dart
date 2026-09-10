import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/category_definitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/event_item.dart';

class WeekView extends StatelessWidget {
  final DateTime selectedDate;
  final List<EventItem> events;
  final int firstDayOfWeek;
  final Function(EventItem) onEventTapped;
  final Function(DateTime) onSlotLongPressed;

  const WeekView({
    super.key,
    required this.selectedDate,
    required this.events,
    this.firstDayOfWeek = 1,
    required this.onEventTapped,
    required this.onSlotLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate week days
    final currentWeekday = selectedDate.weekday;
    final diff = (currentWeekday - firstDayOfWeek + 7) % 7;
    final startOfWeek = selectedDate.subtract(Duration(days: diff));
    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    const double hourHeight = 56.0;
    const int startHour = 7;
    const int endHour = 22;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Day columns header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
            child: Row(
              children: [
                const SizedBox(width: 50), // Time gutter width
                ...weekDays.map((day) {
                  final isToday = day.year == DateTime.now().year &&
                      day.month == DateTime.now().month &&
                      day.day == DateTime.now().day;
                  final isSelected = day.year == selectedDate.year &&
                      day.month == selectedDate.month &&
                      day.day == selectedDate.day;

                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(day).substring(0, 1),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.warmAmber)
                                : (isToday ? AppColors.warmAmber.withOpacity(0.2) : Colors.transparent),
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : (isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // Hours timeline and columns
          SizedBox(
            height: (endHour - startHour) * hourHeight,
            child: Stack(
              children: [
                // Hour grid lines
                ...List.generate(endHour - startHour, (index) {
                  final hour = startHour + index;
                  final hourLabel = DateFormat('h a').format(DateTime(2026, 1, 1, hour));

                  return Positioned(
                    top: index * hourHeight,
                    left: 0,
                    right: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(
                            hourLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
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
                  );
                }),

                // Event blocks per day column
                Positioned.fill(
                  left: 50,
                  child: Row(
                    children: weekDays.map((day) {
                      final dayStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                      final dayEvents = events.where((e) => e.dateOnly == dayStr && !e.isAllDay).toList();

                      return Expanded(
                        child: GestureDetector(
                          onLongPressStart: (details) {
                            final hourTapped = startHour + (details.localPosition.dy ~/ hourHeight);
                            final targetDt = DateTime(day.year, day.month, day.day, hourTapped);
                            onSlotLongPressed(targetDt);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            children: dayEvents.map((event) {
                              final startH = event.startDateTime.hour + event.startDateTime.minute / 60.0;
                              final endH = event.endDateTime.hour + event.endDateTime.minute / 60.0;
                              if (endH <= startHour || startH >= endHour) return const SizedBox.shrink();

                              final top = (startH - startHour).clamp(0.0, 24.0) * hourHeight;
                              final height = ((endH - startH) * hourHeight).clamp(24.0, 300.0);
                              final cat = CategoryDefinitions.getById(event.category);

                              return Positioned(
                                top: top,
                                left: 2,
                                right: 2,
                                height: height,
                                child: GestureDetector(
                                  onTap: () => onEventTapped(event),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: cat.color.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: cat.foregroundColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      event.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: cat.foregroundColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
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
