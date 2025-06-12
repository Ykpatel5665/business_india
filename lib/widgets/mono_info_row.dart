import 'package:flutter/material.dart';

class MonoInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const MonoInfoRow({super.key, required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
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
}
