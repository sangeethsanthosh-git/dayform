import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Editorial Display for Dates and Section Titles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayDateNumber = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  // Interface Text Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.25,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.35,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  // TextTheme builders
  static TextTheme buildTextTheme(bool isDark) {
    final Color primary = isDark ? AppColors.primaryLightText : AppColors.primaryDarkText;
    final Color secondary = isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText;

    return TextTheme(
      displayLarge: displayLarge.copyWith(color: primary),
      displayMedium: displayMedium.copyWith(color: primary),
      headlineMedium: displayMedium.copyWith(color: primary),
      titleLarge: titleLarge.copyWith(color: primary),
      titleMedium: titleMedium.copyWith(color: primary),
      bodyLarge: bodyLarge.copyWith(color: primary),
      bodyMedium: bodyMedium.copyWith(color: secondary),
      bodySmall: bodySmall.copyWith(color: secondary),
      labelLarge: labelLarge.copyWith(color: primary),
      labelSmall: labelSmall.copyWith(color: secondary),
    );
  }
}
