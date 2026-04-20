// Chunky cartoon dice painter.
//
// Rounded square face (radius ~15% of side), thick dark outline, large round
// pips positioned correctly for 1..6, soft diagonal highlight on the top-left
// edge, hard offset shadow.
//
// Hardcoded colors (until GameColors exists):
//   outline = 0xFF1A1A2E
//   pip     = 0xFF1A1A2E
//   default face = 0xFFFFFFFF
import 'dart:math' as math;
import 'package:flutter/material.dart';

class DicePainter extends CustomPainter {
  const DicePainter({required this.value, this.color = const Color(0xFFFFFFFF)});

  final int value;
  final Color color;

  static const Color _outline = Color(0xFF1A1A2E);
  static const Color _pip = Color(0xFF1A1A2E);
  static const Color _white = Color(0xFFFFFFFF);

  Color _darken(Color c, [double amt = 0.25]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amt).clamp(0.0, 1.0)).toColor();
  }

  // Pip positions normalized to a 0..1 square (3x3 grid).
  static const Map<int, List<Offset>> _pipMap = {
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.3, 0.3), Offset(0.7, 0.7)],
    3: [Offset(0.3, 0.3), Offset(0.5, 0.5), Offset(0.7, 0.7)],
    4: [
      Offset(0.3, 0.3), Offset(0.7, 0.3),
      Offset(0.3, 0.7), Offset(0.7, 0.7),
    ],
    5: [
      Offset(0.3, 0.3), Offset(0.7, 0.3),
      Offset(0.5, 0.5),
      Offset(0.3, 0.7), Offset(0.7, 0.7),
    ],
    6: [
      Offset(0.3, 0.25), Offset(0.7, 0.25),
      Offset(0.3, 0.5),  Offset(0.7, 0.5),
      Offset(0.3, 0.75), Offset(0.7, 0.75),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final pad = side * 0.08;
    final faceRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side - pad * 2,
      height: side - pad * 2,
    );
    final radius = Radius.circular(faceRect.width * 0.18);
    final outlineWidth = math.max(3.0, side * 0.06);

    // Shadow.
    final shadowOff = Offset(outlineWidth * 0.9, outlineWidth * 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect.shift(shadowOff), radius),
      Paint()..color = _darken(color, 0.30),
    );

    // Face fill.
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, radius),
      Paint()..color = color,
    );

    // Soft diagonal highlight on top-left (curved strip).
    final highlightPath = Path()
      ..moveTo(faceRect.left + faceRect.width * 0.08,
          faceRect.top + faceRect.height * 0.40)
      ..quadraticBezierTo(
        faceRect.left + faceRect.width * 0.10,
        faceRect.top + faceRect.height * 0.10,
        faceRect.left + faceRect.width * 0.45,
        faceRect.top + faceRect.height * 0.07,
      )
      ..quadraticBezierTo(
        faceRect.left + faceRect.width * 0.25,
        faceRect.top + faceRect.height * 0.18,
        faceRect.left + faceRect.width * 0.14,
        faceRect.top + faceRect.height * 0.50,
      )
      ..close();
    canvas.drawPath(
      highlightPath,
      Paint()..color = _white.withValues(alpha: 0.55),
    );

    // Outline.
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, radius),
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth
        ..strokeJoin = StrokeJoin.round,
    );

    // Pips.
    final pips = _pipMap[value.clamp(1, 6)] ?? _pipMap[1]!;
    final pipR = faceRect.width * 0.09;
    final pipPaint = Paint()..color = _pip;
    for (final p in pips) {
      canvas.drawCircle(
        Offset(faceRect.left + p.dx * faceRect.width,
            faceRect.top + p.dy * faceRect.height),
        pipR,
        pipPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DicePainter old) =>
      old.value != value || old.color != color;
}
