import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game_colors.dart';
import 'game_fonts.dart';

/// Minimal ThemeData. We use Material only as an outer scaffold — game
/// surfaces are rendered directly with CartoonPanel / CartoonButton, not
/// Material widgets. This theme mostly sets the text theme for incidental
/// text (e.g. error screens, system dialogs).
class GameTheme {
  GameTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GameColors.happyOrange,
        brightness: Brightness.light,
        primary: GameColors.happyOrange,
        surface: GameColors.cream,
      ),
      scaffoldBackgroundColor: GameColors.cream,
      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: GameColors.outline,
        displayColor: GameColors.outline,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
    return base.copyWith(
      primaryTextTheme: GoogleFonts.fredokaTextTheme(base.primaryTextTheme),
      textTheme: base.textTheme.copyWith(
        titleLarge: GameFonts.title(),
        titleMedium: GameFonts.subtitle(),
        bodyLarge: GameFonts.body(),
        bodyMedium: GameFonts.body(),
        labelLarge: GameFonts.buttonLabel(color: GameColors.white),
      ),
    );
  }
}
