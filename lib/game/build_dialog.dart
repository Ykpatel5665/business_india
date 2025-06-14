import 'package:flutter/material.dart';

class BuildDialog extends StatelessWidget {
  final String propertyName;
  final int currentHouses;
  final bool canBuildHouse;
  final bool canBuildHotel;
  final VoidCallback onBuildHouse;
  final VoidCallback onBuildHotel;
  final VoidCallback onClose;
  const BuildDialog({
    required this.propertyName,
    required this.currentHouses,
    required this.canBuildHouse,
    required this.canBuildHotel,
    required this.onBuildHouse,
    required this.onBuildHotel,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.black54,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Build on $propertyName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Current houses: $currentHouses', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              if (canBuildHouse)
                ElevatedButton(
                  onPressed: onBuildHouse,
                  child: const Text('Build House'),
                ),
              if (canBuildHotel)
                ElevatedButton(
                  onPressed: onBuildHotel,
                  child: const Text('Build Hotel'),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onClose,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
