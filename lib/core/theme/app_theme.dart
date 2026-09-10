import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = AppTypography.buildTextTheme(false);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDarkText,
        onPrimary: AppColors.lightCardSurface,
        surface: AppColors.lightCardSurface,
        onSurface: AppColors.primaryDarkText,
        outline: AppColors.lightBorder,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.lightCardSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primaryDarkText),
        titleTextStyle: TextStyle(
          color: AppColors.primaryDarkText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        indicatorColor: AppColors.warmAmber.withOpacity(0.35),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDarkText,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryDarkText,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 0.7,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceMuted,
        hintStyle: const TextStyle(
          color: AppColors.secondaryDarkText,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.secondaryDarkText,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: const BorderSide(color: AppColors.primaryDarkText, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCardSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: AppColors.primaryDarkText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.secondaryDarkText,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.lightCardSurface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.lightCardSurface,
        headerForegroundColor: AppColors.primaryDarkText,
        headerHeadlineStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDarkText,
        ),
        headerHelpStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryDarkText,
          letterSpacing: 0.5,
        ),
        weekdayStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryDarkText,
        ),
        dayStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) return AppColors.secondaryDarkText.withOpacity(0.35);
          return AppColors.primaryDarkText;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.warmAmber;
          return null;
        }),
        todayForegroundColor: WidgetStateProperty.all(AppColors.warmAmberForeground),
        todayBorder: const BorderSide(color: AppColors.warmAmber, width: 1.5),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.primaryDarkText;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.warmAmber;
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.lightCardSurface,
        hourMinuteColor: AppColors.lightSurfaceMuted,
        hourMinuteTextColor: AppColors.primaryDarkText,
        dayPeriodColor: AppColors.warmAmber.withOpacity(0.35),
        dayPeriodTextColor: AppColors.primaryDarkText,
        dialHandColor: AppColors.warmAmber,
        dialBackgroundColor: AppColors.lightSurfaceMuted,
        dialTextColor: AppColors.primaryDarkText,
        entryModeIconColor: AppColors.primaryDarkText,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.lightBorder, width: 1),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = AppTypography.buildTextTheme(true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLightText,
        onPrimary: AppColors.darkBackground,
        surface: AppColors.darkCardSurface,
        onSurface: AppColors.primaryLightText,
        outline: AppColors.darkBorder,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.darkCardSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primaryLightText),
        titleTextStyle: TextStyle(
          color: AppColors.primaryLightText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        indicatorColor: AppColors.darkSurfaceMuted,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLightText,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryLightText,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 0.7,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceMuted,
        hintStyle: const TextStyle(
          color: AppColors.secondaryLightText,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.secondaryLightText,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: const BorderSide(color: AppColors.warmAmber, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCardSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: AppColors.primaryLightText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.secondaryLightText,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.darkCardSurface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.darkCardSurface,
        headerForegroundColor: AppColors.primaryLightText,
        headerHeadlineStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryLightText,
        ),
        headerHelpStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryLightText,
          letterSpacing: 0.5,
        ),
        weekdayStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryLightText,
        ),
        dayStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.pillBlack;
          if (states.contains(WidgetState.disabled)) return AppColors.secondaryLightText.withOpacity(0.35);
          return AppColors.primaryLightText;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.warmAmber;
          return null;
        }),
        todayForegroundColor: WidgetStateProperty.all(AppColors.warmAmber),
        todayBorder: const BorderSide(color: AppColors.warmAmber, width: 1.5),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.pillBlack;
          return AppColors.primaryLightText;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.warmAmber;
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.darkCardSurface,
        hourMinuteColor: AppColors.darkSurfaceMuted,
        hourMinuteTextColor: AppColors.primaryLightText,
        dayPeriodColor: AppColors.warmAmber.withOpacity(0.35),
        dayPeriodTextColor: AppColors.primaryLightText,
        dialHandColor: AppColors.warmAmber,
        dialBackgroundColor: AppColors.darkSurfaceMuted,
        dialTextColor: AppColors.primaryLightText,
        entryModeIconColor: AppColors.primaryLightText,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
      ),
    );
  }
}
