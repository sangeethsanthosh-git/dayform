import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/task_item.dart';

class PriorityTasksSection extends StatelessWidget {
  final List<TaskItem> todayTasks;
  final List<TaskItem> overdueTasks;
  final Function(String, bool) onToggleTask;
  final Function(TaskItem) onTaskTapped;
  final VoidCallback onAddTask;

  const PriorityTasksSection({
    super.key,
    required this.todayTasks,
    required this.overdueTasks,
    required this.onToggleTask,
    required this.onTaskTapped,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Overdue Section (if any overdue tasks)
        if (overdueTasks.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.dustyRose.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dustyRose.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.dustyRoseForeground),
                const SizedBox(width: 8),
                Text(
                  '${overdueTasks.length} OVERDUE',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.dustyRoseForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: overdueTasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = overdueTasks[index];
              return _buildTaskRow(context, task, isDark, isOverdue: true);
            },
          ),
          const SizedBox(height: 16),
        ],

        // 2. Today's Priority Tasks Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tasks for today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                letterSpacing: -0.2,
              ),
            ),
            IconButton(
              onPressed: onAddTask,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
              color: AppColors.warmAmber,
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (todayTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: AppColors.sage, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All caught up',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                        ),
                      ),
                      Text(
                        'No pending tasks for today.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todayTasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = todayTasks[index];
              return _buildTaskRow(context, task, isDark, isOverdue: false);
            },
          ),
      ],
    );
  }

  Widget _buildTaskRow(BuildContext context, TaskItem task, bool isDark, {required bool isOverdue}) {
    return GestureDetector(
      onTap: () => onTaskTapped(task),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          border: Border.all(
            color: isOverdue
                ? AppColors.dustyRose.withOpacity(0.6)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: task.isCompleted,
                activeColor: AppColors.sage,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                onChanged: (val) {
                  if (val != null) onToggleTask(task.id, val);
                },
              ),
            ),
            const SizedBox(width: 8),

            // Title & Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted
                          ? (isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText)
                          : (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText),
                    ),
                  ),
                  if (task.dueTime != null || task.priority > 0) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (task.dueTime != null) ...[
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.dueTime!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (task.priority > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: task.priority == 3
                                  ? AppColors.dustyRose.withOpacity(0.25)
                                  : AppColors.warmAmber.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.priority == 3 ? 'High' : (task.priority == 2 ? 'Med' : 'Low'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: task.priority == 3
                                    ? AppColors.dustyRoseForeground
                                    : AppColors.warmAmberForeground,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
