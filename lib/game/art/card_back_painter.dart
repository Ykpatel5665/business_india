// Card-back painters for Chance and Community Chest piles.
//
// Both draw a rounded rectangle occupying the painter's Size with thick dark
// outline and hard offset shadow. Chance = orange gradient + chunky "?"
// in a script-ish face. Community = warm yellow + centred diamond icon.
//
// Hardcoded colors (until GameColors exists):
//   outline       = 0xFF1A1A2E
//   chanceTop     = 0xFFFF9F43
//   chanceBottom  = 0xFFE8590C
//   chanceGlyph   = 0xFFFFFFFF
//   communityTop  = 0xFFFFE27A
//   communityBot  = 0xFFF5B301
//   communityIcon = 0xFF7A4B00
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _outline = Color(0xFF1A1A2E);

Color _darken(Color c, [double amt = 0.30]) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - amt).clamp(0.0, 1.0)).toColor();
}

RRect _cardRRect(Size size) {
  final w = size.width;
  final h = size.height;
  final pad = math.min(w, h) * 0.06;
  return RRect.fromRectAndRadius(
    Rect.fromLTWH(pad, pad, w - pad * 2, h - pad * 2),
    Radius.circular(math.min(w, h) * 0.09),
  );
}

void _drawShadowAndOutline(Canvas canvas, RRect rr, Color shadowColor, double outlineWidth) {
  final offset = Offset(outlineWidth, outlineWidth);
  canvas.drawRRect(
    RRect.fromRectAndRadius(rr.outerRect.shift(offset), Radius.circular(rr.blRadiusX)),
    Paint()..color = shadowColor,
  );
}

class ChanceCardBackPainter extends CustomPainter {
  const ChanceCardBackPainter();

  static const Color _top = Color(0xFFFF9F43);
  static const Color _bottom = Color(0xFFE8590C);
  static const Color _glyph = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final rr = _cardRRect(size);
    final outlineWidth = math.max(3.0, math.min(size.width, size.height) * 0.04);

    _drawShadowAndOutline(canvas, rr, _darken(_bottom, 0.30), outlineWidth);

    // Gradient fill.
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_top, _bottom],
        ).createShader(rr.outerRect),
    );

    // Subtle diagonal highlight band.
    canvas.save();
    canvas.clipRRect(rr);
    final highlightPath = Path()
      ..moveTo(rr.left, rr.top + rr.height * 0.15)
      ..lineTo(rr.left + rr.width * 0.45, rr.top)
      ..lineTo(rr.left + rr.width * 0.65, rr.top)
      ..lineTo(rr.left, rr.top + rr.height * 0.45)
      ..close();
    canvas.drawPath(highlightPath, Paint()..color = Colors.white.withValues(alpha: 0.15));
    canvas.restore();

    // Outline.
    canvas.drawRRect(
      rr,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth
        ..strokeJoin = StrokeJoin.round,
    );

    // Big "?" glyph.
    final fontSize = rr.height * 0.60;
    TextStyle style;
    try {
      style = GoogleFonts.pacifico(
        fontSize: fontSize,
        color: _glyph,
        fontWeight: FontWeight.w900,
        height: 1.0,
      );
    } catch (_) {
      style = TextStyle(
        fontSize: fontSize,
        color: _glyph,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        height: 1.0,
      );
    }
    final tp = TextPainter(
      text: TextSpan(text: '?', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(rr.center.dx - tp.width / 2, rr.center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant ChanceCardBackPainter old) => false;
}

class CommunityCardBackPainter extends CustomPainter {
  const CommunityCardBackPainter();

  static const Color _top = Color(0xFFFFE27A);
  static const Color _bottom = Color(0xFFF5B301);
  static const Color _icon = Color(0xFF7A4B00);

  @override
  void paint(Canvas canvas, Size size) {
    final rr = _cardRRect(size);
    final outlineWidth = math.max(3.0, math.min(size.width, size.height) * 0.04);

    _drawShadowAndOutline(canvas, rr, _darken(_bottom, 0.35), outlineWidth);

    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_top, _bottom],
        ).createShader(rr.outerRect),
    );

    // Outline.
    canvas.drawRRect(
      rr,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth
        ..strokeJoin = StrokeJoin.round,
    );

    // Diamond icon centred.
    final cx = rr.center.dx;
    final cy = rr.center.dy;
    final dw = rr.width * 0.38;
    final dh = rr.height * 0.42;
    final diamond = Path()
      ..moveTo(cx, cy - dh / 2)
      ..lineTo(cx + dw / 2, cy)
      ..lineTo(cx, cy + dh / 2)
      ..lineTo(cx - dw / 2, cy)
      ..close();

    canvas.drawPath(diamond, Paint()..color = _icon);

    // Inner shine band on the diamond.
    final shine = Path()
      ..moveTo(cx - dw * 0.18, cy - dh * 0.05)
      ..lineTo(cx, cy - dh * 0.30)
      ..lineTo(cx + dw * 0.08, cy - dh * 0.18)
      ..lineTo(cx - dw * 0.12, cy + dh * 0.05)
      ..close();
    canvas.drawPath(shine, Paint()..color = Colors.white.withValues(alpha: 0.25));

    // Diamond outline.
    canvas.drawPath(
      diamond,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth * 0.7
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CommunityCardBackPainter old) => false;
}
