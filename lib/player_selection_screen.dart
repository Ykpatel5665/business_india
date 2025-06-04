import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'app_theme.dart';

class PlayerSelectionScreen extends StatelessWidget {
  const PlayerSelectionScreen({super.key});

  void _onProceed(BuildContext context, int selectedPlayers) {
    if (selectedPlayers < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 players to start the game.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // Proceed to game or next screen
    Navigator.pushNamed(context, '/game');
  }

  @override
  Widget build(BuildContext context) {
    // For demonstration, assume 0 players selected. Replace with actual logic.
    int selectedPlayers = 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Player Selection')),
      body: ResponsiveLayout(
        mobile: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Player Selection (Mobile)', style: AppTextStyles.bodyLarge(1.0)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _onProceed(context, selectedPlayers),
              child: const Text('Start Game'),
            ),
          ],
        ),
        tablet: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Player Selection (Tablet)', style: AppTextStyles.titleLarge(1.1)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _onProceed(context, selectedPlayers),
              child: const Text('Start Game'),
            ),
          ],
        ),
        desktop: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Player Selection (Desktop)', style: AppTextStyles.titleLarge(1.3)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _onProceed(context, selectedPlayers),
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
