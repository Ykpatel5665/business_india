import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'widgets/responsive_centered_text.dart';

class EndGameScreen extends StatelessWidget {
  const EndGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Over')),
      body: const ResponsiveCenteredText(
        mobileText: 'End Game (Mobile)',
        tabletText: 'End Game (Tablet)',
        desktopText: 'End Game (Desktop)',
        styleBuilder: AppTextStyles.bodyLarge,
      ),
    );
  }
}
