import 'package:flutter/material.dart';

import '../theme/game_colors.dart';
import '../theme/game_shapes.dart';

/// A rounded cartoon surface with a thick border and hard offset shadow.
/// Used anywhere a Material `Card` would be used elsewhere.
class CartoonPanel extends StatelessWidget {
  const CartoonPanel({
    super.key,
    required this.child,
    this.fill = GameColors.cream,
    this.border,
    this.padding = const EdgeInsets.all(16),
    this.radius = CartoonShape.radiusMedium,
    this.offset = CartoonShape.shadowMedium,
    this.borderWidth = CartoonShape.borderMedium,
    this.glossy = false,
    this.shadowColor,
  });

  final Widget child;
  final Color fill;
  final Color? border;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double offset;
  final double borderWidth;
  final bool glossy;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: glossy
          ? CartoonShape.cartoonGlossy(
              fill: fill,
              border: border,
              radius: radius,
              offset: offset,
              borderWidth: borderWidth,
              shadowColor: shadowColor,
            )
          : CartoonShape.cartoonBox(
              fill: fill,
              border: border,
              radius: radius,
              offset: offset,
              borderWidth: borderWidth,
              shadowColor: shadowColor,
            ),
      child: child,
    );
  }
}

/// A tag-like pill commonly used for labels (e.g. "CPU", "YOU", price chips).
class CartoonChip extends StatelessWidget {
  const CartoonChip({
    super.key,
    required this.label,
    this.fill = GameColors.happyYellow,
    this.textStyle,
    this.icon,
  });

  final String label;
  final Color fill;
  final TextStyle? textStyle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: CartoonShape.pill(fill: fill, borderWidth: 2.5, offset: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: GameColors.outline),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: textStyle ??
                const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: GameColors.outline,
                ),
          ),
        ],
      ),
    );
  }
}
