import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TopDualPillBar extends StatelessWidget {
  final int selectedIndex; // 0 = Today, 1 = Calendar
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;
  final VoidCallback? onSearchPressed;

  const TopDualPillBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onAddPressed,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeBg = isDark ? Colors.white : AppColors.pillBlack;
    final activeFg = isDark ? AppColors.pillBlack : Colors.white;
    final inactiveBg = isDark ? AppColors.darkSurfaceMuted : AppColors.pillLight;
    final inactiveFg = isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText;

    return Row(
      children: [
        // Dual Pill Container
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardSurface : const Color(0xFFEFEFEA),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPill(
                title: 'Today',
                isSelected: selectedIndex == 0,
                activeBg: activeBg,
                activeFg: activeFg,
                inactiveBg: inactiveBg,
                inactiveFg: inactiveFg,
                onTap: () => onTabSelected(0),
              ),
              const SizedBox(width: 4),
              _buildPill(
                title: 'Calendar',
                isSelected: selectedIndex == 1,
                activeBg: activeBg,
                activeFg: activeFg,
                inactiveBg: inactiveBg,
                inactiveFg: inactiveFg,
                onTap: () => onTabSelected(1),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Search Button (if provided)
        if (onSearchPressed != null) ...[
          IconButton(
            onPressed: onSearchPressed,
            icon: const Icon(Icons.search_rounded, size: 22),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              shape: const CircleBorder(),
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Circular (+) Quick Add Button (from Image 1)
        GestureDetector(
          onTap: onAddPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white : AppColors.pillBlack,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              size: 24,
              color: isDark ? AppColors.pillBlack : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPill({
    required String title,
    required bool isSelected,
    required Color activeBg,
    required Color activeFg,
    required Color inactiveBg,
    required Color inactiveFg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? activeFg : inactiveFg,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
