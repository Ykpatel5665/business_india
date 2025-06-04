import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'app_theme.dart';

class EndGameScreen extends StatelessWidget {
  const EndGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Over')),
      body: ResponsiveLayout(
        mobile: Center(child: Text('End Game (Mobile)', style: AppTextStyles.bodyLarge(1.0))),
        tablet: Center(child: Text('End Game (Tablet)', style: AppTextStyles.titleLarge(1.1))),
        desktop: Center(child: Text('End Game (Desktop)', style: AppTextStyles.titleLarge(1.3))),
      ),
    );
  }
}
