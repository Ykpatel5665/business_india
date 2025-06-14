import '../game_logic/models/ai_player.dart';
import '../game_logic/models/property.dart';
import '../game_logic/models/board_tile.dart';
import '../game_logic/models/tile_type.dart';
import 'monopoly_flame_game.dart';

class AIManager {
  final MonopolyFlameGame game;
  AIManager(this.game);

  Future<void> handleAITurn(AIPlayer ai, int d1, int d2) async {
    game.engine.movePlayer(d1, d2);
    final newTile = ai.position;
    await game.tokens[game.engine.currentPlayerIndex].moveToTile(newTile, game.boardManager.tileToPosition(newTile));
    final tile = game.engine.board[newTile];
    if (tile.type == TileType.property && tile.property != null && tile.property!.owner == null) {
      ai.buyProperty(tile.property!, tile.property!.price);
      game.notificationManager.show('${ai.name} bought ${tile.property!.name}');
    }
    // TODO: Add more AI actions (build, trade, etc.)
  }
}
