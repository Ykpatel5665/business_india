// Regular (non-corner) board tile. Renders the cream face, color strip on the
// interior-facing side (property tiles only), name + price, improvements, and
// a mortgage bar when needed.
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../app/theme/game_colors.dart';
import '../../app/theme/game_fonts.dart';
import '../../game_logic/models/board_tile.dart';
import '../../game_logic/models/enums.dart';
import 'board_geometry.dart';
import 'hotel_component.dart';
import 'house_component.dart';

typedef TileTapped = void Function(int position);

class TileComponent extends PositionComponent with TapCallbacks {
  TileComponent({
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

  bool _mortgaged = false;
  int _improvementLevel = 0; // 0..5; 5 = hotel
  bool _highlight = false;
  double _glowPhase = 0;

  final List<Component> _improvementChildren = [];

  @override
  Future<void> onLoad() async {
    _refreshFromTile();
  }

  /// Call from the board every time the engine state changes.
  void syncFromEngine() {
    _refreshFromTile();
  }

  void _refreshFromTile() {
    final prop = tile.property;
    final newMortgaged = prop?.isMortgaged ?? false;
    final newLevel = prop == null ? 0 : (prop.hasHotel ? 5 : prop.houses);
    if (newMortgaged != _mortgaged || newLevel != _improvementLevel) {
      _mortgaged = newMortgaged;
      _improvementLevel = newLevel;
      _rebuildImprovements();
    }
  }

  void _rebuildImprovements() {
    for (final c in _improvementChildren) {
      c.removeFromParent();
    }
    _improvementChildren.clear();

    final w = size.x;
    final h = size.y;
    if (_improvementLevel == 5) {
      final hotel = HotelComponent()
        ..position = Vector2(w / 2, h * 0.30)
        ..anchor = Anchor.center
        ..size = Vector2(w * 0.55, h * 0.28);
      add(hotel);
      _improvementChildren.add(hotel);
    } else if (_improvementLevel > 0) {
      final count = _improvementLevel;
      final slotW = w / (count + 1);
      for (var i = 0; i < count; i++) {
        final house = HouseComponent()
          ..position = Vector2(slotW * (i + 1), h * 0.30)
          ..anchor = Anchor.center
          ..size = Vector2(14, 16);
        add(house);
        _improvementChildren.add(house);
      }
    }
  }

  void highlight(bool on) {
    _highlight = on;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_highlight) {
      _glowPhase = (_glowPhase + dt * 4) % (math.pi * 2);
    }
  }

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
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    canvas.drawRRect(
      rrect.shift(const Offset(2, 3)),
      Paint()..color = const Color(0xFFD9CCA3),
    );

    canvas.drawRRect(rrect, Paint()..color = GameColors.cream);

    // Color strip — only for street / ownable tiles with a color group 0..7.
    if (tile.isOwnable && tile.property!.colorGroup <= 7 &&
        tile.property!.type == PropertyType.street) {
      final group = tile.property!.colorGroup;
      final stripH = size.y * 0.22;
      final stripRect = Rect.fromLTWH(0, 0, size.x, stripH);
      canvas.drawRect(stripRect, Paint()..color = GameColors.forGroup(group));
      canvas.drawLine(
        Offset(0, stripH),
        Offset(size.x, stripH),
        Paint()
          ..color = GameColors.outline
          ..strokeWidth = 1.2,
      );
    }

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = GameColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );

    _drawTileBody(canvas);

    if (_mortgaged) {
      _drawMortgageBar(canvas);
    }

