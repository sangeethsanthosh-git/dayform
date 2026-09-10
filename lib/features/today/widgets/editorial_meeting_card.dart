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
  final bool showAvatars;

  const EditorialMeetingCard({
    super.key,
    required this.event,
    required this.onTap,
    this.backgroundColor,
    this.showAvatars = true,
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
            // Top Row: Category pill & Overlapping Avatars (Image 1 Left)
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

                if (showAvatars) _buildOverlappingAvatars(isDark),
              ],
            ),
            const SizedBox(height: 14),

            // Meeting Title (Image 1 Left)
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
            const SizedBox(height: 18),

            // Bottom Timeline Row: [Start Time] --- [Duration Pill] --- [End Time] (Image 1 Left)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Start Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                        ),
                      ),
                      Text(
                        startTimeStr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                        ),
                      ),
                    ],
                  ),

                  // Duration Pill (Dark pill in Image 1 Left)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : AppColors.pillBlack,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.isAllDay ? 'All Day' : '$durationMinutes Min',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.pillBlack : Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  // End Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'End',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                        ),
                      ),
                      Text(
                        endTimeStr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlappingAvatars(bool isDark) {
    final avatarColors = [
      const Color(0xFFD6A6AF), // Rose
      const Color(0xFFA7CFCA), // Teal
      const Color(0xFFE5BD78), // Amber
    ];
    final avatarInitials = ['JD', 'AK', 'WZ'];

    return SizedBox(
      width: 68,
      height: 28,
      child: Stack(
        children: [
          for (int i = 0; i < 3; i++)
            Positioned(
              left: i * 18.0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarColors[i],
                  border: Border.all(
                    color: isDark ? AppColors.darkCardSurface : Colors.white,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  avatarInitials[i],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
