import 'package:flutter/material.dart';
import '../../domain/models/user_settings.dart';

class AccentColorOption {
  final String id;
  final String name;
  final Color color;
  final Color foreground;
  final Color darkBg;

  const AccentColorOption({
    required this.id,
    required this.name,
    required this.color,
    required this.foreground,
    required this.darkBg,
  });
}

class AppColors {
  // --- Curated Universal Color Presets ---
  static const List<AccentColorOption> presetAccents = [
    AccentColorOption(
      id: 'gold',
      name: 'Classic Gold',
      color: Color(0xFFE5BD78),
      foreground: Color(0xFF5A3D0B),
      darkBg: Color(0xFF362B18),
    ),
    AccentColorOption(
      id: 'sapphire',
      name: 'Sapphire Blue',
      color: Color(0xFF3B82F6),
      foreground: Color(0xFF1E3A8A),
      darkBg: Color(0xFF172554),
    ),
    AccentColorOption(
      id: 'emerald',
      name: 'Emerald Green',
      color: Color(0xFF10B981),
      foreground: Color(0xFF064E3B),
      darkBg: Color(0xFF052E16),
    ),
    AccentColorOption(
      id: 'ruby',
      name: 'Ruby Red',
      color: Color(0xFFEF4444),
      foreground: Color(0xFF7F1D1D),
      darkBg: Color(0xFF450A0A),
    ),
    AccentColorOption(
      id: 'amethyst',
      name: 'Amethyst Purple',
      color: Color(0xFF8B5CF6),
      foreground: Color(0xFF4C1D95),
      darkBg: Color(0xFF2E1065),
    ),
    AccentColorOption(
      id: 'coral',
      name: 'Sunset Coral',
      color: Color(0xFFF97316),
      foreground: Color(0xFF7C2D12),
      darkBg: Color(0xFF431407),
    ),
    AccentColorOption(
      id: 'rose',
      name: 'Rose Pink',
      color: Color(0xFFEC4899),
      foreground: Color(0xFF831843),
      darkBg: Color(0xFF500724),
    ),
    AccentColorOption(
      id: 'teal',
      name: 'Ocean Teal',
      color: Color(0xFF14B8A6),
      foreground: Color(0xFF134E4A),
      darkBg: Color(0xFF042F2E),
    ),
    AccentColorOption(
      id: 'indigo',
      name: 'Midnight Indigo',
      color: Color(0xFF6366F1),
      foreground: Color(0xFF312E81),
      darkBg: Color(0xFF1E1B4B),
    ),
    AccentColorOption(
      id: 'slate',
      name: 'Graphite Slate',
      color: Color(0xFF64748B),
      foreground: Color(0xFF0F172A),
      darkBg: Color(0xFF1E293B),
    ),
  ];

  // --- Dynamic Active Accent State ---
  static Color _activeAccent = const Color(0xFFE5BD78);
  static Color _activeForeground = const Color(0xFF5A3D0B);
  static Color _activeDarkBg = const Color(0xFF362B18);

  // Dynamic getters replacing hardcoded gold warmAmber across entire codebase
  static Color get warmAmber => _activeAccent;
  static Color get warmAmberForeground => _activeForeground;
  static Color get warmAmberDarkBg => _activeDarkBg;

  // Clean alias getters
  static Color get accent => _activeAccent;
  static Color get accentForeground => _activeForeground;
  static Color get accentDarkBg => _activeDarkBg;

  // Set active accent color with automatic contrast calculation
  static void setAccentColor(Color color, [Color? foreground, Color? darkBg]) {
    _activeAccent = color;
    if (foreground != null) {
      _activeForeground = foreground;
    } else {
      _activeForeground = color.computeLuminance() > 0.45 ? const Color(0xFF202320) : Colors.white;
    }
    if (darkBg != null) {
      _activeDarkBg = darkBg;
    } else {
      _activeDarkBg = Color.alphaBlend(color.withOpacity(0.2), const Color(0xFF171A18));
    }
  }

  // Synchronize active accent with UserSettings
  static void applyAccentFromSettings(UserSettings settings) {
    if (settings.customAccentColorValue != null) {
      setAccentColor(Color(settings.customAccentColorValue!));
    } else if (settings.accentColorIndex >= 0 && settings.accentColorIndex < presetAccents.length) {
      final opt = presetAccents[settings.accentColorIndex];
      setAccentColor(opt.color, opt.foreground, opt.darkBg);
    } else {
      final opt = presetAccents[0];
      setAccentColor(opt.color, opt.foreground, opt.darkBg);
    }
  }

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
  static const Color slate = Color(0xFFCAD2C5);

  static const Color pillBlack = Color(0xFF1E211E);
  static const Color pillLight = Color(0xFFEBEAE5);

  // --- Accessible High-Contrast Text / Foreground for Pastels (Light Mode) ---
  static const Color lavenderForeground = Color(0xFF3F355A);
  static const Color dustyRoseForeground = Color(0xFF5B2B35);
  static const Color sageForeground = Color(0xFF34431D);
  static const Color tealForeground = Color(0xFF184742);

  // --- Dark Mode Category Tint Surfaces (Restrained & Deep) ---
  static const Color lavenderDarkBg = Color(0xFF2A2536);
  static const Color dustyRoseDarkBg = Color(0xFF382327);
  static const Color sageDarkBg = Color(0xFF272F20);
  static const Color tealDarkBg = Color(0xFF1F2E2C);

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
