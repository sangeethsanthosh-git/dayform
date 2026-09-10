import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class BirthdayCelebrationCard extends StatelessWidget {
  final String userName;
  final VoidCallback? onTap;

  const BirthdayCelebrationCard({
    super.key,
    required this.userName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = userName.trim().isNotEmpty ? userName : 'Friend';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF3D2516),
                    const Color(0xFF331B2B),
                  ]
                : [
                    const Color(0xFFFFF8EC),
                    const Color(0xFFFFF0F5),
                  ],
          ),
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
          border: Border.all(
            color: isDark ? const Color(0xFFD4A373).withOpacity(0.5) : const Color(0xFFE07A5F).withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFFE07A5F).withOpacity(0.12)
                  : const Color(0xFFE07A5F).withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Festive 3D Cake Icon Badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA07A), Color(0xFFE07A5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE07A5F).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🎂',
                  style: TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Greeting & Wishes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE07A5F),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🎉 SPECIAL DAY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Happy Birthday, $displayName! ✨',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wishing you a magnificent year filled with health, joy, and inspiring milestones!',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
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
