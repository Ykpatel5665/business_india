import 'package:flutter/material.dart';
import '../game_logic/models/property.dart';

class PropertyInfoDialog extends StatelessWidget {
  final Property property;
  static const String currency = '₹';
  const PropertyInfoDialog({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Expanded(
            child: Column(
                children: [
                    Text(
                        property.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    if (property.owner != null)
                        Text(
                            'Owned by ${property.owner!.name}',
                            style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                        ),
                ]
            ),
          ),
        ],
      ),
      content: Container(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            _monoInfoRow('Purchase Price', '${currency}${property.price.toInt()}', highlight: true),
            _monoInfoRow('Mortgage Value', '${currency}${property.mortgageValue.toInt()}'),
            _monoInfoRow('Construction Cost', '${currency}${property.houseCost}'),
            const Divider(height: 18, thickness: 1.1),
            _monoInfoRow('Rent', '${currency}${property.baseRent.toInt()}'),
            _monoRentRow(1, '${currency}${property.getRent(1).toInt()}'),
            _monoRentRow(2, '${currency}${property.getRent(2).toInt()}'),
            _monoRentRow(3, '${currency}${property.getRent(3).toInt()}'),
            _monoRentRow(4, '${currency}${property.getRent(4).toInt()}'),
            _monoRentRow(5, '${currency}${property.getRent(5).toInt()}')
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Helper for info row with icon
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey[700]),
          const SizedBox(width: 7),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  int _monopolyRent(Property property) {
    // Example: double base rent for full set
    return (property.baseRent * 2).toInt();
  }

  Widget _monoInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                fontSize: 15.5,
                color: highlight ? Colors.blue[900] : Colors.black87,
              )),
          Text(value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                fontSize: 15.5,
                color: highlight ? Colors.blue[900] : Colors.black87,
              )),
        ],
      ),
    );
  }

  Widget _monoRentRow(int count, String value) {
    Widget iconWidget;
    if (count == 5) {
      iconWidget = const Icon(Icons.hotel, color: Colors.red, size: 20);
    } else {
      iconWidget = Row(
        children: [
          for (int i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Icon(Icons.house, color: Colors.green[700], size: 18),
            )
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const SizedBox(width: 2),
            iconWidget,
            const SizedBox(width: 8)
          ]),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}
