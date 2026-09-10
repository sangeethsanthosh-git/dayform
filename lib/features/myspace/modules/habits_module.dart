import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/habit_item.dart';

class HabitsModule extends StatelessWidget {
  final List<HabitItem> habits;
  final Set<String> todayCompletedHabits;
  final Map<String, int> habitStreaks;
  final Function(String) onToggleHabit;
  final Function(String) onDeleteHabit;
  final VoidCallback onAddHabit;

  const HabitsModule({
    super.key,
    required this.habits,
    required this.todayCompletedHabits,
    required this.habitStreaks,
    required this.onToggleHabit,
    required this.onDeleteHabit,
    required this.onAddHabit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Habit Consistency (${habits.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                onPressed: onAddHabit,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Habit'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (habits.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.repeat_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    const Text('No habits created yet.', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Build daily momentum with offline streak tracking.'),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final habit = habits[index];
                final isDone = todayCompletedHabits.contains(habit.id);
                final streak = habitStreaks[habit.id] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
                    borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      // Check-in button
                      GestureDetector(
                        onTap: () => onToggleHabit(habit.id),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.sage : (isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted),
                            shape: BoxShape.circle,
                            border: Border.all(color: isDone ? AppColors.sage : Colors.grey.withOpacity(0.4), width: 1.5),
                          ),
                          child: Icon(
                            isDone ? Icons.check_rounded : habit.icon,
                            color: isDone ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title & schedule
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              streak > 0 ? '$streak-day streak' : 'Ready for today',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: streak > 0 ? AppColors.sageForeground : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Schedule weekdays indicator (e.g. M T W T F S S)
                      Row(
                        children: [1, 2, 3, 4, 5, 6, 7].map((day) {
                          final isScheduled = habit.isScheduledForDay(day);
                          const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isScheduled ? AppColors.warmAmber.withOpacity(0.2) : Colors.transparent,
                            ),
                            child: Text(
                              labels[day - 1],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isScheduled ? FontWeight.bold : FontWeight.normal,
                                color: isScheduled ? AppColors.warmAmberForeground : Colors.grey,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 8),

                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                        onPressed: () => onDeleteHabit(habit.id),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
