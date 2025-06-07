// Monopoly Game Engine Builder: merges edition assets and factory
import '../models/player.dart';
import '../models/bank.dart';
import '../models/card.dart';
import '../models/game_config.dart';
import 'game_engine.dart';

/// Abstract builder for Monopoly game engine, merging edition assets and factory logic.
abstract class MonopolyGameEdition {
  final List<Player> players;
  final GameConfig config;

  MonopolyGameEdition({
    required this.players,
    required this.config,
  });

  Board getBoard();
  List<Card> getChanceDeck();
  List<Card> getCommunityChestDeck();

  GameEngine create() {
    return GameEngine(
      players: players,
      board: getBoard(),
      chanceDeck: getChanceDeck(),
      communityChestDeck: getCommunityChestDeck(),
      config: config,
    );
  }
}
