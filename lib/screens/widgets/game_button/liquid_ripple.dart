import 'package:flutter/material.dart';
import 'liquid_ripple_painter.dart';

/// Reusable liquid ripple effect widget for game buttons
class LiquidRipple extends StatelessWidget {
  final Color color;
  final bool show;
  final Key? rippleKey;
  const LiquidRipple({
    super.key,
    required this.color,
    required this.show,
    this.rippleKey,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        key: rippleKey,
        opacity: show ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: CustomPaint(
          painter: LiquidRipplePainter(color: color.withOpacity(0.25)),
        ),
      ),
    );
  }
}
