import 'package:flutter/material.dart';
import 'network_manager.dart';

class MultiplayerButtonOverlay extends StatelessWidget {
  final VoidCallback onOpen;
  const MultiplayerButtonOverlay({Key? key, required this.onOpen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 90,
      right: 24,
      child: FloatingActionButton(
        heroTag: 'multiplayer',
        onPressed: onOpen,
        child: const Icon(Icons.people),
        tooltip: 'Online Multiplayer',
      ),
    );
  }
}
