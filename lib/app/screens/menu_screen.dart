import 'package:flutter/material.dart';

import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';
import '../widgets/cartoon_button.dart';
import '../widgets/cartoon_dialog.dart';
import 'backdrop.dart';
import 'how_to_play_screen.dart';
import 'player_setup_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  static const routeName = '/menu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.sunsetStart,
      body: SunsetBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 380;
              final tight = constraints.maxHeight < 620;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: compact ? 16 : 28, vertical: 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 6),
                      _Logo(size: compact || tight ? 40 : 56),
                      SizedBox(height: tight ? 16 : 28),
                    CartoonButton(
                      label: 'PLAY',
                      icon: Icons.play_arrow_rounded,
                      color: GameColors.happyGreen,
                      size: CartoonButtonSize.huge,
                      pulse: true,
                      sparkle: true,
                      expanded: true,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PlayerSetupScreen()),
                      ),
                    ),
                      SizedBox(height: tight ? 8 : 14),
                      CartoonButton(
                      label: 'MULTIPLAYER',
                      icon: Icons.lock,
                      color: GameColors.happyBlue,
                      size: CartoonButtonSize.large,
                      expanded: true,
                      onPressed: () => CartoonDialog.alert(context,
                          title: 'Coming Soon',
                          message:
                              'Online multiplayer is on the roadmap. Stay tuned!',
                          headerColor: GameColors.happyBlue),
                    ),
                      SizedBox(height: tight ? 8 : 14),
                      CartoonButton(
                      label: 'HOW TO PLAY',
                      icon: Icons.menu_book_rounded,
                      color: GameColors.happyOrange,
                      size: CartoonButtonSize.large,
                      expanded: true,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const HowToPlayScreen()),
                      ),
                    ),
                      SizedBox(height: tight ? 8 : 14),
                      CartoonButton(
                      label: 'SETTINGS',
                      icon: Icons.settings_rounded,
                      color: GameColors.happyPurple,
                      size: CartoonButtonSize.medium,
                      expanded: true,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      ),
                    ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'v0.2 — cartoon rebuild',
                          style: GameFonts.nunito(
                            size: 11,
                            weight: FontWeight.w700,
                            color: GameColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Business',
          style: GameFonts.logo(
            size: size,
            fill: GameColors.happyYellow,
            outline: GameColors.happyRed,
          ),
        ),
        Text(
          'India',
          style: GameFonts.logo(
            size: size * 1.2,
            fill: GameColors.white,
            outline: GameColors.happyPurple,
          ),
        ),
      ],
    );
  }
}
