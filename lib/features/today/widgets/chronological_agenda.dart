import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/event_item.dart';
import 'editorial_meeting_card.dart';

class ChronologicalAgenda extends StatelessWidget {
  final List<EventItem> events;
  final bool isSelectedDateToday;
  final Function(EventItem) onEventTapped;
  final VoidCallback onAddEvent;

  const ChronologicalAgenda({
    super.key,
    required this.events,
    required this.isSelectedDateToday,
    required this.onEventTapped,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 40,
              color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
            ),
            const SizedBox(height: 12),
            Text(
              'No events scheduled',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your schedule is clear for this date.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onAddEvent,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add event'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final sortedEvents = List<EventItem>.from(events)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    final pastelColors = [
      const Color(0xFFE9E4F0), // Soft Lavender
      const Color(0xFFF7E4E7), // Soft Rose
      const Color(0xFFE0EFEB), // Soft Teal
      const Color(0xFFF5EDD8), // Soft Amber
      const Color(0xFFE8EEDC), // Soft Sage
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live time bar indicator if today
        if (isSelectedDateToday) _buildLiveTimeBanner(context),
        const SizedBox(height: 8),

        // Event Cards Stack with alternating pastel colors (matching Image 1 Left)
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedEvents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final event = sortedEvents[index];
            final color = pastelColors[index % pastelColors.length];
            return EditorialMeetingCard(
              event: event,
              onTap: () => onEventTapped(event),
              backgroundColor: isDark ? null : color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLiveTimeBanner(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.warmAmber,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Now: $timeStr',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.warmAmberForeground,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.warmAmber.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
