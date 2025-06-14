import 'package:flutter/material.dart';

class AuctionDialog extends StatelessWidget {
  final String propertyName;
  final List<String> playerNames;
  final void Function(String winner, int bid) onAuctionComplete;
  final VoidCallback onCancel;
  const AuctionDialog({
    required this.propertyName,
    required this.playerNames,
    required this.onAuctionComplete,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int bid = 0;
    String winner = playerNames.first;
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
              Text('Auction: $propertyName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: winner,
                items: playerNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    winner = val;
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Bid Amount'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  bid = int.tryParse(val) ?? 0;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => onAuctionComplete(winner, bid),
                    child: const Text('Complete Auction'),
                  ),
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
