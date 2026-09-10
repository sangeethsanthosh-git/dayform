import 'package:flutter/material.dart';

class AppColors {
  // --- Core Neutrals (from Brief) ---
  static const Color lightBackground = Color(0xFFF4F3EE);
  static const Color lightCardSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFEBE9E1);
  static const Color primaryDarkText = Color(0xFF202320);
  static const Color secondaryDarkText = Color(0xFF6B726C);
  static const Color lightBorder = Color(0x14202320); // subtle 8% border
  static const Color lightDivider = Color(0x1F202320);

  static const Color darkBackground = Color(0xFF171A18);
  static const Color darkCardSurface = Color(0xFF232824);
  static const Color darkSurfaceMuted = Color(0xFF2C322D);
  static const Color primaryLightText = Color(0xFFF2F4F1);
  static const Color secondaryLightText = Color(0xFF9CA59E);
  static const Color darkBorder = Color(0x24FFFFFF); // subtle 14% border
  static const Color darkDivider = Color(0x28FFFFFF);

  // --- Pastels (from Brief) ---
  static const Color lavender = Color(0xFFC5BDD8);
  static const Color dustyRose = Color(0xFFD6A6AF);
  static const Color sage = Color(0xFFC4D0AD);
  static const Color teal = Color(0xFFA7CFCA);
  static const Color warmAmber = Color(0xFFE5BD78);
  static const Color slate = Color(0xFFCAD2C5);

  static const Color pillBlack = Color(0xFF1E211E);
  static const Color pillLight = Color(0xFFEBEAE5);

  // --- Accessible High-Contrast Text / Foreground for Pastels (Light Mode) ---
  static const Color lavenderForeground = Color(0xFF3F355A);
  static const Color dustyRoseForeground = Color(0xFF5B2B35);
  static const Color sageForeground = Color(0xFF34431D);
  static const Color tealForeground = Color(0xFF184742);
  static const Color warmAmberForeground = Color(0xFF5A3D0B);

  // --- Dark Mode Category Tint Surfaces (Restrained & Deep) ---
  static const Color lavenderDarkBg = Color(0xFF2A2536);
  static const Color dustyRoseDarkBg = Color(0xFF382327);
  static const Color sageDarkBg = Color(0xFF272F20);
  static const Color tealDarkBg = Color(0xFF1F2E2C);
  static const Color warmAmberDarkBg = Color(0xFF362B18);

  // --- Semantic Highlights ---
  static const Color success = Color(0xFF528C59);
  static const Color error = Color(0xFFC84B4B);
  static const Color warning = Color(0xFFDC8B32);
  static const Color info = Color(0xFF4A89A9);

  // Helper to obtain contrasting text for a given pastel
  static Color getPastelForeground(Color pastel) {
    if (pastel.value == lavender.value) return lavenderForeground;
    if (pastel.value == dustyRose.value) return dustyRoseForeground;
    if (pastel.value == sage.value) return sageForeground;
    if (pastel.value == teal.value) return tealForeground;
    if (pastel.value == warmAmber.value) return warmAmberForeground;
    return primaryDarkText;
  }
}
