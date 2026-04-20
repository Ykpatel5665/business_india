import 'package:flutter/material.dart';

import 'game_colors.dart';

/// Shape tokens for the cartoon look.
///
/// RULES:
///   * All corners use at least 16px radius. Material's default 4–8px is banned.
///   * Borders are thick and solid, never faint hairlines.
///   * Shadows are OFFSET and HARD (blurRadius = 0). No soft Material blur.
///     Always offset down-right to feel "pressed from above".
class CartoonShape {
  CartoonShape._();

  // ── Corner radii ──
  static const double radiusSmall = 16.0;
  static const double radiusMedium = 24.0;
  static const double radiusLarge = 32.0;
  static const double radiusHuge = 48.0;

  // ── Border widths ──
  static const double borderThin = 2.5;
  static const double borderMedium = 4.0;
  static const double borderThick = 5.5;

  // ── Shadow offsets ──
  static const double shadowSmall = 3.0;
  static const double shadowMedium = 5.0;
  static const double shadowLarge = 7.0;

  /// Classic cartoon box: solid fill, thick border, hard offset shadow.
  static BoxDecoration cartoonBox({
    required Color fill,
    Color? border,
    Color? shadowColor,
    double radius = radiusMedium,
    double offset = shadowMedium,
    double borderWidth = borderMedium,
    Gradient? gradient,
  }) {
    final brd = border ?? GameColors.outline;
    return BoxDecoration(
      color: gradient == null ? fill : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: brd, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: shadowColor ?? GameColors.darken(fill, 0.30),
          offset: Offset(0, offset),
          blurRadius: 0,
        ),
      ],
    );
  }

  /// Cartoon box with an inset "highlight" gradient on the top third — gives
  /// the surface a chunky 3D feel even though it's a flat fill.
  static BoxDecoration cartoonGlossy({
    required Color fill,
    Color? border,
    Color? shadowColor,
    double radius = radiusMedium,
    double offset = shadowMedium,
    double borderWidth = borderMedium,
  }) {
    return cartoonBox(
      fill: fill,
      border: border,
      shadowColor: shadowColor,
      radius: radius,
      offset: offset,
      borderWidth: borderWidth,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          GameColors.lighten(fill, 0.12),
          fill,
          GameColors.darken(fill, 0.05),
        ],
        stops: const [0.0, 0.55, 1.0],
      ),
    );
  }

  /// Pill (fully-rounded) variant — used for chips, bid steps, toggles.
  static BoxDecoration pill({
    required Color fill,
    Color? border,
    Color? shadowColor,
    double offset = shadowSmall,
    double borderWidth = borderMedium,
  }) {
    final brd = border ?? GameColors.outline;
    return BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: brd, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: shadowColor ?? GameColors.darken(fill, 0.30),
          offset: Offset(0, offset),
          blurRadius: 0,
        ),
      ],
    );
  }
}

/// Spacing tokens (chunky — a cartoon UI should breathe).
class CartoonSpacing {
  CartoonSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}
