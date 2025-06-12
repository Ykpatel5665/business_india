import 'package:flutter/material.dart';
import '../game_logic/models/property.dart';
import '../game_logic/models/enums.dart';
import 'property_details_section.dart';

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
            if (property.canConstruct) ...[
              Center(
                child: Text(
                  'Rent is doubled on owning all unimproved sites in the group.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
            const SizedBox(height: 5),
            PropertyDetailsSection(property: property),
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
}
