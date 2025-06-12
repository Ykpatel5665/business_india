import 'package:flutter/material.dart';

class MonoRentRow extends StatelessWidget {
  final int count;
  final String value;
  const MonoRentRow({super.key, required this.count, required this.value});

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (count == 5) {
      iconWidget = const Icon(Icons.apartment, color: Colors.red, size: 22);
    } else {
      iconWidget = Row(
        children: [
          for (int i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Icon(Icons.house, color: Colors.green[500], size: 18),
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
