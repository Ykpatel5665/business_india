import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'widgets/responsive_centered_text.dart';

class GameBoardScreen extends StatelessWidget {
  final String? mode;
  final int? playerCount;
  const GameBoardScreen({Key? key, this.mode, this.playerCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Board')),
      body: ResponsiveCenteredText(
        mobileText: 'Game Board (Mobile)\nMode: ${mode ?? "-"} | Players: $playerCount',
        tabletText: 'Game Board (Tablet)\nMode: ${mode ?? "-"} | Players: $playerCount',
        desktopText: 'Game Board (Desktop)\nMode: ${mode ?? "-"} | Players: $playerCount',
        styleBuilder: (scale) => scale > 1.0 ? AppTextStyles.titleLarge(scale) : AppTextStyles.bodyLarge(scale),
      ),
    );
  }
}
