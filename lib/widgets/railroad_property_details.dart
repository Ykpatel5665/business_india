import 'package:flutter/material.dart';
import '../game_logic/models/property.dart';
import 'mono_info_row.dart';

class RailroadPropertyDetails extends StatelessWidget {
  final Property property;
  static const String currency = '₹';
  const RailroadPropertyDetails({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    // Assuming getHouseRent(n) returns rent for n railroads owned
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoInfoRow(label: '1 Station', value: '$currency${property.getRailRoadRent(1).toInt()}'),
        MonoInfoRow(label: '2 Stations', value: '$currency${property.getRailRoadRent(2).toInt()}'),
        MonoInfoRow(label: '3 Stations', value: '$currency${property.getRailRoadRent(3).toInt()}'),
        MonoInfoRow(label: '4 Stations', value: '$currency${property.getRailRoadRent(4).toInt()}'),
      ],
    );
  }
}
