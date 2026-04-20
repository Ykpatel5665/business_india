// Wooden-table background painter.
//
// Tiles a full-screen warm brown plank texture with parallel horizontal
// plank lines (~80px spacing), subtle darker grain lines with jitter, and a
// couple of knot circles. No Flame, no images — pure canvas.
//
// Hardcoded colors (until GameColors exists):
//   base        = 0xFF8A5A3B  (warm plank brown)
//   plankShade  = 0xFF6B4227  (darker brown for plank seams)
//   grain       = 0xFF764A32  (subtle darker grain)
//   knot        = 0xFF4A2C18  (darkest brown)
import 'dart:math' as math;
import 'package:flutter/material.dart';

class WoodenTablePainter extends CustomPainter {
  const WoodenTablePainter({this.plankHeight = 80});

  final double plankHeight;

  static const Color _base = Color(0xFF8A5A3B);
  static const Color _plankShade = Color(0xFF6B4227);
  static const Color _grain = Color(0xFF764A32);
  static const Color _knot = Color(0xFF4A2C18);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base plank color.
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = _base);

    // Deterministic pseudo-random (seed 42) so pattern is stable per paint.
    final rng = math.Random(42);

    // Plank seams — solid horizontal lines every ~plankHeight, with a thick
    // darker stroke plus a thin brighter highlight right below for a bevel.
    final seamPaint = Paint()
      ..color = _plankShade
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;
    final seamHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 2;

    for (double y = plankHeight; y < h; y += plankHeight) {
      canvas.drawLine(Offset(0, y), Offset(w, y), seamPaint);
      canvas.drawLine(Offset(0, y + 2), Offset(w, y + 2), seamHighlight);
    }

    // Grain lines — many subtle horizontal strokes with jitter.
    final grainPaint = Paint()
      ..color = _grain.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    final grainCount = ((w * h) / 2400).clamp(40, 800).toInt();
    for (int i = 0; i < grainCount; i++) {
      final gy = rng.nextDouble() * h;
      final gx = rng.nextDouble() * w;
      final len = 30 + rng.nextDouble() * 90;
      final jitter = (rng.nextDouble() - 0.5) * 1.4;
      canvas.drawLine(
        Offset(gx, gy),
        Offset(gx + len, gy + jitter),
        grainPaint,
      );
    }

    // Two knot circles — stable positions at 23% / 72% width, 40% / 80% h.
    final knotPaint = Paint()..color = _knot;
    final knotRingPaint = Paint()
      ..color = _knot.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    void drawKnot(Offset c, double r) {
      canvas.drawCircle(c, r, knotPaint);
      canvas.drawCircle(c, r * 1.6, knotRingPaint);
      canvas.drawCircle(c, r * 2.2, knotRingPaint..color = _knot.withValues(alpha: 0.35));
    }

    drawKnot(Offset(w * 0.23, h * 0.40), 6);
    drawKnot(Offset(w * 0.72, h * 0.78), 5);
  }

  @override
  bool shouldRepaint(covariant WoodenTablePainter old) =>
      old.plankHeight != plankHeight;
}
