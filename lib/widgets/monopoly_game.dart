import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_logic/models/board_tile.dart';
import 'board_tile_component.dart';

class MonopolyGame extends FlameGame with HasTappables {
  final List<BoardTile> tiles;
  BoardTile? selectedTile;
  MonopolyGame({this.tiles = const []});

  @override
  Future<void> onLoad() async {
    overlays.add('splash');
    await Future.delayed(const Duration(seconds: 2));
    overlays.remove('splash');
    overlays.add('login');
  }

  void proceedToModeSelection() {
    overlays.remove('login');
    overlays.add('mode');
  }

  void proceedToGame(List<BoardTile> gameTiles) {
    overlays.remove('mode');
    // ...setup game state, add board components, etc...
  }

  void showEndGame() {
    overlays.add('end');
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Layout the board tiles in a grid
    final double tileSize = 64; // Example size, adjust as needed
    for (var i = 0; i < tiles.length; i++) {
      final tile = tiles[i];
      final component = BoardTileComponent(
        tile: tile,
        size: Vector2(tileSize, tileSize),
        position: _getTilePosition(i, tileSize),
        onTileTap: () {
          selectedTile = tile;
          overlays.add('propertyInfo');
        },
      );
      add(component);
    }
  }

  Vector2 _getTilePosition(int index, double tileSize) {
    // Simple square board layout (adjust for your board shape)
    int side = 10;
    if (index < side) return Vector2(index * tileSize, 0);
    if (index < side * 2) return Vector2((side - 1) * tileSize, (index - side) * tileSize);
    if (index < side * 3) return Vector2((side * 3 - 1 - index) * tileSize, (side - 1) * tileSize);
    return Vector2(0, (side * 4 - 1 - index) * tileSize);
  }
}
