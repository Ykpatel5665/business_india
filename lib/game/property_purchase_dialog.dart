import 'package:flutter/material.dart';

class PropertyPurchaseDialog extends StatelessWidget {
  final dynamic property;
  final dynamic player;
  final VoidCallback onBuy;
  final VoidCallback onAuction;
  final VoidCallback onClose;
  const PropertyPurchaseDialog({
    required this.property,
    required this.player,
    required this.onBuy,
    required this.onAuction,
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
              Text(property.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Price: \$${property.price}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text('Rent: \$${property.baseRent}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onBuy,
                    child: const Text('Buy'),
                  ),
                  OutlinedButton(
                    onPressed: onAuction,
                    child: const Text('Auction'),
                  ),
                ],
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
