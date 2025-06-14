import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game_logic/engine/game_engine.dart';
import 'monopoly_flame_game.dart';

/// GameBoardFlameScreen: Hybrid layout with classic Flutter UI and Flame board.
class GameBoardFlameScreen extends StatelessWidget {
  final dynamic engine;
  const GameBoardFlameScreen({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monopoly City'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings dialog
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main layout: Player HUD (top), board (center), actions (right)
            Column(
              children: [
                // Player HUD/info bar
                Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text('Players', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                      const SizedBox(width: 16),
                      for (var i = 0; i < engine.players.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '${engine.players[i].name}:  \$${engine.players[i].balance.toInt()}  (Pos: ${engine.players[i].position})',
                            style: TextStyle(
                              color: i == 0 ? Colors.red : Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Board and dice area
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GameWidget(
                        game: MonopolyFlameGame(engine: engine),
                        overlayBuilderMap: {
                          // Only popups/dialogs as overlays
                          'PropertyDialog': (context, game) => Container(),
                          'BuildDialog': (context, game) => Container(),
                          'AuctionDialog': (context, game) => Container(),
                          'CardDialog': (context, game) => Container(),
                          'LoadingSpinner': (context, game) => const Center(child: CircularProgressIndicator()),
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Action bar (right)
            Positioned(
              right: 16,
              top: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'game_log',
                    child: const Icon(Icons.list_alt),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'save',
                    child: const Icon(Icons.save),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'load',
                    child: const Icon(Icons.folder_open),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'dark_mode',
                    child: const Icon(Icons.dark_mode),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'multiplayer',
                    child: const Icon(Icons.people),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'chat',
                    child: const Icon(Icons.chat),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // TODO: Add dice overlay, property dialogs, etc. as overlays or widgets here
          ],
        ),
      ),
    );
  }
}
