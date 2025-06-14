import 'package:flutter/material.dart';

class TradeDialog extends StatefulWidget {
  final List<String> playerNames;
  final List<String> myProperties;
  final List<String> otherProperties;
  final void Function(String targetPlayer, List<String> offerProps, int offerCash, List<String> requestProps, int requestCash) onSendTrade;
  final VoidCallback onCancel;
  const TradeDialog({
    required this.playerNames,
    required this.myProperties,
    required this.otherProperties,
    required this.onSendTrade,
    required this.onCancel,
    super.key,
  });

  @override
  State<TradeDialog> createState() => _TradeDialogState();
}

class _TradeDialogState extends State<TradeDialog> {
  String? targetPlayer;
  List<String> offerProps = [];
  int offerCash = 0;
  List<String> requestProps = [];
  int requestCash = 0;

  @override
  void initState() {
    super.initState();
    targetPlayer = widget.playerNames.isNotEmpty ? widget.playerNames.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.black54,
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Trade', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: targetPlayer,
                  items: widget.playerNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                  onChanged: (val) => setState(() => targetPlayer = val),
                ),
                const SizedBox(height: 12),
                const Text('Offer Properties:'),
                Wrap(
                  children: widget.myProperties.map((prop) => FilterChip(
                    label: Text(prop),
                    selected: offerProps.contains(prop),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        offerProps.add(prop);
                      } else {
                        offerProps.remove(prop);
                      }
                    }),
                  )).toList(),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Offer Cash'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => offerCash = int.tryParse(val) ?? 0,
                ),
                const SizedBox(height: 12),
                const Text('Request Properties:'),
                Wrap(
                  children: widget.otherProperties.map((prop) => FilterChip(
                    label: Text(prop),
                    selected: requestProps.contains(prop),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        requestProps.add(prop);
                      } else {
                        requestProps.remove(prop);
                      }
                    }),
                  )).toList(),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Request Cash'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => requestCash = int.tryParse(val) ?? 0,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: targetPlayer == null ? null : () {
                        widget.onSendTrade(
                          targetPlayer!,
                          offerProps,
                          offerCash,
                          requestProps,
                          requestCash,
                        );
                      },
                      child: const Text('Send Trade'),
                    ),
                    TextButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
