import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'app_theme.dart';

class GameBoardScreen extends StatelessWidget {
  final String? mode;
  final int? playerCount;
  const GameBoardScreen({Key? key, this.mode, this.playerCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Board')),
      body: ResponsiveLayout(
        mobile: Center(child: Text('Game Board (Mobile)\nMode: ${mode ?? "-"} | Players: $playerCount', style: AppTextStyles.bodyLarge(1.0))),
        tablet: Center(child: Text('Game Board (Tablet)\nMode: ${mode ?? "-"} | Players: $playerCount', style: AppTextStyles.titleLarge(1.1))),
        desktop: Center(child: Text('Game Board (Desktop)\nMode: ${mode ?? "-"} | Players: $playerCount', style: AppTextStyles.titleLarge(1.3))),
      ),
    );
  }
}
