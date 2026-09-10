import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/bill_item.dart';
import '../../../domain/models/event_item.dart';

class MonthTimelineView extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final List<EventItem> events;
  final List<BillItem> bills;
  final Function(DateTime) onDateSelected;
  final Function(EventItem) onEventTapped;
  final Function(BillItem) onBillTapped;
  final Function(String id, double amount, String currency) onMarkBillPaid;

  const MonthTimelineView({
    super.key,
    required this.visibleMonth,
    required this.selectedDate,
    required this.events,
    required this.bills,
    required this.onDateSelected,
    required this.onEventTapped,
    required this.onBillTapped,
    required this.onMarkBillPaid,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Floating Calendar Grid Card (Image 3)
          _buildFloatingCalendarCard(context, isDark),
          const SizedBox(height: 24),

          // 2. Timeline Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subscriptions & Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${bills.length} active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Connected Vertical Node Timeline (Image 3)
          if (bills.isEmpty && events.isEmpty)
            _buildEmptyTimelineState(isDark)
          else
            _buildConnectedTimeline(context, isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFloatingCalendarCard(BuildContext context, bool isDark) {
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final firstDayWeekday = DateTime(visibleMonth.year, visibleMonth.month, 1).weekday; // 1=Mon, 7=Sun
    final leadingBlanks = (firstDayWeekday - 1) % 7;

    final weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekday Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels.map((lbl) {
              return SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    lbl,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - leadingBlanks + 1;
              final dayDate = DateTime(visibleMonth.year, visibleMonth.month, dayNumber);
              final dayDateStr =
                  "${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}";

              final isSelected = selectedDate.year == dayDate.year &&
                  selectedDate.month == dayDate.month &&
                  selectedDate.day == dayDate.day;

              final hasEvents = events.any((e) => e.dateOnly == dayDateStr);
              final hasBills = bills.any((b) => b.renewalDate == dayDateStr);

              return GestureDetector(
                onTap: () => onDateSelected(dayDate),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.warmAmber
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText),
                        ),
                      ),
                      if (hasEvents || hasBills) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasEvents)
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.white : AppColors.teal,
                                ),
                              ),
                            if (hasBills)
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.white : AppColors.dustyRose,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedTimeline(BuildContext context, bool isDark) {
    // Sort bills by renewal date
    final sortedBills = List<BillItem>.from(bills)
      ..sort((a, b) => a.renewalDate.compareTo(b.renewalDate));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedBills.length,
      itemBuilder: (context, index) {
        final bill = sortedBills[index];
        final isLast = index == sortedBills.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Connected Node Column (Line + Circle Node)
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    // Top vertical line
                    Container(
                      width: 2,
                      height: 18,
                      color: index == 0
                          ? Colors.transparent
                          : (isDark ? AppColors.darkBorder : const Color(0xFFDDD8CD)),
                    ),
                    // Timeline Node Circle
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getBrandAccentColor(bill.brandLogo),
                        border: Border.all(
                          color: isDark ? AppColors.darkCardSurface : Colors.white,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getBrandAccentColor(bill.brandLogo).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    // Bottom vertical line connecting next node
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isLast
                            ? Colors.transparent
                            : (isDark ? AppColors.darkBorder : const Color(0xFFDDD8CD)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Subscription/Reminder Card (Image 3)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildSubscriptionCard(context, bill, isDark),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, BillItem bill, bool isDark) {
    return GestureDetector(
      onTap: () => onBillTapped(bill),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Brand Logo / Custom Image (Image 3)
            _buildBrandAvatar(bill, isDark),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Renews: ${bill.renewalDate}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                    ),
                  ),
                ],
              ),
            ),

            // Amount Column (Right aligned bold amount in Image 3)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${bill.currency} ${bill.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => onMarkBillPaid(bill.id, bill.amount, bill.currency),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warmAmber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pay',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warmAmberForeground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandAvatar(BillItem bill, bool isDark) {
    if (bill.customImagePath != null && File(bill.customImagePath!).existsSync()) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: FileImage(File(bill.customImagePath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final brandLower = (bill.brandLogo.isNotEmpty ? bill.brandLogo : bill.name).toLowerCase();
    Color badgeColor = const Color(0xFFE5BD78);
    Widget iconWidget = const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20);

    if (brandLower.contains('netflix')) {
      badgeColor = const Color(0xFFE50914);
      iconWidget = const Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20));
    } else if (brandLower.contains('spotify')) {
      badgeColor = const Color(0xFF1DB954);
      iconWidget = const Icon(Icons.music_note_rounded, color: Colors.white, size: 20);
    } else if (brandLower.contains('claude')) {
      badgeColor = const Color(0xFFD97706);
      iconWidget = const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20);
    } else if (brandLower.contains('figma')) {
      badgeColor = const Color(0xFFA259FF);
      iconWidget = const Icon(Icons.design_services_rounded, color: Colors.white, size: 20);
    } else if (brandLower.contains('google') || brandLower.contains('gpay')) {
      badgeColor = const Color(0xFF4285F4);
      iconWidget = const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18));
    } else if (brandLower.contains('phonepe')) {
      badgeColor = const Color(0xFF5F259F);
      iconWidget = const Text('P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18));
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: iconWidget,
    );
  }

  Color _getBrandAccentColor(String? preset) {
    final p = (preset ?? '').toLowerCase();
    if (p.contains('netflix')) return const Color(0xFFE50914);
    if (p.contains('spotify')) return const Color(0xFF1DB954);
    if (p.contains('claude')) return const Color(0xFFD97706);
    if (p.contains('figma')) return const Color(0xFFA259FF);
    return AppColors.warmAmber;
  }

  Widget _buildEmptyTimelineState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline_rounded,
            size: 36,
            color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
          ),
          const SizedBox(height: 10),
          Text(
            'No recurring subscriptions yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add Netflix, Spotify, bills, or reminders using the (+) button.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
            ),
          ),
        ],
      ),
    );
  }
}
