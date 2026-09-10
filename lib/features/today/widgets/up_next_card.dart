import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/event_item.dart';
import 'editorial_meeting_card.dart';

class UpNextCard extends StatelessWidget {
  final EventItem? event;
  final VoidCallback onQuickAddEvent;
  final Function(EventItem) onEventTapped;

  const UpNextCard({
    super.key,
    required this.event,
    required this.onQuickAddEvent,
    required this.onEventTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (event == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sage,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'UP NEXT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Clear horizon',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No upcoming commitments for today. Enjoy your time or add something new.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onQuickAddEvent,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Schedule event'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return EditorialMeetingCard(
      event: event!,
      onTap: () => onEventTapped(event!),
      backgroundColor: isDark ? null : const Color(0xFFF3EEDC),
    );
  }
}
