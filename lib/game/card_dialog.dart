import 'package:flutter/material.dart';

class CardDialog extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onAcknowledge;
  const CardDialog({required this.title, required this.description, required this.onAcknowledge, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.black54,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(description, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAcknowledge,
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
