import 'package:flutter/material.dart';
import '../game_logic/models/property.dart';
import 'mono_info_row.dart';
import 'mono_rent_row.dart';

class ConstructPropertyDetails extends StatelessWidget {
  final Property property;
  static const String currency = '₹';
  const ConstructPropertyDetails({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoInfoRow(label: 'Construction Cost', value: '$currency${property.houseCost}'),
        const Divider(height: 18, thickness: 1.1),
        MonoInfoRow(label: 'Rent', value: '$currency${property.baseRent.toInt()}'),
        MonoRentRow(count: 1, value: '$currency${property.getHouseRent(1).toInt()}'),
        MonoRentRow(count: 2, value: '$currency${property.getHouseRent(2).toInt()}'),
        MonoRentRow(count: 3, value: '$currency${property.getHouseRent(3).toInt()}'),
        MonoRentRow(count: 4, value: '$currency${property.getHouseRent(4).toInt()}'),
        MonoRentRow(count: 5, value: '$currency${property.getHouseRent(5).toInt()}'),
      ],
    );
  }
}
