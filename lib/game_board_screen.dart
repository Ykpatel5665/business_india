import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'app_theme.dart';

class GameBoardScreen extends StatelessWidget {
  const GameBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Board')),
      body: ResponsiveLayout(
        mobile: Center(child: Text('Game Board (Mobile)', style: AppTextStyles.bodyLarge(1.0))),
        tablet: Center(child: Text('Game Board (Tablet)', style: AppTextStyles.titleLarge(1.1))),
        desktop: Center(child: Text('Game Board (Desktop)', style: AppTextStyles.titleLarge(1.3))),
      ),
    );
  }
}
