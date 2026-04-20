// Cartoon player-token painter — chubby round character with face.
//
// Style: saturated fill, thick dark outline, hard offset shadow, two eye dots
// with black pupils, smile arc. 6 `faceVariant` values tweak eyebrow angle and
// mouth shape to give each seat its own personality.
//
// Color constants (hardcoded until lib/app/theme/game_colors.dart exists):
//   outline = 0xFF1A1A2E
//   white   = 0xFFFFFFFF
//   pupil   = 0xFF1A1A2E
import 'dart:math' as math;
import 'package:flutter/material.dart';

class TokenPainter extends CustomPainter {
  const TokenPainter({required this.color, this.faceVariant = 0});

  final Color color;
  final int faceVariant;

  static const Color _outline = Color(0xFF1A1A2E);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _pupil = Color(0xFF1A1A2E);

  Color _darken(Color c, [double amount = 0.25]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final radius = math.min(w, h) * 0.40;

    // Hard offset drop shadow (NO blur) — darker version of the fill.
    final shadowPaint = Paint()
      ..color = _darken(color, 0.28)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy + radius * 0.18), radius, shadowPaint);

    // Body fill.
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), radius, bodyPaint);

    // Soft top-left highlight (small ellipse, 35% white).
    final highlightPaint = Paint()
      ..color = _white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - radius * 0.35, cy - radius * 0.45),
        width: radius * 0.7,
        height: radius * 0.45,
      ),
      highlightPaint,
    );

    // Thick dark outline (scales with size, ~4% of radius, min 3).
    final outlineWidth = math.max(3.0, radius * 0.14);
    final outlinePaint = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), radius, outlinePaint);

    // --- Face -------------------------------------------------------------
    final eyeY = cy - radius * 0.10;
    final eyeDX = radius * 0.32;
    final eyeR = radius * 0.16;
    final pupilR = eyeR * 0.55;

    // Eye whites.
    final eyeWhitePaint = Paint()..color = _white;
    canvas.drawCircle(Offset(cx - eyeDX, eyeY), eyeR, eyeWhitePaint);
    canvas.drawCircle(Offset(cx + eyeDX, eyeY), eyeR, eyeWhitePaint);

    // Eye outlines.
    final eyeOutline = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth * 0.55
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx - eyeDX, eyeY), eyeR, eyeOutline);
    canvas.drawCircle(Offset(cx + eyeDX, eyeY), eyeR, eyeOutline);

    // Pupils (slightly offset for lively look).
    final pupilPaint = Paint()..color = _pupil;
    final pupilOffset = pupilR * 0.2;
    canvas.drawCircle(
      Offset(cx - eyeDX + pupilOffset, eyeY + pupilOffset * 0.5),
      pupilR,
      pupilPaint,
    );
    canvas.drawCircle(
      Offset(cx + eyeDX + pupilOffset, eyeY + pupilOffset * 0.5),
      pupilR,
      pupilPaint,
    );

    // Eyebrows vary by faceVariant — angle & lift.
    final variant = faceVariant.abs() % 6;
    final browTilt = [
      0.0, // neutral
      -0.25, // raised inner (curious)
      0.25, // angry / stern
      -0.35, // surprised
      0.1, // slight frown
      -0.1, // slight smile
    ][variant];
    final browLen = radius * 0.38;
    final browY = eyeY - radius * 0.32;
    final browPaint = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth * 0.7
      ..strokeCap = StrokeCap.round;
    // left brow
    canvas.drawLine(
      Offset(cx - eyeDX - browLen / 2, browY + browLen * 0.3 * browTilt),
      Offset(cx - eyeDX + browLen / 2, browY - browLen * 0.3 * browTilt),
      browPaint,
    );
    // right brow (mirrored)
    canvas.drawLine(
      Offset(cx + eyeDX - browLen / 2, browY - browLen * 0.3 * browTilt),
      Offset(cx + eyeDX + browLen / 2, browY + browLen * 0.3 * browTilt),
      browPaint,
    );

    // Mouth — variant shape.
    final mouthY = cy + radius * 0.38;
    final mouthW = radius * 0.7;
    final mouthPaint = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth * 0.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final mouthPath = Path();
    switch (variant) {
      case 0: // gentle smile
        mouthPath.moveTo(cx - mouthW / 2, mouthY);
        mouthPath.quadraticBezierTo(cx, mouthY + mouthW * 0.4, cx + mouthW / 2, mouthY);
        break;
      case 1: // big open smile
        mouthPath.addArc(
          Rect.fromCenter(center: Offset(cx, mouthY), width: mouthW, height: mouthW * 0.55),
          0,
          math.pi,
        );
        break;
      case 2: // smirk (one-sided)
        mouthPath.moveTo(cx - mouthW * 0.3, mouthY);
        mouthPath.quadraticBezierTo(cx + mouthW * 0.1, mouthY + mouthW * 0.25, cx + mouthW * 0.45, mouthY - mouthW * 0.05);
        break;
      case 3: // surprised "o"
        canvas.drawCircle(Offset(cx, mouthY + 2), mouthW * 0.18, mouthPaint);
        return;
      case 4: // flat
        mouthPath.moveTo(cx - mouthW / 2, mouthY);
        mouthPath.lineTo(cx + mouthW / 2, mouthY);
        break;
      case 5: // toothy grin
        mouthPath.addArc(
          Rect.fromCenter(center: Offset(cx, mouthY), width: mouthW, height: mouthW * 0.45),
          0,
          math.pi,
        );
        final teethPaint = Paint()..color = _white;
        canvas.drawRect(
          Rect.fromLTWH(cx - mouthW * 0.25, mouthY, mouthW * 0.5, mouthW * 0.08),
          teethPaint,
        );
        break;
    }
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant TokenPainter old) =>
      old.color != color || old.faceVariant != faceVariant;
}
