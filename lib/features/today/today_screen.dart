import 'package:flutter/material.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/top_dual_pill_bar.dart';
import '../../domain/models/bill_item.dart';
import '../../domain/models/event_item.dart';
import '../../domain/models/task_item.dart';
import '../quick_add/quick_add_sheet.dart';
import '../settings/settings_screen.dart';
import 'widgets/birthday_celebration_card.dart';
import 'widgets/chronological_agenda.dart';
import 'widgets/editorial_date_header.dart';
import 'widgets/greeting_header.dart';
import 'widgets/interactive_week_strip.dart';
import 'widgets/mindful_starter_card.dart';
import 'widgets/modular_today_cards.dart';
import 'widgets/priority_tasks_section.dart';
import 'widgets/up_next_card.dart';

class TodayScreen extends StatefulWidget {
  final AppState appState;
  final ValueChanged<int>? onNavigateToTab;

  const TodayScreen({
    super.key,
    required this.appState,
    this.onNavigateToTab,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  int _selectedFilter = 0; // 0: Todays tasks, 1: Reminders

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final isSelectedDateToday = widget.appState.selectedDate.year == now.year &&
        widget.appState.selectedDate.month == now.month &&
        widget.appState.selectedDate.day == now.day;

    final datesWithEvents = widget.appState.allEvents.map((e) => e.dateOnly).toSet();

    final dobStr = widget.appState.settings.userBirthDate;
    bool isUserBirthday = false;
    if (dobStr != null && dobStr.isNotEmpty) {
      try {
        final dob = DateTime.parse(dobStr);
        final cur = widget.appState.selectedDate;
        isUserBirthday = dob.month == cur.month && dob.day == cur.day;
      } catch (_) {}
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.appState.refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Dual Pill Bar (Image 1): [ Today ] [ Calendar ] + (+) Button
                TopDualPillBar(
                  selectedIndex: 0,
                  onTabSelected: (index) {
                    if (index == 1 && widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(1);
                    }
                  },
                  onAddPressed: () => _openQuickAdd(context, initialTab: 0),
                ),
                const SizedBox(height: 16),

                // 2. Greeting Header (Image 2: "Hi, [Name]")
                GreetingHeader(
                  userName: widget.appState.settings.userName,
                  onSearchTapped: () => _showSearchDialog(context),
                  onSettingsTapped: () {
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(4);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Birthday Wish Banner (when today is the user's birthday)
                if (isUserBirthday) ...[
                  BirthdayCelebrationCard(
                    userName: widget.appState.settings.userName,
                  ),
                  const SizedBox(height: 16),
                ],

                // 3. Editorial Date Header with Dual World Clocks (Image 1 Left)
                EditorialDateHeader(
                  selectedDate: widget.appState.selectedDate,
                  onReturnToToday: () => widget.appState.setSelectedDate(DateTime.now()),
                ),
                const SizedBox(height: 16),

                // 4. Interactive Capsule Week Strip (Image 2)
                InteractiveWeekStrip(
                  selectedDate: widget.appState.selectedDate,
                  firstDayOfWeek: widget.appState.settings.firstDayOfWeek,
                  datesWithEvents: datesWithEvents,
                  onDateSelected: (date) => widget.appState.setSelectedDate(date),
                ),
                const SizedBox(height: 16),

                // 5. Mindful Morning Starter Card (Image 2)
                MindfulStarterCard(
                  onTap: () => _openQuickAdd(context, initialTab: 1),
                ),
                const SizedBox(height: 18),

                // 6. Sub-Filter Pills (Image 1 Left: [ Todays tasks ] [ Reminders ])
                Row(
                  children: [
                    _buildFilterPill(
                      label: "Today's tasks",
                      index: 0,
                      isDark: isDark,
                      count: widget.appState.todayTasks.length + widget.appState.selectedDateEvents.length,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterPill(
                      label: 'Reminders',
                      index: 1,
                      isDark: isDark,
                      count: widget.appState.bills.length,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 7. Filtered Content Display
                if (_selectedFilter == 0) ...[
                  // Up Next Card (only on today's view)
                  if (isSelectedDateToday && widget.appState.settings.visibleTodayModules.contains('up_next')) ...[
                    UpNextCard(
                      event: widget.appState.upNextEvent,
                      onQuickAddEvent: () => _openQuickAdd(context, initialTab: 0),
                      onEventTapped: (e) => _showEventDetail(context, e),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Chronological Agenda (Meeting Cards with Duration Pills)
                  if (widget.appState.settings.visibleTodayModules.contains('agenda')) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Agenda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openQuickAdd(context, initialTab: 0),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ChronologicalAgenda(
                      events: widget.appState.selectedDateEvents,
                      isSelectedDateToday: isSelectedDateToday,
                      onEventTapped: (e) => _showEventDetail(context, e),
                      onAddEvent: () => _openQuickAdd(context, initialTab: 0),
                    ),
                    const SizedBox(height: 22),
                  ],

                  // Priority Tasks Section
                  if (widget.appState.settings.visibleTodayModules.contains('tasks')) ...[
                    PriorityTasksSection(
                      todayTasks: widget.appState.todayTasks,
                      overdueTasks: isSelectedDateToday ? widget.appState.overdueTasks : [],
                      onToggleTask: (id, val) => widget.appState.toggleTask(id, val),
                      onTaskTapped: (t) => _showTaskDetail(context, t),
                      onAddTask: () => _openQuickAdd(context, initialTab: 1),
                    ),
                    const SizedBox(height: 24),
                  ],
                ] else ...[
                  // Reminders View (Subscriptions, Bills, Habits)
                  ModularTodayCards(
                    habits: widget.appState.settings.visibleTodayModules.contains('habits')
                        ? widget.appState.habits
                        : [],
                    todayCompletedHabits: widget.appState.todayCompletedHabits,
                    onToggleHabit: (id) => widget.appState.toggleHabitCheckIn(id, widget.appState.todayDateOnly),
                    bills: widget.appState.settings.visibleTodayModules.contains('payments')
                        ? widget.appState.bills
                        : [],
                    onBillTapped: (b) => _showBillDetail(context, b),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required int index,
    required bool isDark,
    required int count,
  }) {
    final isSelected = _selectedFilter == index;
    final activeBg = isDark ? Colors.white : AppColors.pillBlack;
    final activeFg = isDark ? AppColors.pillBlack : Colors.white;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeBg
              : (isDark ? AppColors.darkCardSurface : const Color(0xFFEBEAE5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? activeFg
                    : (isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.pillBlack.withOpacity(0.15) : Colors.white.withOpacity(0.2))
                      : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? activeFg
                        : (isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openQuickAdd(BuildContext context, {int initialTab = 0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddSheet(appState: widget.appState, initialTabIndex: initialTab),
    );
  }

  void _showEventDetail(BuildContext context, EventItem event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
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
                    : '${event.startDateTime.hour}:${event.startDateTime.minute.toString().padLeft(2, '0')} - ${event.endDateTime.hour}:${event.endDateTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              if (event.location != null && event.location!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text(event.location!),
                  ],
                ),
              ],
              if (event.notes != null && event.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(event.notes!, style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showTaskDetail(BuildContext context, TaskItem task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    onPressed: () {
                      widget.appState.deleteTask(task.id);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              if (task.dueDate != null) ...[
                const SizedBox(height: 8),
                Text('Due: ${task.dueDate} ${task.dueTime ?? ''}'),
              ],
              if (task.notes != null && task.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(task.notes!, style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _planTaskSheet(context, task);
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: const Text('Plan this task in Calendar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _planTaskSheet(BuildContext context, TaskItem task) {
    final now = DateTime.now();
    DateTime planStart = DateTime(now.year, now.month, now.day, 14, 0);
    DateTime planEnd = planStart.add(Duration(minutes: task.estimatedDurationMinutes ?? 60));

    final conflicts = widget.appState.checkEventConflicts(planStart, planEnd);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
              Text(
                'Plan Task: ${task.title}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Schedule a dedicated focus block: ${planStart.hour}:${planStart.minute.toString().padLeft(2, '0')} - ${planEnd.hour}:${planEnd.minute.toString().padLeft(2, '0')}',
              ),
              if (conflicts.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Conflicts with "${conflicts.first.title}". You can still proceed if confirmed.',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.appState.planTaskIntoCalendar(task, planStart, planEnd);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task scheduled in calendar!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Confirm Time Block'),
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  void _showBillDetail(BuildContext context, BillItem bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                    bill.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
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
              Text(
                'Amount: ${bill.currency} ${bill.amount.toStringAsFixed(2)} • Renews: ${bill.renewalDate}',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  widget.appState.markBillPaid(bill.id, bill.amount, bill.currency);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Recorded payment for ${bill.name}! Next renewal updated.')),
                  );
                },
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Mark as Paid'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showSearch(
      context: context,
      delegate: AppSearchDelegate(appState: widget.appState),
    );
  }
}

class AppSearchDelegate extends SearchDelegate {
  final AppState appState;

  AppSearchDelegate({required this.appState});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Search events, tasks, and subscriptions...'));
    }

    final q = query.toLowerCase();
    final matchedEvents = appState.allEvents.where((e) => e.title.toLowerCase().contains(q)).toList();
    final matchedTasks = appState.todayTasks.where((t) => t.title.toLowerCase().contains(q)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (matchedEvents.isNotEmpty) ...[
          const Text('Events', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...matchedEvents.map((e) => ListTile(
                title: Text(e.title),
                subtitle: Text(e.dateOnly),
                leading: const Icon(Icons.event),
              )),
          const SizedBox(height: 16),
        ],
        if (matchedTasks.isNotEmpty) ...[
          const Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...matchedTasks.map((t) => ListTile(
                title: Text(t.title),
                subtitle: Text(t.dueDate ?? 'No date'),
                leading: const Icon(Icons.check_box_outlined),
              )),
        ],
      ],
    );
  }
}
