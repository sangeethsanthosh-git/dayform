import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/category_definitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/bill_item.dart';
import '../../../domain/models/birthday_item.dart';
import '../../../domain/models/event_item.dart';
import '../../../domain/models/task_item.dart';

class MonthView extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final List<EventItem> events;
  final List<TaskItem> tasks;
  final List<BillItem> bills;
  final List<BirthdayItem> birthdays;
  final int firstDayOfWeek; // 1=Mon, 7=Sun
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onDateLongPressed;

  const MonthView({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.events,
    required this.tasks,
    required this.bills,
    required this.birthdays,
    this.firstDayOfWeek = 1,
    required this.onDateSelected,
    required this.onDateLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday; // 1..7 (Mon..Sun)

    final offset = (firstWeekday - firstDayOfWeek + 7) % 7;

    // Weekday labels
    final weekdayLabels = _getWeekdayLabels(firstDayOfWeek);

    return Column(
      children: [
        // Weekday header (M T W T F S S)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels.map((label) {
              return Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                ),
              );
            }).toList(),
          ),
        ),

        // Month Days Grid (Faithful to Reference media_1788962478438.jpg)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offset + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            if (index < offset) {
              return const SizedBox.shrink();
            }

            final dayNumber = index - offset + 1;
            final cellDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);
            final cellDateStr = "${cellDate.year}-${cellDate.month.toString().padLeft(2, '0')}-${cellDate.day.toString().padLeft(2, '0')}";

            final isSelected = cellDate.year == selectedDate.year &&
                cellDate.month == selectedDate.month &&
                cellDate.day == selectedDate.day;

            final isToday = cellDate.year == DateTime.now().year &&
                cellDate.month == DateTime.now().month &&
                cellDate.day == DateTime.now().day;

            // Gather items on this date
            final dayEvents = events.where((e) => e.dateOnly == cellDateStr).toList();
            final dayBills = bills.where((b) => b.renewalDate == cellDateStr).toList();
            final dayBirthdays = birthdays.where((b) {
              final parts = b.birthDate.split('-');
              return (parts.length == 3 && parts[1] == cellDate.month.toString().padLeft(2, '0') && parts[2] == cellDate.day.toString().padLeft(2, '0')) ||
                     (parts.length == 2 && parts[0] == cellDate.month.toString().padLeft(2, '0') && parts[1] == cellDate.day.toString().padLeft(2, '0'));
            }).toList();

            return GestureDetector(
              onTap: () => onDateSelected(cellDate),
              onLongPress: () => onDateLongPressed(cellDate),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isToday
                      ? Border.all(color: AppColors.warmAmber, width: 1.5)
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Day Number
                    Positioned(
                      top: 6,
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: (isSelected || isToday) ? FontWeight.w800 : FontWeight.w500,
                          color: isToday
                              ? AppColors.warmAmberForeground
                              : (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText),
                        ),
                      ),
                    ),

                    // Stickers & Overlapping Logos (matching media_1788962478438.jpg)
                    Positioned(
                      bottom: 4,
                      child: _buildStickerCluster(dayBirthdays, dayBills, dayEvents),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStickerCluster(
    List<BirthdayItem> birthdays,
    List<BillItem> bills,
    List<EventItem> events,
  ) {
    // Collect badges
    final List<Widget> badges = [];

    // Birthday avatar badges
    for (final b in birthdays) {
      final hasCustomImg = b.customImagePath != null && File(b.customImagePath!).existsSync();
      badges.add(
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.warmAmber,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: hasCustomImg
              ? Image.file(File(b.customImagePath!), width: 22, height: 22, fit: BoxFit.cover)
              : Text(
                  b.personName.isNotEmpty ? b.personName[0].toUpperCase() : 'B',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      );
    }

    // Bill logo badges
    for (final bill in bills) {
      final hasCustomImg = bill.customImagePath != null && File(bill.customImagePath!).existsSync();
      badges.add(
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getBrandColor(bill.brandLogo),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: hasCustomImg
              ? Image.file(File(bill.customImagePath!), width: 20, height: 20, fit: BoxFit.cover)
              : Icon(_getBrandIconData(bill.brandLogo), size: 12, color: Colors.white),
        ),
      );
    }

    // Event category dot
    if (events.isNotEmpty && badges.isEmpty) {
      badges.add(
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CategoryDefinitions.getById(events.first.category).color,
          ),
        ),
      );
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    // Stack overlapping stickers as in reference media_1788962478438.jpg
    if (badges.length == 1) {
      return badges.first;
    }

    // Overlapping row
    return SizedBox(
      height: 22,
      width: 36,
      child: Stack(
        children: [
          Positioned(left: 0, child: badges[0]),
          Positioned(left: 12, child: badges[1]),
        ],
      ),
    );
  }

  Color _getBrandColor(String logo) {
    switch (logo.toLowerCase()) {
      case 'gpay':
      case 'googlepay':
        return const Color(0xFF4285F4);
      case 'phonepe':
        return const Color(0xFF5F259F);
      case 'paytm':
        return const Color(0xFF002970);
      case 'amazonpay':
        return const Color(0xFFFF9900);
      case 'paypal':
        return const Color(0xFF003087);
      case 'applepay':
        return Colors.black87;
      case 'bank':
        return const Color(0xFF2C5E8A);
      case 'cash':
        return const Color(0xFF2E7D32);
      case 'spotify':
        return const Color(0xFF1DB954);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'chatgpt':
        return Colors.black;
      case 'athlytic':
        return const Color(0xFF8A2BE2);
      case 'netflix':
        return const Color(0xFFE50914);
      default:
        return AppColors.warmAmber;
    }
  }

  IconData _getBrandIconData(String logo) {
    switch (logo.toLowerCase()) {
      case 'gpay':
      case 'googlepay':
        return Icons.account_balance_wallet_rounded;
      case 'phonepe':
        return Icons.currency_rupee_rounded;
      case 'paytm':
        return Icons.payment_rounded;
      case 'amazonpay':
        return Icons.shopping_bag_rounded;
      case 'paypal':
        return Icons.credit_card_rounded;
      case 'applepay':
        return Icons.apple_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'cash':
        return Icons.payments_rounded;
      case 'spotify':
        return Icons.music_note_rounded;
      case 'youtube':
        return Icons.play_arrow_rounded;
      case 'chatgpt':
        return Icons.auto_awesome;
      case 'athlytic':
        return Icons.fitness_center_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  List<String> _getWeekdayLabels(int firstDay) {
    const all = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final startIdx = firstDay - 1;
    return List.generate(7, (i) => all[(startIdx + i) % 7]);
  }
}
