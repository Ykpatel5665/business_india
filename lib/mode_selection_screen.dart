import 'package:flutter/material.dart';
import 'responsive_layout.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Game Mode')),
      body: ResponsiveLayout(
        mobile: Center(child: Text('Mode Selection (Mobile)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        tablet: Center(child: Text('Mode Selection (Tablet)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        desktop: Center(child: Text('Mode Selection (Desktop)', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
