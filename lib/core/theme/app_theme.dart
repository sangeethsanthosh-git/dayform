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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: const BorderSide(color: AppColors.primaryDarkText, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadiusSmall),
          borderSide: const BorderSide(color: AppColors.primaryLightText, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
