import 'package:flutter/material.dart';
import '../game_logic/models/property.dart';
import 'mono_info_row.dart';

class UtilityPropertyDetails extends StatelessWidget {
    final Property property;
    static const String currency = '₹';
    const UtilityPropertyDetails({super.key, required this.property});

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
                SizedBox(height: 10),
                Text(
                    'If one "Utility" is owned, rent is 4x amount shown on dice. ',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                ),
                Text(
                    'If both "Utilities" are owned, rent is 10x amount shown on dice.',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                ),
            ],
        );
    }
}
