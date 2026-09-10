import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/category_definitions.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/task_item.dart';
import '../quick_add/quick_add_sheet.dart';

class TasksScreen extends StatefulWidget {
  final AppState appState;

  const TasksScreen({super.key, required this.appState});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                    'Tasks',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
                  ),
                  IconButton(
                    onPressed: () => _openQuickAdd(context),
                    icon: const Icon(Icons.add_circle_rounded, size: 28, color: AppColors.warmAmber),
                  ),
                ],
              ),
            ),

            // Tab Bar: Today, Upcoming, Overdue, Inbox, Completed
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
              unselectedLabelColor: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
              indicatorColor: AppColors.warmAmber,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: [
                Tab(text: 'Today (${widget.appState.todayTasks.where((t) => !t.isCompleted).length})'),
                Tab(text: 'Upcoming (${widget.appState.upcomingTasks.length})'),
                Tab(text: 'Overdue (${widget.appState.overdueTasks.length})'),
                Tab(text: 'Inbox (${widget.appState.inboxTasks.length})'),
                Tab(text: 'Completed (${widget.appState.completedTasks.length})'),
              ],
            ),

            // Category Filter Chips
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildCategoryFilterChip('All Lists', null, isDark),
                  ...CategoryDefinitions.all.map((c) => _buildCategoryFilterChip(c.name, c.id, isDark)),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(widget.appState.todayTasks, 'No tasks scheduled for today.'),
                  _buildTaskList(widget.appState.upcomingTasks, 'No upcoming scheduled tasks.'),
                  _buildTaskList(widget.appState.overdueTasks, 'Great job! No overdue tasks.'),
                  _buildTaskList(widget.appState.inboxTasks, 'Inbox is empty. Undated tasks appear here.'),
                  _buildTaskList(widget.appState.completedTasks, 'No completed tasks yet.'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openQuickAdd(context),
        backgroundColor: AppColors.warmAmber,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildCategoryFilterChip(String label, String? categoryId, bool isDark) {
    final isSelected = _selectedCategory == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.warmAmber.withOpacity(0.3),
        backgroundColor: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (_) {
          setState(() {
            _selectedCategory = categoryId;
          });
        },
      ),
    );
  }

  Widget _buildTaskList(List<TaskItem> tasks, String emptyMessage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _selectedCategory == null
        ? tasks
        : tasks.where((t) => t.category == _selectedCategory).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.checklist_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 14),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = filtered[index];
        return _buildTaskCard(task, isDark);
      },
    );
  }

  Widget _buildTaskCard(TaskItem task, bool isDark) {
    final cat = CategoryDefinitions.getById(task.category);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.sage,
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          widget.appState.toggleTask(task.id, !task.isCompleted);
        } else {
          widget.appState.deleteTask(task.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Transform.scale(
                  scale: 1.15,
                  child: Checkbox(
                    value: task.isCompleted,
                    activeColor: AppColors.sage,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    onChanged: (val) {
                      if (val != null) widget.appState.toggleTask(task.id, val);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Title & notes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? (isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText)
                              : (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText),
                        ),
                      ),
                      if (task.notes != null && task.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.notes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // "Plan this task" action button
                IconButton(
                  tooltip: 'Plan in Calendar',
                  icon: const Icon(Icons.schedule_send_rounded, size: 20),
                  color: AppColors.warmAmber,
                  onPressed: () => _showPlanTaskModal(task),
                ),
              ],
            ),

            // Metadata Chips: Due Date, Category, Priority
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (task.dueDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12),
                          const SizedBox(width: 4),
                          Text(task.dueDate!, style: const TextStyle(fontSize: 11)),
                          if (task.dueTime != null) ...[
                            const SizedBox(width: 4),
                            Text('• ${task.dueTime}', style: const TextStyle(fontSize: 11)),
                          ],
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cat.name,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cat.foregroundColor),
                    ),
                  ),
                  if (task.priority > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: task.priority == 3
                            ? AppColors.dustyRose.withOpacity(0.25)
                            : AppColors.warmAmber.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.priority == 3 ? 'High Priority' : (task.priority == 2 ? 'Medium' : 'Low'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: task.priority == 3 ? AppColors.dustyRoseForeground : AppColors.warmAmberForeground,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Subtasks checklist if present
            if (task.subtasks.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Column(
                  children: task.subtasks.map((sub) {
                    return Row(
                      children: [
                        Icon(
                          sub.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          size: 14,
                          color: sub.isCompleted ? AppColors.sage : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sub.title,
                          style: TextStyle(
                            fontSize: 12,
                            decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPlanTaskModal(TaskItem task) {
    final now = DateTime.now();
    DateTime planStart = DateTime(now.year, now.month, now.day, 14, 0);
    DateTime planEnd = planStart.add(Duration(minutes: task.estimatedDurationMinutes ?? 60));

    // Conflict detection
    final conflicts = widget.appState.checkEventConflicts(planStart, planEnd);

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
            Text('Plan Task in Calendar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(
              'Proposed Block: ${planStart.hour}:${planStart.minute.toString().padLeft(2, '0')} - ${planEnd.hour}:${planEnd.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (conflicts.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Time block conflicts with "${conflicts.first.title}". You can confirm to proceed or reschedule.',
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
                  const SnackBar(content: Text('Task added to calendar timeline!')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppColors.warmAmber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Confirm Calendar Block', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddSheet(appState: widget.appState, initialTabIndex: 1),
    );
  }
}
