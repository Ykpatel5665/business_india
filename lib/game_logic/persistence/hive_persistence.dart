import 'package:hive/hive.dart';
import '../models/player.dart';
import '../models/property.dart';
import '../models/game_config.dart';
import '../engine/game_engine.dart';
import '../models/bank.dart';
import '../models/enums.dart';

/// Handles saving and loading game state using Hive.
class HivePersistence {
  static const String gameStateBoxName = 'game_state';

  Future<void> saveGameState(GameEngine gameEngine) async {
    // final box = await Hive.openBox(gameStateBoxName);
    // await box.put('players', gameEngine.players);
    // await box.put('board', gameEngine.board);
    // await box.put('bank', gameEngine.bank);
    // await box.put('config', gameEngine.config);
    // await box.put('turnNumber', gameEngine.turnNumber);
    // await box.put('currentPlayerIndex', gameEngine.currentPlayerIndex);
    // await box.put('status', gameEngine.status);
    // await box.put('chanceDeck', gameEngine.chanceDeck);
    // await box.put('communityChestDeck', gameEngine.communityChestDeck);
    // await box.put('activeTrades', gameEngine.activeTrades);
  }

  Future<void> loadGameState(GameEngine gameEngine) async {
    // final box = await Hive.openBox(gameStateBoxName);
    // gameEngine.players = box.get('players', defaultValue: []);
    // gameEngine.board = box.get('board', defaultValue: []);
    // gameEngine.bank = box.get('bank', defaultValue: Bank());
    // gameEngine.config = box.get('config', defaultValue: GameConfig());
    // gameEngine.turnNumber = box.get('turnNumber', defaultValue: 0);
    // gameEngine.currentPlayerIndex = box.get('currentPlayerIndex', defaultValue: 0);
    // gameEngine.status = box.get('status', defaultValue: GameStatus.pending);
    // gameEngine.chanceDeck = box.get('chanceDeck', defaultValue: []);
    // gameEngine.communityChestDeck = box.get('communityChestDeck', defaultValue: []);
    // gameEngine.activeTrades = box.get('activeTrades', defaultValue: []);
  }

  GameStatus getGameStatus() {
    return GameStatus.pending; // Replace with actual implementation
  }
}