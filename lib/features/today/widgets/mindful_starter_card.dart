import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class MindfulStarterCard extends StatelessWidget {
  final VoidCallback onTap;

  const MindfulStarterCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2E271D)
              : const Color(0xFFF9F3E5),
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
          border: Border.all(
            color: AppColors.warmAmber.withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.warmAmber.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Morning warm sun / pencil badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmAmber.withOpacity(0.25),
              ),
              child: const Icon(
                Icons.wb_sunny_rounded,
                color: AppColors.warmAmberForeground,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Let's start your day",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warmAmber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'DAILY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Set your top priorities and mindful intentions.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow button
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkCardSurface : Colors.white,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
