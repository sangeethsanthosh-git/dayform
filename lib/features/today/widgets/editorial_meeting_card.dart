import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/category_definitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/event_item.dart';

class EditorialMeetingCard extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const EditorialMeetingCard({
    super.key,
    required this.event,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryItem = CategoryDefinitions.getById(event.category);
    final durationMinutes = event.endDateTime.difference(event.startDateTime).inMinutes;

    final cardBg = backgroundColor ??
        (isDark ? AppColors.darkCardSurface : categoryItem.color.withOpacity(0.35));

    final startTimeStr = DateFormat('h:mm a').format(event.startDateTime);
    final endTimeStr = DateFormat('h:mm a').format(event.endDateTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : categoryItem.color.withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category pill & Subtle Chevron Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(categoryItem.icon, size: 13, color: AppColors.primaryDarkText),
                      const SizedBox(width: 5),
                      Text(
                        categoryItem.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDarkText,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: isDark ? AppColors.secondaryLightText.withOpacity(0.6) : AppColors.secondaryDarkText.withOpacity(0.6),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Meeting Title
            Text(
              event.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                height: 1.2,
              ),
            ),

            if (event.location != null && event.location!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Clean Timeline Row: Time Range & Duration
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.25) : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.isAllDay ? 'All Day' : '$startTimeStr – $endTimeStr',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  if (!event.isAllDay && durationMinutes > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : AppColors.pillBlack,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$durationMinutes min',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.pillBlack : Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
