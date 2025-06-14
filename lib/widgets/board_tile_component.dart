import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../game_logic/models/board_tile.dart';
import '../game_logic/models/property.dart';
import '../game_logic/models/enums.dart';

class BoardTileComponent extends PositionComponent with Tappable {
  final BoardTile tile;
  final void Function()? onTileTap;
  BoardTileComponent({required this.tile, required Vector2 size, required Vector2 position, this.onTileTap}) {
    this.size = size;
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(size.toRect(), paint);
    // Draw property color bar if applicable
    if (tile.property != null && tile.property!.colorGroup != null) {
      final barPaint = Paint()..color = _getBarColor(tile.property!.colorGroup);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 10), barPaint);
    }
    // Draw tile label
    final textPainter = TextPainter(
      text: TextSpan(
        text: tile.property?.name ?? tile.label,
        style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: size.x - 4);
    textPainter.paint(canvas, Offset(2, size.y / 2 - 10));
  }

  @override
  bool onTapDown(TapDownInfo event) {
    if (onTileTap != null) {
      onTileTap!();
    }
    debugPrint('Tile tapped: \\${tile.label}');
    return true;
  }

  Color _getBarColor(PropertyColor? colorGroup) {
    // Example mapping, adjust as needed
    switch (colorGroup) {
      case PropertyColor.red:
        return Colors.red;
      case PropertyColor.blue:
        return Colors.blue;
      case PropertyColor.green:
        return Colors.green;
      case PropertyColor.yellow:
        return Colors.yellow;
      case PropertyColor.orange:
        return Colors.orange;
      case PropertyColor.purple:
        return Colors.purple;
      case PropertyColor.brown:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
