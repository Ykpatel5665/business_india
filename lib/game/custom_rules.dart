import 'package:flutter/material.dart';

class CustomRules {
  bool freeParkingCash;
  bool doubleOnGo;
  bool auctionOnAllUnpurchased;

  CustomRules({
    this.freeParkingCash = false,
    this.doubleOnGo = false,
    this.auctionOnAllUnpurchased = true,
  });
}

class CustomRulesDialog extends StatefulWidget {
  final CustomRules initialRules;
  final void Function(CustomRules) onApply;
  final VoidCallback onCancel;
  const CustomRulesDialog({Key? key, required this.initialRules, required this.onApply, required this.onCancel}) : super(key: key);

  @override
  State<CustomRulesDialog> createState() => _CustomRulesDialogState();
}

class _CustomRulesDialogState extends State<CustomRulesDialog> {
  late CustomRules rules;

  @override
  void initState() {
    super.initState();
    rules = CustomRules(
      freeParkingCash: widget.initialRules.freeParkingCash,
      doubleOnGo: widget.initialRules.doubleOnGo,
      auctionOnAllUnpurchased: widget.initialRules.auctionOnAllUnpurchased,
    );
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
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Custom Rules', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Free Parking collects cash'),
                value: rules.freeParkingCash,
                onChanged: (v) => setState(() => rules.freeParkingCash = v),
              ),
              SwitchListTile(
                title: const Text('Double salary on landing on GO'),
                value: rules.doubleOnGo,
                onChanged: (v) => setState(() => rules.doubleOnGo = v),
              ),
              SwitchListTile(
                title: const Text('Auction all unpurchased properties'),
                value: rules.auctionOnAllUnpurchased,
                onChanged: (v) => setState(() => rules.auctionOnAllUnpurchased = v),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: () => widget.onApply(rules), child: const Text('Apply')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