    if (_highlight) {
      final glow = Paint()
        ..color = GameColors.happyYellow
            .withValues(alpha: 0.45 + 0.35 * math.sin(_glowPhase).abs())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawRRect(rrect.deflate(1.2), glow);
    }
  }

  void _drawTileBody(Canvas canvas) {
    final prop = tile.property;
    final bodyTop = (tile.isOwnable &&
            (prop?.colorGroup ?? 99) <= 7 &&
            prop?.type == PropertyType.street)
        ? size.y * 0.24
        : 4.0;

    _drawCenteredText(
      canvas,
      _displayLabel(),
      Offset(size.x / 2, bodyTop + 4),
      GameFonts.tileName(color: GameColors.outline),
      maxWidth: size.x - 4,
      maxLines: 2,
    );

    _drawGlyph(canvas, Offset(size.x / 2, size.y * 0.58));

    if (prop != null) {
      _drawCenteredText(
        canvas,
        _compactPrice(prop.price),
        Offset(size.x / 2, size.y - 12),
        GameFonts.tilePrice(color: GameColors.outline),
        maxWidth: size.x - 4,
      );
    }
  }

  String _displayLabel() {
    const shorten = {
      'Vishakhapatnam': 'Vizag',
      'Community Chest': 'Community',
      'Mumbai Central': 'Mumbai Ctl',
      'Chennai Central': 'Chennai Ctl',
      'Howrah Junction': 'Howrah Jn',
    };
    return shorten[tile.label] ?? tile.label;
  }

  String _compactPrice(int price) {
    if (price >= 100000) {
      final lakhs = price / 100000.0;
      final trimmed =
          lakhs.toStringAsFixed(lakhs == lakhs.truncate() ? 0 : 1);
      return 'Rs $trimmed L';
    }
    if (price >= 1000) {
      return 'Rs ${(price / 1000).round()}k';
    }
    return 'Rs $price';
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset topCenter,
    TextStyle style, {
    required double maxWidth,
    int maxLines = 1,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, Offset(topCenter.dx - tp.width / 2, topCenter.dy));
  }

  void _drawGlyph(Canvas canvas, Offset c) {
    final paint = Paint()
      ..color = GameColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = GameColors.happyYellow;

    switch (tile.type) {
      case TileType.chance:
        final rr = RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: 18, height: 22),
          const Radius.circular(3),
        );
        canvas.drawRRect(rr, Paint()..color = const Color(0xFFFF9F43));
        canvas.drawRRect(rr, paint);
        _drawCenteredText(
          canvas,
          '?',
          Offset(c.dx, c.dy - 9),
          GameFonts.fredoka(size: 14, color: GameColors.white),
          maxWidth: 20,
        );
        break;
      case TileType.communityChest:
        final r = Rect.fromCenter(center: c, width: 20, height: 14);
        canvas.drawRect(r, Paint()..color = const Color(0xFFFFD60A));
        canvas.drawRect(r, paint);
        final d = Path()
          ..moveTo(c.dx, c.dy - 4)
          ..lineTo(c.dx + 4, c.dy)
          ..lineTo(c.dx, c.dy + 4)
          ..lineTo(c.dx - 4, c.dy)
          ..close();
        canvas.drawPath(d, Paint()..color = GameColors.goldDark);
        canvas.drawPath(d, paint);
        break;
      case TileType.tax:
        canvas.drawCircle(c, 10, fill);
        canvas.drawCircle(c, 10, paint);
        _drawCenteredText(
          canvas,
          '\u20B9',
          Offset(c.dx, c.dy - 8),
          GameFonts.fredoka(size: 13, color: GameColors.outline),
          maxWidth: 20,
        );
        break;
      case TileType.property:
        final t = tile.property?.type;
        if (t == PropertyType.railroad) {
          final body = Rect.fromCenter(center: c, width: 20, height: 10);
          canvas.drawRect(body, Paint()..color = GameColors.outline);
          canvas.drawCircle(Offset(c.dx - 6, c.dy + 7), 2.2, paint);
          canvas.drawCircle(Offset(c.dx + 6, c.dy + 7), 2.2, paint);
          canvas.drawRect(
            Rect.fromCenter(
                center: Offset(c.dx - 2, c.dy - 2), width: 5, height: 5),
            Paint()..color = GameColors.happyYellow,
          );
        } else if (t == PropertyType.utility) {
          final bulb = Rect.fromCenter(center: c, width: 14, height: 16);
          canvas.drawOval(bulb, fill);
          canvas.drawOval(bulb, paint);
          canvas.drawLine(
            Offset(c.dx - 4, c.dy + 8),
            Offset(c.dx + 4, c.dy + 8),
            paint,
          );
        }
        break;
      default:
        break;
    }
  }

  void _drawMortgageBar(Canvas canvas) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(4),
      ),
    );
    final paint = Paint()
      ..color = GameColors.outline.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(-size.y, size.y * 0.4)
      ..lineTo(size.x + size.y, -size.y * 0.4)
      ..lineTo(size.x + size.y, -size.y * 0.4 + 14)
      ..lineTo(-size.y, size.y * 0.4 + 14)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }
}

/// Brief scale pop-in — shared helper for improvement drop animations.
void addPopIn(PositionComponent c,
    {double duration = 0.26, double overshoot = 1.2}) {
  c.scale = Vector2.zero();
  c.add(
    SequenceEffect([
      ScaleEffect.to(
        Vector2.all(overshoot),
        EffectController(duration: duration * 0.6),
      ),
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: duration * 0.4),
      ),
    ]),
  );
}
