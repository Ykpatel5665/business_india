import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';
import '../theme/game_shapes.dart';

/// A chunky cartoon toggle — NEVER use Material Switch.
class CartoonToggle extends StatelessWidget {
  const CartoonToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.onLabel = 'ON',
    this.offLabel = 'OFF',
    this.activeColor = GameColors.happyGreen,
    this.inactiveColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String onLabel;
  final String offLabel;
  final Color activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final fill = value ? activeColor : (inactiveColor ?? Colors.grey.shade400);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 84,
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: CartoonShape.pill(
          fill: fill,
          offset: 3,
          borderWidth: 3,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    value ? onLabel : '',
                    style: GameFonts.fredoka(
                        size: 11,
                        weight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    value ? '' : offLabel,
                    style: GameFonts.fredoka(
                        size: 11,
                        weight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 32,
                height: 32,
                decoration: CartoonShape.pill(
                  fill: Colors.white,
                  border: GameColors.outline,
                  offset: 1.5,
                  borderWidth: 2.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
