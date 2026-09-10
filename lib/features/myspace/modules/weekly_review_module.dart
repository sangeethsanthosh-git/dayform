import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/bill_item.dart';
import '../../../domain/models/event_item.dart';
import '../../../domain/models/habit_item.dart';
import '../../../domain/models/task_item.dart';

class WeeklyReviewModule extends StatelessWidget {
  final List<TaskItem> completedTasks;
  final List<TaskItem> pendingTasks;
  final List<EventItem> upcomingEvents;
  final List<HabitItem> habits;
  final List<BillItem> upcomingBills;
  final Function(String, DateTime) onRescheduleTask;

  const WeeklyReviewModule({
    super.key,
    required this.completedTasks,
    required this.pendingTasks,
    required this.upcomingEvents,
    required this.habits,
    required this.upcomingBills,
    required this.onRescheduleTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Summary Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Review & Horizon',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                ),
                const SizedBox(height: 4),
                Text(
                  'A factual summary of your momentum, commitments, and pending items.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetric('Completed', '${completedTasks.length}', AppColors.sage),
                    _buildMetric('Pending', '${pendingTasks.length}', AppColors.warmAmber),
                    _buildMetric('Commitments', '${upcomingEvents.length}', AppColors.teal),
                    _buildMetric('Bills', '${upcomingBills.length}', AppColors.dustyRose),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Unfinished Tasks Needing Attention / Rescheduling
          if (pendingTasks.isNotEmpty) ...[
            const Text('Unfinished Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...pendingTasks.take(5).map((t) => _buildRescheduleTile(context, t, isDark)),
            const SizedBox(height: 20),
          ],

          // 2. Upcoming Commitments
          if (upcomingEvents.isNotEmpty) ...[
            const Text('Upcoming Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...upcomingEvents.take(4).map((e) => _buildCommitmentTile(e, isDark)),
            const SizedBox(height: 20),
          ],

          // 3. Upcoming Renewals
          if (upcomingBills.isNotEmpty) ...[
            const Text('Upcoming Renewals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...upcomingBills.take(3).map((b) => _buildBillTile(b, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRescheduleTile(BuildContext context, TaskItem task, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle_outlined, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(task.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              final tomorrow = DateTime.now().add(const Duration(days: 1));
              onRescheduleTask(task.id, tomorrow);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rescheduled for tomorrow!')),
              );
            },
            child: Text('Move to Tomorrow', style: TextStyle(fontSize: 12, color: AppColors.warmAmberForeground)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitmentTile(EventItem event, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.event_note_rounded, size: 18, color: AppColors.teal),
              const SizedBox(width: 10),
              Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          Text(event.dateOnly, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBillTile(BillItem bill, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.payment_rounded, size: 18, color: AppColors.dustyRose),
              const SizedBox(width: 10),
              Text(bill.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          Text('${bill.currency} ${bill.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
