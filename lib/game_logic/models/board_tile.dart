import 'enums.dart';
import 'property.dart';

/// Represents a tile on the Monopoly game board.
class BoardTile {
  final int position;
  final TileType type;
  final String label;
  final Property? property;

  BoardTile({
    required this.position,
    required this.type,
    required this.label,
    this.property,
  });
}