// Cartoon golden coin painter.
//
// Bright gold circle with a darker gold ring for depth, the rupee symbol '₹'
// centred, hard offset drop shadow. Uses Fredoka via google_fonts when the
// font is available; falls back to a bold system font otherwise.
//
// Hardcoded colors (until GameColors exists):
//   outline    = 0xFF1A1A2E
//   gold       = 0xFFFFD700
//   darkerGold = 0xFFC99A00
//   glyph      = 0xFF7A4B00  (warm brown for the ₹)
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoinPainter extends CustomPainter {
  const CoinPainter({this.color = const Color(0xFFFFD700)});

  final Color color;

  static const Color _outline = Color(0xFF1A1A2E);
  static const Color _darkGold = Color(0xFFC99A00);
  static const Color _glyph = Color(0xFF7A4B00);

  Color _darken(Color c, [double amt = 0.28]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amt).clamp(0.0, 1.0)).toColor();
  }

  TextStyle _symbolStyle(double fontSize) {
    try {
      return GoogleFonts.fredoka(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: _glyph,
        height: 1.0,
      );
    } catch (_) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: _glyph,
        height: 1.0,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = side * 0.44;
    final innerR = outerR * 0.82;
    final outlineWidth = math.max(2.5, side * 0.05);

    // Shadow — hard offset, no blur, darker gold.
    final shadowOff = Offset(outlineWidth, outlineWidth);
    canvas.drawCircle(
      Offset(cx + shadowOff.dx, cy + shadowOff.dy),
      outerR,
      Paint()..color = _darken(color, 0.38),
    );

    // Outer rim.
    canvas.drawCircle(Offset(cx, cy), outerR, Paint()..color = _darkGold);

    // Inner coin face.
    canvas.drawCircle(Offset(cx, cy), innerR, Paint()..color = color);

    // Subtle top-left highlight crescent.
    final highlight = Paint()..color = Colors.white.withValues(alpha: 0.35);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: innerR)));
    canvas.drawCircle(Offset(cx - innerR * 0.25, cy - innerR * 0.3), innerR * 0.55, highlight);
    canvas.restore();

    // Outlines (outer and inner ring).
    final outlinePaint = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth;
    canvas.drawCircle(Offset(cx, cy), outerR, outlinePaint);
    canvas.drawCircle(
      Offset(cx, cy),
      innerR,
      Paint()
        ..color = _darken(_darkGold, 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth * 0.5,
    );

    // ₹ glyph, centred.
    final fontSize = innerR * 1.35;
    final tp = TextPainter(
      text: TextSpan(text: '\u20B9', style: _symbolStyle(fontSize)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(
      canvas,
      Offset(cx - tp.width / 2, cy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CoinPainter old) => old.color != color;
}
