// Tiny cartoon monopoly house painter.
//
// Rounded square body, triangular roof, single square window, thick dark
// outline, hard offset shadow. Drawn within the painter's Size on the
// assumption that Size is roughly square (20..60 logical units is typical).
//
// Hardcoded colors (until GameColors exists):
//   outline = 0xFF1A1A2E
//   default roof  = 0xFFE63946 (saturated red)
//   default body  = 0xFF43AA46 (saturated green)
//   window        = 0xFFFFE27A (warm yellow)
import 'dart:math' as math;
import 'package:flutter/material.dart';

class HousePainter extends CustomPainter {
  const HousePainter({
    this.roofColor = const Color(0xFFE63946),
    this.bodyColor = const Color(0xFF43AA46),
  });

  final Color roofColor;
  final Color bodyColor;

  static const Color _outline = Color(0xFF1A1A2E);
  static const Color _window = Color(0xFFFFE27A);

  Color _darken(Color c, [double amt = 0.28]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amt).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final outlineWidth = math.max(2.5, math.min(w, h) * 0.08);

    // Rectangle regions.
    final bodyRect = Rect.fromLTWH(
      w * 0.12,
      h * 0.45,
      w * 0.76,
      h * 0.42,
    );
    final roofTop = Offset(w * 0.5, h * 0.12);
    final roofLeft = Offset(w * 0.05, h * 0.47);
    final roofRight = Offset(w * 0.95, h * 0.47);

    final shadowOffset = Offset(outlineWidth * 0.8, outlineWidth * 0.8);

    // --- SHADOW pass (darker of body color, flat, no blur).
    final shadowPaint = Paint()..color = _darken(bodyColor, 0.35);
    final shadowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          bodyRect.shift(shadowOffset), Radius.circular(w * 0.05)))
      ..moveTo(roofLeft.dx + shadowOffset.dx, roofLeft.dy + shadowOffset.dy)
      ..lineTo(roofTop.dx + shadowOffset.dx, roofTop.dy + shadowOffset.dy)
      ..lineTo(roofRight.dx + shadowOffset.dx, roofRight.dy + shadowOffset.dy)
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // --- Body fill (rounded square).
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.05));
    canvas.drawRRect(bodyRRect, Paint()..color = bodyColor);

    // --- Roof fill (triangle).
    final roofPath = Path()
      ..moveTo(roofLeft.dx, roofLeft.dy)
      ..lineTo(roofTop.dx, roofTop.dy)
      ..lineTo(roofRight.dx, roofRight.dy)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = roofColor);

    // --- Window (single small square on body).
    final windowRect = Rect.fromCenter(
      center: Offset(w * 0.5, bodyRect.center.dy + h * 0.02),
      width: w * 0.22,
      height: h * 0.18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, Radius.circular(w * 0.02)),
      Paint()..color = _window,
    );

    // --- Outlines (thick).
    final outlinePaint = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(bodyRRect, outlinePaint);
    canvas.drawPath(roofPath, outlinePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, Radius.circular(w * 0.02)),
      outlinePaint..strokeWidth = outlineWidth * 0.7,
    );
    // Window cross bars.
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top),
      Offset(windowRect.center.dx, windowRect.bottom),
      outlinePaint..strokeWidth = outlineWidth * 0.5,
    );
    canvas.drawLine(
      Offset(windowRect.left, windowRect.center.dy),
      Offset(windowRect.right, windowRect.center.dy),
      outlinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant HousePainter old) =>
      old.roofColor != roofColor || old.bodyColor != bodyColor;
}

