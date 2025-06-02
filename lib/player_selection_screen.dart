import 'package:flutter/material.dart';
import 'responsive_layout.dart';

class PlayerSelectionScreen extends StatelessWidget {
  const PlayerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Selection')),
      body: ResponsiveLayout(
        mobile: Center(child: Text('Player Selection (Mobile)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        tablet: Center(child: Text('Player Selection (Tablet)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        desktop: Center(child: Text('Player Selection (Desktop)', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
