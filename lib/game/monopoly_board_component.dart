import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

/// MonopolyBoardComponent: Renders the Monopoly board as a grid of tiles.
class MonopolyBoardComponent extends PositionComponent {
  final int tileCount;
  final double tileSize;
  final List<Color> propertyColors;

  MonopolyBoardComponent({
    required this.tileCount,
    required this.tileSize,
    required this.propertyColors,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add all board tiles as children, positioned correctly
    for (int i = 0; i < tileCount; i++) {
      final pos = _tileToPosition(i, tileSize);
      add(BoardTileComponent(
        index: i,
        size: Vector2(tileSize, tileSize),
        color: propertyColors[i % propertyColors.length],
      )..position = pos);
    }
  }

  // Helper: returns the position for a given tile index (like BoardManager)
  Vector2 _tileToPosition(int tileIndex, double tileSize) {
    if (tileIndex < 10) {
      return Vector2(tileSize * (10 - tileIndex), 0);
    } else if (tileIndex < 20) {
      return Vector2(0, tileSize * (tileIndex - 10));
    } else if (tileIndex < 30) {
      return Vector2(tileSize * (tileIndex - 20), tileSize * 10);
    } else {
      return Vector2(tileSize * 10, tileSize * (40 - tileIndex));
    }
  }
}

/// BoardTileComponent: Represents a single tile on the board.
class BoardTileComponent extends PositionComponent {
  final int index;
  final Color color;

  BoardTileComponent({
    required this.index,
    required Vector2 size,
    required this.color,
  }) : super(size: size);

  @override
  void render(Canvas canvas) {
    final paint = BasicPalette.white.paint()..color = color;
    canvas.drawRect(size.toRect(), paint);
    // Optionally draw tile index or icon
    TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ).render(canvas, index.toString(), Vector2(4, 4));
  }
}
