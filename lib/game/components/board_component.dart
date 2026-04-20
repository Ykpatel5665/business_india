// Full 40-tile board + center panel. Holds one TileComponent per index and
// exposes a helper to re-sync tile visuals from the engine after every
// controller update.
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../app/theme/game_colors.dart';
import '../../app/theme/game_fonts.dart';
import '../../game_logic/engine/game_engine.dart';
import '../art/card_back_painter.dart';
import 'board_geometry.dart';
import 'corner_tile_component.dart';
import 'tile_component.dart';

class BoardComponent extends PositionComponent {
  BoardComponent({
    required this.geometry,
    required this.engine,
    required this.onTilePressed,
  }) : super(anchor: Anchor.center);

  final BoardGeometry geometry;
  final GameEngine engine;
  final void Function(int position) onTilePressed;

  // Pre-filled with placeholders so `syncFromEngine()` never crashes if
  // called between construction and onLoad completion.
  final List<PositionComponent> tilesByIndex =
      List<PositionComponent>.filled(40, _Placeholder(), growable: false);

  @override
  Future<void> onLoad() async {
    size = Vector2.all(geometry.boardSize);

    for (var i = 0; i < 40; i++) {
      final tile = engine.board[i];
      if (geometry.isCorner(i)) {
        final comp = CornerTileComponent(
          tile: tile,
          geometry: geometry,
          onTap: onTilePressed,
        );
        add(comp);
        tilesByIndex[i] = comp;
      } else {
        final comp = TileComponent(
          tile: tile,
          geometry: geometry,
          onTap: onTilePressed,
        );
        add(comp);
        tilesByIndex[i] = comp;
      }
    }

    // Center panel — parchment square with two mini card stacks, placed at
    // the centre of the board in its top-left-origin local coord system.
    add(_CenterPanel(geometry: geometry)..position = geometry.boardCentre);
  }

  @override
  void render(Canvas canvas) {
    // Board frame — a cream square outlined in dark. The play field is the
    // cream interior visible between the perimeter tiles. Drawn at the
    // component's own top-left-origin local coords so it aligns with tiles.
    final rect = Rect.fromLTWH(0, 0, geometry.boardSize, geometry.boardSize);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(
      rrect.shift(const Offset(6, 8)),
      Paint()..color = const Color(0xFF6B3E1A),
    );
    canvas.drawRRect(rrect, Paint()..color = GameColors.cream);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = GameColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Re-reads the engine and refreshes every tile's visual state (mortgage
  /// bar, houses/hotels). Cheap — only rebuilds children where values change.
  void syncFromEngine() {
    for (final t in tilesByIndex) {
      if (t is TileComponent) t.syncFromEngine();
    }
  }
}

class _CenterPanel extends PositionComponent {
  _CenterPanel({required this.geometry}) : super(anchor: Anchor.center);

  final BoardGeometry geometry;

  @override
  Future<void> onLoad() async {
    // Interior is boardSize - 2 * cornerSide (the play area between tiles).
    final inner = geometry.boardSize - 2 * geometry.cornerSide;
    size = Vector2.all(inner);

    // Card stacks — children use top-left origin relative to the panel,
    // so to sit near the panel centre we place them at `inner/2 + offset`.
    final cardW = inner * 0.22;
    final cardH = inner * 0.30;
    final centre = inner / 2;

    final chance = _CardBackStack(
      backPainter: const ChanceCardBackPainter(),
      label: 'CHANCE',
      stackSize: Vector2(cardW, cardH),
    )
      ..position = Vector2(centre - inner * 0.18, centre + inner * 0.10)
      ..angle = -0.14
      ..anchor = Anchor.center;
    add(chance);

    final community = _CardBackStack(
      backPainter: const CommunityCardBackPainter(),
      label: 'COMMUNITY',
      stackSize: Vector2(cardW, cardH),
    )
      ..position = Vector2(centre + inner * 0.18, centre - inner * 0.10)
      ..angle = 0.14
      ..anchor = Anchor.center;
    add(community);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));
    canvas.drawRRect(rrect, Paint()..color = GameColors.parchment);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = GameColors.outline.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // "Business India" title across the panel centre.
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(-0.04);
    final tp = TextPainter(
      text: TextSpan(
        text: 'BUSINESS INDIA',
        style: GameFonts.fredoka(
          size: size.x * 0.08,
          color: GameColors.happyRed,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x * 0.7);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }
}

class _CardBackStack extends PositionComponent {
  _CardBackStack({
    required this.backPainter,
    required this.label,
    required Vector2 stackSize,
  }) : super(size: stackSize);

  final CustomPainter backPainter;
  final String label;

  @override
  void render(Canvas canvas) {
    // Draw two faint card backs underneath the main one for a "pile" feel.
    canvas.save();
    canvas.translate(-4, 6);
    backPainter.paint(canvas, size.toSize());
    canvas.restore();
    canvas.save();
    canvas.translate(-2, 3);
    backPainter.paint(canvas, size.toSize());
    canvas.restore();
    backPainter.paint(canvas, size.toSize());

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: GameFonts.fredoka(size: 9, color: GameColors.cream),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.x);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, size.y - 14));
  }
}

class _Placeholder extends PositionComponent {}
