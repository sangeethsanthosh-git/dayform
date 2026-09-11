import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../settings/settings_screen.dart';

class GreetingHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onSearchTapped;
  final VoidCallback? onSettingsTapped;

  const GreetingHeader({
    super.key,
    required this.userName,
    required this.onSearchTapped,
    this.onSettingsTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17) {
      greeting = 'Good evening';
    }

    return Row(
      children: [
        // User greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                ),
              ),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Global Search Action
        IconButton(
          onPressed: onSearchTapped,
          icon: const Icon(Icons.search_rounded, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Profile / Settings Action
        IconButton(
          onPressed: onSettingsTapped ?? () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          icon: const Icon(Icons.tune_rounded, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
