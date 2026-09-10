import 'package:flutter/material.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../quick_add/quick_add_sheet.dart';
import 'modules/bills_module.dart';
import 'modules/birthdays_module.dart';
import 'modules/focus_timer_module.dart';
import 'modules/habits_module.dart';
import 'modules/weekly_review_module.dart';

class MySpaceScreen extends StatefulWidget {
  final AppState appState;

  const MySpaceScreen({super.key, required this.appState});

  @override
  State<MySpaceScreen> createState() => _MySpaceScreenState();
}

class _MySpaceScreenState extends State<MySpaceScreen> {
  int _activeModuleIndex = 0;

  final List<String> _moduleTitles = [
    'Bills & Subs',
    'Birthdays',
    'Habits',
    'Focus Timer',
    'Weekly Review',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Space',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
                  ),
                  IconButton(
                    onPressed: () => _openQuickAdd(context),
                    icon: Icon(Icons.add_circle_rounded, size: 28, color: AppColors.warmAmber),
                  ),
                ],
              ),
            ),

            // Module Switcher Pills
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _moduleTitles.length,
                itemBuilder: (context, index) {
                  final isSelected = _activeModuleIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_moduleTitles[index]),
                      selected: isSelected,
                      selectedColor: AppColors.warmAmber,
                      backgroundColor: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _activeModuleIndex = index);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),

            // Module Content
            Expanded(
              child: _buildActiveModule(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveModule() {
    switch (_activeModuleIndex) {
      case 0:
        return BillsModule(
          bills: widget.appState.bills,
          currencyTotals: widget.appState.currencyTotals,
          onMarkPaid: (id, amt, curr) => widget.appState.markBillPaid(id, amt, curr),
          onDeleteBill: (id) => widget.appState.deleteBill(id),
          onAddBill: () => _openQuickAdd(context, initialTab: 3),
        );
      case 1:
        return BirthdaysModule(
          birthdays: widget.appState.birthdays,
          onDeleteBirthday: (id) => widget.appState.deleteBirthday(id),
          onAddBirthday: () => _openQuickAdd(context, initialTab: 4),
        );
      case 2:
        return HabitsModule(
          habits: widget.appState.habits,
          todayCompletedHabits: widget.appState.todayCompletedHabits,
          habitStreaks: widget.appState.habitStreaks,
          onToggleHabit: (id) => widget.appState.toggleHabitCheckIn(id, widget.appState.todayDateOnly),
          onDeleteHabit: (id) => widget.appState.deleteHabit(id),
          onAddHabit: () => _openQuickAdd(context, initialTab: 5),
        );
      case 3:
        return FocusTimerModule(
          tasks: widget.appState.todayTasks,
          focusRepo: widget.appState.focusRepo,
        );
      case 4:
      default:
        return WeeklyReviewModule(
          completedTasks: widget.appState.completedTasks,
          pendingTasks: widget.appState.todayTasks.where((t) => !t.isCompleted).toList(),
          upcomingEvents: widget.appState.allEvents,
          habits: widget.appState.habits,
          upcomingBills: widget.appState.bills,
          onRescheduleTask: (taskId, newDate) async {
            final task = await widget.appState.taskRepo.getTaskById(taskId);
            if (task != null) {
              final newDateStr = "${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";
              await widget.appState.taskRepo.updateTask(task.copyWith(dueDate: newDateStr));
              widget.appState.refreshAll();
            }
          },
        );
    }
  }

  void _openQuickAdd(BuildContext context, {int initialTab = 0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddSheet(appState: widget.appState, initialTabIndex: initialTab),
    );
  }
}
