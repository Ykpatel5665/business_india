import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'widgets/responsive_centered_text.dart';
import 'game_logic/engine/game_factory.dart';
import 'game_logic/models/player.dart';
import 'game_logic/models/game_config.dart';
import 'widgets/monopoly_board_widget.dart';
import 'game_logic/models/board_tile.dart';
import 'widgets/property_info_dialog.dart';

class GameBoardScreen extends StatelessWidget {
  final String? mode;
  final int? playerCount;
  const GameBoardScreen({Key? key, this.mode, this.playerCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example: create a dummy player list and config for preview/demo
    final players = [Player(name: 'Bala', tokenId: 1)];
    final config = GameConfig();
    // Use UK edition for now
    final engine = MonopolyGameEngineBuilder(players: players, config: config).create('uk');
    final boardTiles = engine.board;
    return Scaffold(
      appBar: AppBar(title: const Text('Game Board')),
      body: Center(
        child: MonopolyBoardWidget(
          boardTiles: boardTiles,
          onTileTap: (tile) {
            if (tile.property != null) {
              showDialog(
                context: context,
                builder: (ctx) => PropertyInfoDialog(property: tile.property!),
              );
            }
          },
        ),
      ),
    );
  }
}
