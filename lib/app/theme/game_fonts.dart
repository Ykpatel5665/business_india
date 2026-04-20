import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game_colors.dart';

/// Typography for Business India — rounded, chunky, cartoon.
///
/// Fredoka: display / headlines / numbers / buttons (rounded, playful).
/// Nunito: body text (friendly, legible).
///
/// DO NOT use Inter, Roboto, Roboto Mono, Playfair, Cinzel — those are for
/// finance / luxury apps. This is a game.
class GameFonts {
  GameFonts._();

  static TextStyle fredoka({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color color = GameColors.outline,
    double? height,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.fredoka(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
  }

  static TextStyle nunito({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = GameColors.outline,
    double? height,
    FontStyle style = FontStyle.normal,
  }) {
    return GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      fontStyle: style,
    );
  }

  // ── Display presets ──
  static TextStyle logo({
    double size = 64,
    Color fill = GameColors.happyYellow,
    Color outline = GameColors.happyRed,
  }) =>
      fredoka(
        size: size,
        weight: FontWeight.w900,
        color: fill,
        letterSpacing: 1.0,
        shadows: [
          // Dark bottom-right "sticker" shadow
          Shadow(
            color: GameColors.outline,
            offset: const Offset(4, 6),
            blurRadius: 0,
          ),
          // Thick outline simulated via multiple tight shadows
          for (final dx in const [-3.0, 0.0, 3.0])
            for (final dy in const [-3.0, 0.0, 3.0])
              if (dx != 0 || dy != 0)
                Shadow(
                  color: outline,
                  offset: Offset(dx, dy),
                  blurRadius: 0,
                ),
        ],
      );

  static TextStyle titleBig({Color color = GameColors.outline}) =>
      fredoka(size: 32, weight: FontWeight.w800, color: color);

  static TextStyle title({Color color = GameColors.outline}) =>
      fredoka(size: 24, weight: FontWeight.w700, color: color);

  static TextStyle subtitle({Color color = GameColors.inkSoft}) =>
      nunito(size: 16, weight: FontWeight.w600, color: color);

  static TextStyle body({Color color = GameColors.outline}) =>
      nunito(size: 14, weight: FontWeight.w500, color: color);

  static TextStyle bodyBold({Color color = GameColors.outline}) =>
      nunito(size: 14, weight: FontWeight.w700, color: color);

  static TextStyle buttonLabel({Color color = GameColors.white, double size = 20}) =>
      fredoka(
        size: size,
        weight: FontWeight.w800,
        color: color,
        letterSpacing: 0.5,
      );

  static TextStyle tileName({Color color = GameColors.outline}) =>
      fredoka(size: 10, weight: FontWeight.w700, color: color, height: 1.0);

  static TextStyle tilePrice({Color color = GameColors.outline}) =>
      fredoka(size: 9, weight: FontWeight.w600, color: color, height: 1.0);

  static TextStyle money({Color color = GameColors.outline, double size = 18}) =>
      fredoka(
        size: size,
        weight: FontWeight.w800,
        color: color,
        letterSpacing: 0.2,
      );

  static TextStyle numberHuge({
    Color color = GameColors.happyYellow,
    Color outline = GameColors.outline,
  }) =>
      fredoka(
        size: 56,
        weight: FontWeight.w900,
        color: color,
        shadows: [
          Shadow(color: outline, offset: const Offset(3, 4), blurRadius: 0),
          for (final dx in const [-2.0, 0.0, 2.0])
            for (final dy in const [-2.0, 0.0, 2.0])
              if (dx != 0 || dy != 0)
                Shadow(
                  color: outline,
                  offset: Offset(dx, dy),
                  blurRadius: 0,
                ),
        ],
      );
}
