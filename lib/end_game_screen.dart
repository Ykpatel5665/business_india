import 'package:flutter/material.dart';
import 'responsive_layout.dart';

class EndGameScreen extends StatelessWidget {
  const EndGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Over')),
      body: ResponsiveLayout(
        mobile: Center(child: Text('End Game (Mobile)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        tablet: Center(child: Text('End Game (Tablet)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        desktop: Center(child: Text('End Game (Desktop)', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
