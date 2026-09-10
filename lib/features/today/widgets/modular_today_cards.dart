import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/bill_item.dart';
import '../../../domain/models/habit_item.dart';

class ModularTodayCards extends StatelessWidget {
  final List<HabitItem> habits;
  final Set<String> todayCompletedHabits;
  final Function(String) onToggleHabit;
  final List<BillItem> bills;
  final Function(BillItem) onBillTapped;

  const ModularTodayCards({
    super.key,
    required this.habits,
    required this.todayCompletedHabits,
    required this.onToggleHabit,
    required this.bills,
    required this.onBillTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Habits Today Card
        if (habits.isNotEmpty) ...[
          _buildHabitsSection(context, isDark),
          const SizedBox(height: 24),
        ],

        // 2. Upcoming Payments Panel (Faithful to Reference media_1788962478434.jpg)
        if (bills.isNotEmpty) ...[
          _buildUpcomingPaymentsPanel(context, isDark),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  // --- HABITS SECTION ---
  Widget _buildHabitsSection(BuildContext context, bool isDark) {
    final todayWeekday = DateTime.now().weekday;
    final scheduledHabits = habits.where((h) => h.isScheduledForDay(todayWeekday)).toList();
    if (scheduledHabits.isEmpty) return const SizedBox.shrink();

    final completedCount = scheduledHabits.where((h) => todayCompletedHabits.contains(h.id)).length;
    final progress = completedCount / scheduledHabits.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Habits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '$completedCount of ${scheduledHabits.length} done',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sageForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),

          // Habit check-in chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: scheduledHabits.map((h) {
              final isDone = todayCompletedHabits.contains(h.id);
              return FilterChip(
                label: Text(h.title),
                avatar: Icon(
                  isDone ? Icons.check_circle_rounded : h.icon,
                  size: 16,
                  color: isDone ? Colors.white : AppColors.sageForeground,
                ),
                selected: isDone,
                selectedColor: AppColors.sage,
                backgroundColor: isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
                  color: isDone
                      ? Colors.white
                      : (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDone ? Colors.transparent : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                ),
                onSelected: (_) => onToggleHabit(h.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- UPCOMING PAYMENTS PANEL (Faithful to Reference media_1788962478434.jpg) ---
  Widget _buildUpcomingPaymentsPanel(BuildContext context, bool isDark) {
    // Show top 4 upcoming bills
    final displayBills = bills.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1A29) : AppColors.lightCardSurface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
        border: Border.all(
          color: isDark ? const Color(0x33C5BDD8) : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Upcoming payments"
          Text(
            'Upcoming payments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),

          // Stack of payment rows (matching media_1788962478434.jpg)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayBills.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final bill = displayBills[index];
              return _buildPaymentRow(context, bill, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(BuildContext context, BillItem bill, bool isDark) {
    final dueDate = DateTime.tryParse(bill.renewalDate);
    final now = DateTime.now();
    String relativeDue;

    if (dueDate != null) {
      final daysDiff = DateTime(dueDate.year, dueDate.month, dueDate.day)
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;

      if (daysDiff == 0) {
        relativeDue = 'Today';
      } else if (daysDiff == 1) {
        relativeDue = 'Tomorrow';
      } else if (daysDiff > 1 && daysDiff <= 7) {
        relativeDue = 'In $daysDiff days';
      } else {
        relativeDue = DateFormat('d MMM yyyy').format(dueDate);
      }
    } else {
      relativeDue = bill.renewalDate;
    }

    final currencySymbol = _getCurrencySymbol(bill.currency);

    return GestureDetector(
      onTap: () => onBillTapped(bill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF282338) : AppColors.lightSurfaceMuted,
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
          border: Border.all(
            color: isDark ? const Color(0x22FFFFFF) : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Branded Service Icon or Custom Image
            _buildBrandIcon(bill.brandLogo, bill.name, bill.customImagePath),
            const SizedBox(width: 14),

            // Service name and due date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dueDate != null && relativeDue != DateFormat('d MMM yyyy').format(dueDate)
                        ? '$relativeDue • ${DateFormat('d MMM yyyy').format(dueDate)}'
                        : relativeDue,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                    ),
                  ),
                ],
              ),
            ),

            // Right-aligned formatted currency amount (e.g. £19.99 or ₹1,199)
            Text(
              '$currencySymbol${bill.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandIcon(String logoType, String name, [String? customImagePath]) {
    if (customImagePath != null && File(customImagePath).existsSync()) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.file(File(customImagePath), fit: BoxFit.cover),
      );
    }

    Color bg;
    Widget iconWidget;

    switch (logoType.toLowerCase()) {
      case 'gpay':
      case 'googlepay':
        bg = const Color(0xFF4285F4);
        iconWidget = const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20);
        break;
      case 'phonepe':
        bg = const Color(0xFF5F259F);
        iconWidget = const Icon(Icons.currency_rupee_rounded, color: Colors.white, size: 20);
        break;
      case 'paytm':
        bg = const Color(0xFF002970);
        iconWidget = const Icon(Icons.payment_rounded, color: Colors.white, size: 20);
        break;
      case 'amazonpay':
        bg = const Color(0xFFFF9900);
        iconWidget = const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20);
        break;
      case 'paypal':
        bg = const Color(0xFF003087);
        iconWidget = const Icon(Icons.credit_card_rounded, color: Colors.white, size: 20);
        break;
      case 'applepay':
        bg = Colors.black87;
        iconWidget = const Icon(Icons.apple_rounded, color: Colors.white, size: 20);
        break;
      case 'bank':
        bg = const Color(0xFF2C5E8A);
        iconWidget = const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20);
        break;
      case 'cash':
        bg = const Color(0xFF2E7D32);
        iconWidget = const Icon(Icons.payments_rounded, color: Colors.white, size: 20);
        break;
      case 'spotify':
        bg = const Color(0xFF1DB954);
        iconWidget = const Icon(Icons.music_note_rounded, color: Colors.white, size: 20);
        break;
      case 'youtube':
        bg = const Color(0xFFFF0000);
        iconWidget = const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20);
        break;
      case 'chatgpt':
        bg = Colors.black;
        iconWidget = const Icon(Icons.auto_awesome, color: Colors.white, size: 18);
        break;
      case 'athlytic':
        bg = const Color(0xFF8A2BE2);
        iconWidget = const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 18);
        break;
      case 'netflix':
        bg = const Color(0xFFE50914);
        iconWidget = const Text(
          'N',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
        );
        break;
      default:
        bg = AppColors.warmAmber;
        iconWidget = Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'B',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
        );
    }

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: iconWidget,
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'GBP':
        return '£';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'INR':
      default:
        return '₹';
    }
  }
}
