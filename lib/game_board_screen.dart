import 'package:flutter/material.dart';
import 'responsive_layout.dart';

class GameBoardScreen extends StatelessWidget {
  const GameBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Board')),
      body: ResponsiveLayout(
        mobile: Center(child: Text('Game Board (Mobile)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        tablet: Center(child: Text('Game Board (Tablet)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        desktop: Center(child: Text('Game Board (Desktop)', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
