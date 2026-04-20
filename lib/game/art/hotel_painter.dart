// Tall cartoon hotel painter.
//
// Taller rounded-square building, 3 rows of square lit windows (yellow),
// simple flag on top, thick dark outline, hard offset shadow.
//
// Hardcoded colors (until GameColors exists):
//   outline = 0xFF1A1A2E
//   default body = 0xFFE63946 (saturated red)
//   window       = 0xFFFFE27A
//   flag         = 0xFFFFD700 (gold)
//   flagpole     = 0xFF1A1A2E
import 'dart:math' as math;
import 'package:flutter/material.dart';

class HotelPainter extends CustomPainter {
  const HotelPainter({this.color = const Color(0xFFE63946)});

  final Color color;

  static const Color _outline = Color(0xFF1A1A2E);
  static const Color _window = Color(0xFFFFE27A);
  static const Color _flag = Color(0xFFFFD700);

  Color _darken(Color c, [double amt = 0.30]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amt).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final outlineWidth = math.max(3.0, math.min(w, h) * 0.07);

    // Body rect: leaves space at top for flag.
    final body = Rect.fromLTWH(w * 0.15, h * 0.22, w * 0.70, h * 0.72);
    final bodyRRect = RRect.fromRectAndRadius(body, Radius.circular(w * 0.06));

    // Shadow pass — offset down-right, darker fill.
    final shadowOff = Offset(outlineWidth * 0.9, outlineWidth * 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body.shift(shadowOff), Radius.circular(w * 0.06)),
      Paint()..color = _darken(color, 0.35),
    );

    // Body fill.
    canvas.drawRRect(bodyRRect, Paint()..color = color);

    // Top horizontal band (slightly darker stripe under the flag base).
    final band = Rect.fromLTWH(body.left, body.top, body.width, h * 0.07);
    canvas.drawRect(band, Paint()..color = _darken(color, 0.18));

    // --- Windows: 3 rows × 3 columns of warm-yellow squares.
    final winPaint = Paint()..color = _window;
    final winOutline = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth * 0.45
      ..strokeJoin = StrokeJoin.round;
    final cols = 3;
    final rows = 3;
    final winAreaTop = body.top + h * 0.14;
    final winAreaBottom = body.bottom - h * 0.08;
    final winAreaLeft = body.left + w * 0.08;
    final winAreaRight = body.right - w * 0.08;
    final cellW = (winAreaRight - winAreaLeft) / cols;
    final cellH = (winAreaBottom - winAreaTop) / rows;
    final winW = cellW * 0.65;
    final winH = cellH * 0.65;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = winAreaLeft + cellW * (c + 0.5);
        final cy = winAreaTop + cellH * (r + 0.5);
        final rect = Rect.fromCenter(
          center: Offset(cx, cy),
          width: winW,
          height: winH,
        );
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(winW * 0.15));
        canvas.drawRRect(rr, winPaint);
        canvas.drawRRect(rr, winOutline);
      }
    }

    // --- Flag pole + triangular flag.
    final poleX = w * 0.5;
    final poleTopY = h * 0.04;
    final poleBottomY = body.top + 2;
    final polePaint = Paint()
      ..color = _outline
      ..strokeWidth = outlineWidth * 0.7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(poleX, poleTopY), Offset(poleX, poleBottomY), polePaint);

    final flagPath = Path()
      ..moveTo(poleX, poleTopY)
      ..lineTo(poleX + w * 0.18, poleTopY + h * 0.04)
      ..lineTo(poleX, poleTopY + h * 0.09)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = _flag);
    canvas.drawPath(
      flagPath,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth * 0.6
        ..strokeJoin = StrokeJoin.round,
    );

    // --- Body outline (on top so it stays crisp).
    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant HotelPainter old) => old.color != color;
}
