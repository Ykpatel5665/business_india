import 'package:flutter/material.dart';

/// Color palette for Business India's cartoon look.
///
/// These are deliberately SATURATED and WARM — not the muted professional
/// palette of a dashboard. Every UI surface should feel like a sticker, toy,
/// or candy. If a color here reads as "muted" or "corporate", change it.
class GameColors {
  GameColors._();

  // ── Surfaces ──
  static const tableWood = Color(0xFF8B5A2B);
  static const tableLight = Color(0xFFBF8A50);
  static const tableDark = Color(0xFF6B3E1A);
  static const parchment = Color(0xFFFFF4D6);
  static const cream = Color(0xFFFFF9E6);
  static const white = Color(0xFFFFFFFF);

  // ── Sky / menu gradients ──
  static const sunsetStart = Color(0xFFFF6B6B);
  static const sunsetMid = Color(0xFFFFB347);
  static const sunsetEnd = Color(0xFFFFD93D);

  // ── Happy accent palette (used for buttons, panels, highlights) ──
  static const happyRed = Color(0xFFE63946);
  static const happyBlue = Color(0xFF3A86FF);
  static const happyGreen = Color(0xFF06D6A0);
  static const happyYellow = Color(0xFFFFD60A);
  static const happyPurple = Color(0xFF9B5DE5);
  static const happyOrange = Color(0xFFFF8C42);
  static const happyPink = Color(0xFFFF5D8F);
  static const happyTeal = Color(0xFF00C2A8);

  // ── Premium (trophies, gold ribbons) ──
  static const gold = Color(0xFFFFD700);
  static const goldDark = Color(0xFFD4A017);
  static const silver = Color(0xFFC0C0C0);
  static const bronze = Color(0xFFCD7F32);

  // ── Ink / outlines (every cartoon element needs a dark outline) ──
  static const outline = Color(0xFF1A1A2E);
  static const inkSoft = Color(0xFF2B2B4A);

  // ── Property group colors (8 Monopoly groups) ──
  static const groupBrown = Color(0xFF8B4513);
  static const groupLightBlue = Color(0xFF87CEEB);
  static const groupPink = Color(0xFFE91E63);
  static const groupOrange = Color(0xFFFF6D00);
  static const groupRed = Color(0xFFD32F2F);
  static const groupYellow = Color(0xFFFDD835);
  static const groupGreen = Color(0xFF2E7D32);
  static const groupDarkBlue = Color(0xFF1565C0);
  // 8 = railroad, 9 = utility (not strictly groups, but used by engine)
  static const groupRailroad = Color(0xFF424242);
  static const groupUtility = Color(0xFF9E9E9E);

  /// Map engine `colorGroup` index → surface color.
  static Color forGroup(int group) {
    switch (group) {
      case 0:
        return groupBrown;
      case 1:
        return groupLightBlue;
      case 2:
        return groupPink;
      case 3:
        return groupOrange;
      case 4:
        return groupRed;
      case 5:
        return groupYellow;
      case 6:
        return groupGreen;
      case 7:
        return groupDarkBlue;
      case 8:
        return groupRailroad;
      case 9:
        return groupUtility;
      default:
        return inkSoft;
    }
  }

  // ── Player token palette (6 distinct, high-contrast) ──
  static const playerColors = <Color>[
    Color(0xFFE63946), // red
    Color(0xFF3A86FF), // blue
    Color(0xFF06D6A0), // green
    Color(0xFFFFD60A), // yellow
    Color(0xFF9B5DE5), // purple
    Color(0xFFFF8C42), // orange
  ];

  /// Returns a slightly-darker companion for a fill — used for hard offset
  /// cartoon shadows (not blurs). `amount` 0..1, higher = darker.
  static Color darken(Color c, [double amount = 0.25]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Returns a lighter companion — used for highlights on tops/edges.
  static Color lighten(Color c, [double amount = 0.15]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
