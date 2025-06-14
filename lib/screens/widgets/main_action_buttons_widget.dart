import 'package:flutter/material.dart';
import 'animated_game_button.dart';

/// MainActionButtonsWidget: Vertical stack of main game action buttons.
/// Uses AnimatedGameButton for a playful, game-like UI.
class MainActionButtonsWidget extends StatelessWidget {
  const MainActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 400.0;
    return Column(
      children: [
        AnimatedGameButton(
          label: 'Play',
          onPressed: () {},
          scale: scale,
          icon: Icons.play_arrow,
        ),
        const SizedBox(height: 16),
        AnimatedGameButton(
          label: 'How to Play',
          onPressed: () {},
          scale: scale,
          icon: Icons.help_outline,
          color: const Color(0xFF4A90E2),
        ),
        const SizedBox(height: 16),
        AnimatedGameButton(
          label: 'Settings',
          onPressed: () {},
          scale: scale,
          icon: Icons.settings,
          color: Colors.white,
          textColor: const Color(0xFF0ED2F7),
        ),
      ],
    );
  }
}
