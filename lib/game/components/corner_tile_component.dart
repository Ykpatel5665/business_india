// Corner tiles: GO (0), Jail (10), Free Parking (20), Go To Jail (30).
//
// Each corner gets a distinct chunky icon. We draw everything inline rather
// than leaning on a CityLandmarkPainter so the file is self-contained and the
// four corners read as visually different even at small sizes.
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../app/theme/game_colors.dart';
import '../../app/theme/game_fonts.dart';
import '../../game_logic/models/board_tile.dart';
import '../../game_logic/models/enums.dart';
import 'board_geometry.dart';
import 'tile_component.dart';

class CornerTileComponent extends PositionComponent with TapCallbacks {
  CornerTileComponent({
    required this.tile,
    required this.geometry,
    required this.onTap,
  }) : super(
          size: geometry.tileSize(tile.position),
          position: geometry.tileCenter(tile.position),
          angle: geometry.tileAngle(tile.position),
          anchor: Anchor.center,
        );

  final BoardTile tile;
  final BoardGeometry geometry;
  final TileTapped onTap;

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.x >= 0 &&
        point.y >= 0 &&
        point.x <= size.x &&
        point.y <= size.y;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(tile.position);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    // Shadow + cream face.
    canvas.drawRRect(
      rrect.shift(const Offset(2, 3)),
      Paint()..color = const Color(0xFFD9CCA3),
    );
    canvas.drawRRect(rrect, Paint()..color = GameColors.cream);

    // Outline.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = GameColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round,
    );

    switch (tile.type) {
      case TileType.go:
        _drawGo(canvas);
        break;
      case TileType.jail:
        _drawJail(canvas);
        break;
      case TileType.freeParking:
        _drawFreeParking(canvas);
        break;
      case TileType.goToJail:
        _drawGoToJail(canvas);
        break;
      default:
        break;
    }
  }

  Paint get _outlinePaint => Paint()
    ..color = GameColors.outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _drawGo(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    // Golden arrow pointing into the board (upper-left from bottom-right corner).
    // We aim the arrow at -135 degrees from +x so it visually points across
    // the diagonal of the board.
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(math.pi * 1.25);
    final arrow = Path()
      ..moveTo(-size.x * 0.28, -size.y * 0.06)
      ..lineTo(size.x * 0.10, -size.y * 0.06)
      ..lineTo(size.x * 0.10, -size.y * 0.14)
      ..lineTo(size.x * 0.30, 0)
      ..lineTo(size.x * 0.10, size.y * 0.14)
      ..lineTo(size.x * 0.10, size.y * 0.06)
      ..lineTo(-size.x * 0.28, size.y * 0.06)
      ..close();
    canvas.drawPath(arrow, Paint()..color = GameColors.gold);
    canvas.drawPath(arrow, _outlinePaint);
    canvas.restore();

    _drawLabel(canvas, 'GO', topCenter: Offset(cx, size.y - 18));
  }

  void _drawJail(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    // Jail cell window — inset rectangle with vertical bars.
    final cellRect = Rect.fromCenter(
      center: Offset(cx, cy - 6),
      width: size.x * 0.55,
      height: size.y * 0.45,
    );
    canvas.drawRect(cellRect, Paint()..color = const Color(0xFF7B8794));
    canvas.drawRect(cellRect, _outlinePaint);
    final barX0 = cellRect.left + cellRect.width * 0.18;
    final barX1 = cellRect.right - cellRect.width * 0.18;
    const bars = 4;
    for (var i = 0; i < bars; i++) {
      final t = i / (bars - 1);
      final x = barX0 + (barX1 - barX0) * t;
      canvas.drawLine(
        Offset(x, cellRect.top + 4),
        Offset(x, cellRect.bottom - 4),
        Paint()
          ..color = GameColors.outline
          ..strokeWidth = 3,
      );
    }

    // Orange "just visiting" stripe along the diagonal corner.
    final stripe = Path()
      ..moveTo(0, size.y * 0.15)
      ..lineTo(size.x * 0.15, 0)
      ..lineTo(size.x * 0.28, 0)
      ..lineTo(0, size.y * 0.28)
      ..close();
    canvas.drawPath(stripe, Paint()..color = GameColors.happyOrange);
    canvas.drawPath(stripe, _outlinePaint);

    _drawLabel(canvas, 'JAIL', topCenter: Offset(cx, size.y - 18));
  }

  void _drawFreeParking(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    // Simple car silhouette.
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 4),
          width: size.x * 0.62, height: size.y * 0.22),
      const Radius.circular(6),
    );
    canvas.drawRRect(body, Paint()..color = GameColors.happyRed);
    canvas.drawRRect(body, _outlinePaint);

    // Roof (upper smaller rect).
    final roof = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 14),
          width: size.x * 0.38, height: size.y * 0.16),
      const Radius.circular(5),
    );
    canvas.drawRRect(roof, Paint()..color = GameColors.happyRed);
    canvas.drawRRect(roof, _outlinePaint);

    // Windows.
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx - size.x * 0.08, cy - 14),
          width: size.x * 0.12, height: size.y * 0.10),
      Paint()..color = GameColors.cream,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx + size.x * 0.08, cy - 14),
          width: size.x * 0.12, height: size.y * 0.10),
      Paint()..color = GameColors.cream,
    );

    // Wheels.
    final wheelPaint = Paint()..color = GameColors.outline;
    canvas.drawCircle(Offset(cx - size.x * 0.18, cy + 4), 6, wheelPaint);
    canvas.drawCircle(Offset(cx + size.x * 0.18, cy + 4), 6, wheelPaint);
    canvas.drawCircle(
        Offset(cx - size.x * 0.18, cy + 4), 2.5, Paint()..color = GameColors.cream);
    canvas.drawCircle(
        Offset(cx + size.x * 0.18, cy + 4), 2.5, Paint()..color = GameColors.cream);

    _drawLabel(canvas, 'FREE\nPARKING',
        topCenter: Offset(cx, size.y - 24), lines: 2);
  }

  void _drawGoToJail(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    // Police whistle — a chunky circle + small pipe.
    final whistle = Rect.fromCircle(center: Offset(cx, cy - 4), radius: size.x * 0.18);
    canvas.drawCircle(whistle.center, whistle.width / 2, Paint()..color = GameColors.silver);
    canvas.drawCircle(whistle.center, whistle.width / 2, _outlinePaint);
    canvas.drawCircle(whistle.center, 3, Paint()..color = GameColors.outline);

    // Mouthpiece rectangle.
    final mouth = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(whistle.right + 10, whistle.center.dy),
          width: 16, height: 10),
      const Radius.circular(3),
    );
    canvas.drawRRect(mouth, Paint()..color = GameColors.silver);
    canvas.drawRRect(mouth, _outlinePaint);

    // Red banner.
    final banner = Rect.fromCenter(center: Offset(cx, size.y * 0.78),
        width: size.x * 0.75, height: size.y * 0.16);
    canvas.drawRect(banner, Paint()..color = GameColors.happyRed);
    canvas.drawRect(banner, _outlinePaint);

    _drawLabel(
      canvas,
      'GO TO JAIL',
      topCenter: Offset(cx, banner.top + 2),
      lines: 1,
      color: GameColors.white,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String text, {
    required Offset topCenter,
    int lines = 1,
    Color color = GameColors.outline,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: GameFonts.fredoka(size: 11, color: color),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: lines,
      ellipsis: '…',
    )..layout(maxWidth: size.x - 8);
    tp.paint(canvas, Offset(topCenter.dx - tp.width / 2, topCenter.dy));
  }
}
