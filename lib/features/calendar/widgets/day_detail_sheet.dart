import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/category_definitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/bill_item.dart';
import '../../../domain/models/birthday_item.dart';
import '../../../domain/models/event_item.dart';
import '../../../domain/models/task_item.dart';

class DayDetailSheet extends StatelessWidget {
  final DateTime date;
  final List<EventItem> events;
  final List<TaskItem> tasks;
  final List<BillItem> bills;
  final List<BirthdayItem> birthdays;
  final Function(EventItem) onEventTapped;
  final Function(TaskItem) onTaskTapped;
  final VoidCallback onAddEvent;

  const DayDetailSheet({
    super.key,
    required this.date,
    required this.events,
    required this.tasks,
    required this.bills,
    required this.birthdays,
    required this.onEventTapped,
    required this.onTaskTapped,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE').format(date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmAmberForeground,
                    ),
                  ),
                  Text(
                    DateFormat('d MMMM').format(date),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              IconButton(
                onPressed: onAddEvent,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
                color: AppColors.warmAmber,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              children: [
                // 1. Birthdays
                if (birthdays.isNotEmpty) ...[
                  const Text('Birthdays', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...birthdays.map((b) => _buildBirthdayTile(b, isDark)),
                  const SizedBox(height: 16),
                ],

                // 2. Bills due on date
                if (bills.isNotEmpty) ...[
                  const Text('Recurring Bills', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...bills.map((bill) => _buildBillTile(bill, isDark)),
                  const SizedBox(height: 16),
                ],

                // 3. Events
                const Text('Schedule & Events', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (events.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No events on this date.',
                      style: TextStyle(
                        color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                      ),
                    ),
                  )
                else
                  ...events.map((e) => _buildEventTile(e, isDark)),
                const SizedBox(height: 16),

                // 4. Tasks due
                if (tasks.isNotEmpty) ...[
                  const Text('Deadlines & Tasks Due', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...tasks.map((t) => _buildTaskTile(t, isDark)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayTile(BirthdayItem b, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warmAmber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warmAmber.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.cake_outlined, color: AppColors.warmAmber, size: 20),
          const SizedBox(width: 10),
          Text(
            "${b.personName}'s Birthday",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBillTile(BillItem bill, bool isDark) {
    final hasCustomImg = bill.customImagePath != null && File(bill.customImagePath!).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (hasCustomImg)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(File(bill.customImagePath!), fit: BoxFit.cover),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.warmAmber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.payment_rounded, size: 20, color: Colors.white),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    'Renews: ${bill.renewalDate}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${bill.currency} ${bill.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(EventItem event, bool isDark) {
    final cat = CategoryDefinitions.getById(event.category);
    final time = event.isAllDay
        ? 'All day'
        : "${DateFormat('h:mm a').format(event.startDateTime)} - ${DateFormat('h:mm a').format(event.endDateTime)}";

    return GestureDetector(
      onTap: () => onEventTapped(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cat.color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 36,
              decoration: BoxDecoration(
                color: cat.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(time, style: TextStyle(fontSize: 12, color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile(TaskItem task, bool isDark) {
    return GestureDetector(
      onTap: () => onTaskTapped(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: task.isCompleted ? AppColors.sage : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (task.priority > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.dustyRose.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Priority', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.dustyRoseForeground)),
              ),
          ],
        ),
      ),
    );
  }
}
