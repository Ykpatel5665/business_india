import 'package:flutter/material.dart';
import 'dart:math' as Math;

/// LiquidRipplePainter draws a wavy, liquid-like ripple effect for game UI.
/// Highly reusable for any game button or surface.
class LiquidRipplePainter extends CustomPainter {
  final Color color;
  final int waveCount;
  final double waveDepth;

  /// [color]: The color of the ripple.
  /// [waveCount]: Number of waves (default: 12).
  /// [waveDepth]: Depth of the wave (0.0-1.0, default: 0.15).
  const LiquidRipplePainter({
    required this.color,
    this.waveCount = 12,
    this.waveDepth = 0.15,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.6;
    final path = Path();
    for (int i = 0; i < waveCount; i++) {
      final angle = (i / waveCount) * 2 * Math.pi;
      final wave = (i % 2 == 0) ? 1.0 : (1.0 - waveDepth);
      final dx = center.dx + radius * wave * Math.cos(angle);
      final dy = center.dy + radius * wave * Math.sin(angle);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
