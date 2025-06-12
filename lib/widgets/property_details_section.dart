import 'package:flutter/material.dart';
import '../game_logic/models/property.dart';
import '../game_logic/models/enums.dart';
import 'construct_property_details.dart';
import 'mono_info_row.dart';
import 'mono_rent_row.dart';
import 'railroad_property_details.dart';
import 'utility_property_details.dart';

class PropertyDetailsSection extends StatelessWidget {
  final Property property;
  static const String currency = '₹';
  const PropertyDetailsSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoInfoRow(label: 'Purchase Price', value: '$currency${property.price.toInt()}', highlight: true),
        MonoInfoRow(label: 'Mortgage Value', value: '$currency${property.mortgageValue.toInt()}'),
        if (property.canConstruct) ...[
          ConstructPropertyDetails(property: property),
        ],
        if (property.type == PropertyType.railroad) ...[
          RailroadPropertyDetails(property: property),
        ],
        if (property.type == PropertyType.utility) ...[
          UtilityPropertyDetails(property: property),
        ],
      ],
    );
  }
}
