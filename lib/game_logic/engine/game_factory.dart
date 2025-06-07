// Monopoly Game Engine Builder: merges edition assets and factory
import '../models/player.dart';
import '../models/game_config.dart';
import 'game_engine.dart';
import 'editions/board_uk.dart';

/// Builder for Monopoly game engine, merging edition assets and factory logic.
class MonopolyGameEngineBuilder {
  final List<Player> players;
  final GameConfig config;

  MonopolyGameEngineBuilder({
    required this.players,
    required this.config,
  });

  GameEngine create(edition String) {
    switch (edition) {
      case 'uk':
        return UKMonopolyEdition(players: players, config: config).create();
    }
    throw ArgumentError('Unsupported game edition: $edition');
  }
}
