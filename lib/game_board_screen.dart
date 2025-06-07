import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'widgets/responsive_centered_text.dart';
import 'game_logic/engine/game_factory.dart';
import 'game_logic/models/player.dart';
import 'game_logic/models/game_config.dart';
import 'widgets/monopoly_board_widget.dart';
import 'game_logic/models/board_tile.dart';
import 'widgets/property_info_dialog.dart';
import 'widgets/dice_widget.dart';

class GameBoardScreen extends StatefulWidget {
  final String? mode;
  final int? playerCount;
  const GameBoardScreen({Key? key, this.mode, this.playerCount}) : super(key: key);

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  late final List<Player> players;
  late final GameConfig config;
  late final engine;
  late final List<BoardTile> boardTiles;
  int dice1 = 1;
  int dice2 = 1;
  bool rolling = false;

  @override
  void initState() {
    super.initState();
    players = [Player(name: 'Bala', tokenId: 1)];
    config = GameConfig();
    engine = MonopolyGameEngineBuilder(players: players, config: config).create('uk');
    boardTiles = engine.board;
  }

  void _rollDice() async {
    setState(() { rolling = true; });
    await Future.delayed(const Duration(milliseconds: 300));
    final result = engine.rollDice();
    setState(() {
      dice1 = result[0];
      dice2 = result[1];
      rolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          centerOverlay: DiceWidget(
            dice1: dice1,
            dice2: dice2,
            rolling: rolling,
            onRoll: _rollDice,
          ),
        ),
      ),
    );
  }
}
