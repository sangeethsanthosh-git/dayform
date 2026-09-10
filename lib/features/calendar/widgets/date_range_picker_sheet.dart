import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class DateRangePickerSheet extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;
  final Function(DateTime, DateTime) onRangeSelected;

  const DateRangePickerSheet({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    required this.onRangeSelected,
  });

  @override
  State<DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<DateRangePickerSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStart;
    _endDate = widget.initialEnd;
    _currentMonth = DateTime(_startDate.year, _startDate.month, 1);
  }

  void _onDayTapped(DateTime day) {
    setState(() {
      if (day.isBefore(_startDate) || _startDate != _endDate) {
        _startDate = day;
        _endDate = day;
      } else {
        _endDate = day;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthFormat = DateFormat('MMMM yyyy');
    final rangeLabel = "${DateFormat('d MMM').format(_startDate)} - ${DateFormat('d MMM yyyy').format(_endDate)}";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Date Range',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            rangeLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.warmAmberForeground,
            ),
          ),
          const SizedBox(height: 16),

          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                  });
                },
              ),
              Text(
                monthFormat.format(_currentMonth),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Calendar Grid
          _buildMonthGrid(isDark),
          const SizedBox(height: 20),

          // Apply Button
          ElevatedButton(
            onPressed: () {
              widget.onRangeSelected(_startDate, _endDate);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppColors.warmAmber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Apply Range', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(bool isDark) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1=Mon

    final List<Widget> dayWidgets = [];

    // Weekday headers
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    for (final w in weekdays) {
      dayWidgets.add(Center(
        child: Text(
          w,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
          ),
        ),
      ));
    }

    // Offset before day 1
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    // Days 1..daysInMonth
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, d);
      final isStart = date.year == _startDate.year && date.month == _startDate.month && date.day == _startDate.day;
      final isEnd = date.year == _endDate.year && date.month == _endDate.month && date.day == _endDate.day;
      final isInRange = date.isAfter(_startDate) && date.isBefore(_endDate);

      BoxDecoration decoration;
      if (isStart && isEnd) {
        decoration = const BoxDecoration(shape: BoxShape.circle, color: AppColors.warmAmber);
      } else if (isStart) {
        decoration = const BoxDecoration(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
          color: AppColors.warmAmber,
        );
      } else if (isEnd) {
        decoration = const BoxDecoration(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
          color: AppColors.warmAmber,
        );
      } else if (isInRange) {
        decoration = BoxDecoration(
          color: AppColors.warmAmber.withOpacity(0.25),
        );
      } else {
        decoration = const BoxDecoration();
      }

      dayWidgets.add(
        GestureDetector(
          onTap: () => _onDayTapped(date),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: decoration,
            alignment: Alignment.center,
            child: Text(
              '$d',
              style: TextStyle(
                fontSize: 13,
                fontWeight: (isStart || isEnd) ? FontWeight.w700 : FontWeight.w500,
                color: (isStart || isEnd)
                    ? Colors.white
                    : (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 4,
      crossAxisSpacing: 2,
      children: dayWidgets,
    );
  }
}
