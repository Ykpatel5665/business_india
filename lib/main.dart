import 'package:flutter/material.dart';
import 'game/game_board_flame_screen.dart';
import 'game_logic/engine/game_factory.dart';
import 'game_logic/models/player.dart';
import 'game_logic/models/game_config.dart';
import '../game_logic/models/ai_player.dart';
import 'game/custom_rules.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Monopoly City',
    home: const MonopolyFlameApp(),
  ));
}

class MonopolyFlameApp extends StatefulWidget {
  const MonopolyFlameApp({super.key});

  @override
  State<MonopolyFlameApp> createState() => _MonopolyFlameAppState();
}

class _MonopolyFlameAppState extends State<MonopolyFlameApp> {
  CustomRules _customRules = CustomRules();
  late dynamic engine;

  @override
  void initState() {
    super.initState();
    _createEngine();
  }

  void _createEngine() {
    final players = [
      Player(name: 'Player 1', tokenId: 0),
      AIPlayer(name: 'AI Bot', tokenId: 1),
    ];
    final config = GameConfig();
    engine = MonopolyGameEngineBuilder(players: players, config: config).create('uk');
  }

  void _showCustomRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CustomRulesDialog(
        initialRules: _customRules,
        onApply: (rules) {
          setState(() {
            _customRules = rules;
            _createEngine();
          });
          Navigator.pop(ctx);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monopoly City',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Monopoly City'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showCustomRulesDialog(context),
            ),
          ],
        ),
        body: GameBoardFlameScreen(engine: engine),
      ),
    );
  }
}
