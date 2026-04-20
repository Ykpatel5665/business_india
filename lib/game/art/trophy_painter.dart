// Cartoon golden trophy painter (used on the game-over overlay).
//
// Two-handle cup on a rectangular base, thick dark outline, gold fill, hard
// offset shadow with darker gold.
//
// Hardcoded colors (until GameColors exists):
//   outline    = 0xFF1A1A2E
//   gold       = 0xFFFFD700
//   darkerGold = 0xFFC99A00
//   baseDark   = 0xFF7A4B00
import 'dart:math' as math;
import 'package:flutter/material.dart';

class TrophyPainter extends CustomPainter {
  const TrophyPainter();

  static const Color _outline = Color(0xFF1A1A2E);
  static const Color _gold = Color(0xFFFFD700);
  static const Color _darkGold = Color(0xFFC99A00);
  static const Color _baseDark = Color(0xFF7A4B00);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final outlineWidth = math.max(3.0, math.min(w, h) * 0.05);

    // --- Geometry ---------------------------------------------------------
    // Cup occupies middle-upper ~55% of the height.
    final cupRect = Rect.fromLTWH(w * 0.25, h * 0.12, w * 0.50, h * 0.50);
    final cupRRect = RRect.fromLTRBAndCorners(
      cupRect.left, cupRect.top, cupRect.right, cupRect.bottom,
      topLeft: Radius.circular(w * 0.08),
      topRight: Radius.circular(w * 0.08),
      bottomLeft: Radius.circular(w * 0.20),
      bottomRight: Radius.circular(w * 0.20),
    );

    // Handles — two circles on either side.
    final handleR = w * 0.10;
    final handleLCenter = Offset(cupRect.left - handleR * 0.3, cupRect.top + cupRect.height * 0.28);
    final handleRCenter = Offset(cupRect.right + handleR * 0.3, cupRect.top + cupRect.height * 0.28);

    // Stem.
    final stemRect = Rect.fromLTWH(w * 0.44, cupRect.bottom - 2, w * 0.12, h * 0.12);

    // Plinth base.
    final baseRect = Rect.fromLTWH(w * 0.20, cupRect.bottom + h * 0.11, w * 0.60, h * 0.14);
    final baseRRect = RRect.fromRectAndRadius(baseRect, Radius.circular(w * 0.03));

    // Shadow pass: all shapes offset, darker gold.
    final shadowOff = Offset(outlineWidth, outlineWidth);
    final shadowPaint = Paint()..color = _darkGold;

    canvas.drawCircle(handleLCenter + shadowOff, handleR, shadowPaint);
    canvas.drawCircle(handleRCenter + shadowOff, handleR, shadowPaint);
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        cupRRect.left + shadowOff.dx, cupRRect.top + shadowOff.dy,
        cupRRect.right + shadowOff.dx, cupRRect.bottom + shadowOff.dy,
        topLeft: Radius.circular(w * 0.08),
        topRight: Radius.circular(w * 0.08),
        bottomLeft: Radius.circular(w * 0.20),
        bottomRight: Radius.circular(w * 0.20),
      ),
      shadowPaint,
    );
    canvas.drawRect(stemRect.shift(shadowOff), shadowPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect.shift(shadowOff), Radius.circular(w * 0.03)),
      Paint()..color = _baseDark,
    );

    // Gold fill pass.
    final goldPaint = Paint()..color = _gold;
    canvas.drawCircle(handleLCenter, handleR, goldPaint);
    canvas.drawCircle(handleRCenter, handleR, goldPaint);
    // Knock out handle inner holes (darker gold).
    canvas.drawCircle(handleLCenter, handleR * 0.55, Paint()..color = _darkGold);
    canvas.drawCircle(handleRCenter, handleR * 0.55, Paint()..color = _darkGold);

    canvas.drawRRect(cupRRect, goldPaint);
    canvas.drawRect(stemRect, goldPaint);
    canvas.drawRRect(baseRRect, Paint()..color = _baseDark);

    // Horizontal rim (slightly brighter bar) near the cup top.
    final rimRect = Rect.fromLTWH(
      cupRect.left - w * 0.02,
      cupRect.top - h * 0.02,
      cupRect.width + w * 0.04,
      h * 0.08,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rimRect, Radius.circular(w * 0.02)),
      Paint()..color = _gold,
    );

    // Highlight stripe down the left face of the cup.
    final highlightPath = Path()
      ..moveTo(cupRect.left + w * 0.06, cupRect.top + h * 0.02)
      ..lineTo(cupRect.left + w * 0.13, cupRect.top + h * 0.02)
      ..lineTo(cupRect.left + w * 0.11, cupRect.bottom - h * 0.08)
      ..lineTo(cupRect.left + w * 0.04, cupRect.bottom - h * 0.10)
      ..close();
    canvas.drawPath(
      highlightPath,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // --- Outlines ---------------------------------------------------------
    final outlinePaint = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(handleLCenter, handleR, outlinePaint);
    canvas.drawCircle(handleRCenter, handleR, outlinePaint);
    canvas.drawCircle(handleLCenter, handleR * 0.55, outlinePaint);
    canvas.drawCircle(handleRCenter, handleR * 0.55, outlinePaint);
    canvas.drawRRect(cupRRect, outlinePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rimRect, Radius.circular(w * 0.02)),
      outlinePaint,
    );
    canvas.drawRect(stemRect, outlinePaint);
    canvas.drawRRect(baseRRect, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant TrophyPainter old) => false;
}
