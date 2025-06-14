import 'package:flutter/material.dart';

class PropertyDialog extends StatelessWidget {
  final dynamic property;
  final dynamic player;
  final VoidCallback onClose;
  final VoidCallback? onMortgage;
  final VoidCallback? onUnmortgage;
  const PropertyDialog({
    required this.property,
    required this.player,
    required this.onClose,
    this.onMortgage,
    this.onUnmortgage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = property.owner == player;
    final isMortgaged = property.isMortgaged == true;
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
              Text(property.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Price: \$${property.price}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text('Rent: \$${property.baseRent}', style: const TextStyle(fontSize: 18)),
              if (isOwner && !isMortgaged && onMortgage != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onMortgage,
                  child: const Text('Mortgage'),
                ),
              ],
              if (isOwner && isMortgaged && onUnmortgage != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onUnmortgage,
                  child: const Text('Unmortgage'),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onClose,
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
