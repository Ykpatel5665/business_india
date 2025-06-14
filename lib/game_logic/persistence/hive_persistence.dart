import 'package:hive/hive.dart';
import '../models/player.dart';
import '../models/property.dart';
import '../models/game_config.dart';
import '../engine/game_engine.dart';
import '../models/bank.dart';
import '../models/enums.dart';
import '../models/board_tile.dart';
import '../models/card.dart';
import '../models/trade.dart';

/// Handles saving and loading game state using Hive.
class HivePersistence {
  static const String gameStateBoxName = 'game_state';

  Future<void> saveGameState(GameEngine gameEngine) async {
    final box = await Hive.openBox(gameStateBoxName);
    await box.put('players', gameEngine.players);
    await box.put('board', gameEngine.board);
    await box.put('bank', gameEngine.bank);
    await box.put('config', gameEngine.config);
    await box.put('turnNumber', gameEngine.turnNumber);
    await box.put('currentPlayerIndex', gameEngine.currentPlayerIndex);
    await box.put('status', gameEngine.status);
    await box.put('chanceDeck', gameEngine.chanceDeck);
    await box.put('communityChestDeck', gameEngine.communityChestDeck);
    await box.put('activeTrades', gameEngine.activeTrades);
  }

  Future<void> loadGameState(GameEngine gameEngine) async {
    final box = await Hive.openBox(gameStateBoxName);
    gameEngine.players.clear();
    gameEngine.players.addAll((box.get('players', defaultValue: <Player>[]) as List).cast<Player>());
    gameEngine.board.clear();
    gameEngine.board.addAll((box.get('board', defaultValue: <BoardTile>[]) as List).cast<BoardTile>());
    gameEngine.bank.copyFrom(box.get('bank', defaultValue: Bank()));
    gameEngine.config.copyFrom(box.get('config', defaultValue: GameConfig()));
    gameEngine.turnNumber = box.get('turnNumber', defaultValue: 0) as int;
    gameEngine.currentPlayerIndex = box.get('currentPlayerIndex', defaultValue: 0) as int;
    gameEngine.status = box.get('status', defaultValue: GameStatus.pending) as GameStatus;
    gameEngine.chanceDeck.clear();
    gameEngine.chanceDeck.addAll((box.get('chanceDeck', defaultValue: <Card>[]) as List).cast<Card>());
    gameEngine.communityChestDeck.clear();
    gameEngine.communityChestDeck.addAll((box.get('communityChestDeck', defaultValue: <Card>[]) as List).cast<Card>());
    gameEngine.activeTrades.clear();
    gameEngine.activeTrades.addAll((box.get('activeTrades', defaultValue: <Trade>[]) as List).cast<Trade>());
  }

  GameStatus getGameStatus() {
    return GameStatus.pending; // Replace with actual implementation
  }
}