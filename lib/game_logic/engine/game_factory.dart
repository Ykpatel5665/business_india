// Monopoly game-engine builder. Resolves an edition name to a concrete
// MonopolyGameEdition and builds a ready-to-start GameEngine.
import '../models/player.dart';
import '../models/game_config.dart';
import 'game_engine.dart';
import 'editions/board_india.dart';
import 'editions/board_uk.dart';

/// Builder for Monopoly game engine, merging edition assets and factory logic.
class MonopolyGameEngineBuilder {
  final List<Player> players;
  final GameConfig config;

  MonopolyGameEngineBuilder({
    required this.players,
    required this.config,
  });

  GameEngine create(String edition) {
    switch (edition) {
      case 'india':
        return IndiaMonopolyEdition(players: players, config: config).create();
      case 'uk':
        return UKMonopolyEdition(players: players, config: config).create();
    }
    throw ArgumentError('Unsupported game edition: $edition');
  }
}
