import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class InteractiveWeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Set<String> datesWithEvents;
  final int firstDayOfWeek; // 1=Mon, 7=Sun

  const InteractiveWeekStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.datesWithEvents,
    this.firstDayOfWeek = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate current week range based on selectedDate and firstDayOfWeek
    final currentWeekday = selectedDate.weekday; // 1..7 (Mon..Sun)
    final diff = (currentWeekday - firstDayOfWeek + 7) % 7;
    final startOfWeek = selectedDate.subtract(Duration(days: diff));

    final days = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    final monthYearTitle = DateFormat('MMMM yyyy').format(selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Header: e.g. "September 2026"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthYearTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                    letterSpacing: -0.2,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => onDateSelected(selectedDate.subtract(const Duration(days: 7))),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 20,
                          color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => onDateSelected(selectedDate.add(const Duration(days: 7))),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 7-day capsule row: Fully responsive with Expanded to prevent overflow on any screen
          Row(
            children: days.map((day) {
              final isSelected = day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;

              final weekdayLabel = DateFormat('E').format(day); // Mon, Tue, etc.
              final dayNumberStr = day.day.toString();
              final dayDateStr =
                  "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
              final hasEvents = datesWithEvents.contains(dayDateStr);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDateSelected(day),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.darkSurfaceMuted : const Color(0xFFF6F4EE))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Weekday label (Mon, Tue...)
                        Text(
                          weekdayLabel,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText)
                                : (isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Day Number Circle (Golden Amber filled for active day)
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.warmAmber
                                : Colors.transparent,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.warmAmber.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            dayNumberStr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),

                        // Event indicator dot
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasEvents ? AppColors.warmAmber : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
