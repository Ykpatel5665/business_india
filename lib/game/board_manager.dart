import 'package:flame/components.dart';
import '../game_logic/engine/game_engine.dart';
import 'monopoly_flame_game.dart';

class BoardManager {
  final MonopolyFlameGame game;
  BoardManager(this.game);

  Vector2 tileToPosition(int tileIndex) {
    // Simple square board layout: 10 tiles per side
    const double tileSize = 60;
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
