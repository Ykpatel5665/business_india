// Single confetti-piece painter — used by a particle spawner on the game-over
// and win screens. Draws a small rotated filled rectangle with a thick dark
// outline so it pops against the felt background.
//
// Hardcoded colors (until GameColors exists):
//   outline = 0xFF1A1A2E
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiPiecePainter extends CustomPainter {
  const ConfettiPiecePainter({required this.color, this.rotation = 0.0});

  final Color color;

  /// Radians. Applied around the center of the Size.
  final double rotation;

  static const Color _outline = Color(0xFF1A1A2E);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width;
    final h = size.height;
    final outlineWidth = math.max(1.0, math.min(w, h) * 0.10);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: w * 0.85,
      height: h * 0.55,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(w * 0.08));

    canvas.drawRRect(rr, Paint()..color = color);
    canvas.drawRRect(
      rr,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ConfettiPiecePainter old) =>
      old.color != color || old.rotation != rotation;
}
