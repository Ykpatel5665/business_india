// City-landmark silhouettes for each of the 40 Monopoly tiles.
//
// Drives the board tile illustration. All silhouettes are drawn inside a
// notional 40x40 coordinate space (then scaled to whatever Size the widget
// gives us), using 2-3 solid colors per landmark. No gradients. No fine
// detail. Every drawing has a thick dark outline so it reads at tile size.
//
// Mapping for the India edition (positions as in board_india.dart):
//   0  GO            → rightward arrow
//   1  Nashik        → vineyard (grapes + stake) skyline
//   2  Community Chest → diamond icon
//   3  Ranchi        → hill + temple spire skyline
//   4  Income Tax    → big ₹ in circle
//   5  Mumbai Central (rail) → steam locomotive
//   6  Jaipur        → Hawa Mahal silhouette
//   7  Chance        → question mark in circle
//   8  Lucknow       → Bara Imambara silhouette
//   9  Bhopal        → mosque-domes silhouette
//  10  Jail          → jail bars
//  11  Chandigarh    → Open-Hand monument
//  12  Tata Power    → lightning bolt
//  13  Indore        → Rajwada palace silhouette
//  14  Nagpur        → Deekshabhoomi dome
//  15  Howrah Jn (rail) → steam locomotive
//  16  Kochi         → Chinese fishing nets
//  17  Community Chest → diamond icon
//  18  Coimbatore    → textile mill / 3 buildings
//  19  Vishakhapatnam → lighthouse
//  20  Free Parking  → car icon
//  21  Ahmedabad     → Sabarmati Ashram / pillar
//  22  Chance        → question mark
//  23  Pune          → Shaniwar Wada gate
//  24  Surat         → Dutch-style tower
//  25  Chennai Central (rail) → steam locomotive
//  26  Hyderabad     → Charminar
//  27  Bangalore     → Vidhana Soudha
//  28  Indian Oil    → water-droplet (fuel drop)
//  29  Chennai       → Marina temple skyline
//  30  Go to Jail    → handcuffs
//  31  Kolkata       → Howrah Bridge
//  32  Delhi         → India Gate
//  33  Community Chest → diamond icon
//  34  Mumbai Suburbs → Bandra-Worli sea link cable-stay
//  35  New Delhi (rail) → steam locomotive
//  36  Chance        → question mark
//  37  Mumbai South   → Gateway of India
//  38  Luxury Tax    → diamond + star
//  39  Mumbai Bandra  → Taj Mahal Palace hotel dome trio
//
// Hardcoded colors (until GameColors exists):
//   outline  = 0xFF1A1A2E
//   stone    = 0xFFE8D9B6   (warm cream sandstone)
//   domeGold = 0xFFFFD700
//   accent   = 0xFFE63946
//   skyBlue  = 0xFF6BC1FF
//   green    = 0xFF43AA46
//   red      = 0xFFE63946
//   jailGrey = 0xFF9AA0A8
//   water    = 0xFF3DA9FC
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CityLandmarkPainter extends CustomPainter {
  const CityLandmarkPainter({required this.tileIndex});

  final int tileIndex;

  static const Color outline = Color(0xFF1A1A2E);
  static const Color stone = Color(0xFFE8D9B6);
  static const Color domeGold = Color(0xFFFFD700);
  static const Color accent = Color(0xFFE63946);
  static const Color green = Color(0xFF43AA46);
  static const Color red = Color(0xFFE63946);
  static const Color jailGrey = Color(0xFF9AA0A8);
  static const Color water = Color(0xFF3DA9FC);
  static const Color darkStone = Color(0xFFB89A66);

  @override
  void paint(Canvas canvas, Size size) {
    // Scale the 40x40 unit space to the actual size.
    final sx = size.width / 40.0;
    final sy = size.height / 40.0;
    canvas.save();
    canvas.scale(sx, sy);

    switch (tileIndex) {
      case 0: _drawGoArrow(canvas); break;
      case 1: _drawHills(canvas, accent: Color(0xFF8E44AD)); break; // Nashik
      case 2: _drawDiamond(canvas); break;
      case 3: _drawTempleSpire(canvas); break; // Ranchi
      case 4: _drawTaxRupee(canvas); break;
      case 5: case 15: case 25: case 35:
        _drawSteamEngine(canvas); break;
      case 6: _drawHawaMahal(canvas); break;
      case 7: case 22: case 36:
        _drawChanceMark(canvas); break;
      case 8: _drawImambara(canvas); break;
      case 9: _drawMosqueDomes(canvas); break;
      case 10: _drawJailBars(canvas); break;
      case 11: _drawOpenHand(canvas); break;
      case 12: _drawLightning(canvas); break;
      case 13: _drawRajwada(canvas); break;
      case 14: _drawDomeStupa(canvas); break;
      case 16: _drawFishingNets(canvas); break;
      case 17: case 33:
        _drawDiamond(canvas); break;
      case 18: _drawCitySkyline(canvas); break;
      case 19: _drawLighthouse(canvas); break;
      case 20: _drawCar(canvas); break;
      case 21: _drawAshramPillar(canvas); break;
      case 23: _drawShaniwarWada(canvas); break;
      case 24: _drawDutchTower(canvas); break;
      case 26: _drawCharminar(canvas); break;
      case 27: _drawVidhanaSoudha(canvas); break;
      case 28: _drawFuelDrop(canvas); break;
      case 29: _drawMarinaSkyline(canvas); break;
      case 30: _drawHandcuffs(canvas); break;
      case 31: _drawHowrahBridge(canvas); break;
      case 32: _drawIndiaGate(canvas); break;
      case 34: _drawSeaLink(canvas); break;
      case 37: _drawGatewayOfIndia(canvas); break;
      case 38: _drawLuxuryTax(canvas); break;
      case 39: _drawTajDomes(canvas); break;
      default: _drawCitySkyline(canvas); break;
    }

    canvas.restore();
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  Paint _fill(Color c) => Paint()..color = c;
  Paint _stroke([double width = 1.6]) => Paint()
    ..color = outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  // Fill + outline a path in one call.
  void _shape(Canvas c, Path p, Color fill, [double strokeW = 1.6]) {
    c.drawPath(p, _fill(fill));
    c.drawPath(p, _stroke(strokeW));
  }

  // ---------------------------------------------------------------------
  // Shared motifs
  // ---------------------------------------------------------------------

  void _drawDiamond(Canvas c) {
    final p = Path()
      ..moveTo(20, 8)
      ..lineTo(32, 20)
      ..lineTo(20, 32)
      ..lineTo(8, 20)
      ..close();
    _shape(c, p, domeGold, 1.8);
    // inner shine
    final shine = Path()
      ..moveTo(14, 18)
      ..lineTo(20, 11)
      ..lineTo(23, 14)
      ..lineTo(16, 21)
      ..close();
    c.drawPath(shine, _fill(Colors.white.withValues(alpha: 0.45)));
  }

  void _drawChanceMark(Canvas c) {
    // Orange circle + "?"
    c.drawCircle(const Offset(20, 20), 13, _fill(const Color(0xFFFF9F43)));
    c.drawCircle(const Offset(20, 20), 13, _stroke(1.8));
    TextStyle style;
    try {
      style = GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      );
    } catch (_) {
      style = const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      );
    }
    final tp = TextPainter(
      text: TextSpan(text: '?', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(20 - tp.width / 2, 20 - tp.height / 2));
  }

  void _drawTaxRupee(Canvas c) {
    c.drawCircle(const Offset(20, 20), 13, _fill(const Color(0xFFFFD166)));
    c.drawCircle(const Offset(20, 20), 13, _stroke(1.8));
    TextStyle style;
    try {
      style = GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF7A4B00),
      );
    } catch (_) {
      style = const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: Color(0xFF7A4B00),
      );
    }
    final tp = TextPainter(
      text: TextSpan(text: '\u20B9', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(20 - tp.width / 2, 20 - tp.height / 2));
  }

  void _drawLuxuryTax(Canvas c) {
    _drawDiamond(c);
    // Small star on top-right.
    final star = Path();
    const cx = 28.0;
    const cy = 12.0;
    const r = 4.0;
    for (int i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final rad = (i.isEven) ? r : r * 0.45;
      final x = cx + math.cos(angle) * rad;
      final y = cy + math.sin(angle) * rad;
      if (i == 0) {
        star.moveTo(x, y);
      } else {
        star.lineTo(x, y);
      }
    }
    star.close();
    _shape(c, star, accent, 1.2);
  }

  void _drawGoArrow(Canvas c) {
    final p = Path()
      ..moveTo(6, 16)
      ..lineTo(22, 16)
      ..lineTo(22, 10)
      ..lineTo(34, 20)
      ..lineTo(22, 30)
      ..lineTo(22, 24)
      ..lineTo(6, 24)
      ..close();
    _shape(c, p, accent, 1.8);
  }

  void _drawJailBars(Canvas c) {
    // Frame
    final frame = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 8, 28, 26),
      const Radius.circular(2),
    );
    c.drawRRect(frame, _fill(jailGrey));
    c.drawRRect(frame, _stroke(1.8));
    // Vertical bars
    final barPaint = _stroke(1.8);
    for (double x = 12; x <= 28; x += 4) {
      c.drawLine(Offset(x, 10), Offset(x, 32), barPaint);
    }
  }

  void _drawHandcuffs(Canvas c) {
    // Two interlocked rings.
    c.drawCircle(const Offset(14, 22), 6, _fill(jailGrey));
    c.drawCircle(const Offset(14, 22), 6, _stroke(1.8));
    c.drawCircle(const Offset(14, 22), 3, _fill(Colors.white));
    c.drawCircle(const Offset(14, 22), 3, _stroke(1.2));
    c.drawCircle(const Offset(26, 22), 6, _fill(jailGrey));
    c.drawCircle(const Offset(26, 22), 6, _stroke(1.8));
    c.drawCircle(const Offset(26, 22), 3, _fill(Colors.white));
    c.drawCircle(const Offset(26, 22), 3, _stroke(1.2));
    // Chain link.
    c.drawRect(const Rect.fromLTWH(18.5, 21, 3, 2), _fill(jailGrey));
    c.drawRect(const Rect.fromLTWH(18.5, 21, 3, 2), _stroke(1.0));
  }

  void _drawCar(Canvas c) {
    // Body (taxi yellow).
    final body = Path()
      ..moveTo(6, 26)
      ..lineTo(6, 22)
      ..lineTo(12, 16)
      ..lineTo(26, 16)
      ..lineTo(32, 22)
      ..lineTo(34, 22)
      ..lineTo(34, 26)
      ..close();
    _shape(c, body, const Color(0xFFFFD166), 1.8);
    // Windows
    final win = Path()
      ..moveTo(13, 17)
      ..lineTo(19, 17)
      ..lineTo(19, 21)
      ..lineTo(12, 21)
      ..close();
    _shape(c, win, water, 1.2);
    final win2 = Path()
      ..moveTo(21, 17)
      ..lineTo(25, 17)
      ..lineTo(27, 21)
      ..lineTo(21, 21)
      ..close();
    _shape(c, win2, water, 1.2);
    // Wheels
    c.drawCircle(const Offset(12, 28), 3, _fill(outline));
    c.drawCircle(const Offset(12, 28), 1.4, _fill(jailGrey));
    c.drawCircle(const Offset(28, 28), 3, _fill(outline));
    c.drawCircle(const Offset(28, 28), 1.4, _fill(jailGrey));
  }

  void _drawSteamEngine(Canvas c) {
    // Boiler.
    final boiler = RRect.fromRectAndCorners(
      const Rect.fromLTWH(10, 18, 18, 8),
      topLeft: const Radius.circular(3),
      topRight: const Radius.circular(3),
    );
    c.drawRRect(boiler, _fill(accent));
    c.drawRRect(boiler, _stroke(1.6));
    // Cab.
    final cab = RRect.fromRectAndRadius(
      const Rect.fromLTWH(26, 14, 10, 12),
      const Radius.circular(1.5),
    );
    c.drawRRect(cab, _fill(const Color(0xFF8E1B24)));
    c.drawRRect(cab, _stroke(1.6));
    // Funnel.
    final funnel = Path()
      ..moveTo(13, 18)
      ..lineTo(13, 12)
      ..lineTo(18, 12)
      ..lineTo(18, 18)
      ..close();
    _shape(c, funnel, outline, 1.0);
    // Smoke puff.
    c.drawCircle(const Offset(15.5, 9), 2.5, _fill(Colors.white));
    c.drawCircle(const Offset(15.5, 9), 2.5, _stroke(1.2));
    c.drawCircle(const Offset(19, 7), 2, _fill(Colors.white));
    c.drawCircle(const Offset(19, 7), 2, _stroke(1.0));
    // Wheels.
    c.drawCircle(const Offset(14, 28), 3, _fill(outline));
    c.drawCircle(const Offset(14, 28), 1.2, _fill(domeGold));
    c.drawCircle(const Offset(22, 28), 3, _fill(outline));
    c.drawCircle(const Offset(22, 28), 1.2, _fill(domeGold));
    c.drawCircle(const Offset(30, 28), 3, _fill(outline));
    c.drawCircle(const Offset(30, 28), 1.2, _fill(domeGold));
    // Track.
    c.drawLine(const Offset(6, 32), const Offset(38, 32), _stroke(1.4));
  }

  void _drawLightning(Canvas c) {
    final bolt = Path()
      ..moveTo(22, 6)
      ..lineTo(10, 22)
      ..lineTo(18, 22)
      ..lineTo(14, 34)
      ..lineTo(30, 16)
      ..lineTo(22, 16)
      ..close();
    _shape(c, bolt, domeGold, 1.8);
  }

  void _drawFuelDrop(Canvas c) {
    final drop = Path()
      ..moveTo(20, 6)
      ..cubicTo(26, 14, 30, 20, 30, 24)
      ..arcToPoint(const Offset(10, 24), radius: const Radius.circular(10), clockwise: false)
      ..cubicTo(10, 20, 14, 14, 20, 6)
      ..close();
    _shape(c, drop, water, 1.8);
    // highlight
    final hi = Path()
      ..moveTo(16, 20)
      ..quadraticBezierTo(15, 26, 18, 28)
      ..quadraticBezierTo(13, 27, 14, 20)
      ..close();
    c.drawPath(hi, _fill(Colors.white.withValues(alpha: 0.4)));
  }

  // ---------------------------------------------------------------------
  // Indian landmarks
  // ---------------------------------------------------------------------

  void _drawHawaMahal(Canvas c) {
    // Pink 5-storey wedding-cake facade, row of arched windows.
    final base = const Rect.fromLTWH(6, 12, 28, 22);
    c.drawRect(base, _fill(const Color(0xFFFF8BA7)));
    c.drawRect(base, _stroke(1.6));
    // Tiered silhouette on top.
    final top = Path()
      ..moveTo(4, 12)
      ..lineTo(8, 8)
      ..lineTo(12, 12)
      ..lineTo(16, 6)
      ..lineTo(20, 12)
      ..lineTo(24, 6)
      ..lineTo(28, 12)
      ..lineTo(32, 8)
      ..lineTo(36, 12)
      ..close();
    _shape(c, top, const Color(0xFFFF8BA7), 1.6);
    // Window rows (arched).
    final winP = Paint()..color = outline;
    for (int row = 0; row < 3; row++) {
      final y = 16.0 + row * 5;
      for (double x = 8; x <= 30; x += 5) {
        final r = Rect.fromLTWH(x, y, 3, 3.5);
        c.drawRRect(
          RRect.fromRectAndCorners(
            r,
            topLeft: const Radius.circular(1.5),
            topRight: const Radius.circular(1.5),
          ),
          winP,
        );
      }
    }
  }

  void _drawTempleSpire(Canvas c) {
    // Pointed shikhara spire.
    final spire = Path()
      ..moveTo(20, 4)
      ..lineTo(28, 22)
      ..lineTo(28, 32)
      ..lineTo(12, 32)
      ..lineTo(12, 22)
      ..close();
    _shape(c, spire, stone, 1.6);
    // Ribbing lines.
    final rib = _stroke(1.0);
    c.drawLine(const Offset(16, 14), const Offset(16, 30), rib);
    c.drawLine(const Offset(20, 10), const Offset(20, 30), rib);
    c.drawLine(const Offset(24, 14), const Offset(24, 30), rib);
    // Kalash on top.
    c.drawCircle(const Offset(20, 4), 1.6, _fill(domeGold));
    c.drawCircle(const Offset(20, 4), 1.6, _stroke(1.0));
  }

  void _drawHills(Canvas c, {required Color accent}) {
    // Nashik — grape hill + stake.
    final hill = Path()
      ..moveTo(4, 30)
      ..quadraticBezierTo(14, 16, 24, 26)
      ..quadraticBezierTo(30, 32, 36, 28)
      ..lineTo(36, 34)
      ..lineTo(4, 34)
      ..close();
    _shape(c, hill, green, 1.6);
    // Grapes (small cluster).
    final grapes = [
      const Offset(22, 18), const Offset(26, 18),
      const Offset(20, 22), const Offset(24, 22), const Offset(28, 22),
      const Offset(22, 26), const Offset(26, 26),
    ];
    for (final g in grapes) {
      c.drawCircle(g, 1.8, _fill(accent));
      c.drawCircle(g, 1.8, _stroke(0.8));
    }
    // Stake.
    c.drawLine(const Offset(24, 10), const Offset(24, 18), _stroke(1.4));
  }

  void _drawImambara(Canvas c) {
    // Large central dome + two small side domes, wide rectangular base.
    final base = const Rect.fromLTWH(4, 22, 32, 12);
    c.drawRect(base, _fill(stone));
    c.drawRect(base, _stroke(1.6));
    // Central dome.
    final dome = Path()
      ..moveTo(10, 22)
      ..arcToPoint(const Offset(30, 22), radius: const Radius.circular(10), clockwise: true)
      ..close();
    _shape(c, dome, stone, 1.6);
    c.drawLine(const Offset(20, 10), const Offset(20, 14), _stroke(1.0));
    c.drawCircle(const Offset(20, 9), 0.8, _fill(domeGold));
    // Two side domes.
    final d1 = Path()
      ..moveTo(4, 22)
      ..arcToPoint(const Offset(12, 22), radius: const Radius.circular(4), clockwise: true)
      ..close();
    _shape(c, d1, stone, 1.4);
    final d2 = Path()
      ..moveTo(28, 22)
      ..arcToPoint(const Offset(36, 22), radius: const Radius.circular(4), clockwise: true)
      ..close();
    _shape(c, d2, stone, 1.4);
  }

  void _drawMosqueDomes(Canvas c) {
    // Bhopal — Taj-ul-Masajid style — three domes + minarets.
    final base = const Rect.fromLTWH(4, 24, 32, 10);
    c.drawRect(base, _fill(stone));
    c.drawRect(base, _stroke(1.4));
    // Main dome.
    final dome = Path()
      ..moveTo(12, 24)
      ..arcToPoint(const Offset(28, 24), radius: const Radius.circular(8), clockwise: true)
      ..close();
    _shape(c, dome, const Color(0xFFFFF6D6), 1.6);
    // Side domes.
    final d1 = Path()
      ..moveTo(2, 24)
      ..arcToPoint(const Offset(10, 24), radius: const Radius.circular(4), clockwise: true)
      ..close();
    _shape(c, d1, const Color(0xFFFFF6D6), 1.4);
    final d2 = Path()
      ..moveTo(30, 24)
      ..arcToPoint(const Offset(38, 24), radius: const Radius.circular(4), clockwise: true)
      ..close();
    _shape(c, d2, const Color(0xFFFFF6D6), 1.4);
    // Minarets.
    c.drawRect(const Rect.fromLTWH(7, 12, 2, 16), _fill(stone));
    c.drawRect(const Rect.fromLTWH(7, 12, 2, 16), _stroke(1.0));
    c.drawRect(const Rect.fromLTWH(31, 12, 2, 16), _fill(stone));
    c.drawRect(const Rect.fromLTWH(31, 12, 2, 16), _stroke(1.0));
  }

  void _drawOpenHand(Canvas c) {
    // Chandigarh Open Hand — abstract hand silhouette.
    final palm = Path()
      ..moveTo(14, 34)
      ..lineTo(14, 18)
      ..quadraticBezierTo(14, 10, 20, 10)
      ..quadraticBezierTo(26, 10, 26, 18)
      ..lineTo(26, 34)
      ..close();
    _shape(c, palm, accent, 1.6);
    // Fingers.
    for (double x = 15; x <= 25; x += 3.3) {
      c.drawLine(Offset(x, 10), Offset(x, 4), _stroke(1.6));
    }
    // Base.
    c.drawRect(const Rect.fromLTWH(10, 34, 20, 2), _fill(outline));
  }

  void _drawRajwada(Canvas c) {
    // Indore palace — wide 7-storey facade with tiered top.
    final base = const Rect.fromLTWH(6, 18, 28, 16);
    c.drawRect(base, _fill(const Color(0xFFD4A574)));
    c.drawRect(base, _stroke(1.6));
    // Tiered roof.
    final roof = Path()
      ..moveTo(6, 18)
      ..lineTo(8, 14)
      ..lineTo(32, 14)
      ..lineTo(34, 18)
      ..close();
    _shape(c, roof, const Color(0xFFB06E3B), 1.4);
    final roof2 = Path()
      ..moveTo(12, 14)
      ..lineTo(14, 10)
      ..lineTo(26, 10)
      ..lineTo(28, 14)
      ..close();
    _shape(c, roof2, const Color(0xFFB06E3B), 1.4);
    // Central arch.
    c.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(17, 22, 6, 12),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      ),
      _fill(outline),
    );
  }

  void _drawDomeStupa(Canvas c) {
    // Nagpur — large hemispherical stupa with spire.
    c.drawCircle(const Offset(20, 28), 12, _fill(const Color(0xFFFFF6D6)));
    c.drawCircle(const Offset(20, 28), 12, _stroke(1.8));
    // Base platform.
    c.drawRect(const Rect.fromLTWH(4, 30, 32, 4), _fill(stone));
    c.drawRect(const Rect.fromLTWH(4, 30, 32, 4), _stroke(1.4));
    // Spire.
    c.drawRect(const Rect.fromLTWH(19, 10, 2, 10), _fill(outline));
    c.drawCircle(const Offset(20, 8), 1.5, _fill(domeGold));
  }

  void _drawFishingNets(Canvas c) {
    // Kochi — a triangular net + supporting poles.
    final water = const Rect.fromLTWH(0, 30, 40, 6);
    c.drawRect(water, _fill(const Color(0xFF3DA9FC)));
    c.drawRect(water, _stroke(1.0));
    // Poles.
    c.drawLine(const Offset(8, 30), const Offset(20, 6), _stroke(1.8));
    c.drawLine(const Offset(32, 30), const Offset(20, 6), _stroke(1.8));
    c.drawLine(const Offset(8, 30), const Offset(32, 30), _stroke(1.8));
    // Net (hanging triangle).
    final net = Path()
      ..moveTo(12, 18)
      ..lineTo(28, 18)
      ..lineTo(20, 26)
      ..close();
    _shape(c, net, stone, 1.2);
  }

  void _drawCitySkyline(Canvas c) {
    // Generic fallback — two buildings of different heights.
    c.drawRect(const Rect.fromLTWH(8, 14, 10, 20), _fill(const Color(0xFF6BC1FF)));
    c.drawRect(const Rect.fromLTWH(8, 14, 10, 20), _stroke(1.6));
    c.drawRect(const Rect.fromLTWH(20, 8, 12, 26), _fill(const Color(0xFF4F9DCB)));
    c.drawRect(const Rect.fromLTWH(20, 8, 12, 26), _stroke(1.6));
    // Windows.
    final winPaint = _fill(const Color(0xFFFFE27A));
    for (double y = 18; y <= 30; y += 4) {
      c.drawRect(Rect.fromLTWH(10, y, 2, 2), winPaint);
      c.drawRect(Rect.fromLTWH(14, y, 2, 2), winPaint);
    }
    for (double y = 12; y <= 30; y += 4) {
      c.drawRect(Rect.fromLTWH(22, y, 2, 2), winPaint);
      c.drawRect(Rect.fromLTWH(26, y, 2, 2), winPaint);
      c.drawRect(Rect.fromLTWH(30, y, 2, 2), winPaint);
    }
  }

  void _drawLighthouse(Canvas c) {
    // Tapered tower with red & white stripes.
    final tower = Path()
      ..moveTo(16, 10)
      ..lineTo(24, 10)
      ..lineTo(26, 30)
      ..lineTo(14, 30)
      ..close();
    _shape(c, tower, Colors.white, 1.6);
    // Stripes.
    c.drawRect(const Rect.fromLTWH(14, 14, 12, 3), _fill(accent));
    c.drawRect(const Rect.fromLTWH(14, 21, 12, 3), _fill(accent));
    c.drawRect(const Rect.fromLTWH(14, 14, 12, 3), _stroke(1.0));
    c.drawRect(const Rect.fromLTWH(14, 21, 12, 3), _stroke(1.0));
    // Top lantern.
    c.drawRect(const Rect.fromLTWH(15, 4, 10, 6), _fill(domeGold));
    c.drawRect(const Rect.fromLTWH(15, 4, 10, 6), _stroke(1.2));
    // Base.
    c.drawRect(const Rect.fromLTWH(12, 30, 16, 4), _fill(stone));
    c.drawRect(const Rect.fromLTWH(12, 30, 16, 4), _stroke(1.4));
  }

  void _drawAshramPillar(Canvas c) {
    // Ahmedabad — simple column with book (symbolising Sabarmati / education).
    c.drawRect(const Rect.fromLTWH(18, 8, 4, 22), _fill(stone));
    c.drawRect(const Rect.fromLTWH(18, 8, 4, 22), _stroke(1.4));
    c.drawRect(const Rect.fromLTWH(14, 28, 12, 4), _fill(darkStone));
    c.drawRect(const Rect.fromLTWH(14, 28, 12, 4), _stroke(1.4));
    c.drawRect(const Rect.fromLTWH(14, 6, 12, 4), _fill(darkStone));
    c.drawRect(const Rect.fromLTWH(14, 6, 12, 4), _stroke(1.4));
    // Chakra on top.
    c.drawCircle(const Offset(20, 4), 2, _fill(const Color(0xFF2468B0)));
    c.drawCircle(const Offset(20, 4), 2, _stroke(0.8));
  }

  void _drawShaniwarWada(Canvas c) {
    // Pune — huge gateway with central arch + twin towers.
    c.drawRect(const Rect.fromLTWH(4, 16, 32, 18), _fill(const Color(0xFFB06E3B)));
    c.drawRect(const Rect.fromLTWH(4, 16, 32, 18), _stroke(1.6));
    // Twin towers.
    c.drawRect(const Rect.fromLTWH(4, 10, 6, 8), _fill(const Color(0xFFB06E3B)));
    c.drawRect(const Rect.fromLTWH(4, 10, 6, 8), _stroke(1.4));
    c.drawRect(const Rect.fromLTWH(30, 10, 6, 8), _fill(const Color(0xFFB06E3B)));
    c.drawRect(const Rect.fromLTWH(30, 10, 6, 8), _stroke(1.4));
    // Arch.
    final arch = Path()
      ..moveTo(16, 34)
      ..lineTo(16, 24)
      ..quadraticBezierTo(20, 18, 24, 24)
      ..lineTo(24, 34)
      ..close();
    _shape(c, arch, outline, 1.2);
  }

  void _drawDutchTower(Canvas c) {
    // Surat — clock-tower style colonial building.
    c.drawRect(const Rect.fromLTWH(14, 10, 12, 24), _fill(const Color(0xFFFFF6D6)));
    c.drawRect(const Rect.fromLTWH(14, 10, 12, 24), _stroke(1.6));
    // Roof cap.
    final roof = Path()
      ..moveTo(12, 10)
      ..lineTo(20, 2)
      ..lineTo(28, 10)
      ..close();
    _shape(c, roof, accent, 1.4);
    // Clock face.
    c.drawCircle(const Offset(20, 18), 3.4, _fill(Colors.white));
    c.drawCircle(const Offset(20, 18), 3.4, _stroke(1.2));
    c.drawLine(const Offset(20, 18), const Offset(20, 15.5), _stroke(1.2));
    c.drawLine(const Offset(20, 18), const Offset(22, 18), _stroke(1.0));
    // Base.
    c.drawRect(const Rect.fromLTWH(10, 32, 20, 3), _fill(darkStone));
    c.drawRect(const Rect.fromLTWH(10, 32, 20, 3), _stroke(1.4));
  }

  void _drawCharminar(Canvas c) {
    // Hyderabad — square with four corner minarets + central dome.
    c.drawRect(const Rect.fromLTWH(10, 16, 20, 18), _fill(const Color(0xFFFFD9A0)));
    c.drawRect(const Rect.fromLTWH(10, 16, 20, 18), _stroke(1.6));
    // Central dome.
    final dome = Path()
      ..moveTo(14, 16)
      ..arcToPoint(const Offset(26, 16), radius: const Radius.circular(6), clockwise: true)
      ..close();
    _shape(c, dome, const Color(0xFFFFD9A0), 1.4);
    // Four minarets.
    for (final x in [6.0, 14.0, 22.0, 30.0]) {
      c.drawRect(Rect.fromLTWH(x, 4, 2.5, 14), _fill(const Color(0xFFFFD9A0)));
      c.drawRect(Rect.fromLTWH(x, 4, 2.5, 14), _stroke(1.0));
      c.drawCircle(Offset(x + 1.25, 3), 1.2, _fill(const Color(0xFFFFD9A0)));
      c.drawCircle(Offset(x + 1.25, 3), 1.2, _stroke(0.8));
    }
    // Central arch.
    final arch = Path()
      ..moveTo(18, 34)
      ..lineTo(18, 26)
      ..quadraticBezierTo(20, 22, 22, 26)
      ..lineTo(22, 34)
      ..close();
    _shape(c, arch, outline, 1.0);
  }

  void _drawVidhanaSoudha(Canvas c) {
    // Bangalore — long columned facade with central dome.
    c.drawRect(const Rect.fromLTWH(4, 20, 32, 14), _fill(stone));
    c.drawRect(const Rect.fromLTWH(4, 20, 32, 14), _stroke(1.6));
    // Columns.
    for (double x = 8; x <= 32; x += 4) {
      c.drawLine(Offset(x, 22), Offset(x, 32), _stroke(1.2));
    }
    // Central dome.
    final dome = Path()
      ..moveTo(14, 20)
      ..arcToPoint(const Offset(26, 20), radius: const Radius.circular(6), clockwise: true)
      ..close();
    _shape(c, dome, stone, 1.4);
    // Spire.
    c.drawLine(const Offset(20, 14), const Offset(20, 8), _stroke(1.6));
    c.drawCircle(const Offset(20, 7), 1.2, _fill(domeGold));
  }

  void _drawMarinaSkyline(Canvas c) {
    // Chennai — temple gopuram silhouette.
    final tiers = Path()
      ..moveTo(10, 34)
      ..lineTo(10, 26)
      ..lineTo(12, 22)
      ..lineTo(14, 18)
      ..lineTo(16, 14)
      ..lineTo(18, 10)
      ..lineTo(22, 10)
      ..lineTo(24, 14)
      ..lineTo(26, 18)
      ..lineTo(28, 22)
      ..lineTo(30, 26)
      ..lineTo(30, 34)
      ..close();
    _shape(c, tiers, const Color(0xFFB06E3B), 1.8);
    // Horizontal ribs.
    final rib = _stroke(1.0);
    c.drawLine(const Offset(11, 26), const Offset(29, 26), rib);
    c.drawLine(const Offset(13, 22), const Offset(27, 22), rib);
    c.drawLine(const Offset(15, 18), const Offset(25, 18), rib);
    // Door.
    c.drawRect(const Rect.fromLTWH(18, 28, 4, 6), _fill(outline));
  }

  void _drawHowrahBridge(Canvas c) {
    // Cantilever truss silhouette.
    c.drawLine(const Offset(4, 30), const Offset(36, 30), _stroke(2.2));
    // Towers.
    c.drawRect(const Rect.fromLTWH(7, 6, 3, 24), _fill(const Color(0xFFB7B7B7)));
    c.drawRect(const Rect.fromLTWH(7, 6, 3, 24), _stroke(1.4));
    c.drawRect(const Rect.fromLTWH(30, 6, 3, 24), _fill(const Color(0xFFB7B7B7)));
    c.drawRect(const Rect.fromLTWH(30, 6, 3, 24), _stroke(1.4));
    // Upper chord.
    c.drawLine(const Offset(8.5, 10), const Offset(31.5, 10), _stroke(1.8));
    // Diagonals.
    final d = _stroke(1.0);
    c.drawLine(const Offset(8.5, 10), const Offset(14, 30), d);
    c.drawLine(const Offset(14, 10), const Offset(20, 30), d);
    c.drawLine(const Offset(20, 10), const Offset(26, 30), d);
    c.drawLine(const Offset(26, 10), const Offset(31.5, 30), d);
    // Water.
    c.drawRect(const Rect.fromLTWH(0, 32, 40, 4), _fill(water));
    c.drawRect(const Rect.fromLTWH(0, 32, 40, 4), _stroke(1.0));
  }

  void _drawIndiaGate(Canvas c) {
    // Delhi — a triumphal arch.
    c.drawRect(const Rect.fromLTWH(6, 10, 28, 22), _fill(const Color(0xFFE3C48B)));
    c.drawRect(const Rect.fromLTWH(6, 10, 28, 22), _stroke(1.8));
    // Top cap.
    c.drawRect(const Rect.fromLTWH(4, 8, 32, 3), _fill(const Color(0xFFE3C48B)));
    c.drawRect(const Rect.fromLTWH(4, 8, 32, 3), _stroke(1.4));
    // Arch opening.
    final arch = Path()
      ..moveTo(14, 32)
      ..lineTo(14, 22)
      ..quadraticBezierTo(20, 14, 26, 22)
      ..lineTo(26, 32)
      ..close();
    _shape(c, arch, outline, 1.2);
    // Base.
    c.drawRect(const Rect.fromLTWH(4, 32, 32, 3), _fill(darkStone));
    c.drawRect(const Rect.fromLTWH(4, 32, 32, 3), _stroke(1.2));
  }

  void _drawSeaLink(Canvas c) {
    // Mumbai — cable-stayed bridge deck + A-frame tower.
    c.drawRect(const Rect.fromLTWH(0, 24, 40, 3), _fill(Colors.white));
    c.drawRect(const Rect.fromLTWH(0, 24, 40, 3), _stroke(1.4));
    // Water.
    c.drawRect(const Rect.fromLTWH(0, 30, 40, 6), _fill(water));
    c.drawRect(const Rect.fromLTWH(0, 30, 40, 6), _stroke(1.0));
    // Tower.
    final tower = Path()
      ..moveTo(18, 24)
      ..lineTo(20, 4)
      ..lineTo(22, 24)
      ..close();
    _shape(c, tower, const Color(0xFFB7B7B7), 1.6);
    // Cables.
    final cable = _stroke(1.0);
    c.drawLine(const Offset(20, 6), const Offset(6, 24), cable);
    c.drawLine(const Offset(20, 6), const Offset(12, 24), cable);
    c.drawLine(const Offset(20, 6), const Offset(28, 24), cable);
    c.drawLine(const Offset(20, 6), const Offset(34, 24), cable);
  }

  void _drawGatewayOfIndia(Canvas c) {
    // Mumbai — big central arch with small flanking structures.
    c.drawRect(const Rect.fromLTWH(6, 18, 28, 16), _fill(const Color(0xFFE3C48B)));
    c.drawRect(const Rect.fromLTWH(6, 18, 28, 16), _stroke(1.8));
    // Central dome.
    final dome = Path()
      ..moveTo(12, 18)
      ..arcToPoint(const Offset(28, 18), radius: const Radius.circular(8), clockwise: true)
      ..close();
    _shape(c, dome, const Color(0xFFE3C48B), 1.6);
    c.drawLine(const Offset(20, 8), const Offset(20, 12), _stroke(1.0));
    // Arch.
    final arch = Path()
      ..moveTo(15, 34)
      ..lineTo(15, 26)
      ..quadraticBezierTo(20, 18, 25, 26)
      ..lineTo(25, 34)
      ..close();
    _shape(c, arch, outline, 1.2);
    // Flanking small turrets.
    c.drawRect(const Rect.fromLTWH(2, 22, 4, 12), _fill(const Color(0xFFE3C48B)));
    c.drawRect(const Rect.fromLTWH(2, 22, 4, 12), _stroke(1.4));
    c.drawRect(const Rect.fromLTWH(34, 22, 4, 12), _fill(const Color(0xFFE3C48B)));
    c.drawRect(const Rect.fromLTWH(34, 22, 4, 12), _stroke(1.4));
  }

  void _drawTajDomes(Canvas c) {
    // Mumbai Bandra → Taj Palace hotel — central red dome, two smaller domes.
    c.drawRect(const Rect.fromLTWH(4, 22, 32, 12), _fill(const Color(0xFFFFF6D6)));
    c.drawRect(const Rect.fromLTWH(4, 22, 32, 12), _stroke(1.6));
    // Central large dome.
    final dome = Path()
      ..moveTo(12, 22)
      ..arcToPoint(const Offset(28, 22), radius: const Radius.circular(8), clockwise: true)
      ..close();
    _shape(c, dome, accent, 1.6);
    // Spire.
    c.drawRect(const Rect.fromLTWH(19, 8, 2, 6), _fill(outline));
    c.drawCircle(const Offset(20, 7), 1.4, _fill(domeGold));
    // Side onion domes.
    final d1 = Path()
      ..moveTo(2, 22)
      ..arcToPoint(const Offset(10, 22), radius: const Radius.circular(4), clockwise: true)
      ..close();
    _shape(c, d1, accent, 1.4);
    final d2 = Path()
      ..moveTo(30, 22)
      ..arcToPoint(const Offset(38, 22), radius: const Radius.circular(4), clockwise: true)
      ..close();
    _shape(c, d2, accent, 1.4);
    // Arched windows.
    for (double x = 8; x <= 30; x += 6) {
      final r = Rect.fromLTWH(x, 26, 2, 4);
      c.drawRRect(
        RRect.fromRectAndCorners(
          r,
          topLeft: const Radius.circular(1),
          topRight: const Radius.circular(1),
        ),
        _fill(outline),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CityLandmarkPainter old) =>
      old.tileIndex != tileIndex;
}
