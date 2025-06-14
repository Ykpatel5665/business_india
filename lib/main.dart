import 'package:flutter/material.dart';
import 'game_logic/engine/game_factory.dart';
import 'game_logic/models/player.dart';
import 'game_logic/models/game_config.dart';
import '../game_logic/models/ai_player.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Monopoly City',
    home: const LandingScreen(),
  ));
}

class MonopolyFlameApp extends StatelessWidget {
  const MonopolyFlameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(),
    );
  }
}
