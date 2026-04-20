import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/game_colors.dart';

/// Animated sunset gradient backdrop with floating cartoon elements (coin,
/// dice, tiny house). Used on splash, menu, player setup, settings.
class SunsetBackdrop extends StatefulWidget {
  const SunsetBackdrop({super.key, required this.child, this.floaters = true});
  final Widget child;
  final bool floaters;

  @override
  State<SunsetBackdrop> createState() => _SunsetBackdropState();
}

class _SunsetBackdropState extends State<SunsetBackdrop>
    with TickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _drift,
          builder: (_, _) {
            final t = _drift.value;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(GameColors.sunsetStart, GameColors.sunsetMid, t)!,
                    GameColors.sunsetMid,
                    Color.lerp(GameColors.sunsetMid, GameColors.sunsetEnd,
                        (1 - t).abs())!,
                  ],
                ),
              ),
            );
          },
        ),
        if (widget.floaters)
          AnimatedBuilder(
            animation: _drift,
            builder: (_, _) => CustomPaint(
              painter: _FloatersPainter(t: _drift.value),
              size: Size.infinite,
            ),
          ),
        widget.child,
      ],
    );
  }
}

class _FloatersPainter extends CustomPainter {
  _FloatersPainter({required this.t});
  final double t;

  static const _seeds = <({double x, double y, double r, int kind})>[
    (x: 0.10, y: 0.20, r: 26, kind: 0),
    (x: 0.85, y: 0.15, r: 32, kind: 1),
    (x: 0.15, y: 0.75, r: 28, kind: 2),
    (x: 0.80, y: 0.82, r: 30, kind: 0),
    (x: 0.55, y: 0.10, r: 22, kind: 2),
    (x: 0.40, y: 0.88, r: 24, kind: 1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _seeds.length; i++) {
      final s = _seeds[i];
      final phase = (t + i / _seeds.length) * math.pi * 2;
      final drift = 12 * math.sin(phase);
      final bob = 8 * math.cos(phase * 1.4);
      final cx = s.x * size.width;
      final cy = s.y * size.height + bob;
      final rot = 0.3 * math.sin(phase);
      canvas.save();
      canvas.translate(cx + drift, cy);
      canvas.rotate(rot);
      _draw(canvas, s.r, s.kind);
      canvas.restore();
    }
  }

  void _draw(Canvas canvas, double r, int kind) {
    final outline = Paint()
      ..color = GameColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final shadow = Paint()..color = GameColors.outline.withValues(alpha: 0.25);

    switch (kind) {
      case 0: // coin
        canvas.drawCircle(const Offset(0, 4), r, shadow);
        canvas.drawCircle(Offset.zero, r,
            Paint()..color = GameColors.gold);
        canvas.drawCircle(Offset.zero, r, outline);
        final tp = _text('\u20B9', fontSize: r * 1.1, color: GameColors.outline);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        break;
      case 1: // dice
        final rect = Rect.fromCenter(
            center: Offset.zero, width: r * 2, height: r * 2);
        final rr = RRect.fromRectAndRadius(
            rect.shift(const Offset(0, 4)), Radius.circular(r * 0.25));
        canvas.drawRRect(rr, shadow);
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(r * 0.25)),
            Paint()..color = GameColors.white);
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(r * 0.25)), outline);
        final dotPaint = Paint()..color = GameColors.outline;
        canvas.drawCircle(Offset(-r * 0.4, -r * 0.4), r * 0.12, dotPaint);
        canvas.drawCircle(Offset.zero, r * 0.12, dotPaint);
        canvas.drawCircle(Offset(r * 0.4, r * 0.4), r * 0.12, dotPaint);
        break;
      case 2: // tiny house
        final body = Rect.fromCenter(
            center: const Offset(0, 4), width: r * 1.6, height: r * 1.2);
        final roof = Path()
          ..moveTo(-r * 0.9, -r * 0.2)
          ..lineTo(0, -r)
          ..lineTo(r * 0.9, -r * 0.2)
          ..close();
        canvas.drawRRect(
            RRect.fromRectAndRadius(body.shift(const Offset(0, 4)),
                const Radius.circular(6)),
            shadow);
        canvas.drawRRect(
            RRect.fromRectAndRadius(body, const Radius.circular(6)),
            Paint()..color = GameColors.happyGreen);
        canvas.drawPath(
            roof, Paint()..color = GameColors.happyRed);
        canvas.drawRRect(
            RRect.fromRectAndRadius(body, const Radius.circular(6)), outline);
        canvas.drawPath(roof, outline);
        break;
    }
  }

  TextPainter _text(String s, {double fontSize = 14, required Color color}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp;
  }

  @override
  bool shouldRepaint(_FloatersPainter old) => old.t != t;
}
