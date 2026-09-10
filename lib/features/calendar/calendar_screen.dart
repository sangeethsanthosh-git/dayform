import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/category_definitions.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/top_dual_pill_bar.dart';
import '../../domain/models/bill_item.dart';
import '../../domain/models/event_item.dart';
import '../quick_add/quick_add_sheet.dart';
import 'views/agenda_view.dart';
import 'views/day_view.dart';
import 'views/month_timeline_view.dart';
import 'views/month_view.dart';
import 'views/stacked_days_view.dart';
import 'views/week_view.dart';
import 'widgets/day_detail_sheet.dart';

class CalendarScreen extends StatefulWidget {
  final AppState appState;
  final ValueChanged<int>? onNavigateToTab;

  const CalendarScreen({
    super.key,
    required this.appState,
    this.onNavigateToTab,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late String _activeView; // 'stacked', 'timeline', 'month', 'week', 'day', 'agenda'
  DateTime _visibleDate = DateTime.now();
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    // Default to stacked days matching Image 1 Right
    _activeView = 'stacked';
    _visibleDate = widget.appState.selectedDate;
  }

  void _stepPeriod(int step) {
    setState(() {
      if (_activeView == 'month' || _activeView == 'stacked' || _activeView == 'timeline') {
        _visibleDate = DateTime(_visibleDate.year, _visibleDate.month + step, 1);
      } else if (_activeView == 'week') {
        _visibleDate = _visibleDate.add(Duration(days: 7 * step));
      } else if (_activeView == 'day') {
        _visibleDate = _visibleDate.add(Duration(days: step));
      }
    });
  }

  void _returnToToday() {
    final now = DateTime.now();
    setState(() {
      _visibleDate = now;
    });
    widget.appState.setSelectedDate(now);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter events by selected category if active
    final filteredEvents = _selectedCategoryFilter == null
        ? widget.appState.allEvents
        : widget.appState.allEvents.where((e) => e.category == _selectedCategoryFilter).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Dual Pill Bar (Image 1): [ Today ] [ Calendar ] + (+) Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TopDualPillBar(
                selectedIndex: 1,
                onTabSelected: (index) {
                  if (index == 0 && widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(0);
                  }
                },
                onAddPressed: () => _openQuickAdd(prefilledDate: widget.appState.selectedDate),
              ),
            ),

            // 2. Month Slider Carousel (Image 1 Right: < NOV < DEC > JAN >)
            _buildMonthSlider(isDark),
            const SizedBox(height: 8),

            // 3. View Switcher Pill Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted,
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
                child: Row(
                  children: [
                    _buildViewPill('stacked', 'Cards', isDark),
                    _buildViewPill('timeline', 'Timeline', isDark),
                    _buildViewPill('month', 'Month', isDark),
                    _buildViewPill('week', 'Week', isDark),
                    _buildViewPill('agenda', 'Agenda', isDark),
                  ],
                ),
              ),
            ),

            // 4. Category Filter Chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  _buildCategoryChip('All', null, isDark),
                  ...CategoryDefinitions.all.map((cat) {
                    return _buildCategoryChip(cat.name, cat.id, isDark, color: cat.color);
                  }),
                ],
              ),
            ),
            const Divider(height: 1),

            // 5. Active View Body
            Expanded(
              child: _buildActiveView(filteredEvents),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openQuickAdd(prefilledDate: widget.appState.selectedDate),
        backgroundColor: AppColors.warmAmber,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildMonthSlider(bool isDark) {
    final prevMonth = DateTime(_visibleDate.year, _visibleDate.month - 1, 1);
    final nextMonth = DateTime(_visibleDate.year, _visibleDate.month + 1, 1);

    final prevMonthStr = DateFormat('MMM').format(prevMonth).toUpperCase();
    final currentMonthStr = DateFormat('MMM').format(_visibleDate).toUpperCase();
    final nextMonthStr = DateFormat('MMM').format(nextMonth).toUpperCase();
    final yearStr = _visibleDate.year.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Month button
          GestureDetector(
            onTap: () => _stepPeriod(-1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                ),
                Text(
                  prevMonthStr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Current Month Pill (tap to return to current month/today)
          GestureDetector(
            onTap: _returnToToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$currentMonthStr $yearStr',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Next Month button
          GestureDetector(
            onTap: () => _stepPeriod(1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nextMonthStr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewPill(String viewKey, String label, bool isDark) {
    final isSelected = _activeView == viewKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeView = viewKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.pillRadius),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText)
                  : (isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? categoryId, bool isDark, {Color? color}) {
    final isSelected = _selectedCategoryFilter == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: color?.withOpacity(0.3) ?? AppColors.warmAmber.withOpacity(0.3),
        backgroundColor: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? (color ?? AppColors.warmAmber) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategoryFilter = categoryId;
          });
        },
      ),
    );
  }

  Widget _buildActiveView(List<EventItem> filteredEvents) {
    switch (_activeView) {
      case 'stacked':
        return StackedDaysView(
          visibleMonth: _visibleDate,
          selectedDate: widget.appState.selectedDate,
          events: filteredEvents,
          onDateSelected: (date) {
            widget.appState.setSelectedDate(date);
            _openDayDetail(date);
          },
          onEventTapped: (e) => _showEventDetail(e),
          onAddEventAtHour: (date, hour) {
            final targetDate = DateTime(date.year, date.month, date.day, hour, 0);
            _openQuickAdd(prefilledDate: targetDate);
          },
        );
      case 'timeline':
        return MonthTimelineView(
          visibleMonth: _visibleDate,
          selectedDate: widget.appState.selectedDate,
          events: filteredEvents,
          bills: widget.appState.bills,
          onDateSelected: (date) {
            widget.appState.setSelectedDate(date);
            _openDayDetail(date);
          },
          onEventTapped: (e) => _showEventDetail(e),
          onBillTapped: (b) => _showBillDetail(b),
          onMarkBillPaid: (id, amount, currency) {
            widget.appState.markBillPaid(id, amount, currency);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Marked bill as paid! Next renewal updated.')),
            );
          },
        );
      case 'week':
        return WeekView(
          selectedDate: _visibleDate,
          events: filteredEvents,
          firstDayOfWeek: widget.appState.settings.firstDayOfWeek,
          onEventTapped: (e) => _showEventDetail(e),
          onSlotLongPressed: (dt) => _openQuickAdd(prefilledDate: dt),
        );
      case 'day':
        return DayView(
          selectedDate: _visibleDate,
          events: filteredEvents.where((e) => e.dateOnly == _formatDate(_visibleDate)).toList(),
          onEventTapped: (e) => _showEventDetail(e),
          onSlotLongPressed: (dt) => _openQuickAdd(prefilledDate: dt),
        );
      case 'agenda':
        return AgendaView(
          events: filteredEvents,
          tasks: widget.appState.todayTasks,
          onEventTapped: (e) => _showEventDetail(e),
          onTaskTapped: (_) {},
        );
      case 'month':
      default:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              MonthView(
                currentMonth: _visibleDate,
                selectedDate: widget.appState.selectedDate,
                events: filteredEvents,
                tasks: widget.appState.todayTasks,
                bills: widget.appState.bills,
                birthdays: widget.appState.birthdays,
                firstDayOfWeek: widget.appState.settings.firstDayOfWeek,
                onDateSelected: (date) {
                  widget.appState.setSelectedDate(date);
                  _openDayDetail(date);
                },
                onDateLongPressed: (date) => _openQuickAdd(prefilledDate: date),
              ),
            ],
          ),
        );
    }
  }

  void _openDayDetail(DateTime date) {
    final dateStr = _formatDate(date);
    final dayEvents = widget.appState.allEvents.where((e) => e.dateOnly == dateStr).toList();
    final dayTasks = widget.appState.todayTasks.where((t) => t.dueDate == dateStr).toList();
    final dayBills = widget.appState.bills.where((b) => b.renewalDate == dateStr).toList();
    final dayBirthdays = widget.appState.birthdays.where((b) {
      final parts = b.birthDate.split('-');
      return (parts.length == 3 && parts[1] == date.month.toString().padLeft(2, '0') && parts[2] == date.day.toString().padLeft(2, '0')) ||
             (parts.length == 2 && parts[0] == date.month.toString().padLeft(2, '0') && parts[1] == date.day.toString().padLeft(2, '0'));
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DayDetailSheet(
        date: date,
        events: dayEvents,
        tasks: dayTasks,
        bills: dayBills,
        birthdays: dayBirthdays,
        onEventTapped: (e) => _showEventDetail(e),
        onTaskTapped: (_) {},
        onAddEvent: () => _openQuickAdd(prefilledDate: date),
      ),
    );
  }

  void _openQuickAdd({DateTime? prefilledDate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddSheet(
        appState: widget.appState,
        initialDate: prefilledDate ?? widget.appState.selectedDate,
      ),
    );
  }

  void _showEventDetail(EventItem event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                Expanded(
                  child: Text(event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () {
                    widget.appState.deleteEvent(event.id);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.isAllDay
                  ? 'All day • ${event.dateOnly}'
                  : "${DateFormat('h:mm a').format(event.startDateTime)} - ${DateFormat('h:mm a').format(event.endDateTime)}",
              style: const TextStyle(fontSize: 15),
            ),
            if (event.notes != null) ...[
              const SizedBox(height: 10),
              Text(event.notes!, style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showBillDetail(BillItem bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                Text(bill.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () {
                    widget.appState.deleteBill(bill.id);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Amount: ${bill.currency} ${bill.amount.toStringAsFixed(2)} • Renews: ${bill.renewalDate}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.appState.markBillPaid(bill.id, bill.amount, bill.currency);
                Navigator.pop(ctx);
              },
              child: const Text('Mark as Paid'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }
}
