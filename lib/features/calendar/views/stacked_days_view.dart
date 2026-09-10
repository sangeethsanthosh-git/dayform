import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/event_item.dart';

class StackedDaysView extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final List<EventItem> events;
  final Function(DateTime) onDateSelected;
  final Function(EventItem) onEventTapped;
  final Function(DateTime, int) onAddEventAtHour;

  const StackedDaysView({
    super.key,
    required this.visibleMonth,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.onEventTapped,
    required this.onAddEventAtHour,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Generate days for visible month
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final days = List.generate(
      daysInMonth,
      (i) => DateTime(visibleMonth.year, visibleMonth.month, i + 1),
    );

    // Filter to current day and forward, or all days of the month
    final now = DateTime.now();
    final isCurrentMonth = visibleMonth.year == now.year && visibleMonth.month == now.month;
    final startIndex = isCurrentMonth ? (now.day - 1).clamp(0, daysInMonth - 1) : 0;
    final displayDays = days.sublist(startIndex);

    // Pastel palette cycle matching Image 1 Right
    final pastelCardColors = [
      const Color(0xFFDDD7EA), // Soft Lavender
      const Color(0xFFF3D5DC), // Soft Dusty Rose
      const Color(0xFFD3EBE7), // Soft Teal
      const Color(0xFFDFE8CE), // Soft Sage
      const Color(0xFFF7ECD4), // Soft Amber
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: displayDays.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final day = displayDays[index];
        final dayDateStr =
            "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
        final dayEvents = events.where((e) => e.dateOnly == dayDateStr).toList();
        final cardColor = pastelCardColors[index % pastelCardColors.length];

        return _buildDayCard(
          context: context,
          day: day,
          events: dayEvents,
          cardColor: cardColor,
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildDayCard({
    required BuildContext context,
    required DateTime day,
    required List<EventItem> events,
    required Color cardColor,
    required bool isDark,
  }) {
    final weekdayStr = DateFormat('EEEE').format(day);
    final dayNumberStr = day.day.toString();
    final monthStr = DateFormat('MMM').format(day).toUpperCase();

    return GestureDetector(
      onTap: () => onDateSelected(day),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardSurface : cardColor,
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : cardColor.withOpacity(0.8),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Day Date Block (Image 1 Right)
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekdayStr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.secondaryLightText : AppColors.primaryDarkText.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayNumberStr,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    monthStr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.secondaryLightText : AppColors.primaryDarkText.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Vertical divider
            Container(
              width: 1.2,
              height: 80,
              color: isDark ? AppColors.darkDivider : Colors.black.withOpacity(0.08),
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),

            // Right Column: Horizontal/Vertical Hour Timeline & Event Chips
            Expanded(
              child: events.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: events.map((e) {
                        final timeStr = DateFormat('h:mm a').format(e.startDateTime);
                        return GestureDetector(
                          onTap: () => onEventTapped(e),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : Colors.black.withOpacity(0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.warmAmber,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : _buildEmptyTimelineSlots(day, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTimelineSlots(DateTime day, bool isDark) {
    final defaultHours = [9, 14, 17]; // 9 am, 2 pm, 5 pm
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: defaultHours.map((hour) {
        final period = hour >= 12 ? 'pm' : 'am';
        final displayHour = hour > 12 ? hour - 12 : hour;
        return GestureDetector(
          onTap: () => onAddEventAtHour(day, hour),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.25) : Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : Colors.black.withOpacity(0.04),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$displayHour $period',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 16,
                  color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
