import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_logic/engine/game_engine.dart';
import 'monopoly_board_component.dart';
import 'token_component.dart';
import 'dice_component.dart';
import 'game_widgets.dart';
import 'card_dialog.dart';
import 'property_purchase_dialog.dart';
import 'auction_dialog.dart';
import 'build_dialog.dart';
import 'trade_dialog.dart';
import 'board_manager.dart';
import 'player_manager.dart';
import 'overlay_manager.dart';
import 'notification_manager.dart';
import 'auction_manager.dart';
import 'ai_manager.dart';
import 'property_management_overlay.dart';
import 'game_log_manager.dart';
import 'game_log_overlay.dart';
import 'sound_manager.dart';
import 'accessibility_utils.dart';
import 'save_load_manager.dart';
import 'network/multiplayer_overlay.dart';
import 'network/multiplayer_button_overlay.dart';
import 'network/network_manager.dart';
import 'network/chat_overlay.dart';
import 'hud_component.dart';
import '../game_logic/models/ai_player.dart';
import 'trade_manager.dart';
import 'package:flame/events.dart';
import 'turn_indicator_overlay.dart';
import 'animated_money_transfer.dart';
import '../game_logic/models/game_status.dart' as status;
import '../game_logic/models/player.dart';
import '../game_logic/models/ai_player.dart';
import '../game_logic/models/enums.dart';

/// MonopolyFlameGame: Main Flame game class for Monopoly gameplay and animation.
class MonopolyFlameGame extends FlameGame {
  final GameEngine engine;
  MonopolyFlameGame({required this.engine});

  late DiceComponent dice1;
  late DiceComponent dice2;
  bool _rolling = false;
  late List<TokenComponent> tokens;
  late List<String> chatMessages;

  bool isDarkMode = false;

  // --- Decomposed managers/components ---
  late final BoardManager boardManager;
  late final PlayerManager playerManager;
  late final OverlayManager overlayManager;
  late final NotificationManager notificationManager;
  late final AuctionManager auctionManager;
  late final TradeManager tradeManager;
  late final AIManager aiManager;
  late final GameLogManager gameLogManager;
  late final SoundManager soundManager;
  late final SaveLoadManager saveLoadManager;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    boardManager = BoardManager(this);
    playerManager = PlayerManager(this);
    overlayManager = OverlayManager(this);
    notificationManager = NotificationManager(this);
    auctionManager = AuctionManager(this);
    tradeManager = TradeManager(this);
    aiManager = AIManager(this);
    gameLogManager = GameLogManager();
    soundManager = SoundManager();
    saveLoadManager = SaveLoadManager();
    await soundManager.playBackgroundMusic();
    add(MonopolyBoardComponent(
      tileCount: 40,
      tileSize: 60,
      propertyColors: [
        Colors.brown, Colors.lightBlue, Colors.pink, Colors.orange,
        Colors.red, Colors.yellow, Colors.green, Colors.blue,
        Colors.grey, Colors.black,
      ],
    ));
    tokens = [];
    for (var i = 0; i < engine.players.length; i++) {
      final player = engine.players[i];
      final token = TokenComponent(playerIndex: i, currentTile: player.position, color: i == 0 ? Colors.red : Colors.blue)
        ..position = boardManager.tileToPosition(player.position);
      tokens.add(token);
      add(token);
    }
    dice1 = DiceComponent(value: 1, onRollComplete: _onDiceRollComplete)
      ..position = Vector2(300, 300)
      ..size = Vector2.all(48);
    dice2 = DiceComponent(value: 1, onRollComplete: _onDiceRollComplete)
      ..position = Vector2(360, 300)
      ..size = Vector2.all(48);
    add(dice1);
    add(dice2);
    add(_buildPlayerHud());
    // REMOVE: overlayManager.addTradeButton();
    // overlays.add('PropertyManagementButton');
    // overlayManager.addWidget(
    //   'PropertyManagementButton',
    //   ...
    // );
    // overlays.add('GameLogButton');
    // overlayManager.addWidget(
    //   'GameLogButton',
    //   ...
    // );
    // overlays.add('SaveButton');
    // overlayManager.addWidget(
    //   'SaveButton',
    //   ...
    // );
    // overlays.add('LoadButton');
    // overlayManager.addWidget(
    //   'LoadButton',
    //   ...
    // );
    // overlays.add('DarkModeButton');
    // overlayManager.addWidget(
    //   'DarkModeButton',
    //   ...
    // );
    // overlays.add('MultiplayerButton');
    // overlayManager.addWidget(
    //   'MultiplayerButton',
    //   ...
    // );
    // overlays.add('ChatButton');
    // overlayManager.addWidget(
    //   'ChatButton',
    //   ...
    // );
    // overlays.add('TradeButton');
    // overlayManager.addWidget(
    //   'TradeButton',
    //   ...
    // );
    // overlays.add('TradeDialog');
    // overlayManager.addWidget(
    //   'TradeDialog',
    //   ...
    // );
    // overlays.add('PropertyManagementOverlay');
    // overlayManager.addWidget(
    //   'PropertyManagementOverlay',
    //   ...
    // );
    // overlays.add('GameLogOverlay');
    // overlayManager.addWidget(
    //   'GameLogOverlay',
    //   ...
    // );
    // overlays.add('LoadingSpinner');
    // overlayManager.addWidget(
    //   'LoadingSpinner',
    //   ...
    // );
    // overlays.add('DarkModeSnackbar');
    // overlayManager.addWidget(
    //   'DarkModeSnackbar',
    //   ...
    // );
    // overlays.add('WinnerDialog');
    // overlayManager.addWidget(
    //   'WinnerDialog',
    //   ...
    // );
    // overlays.add('TurnIndicatorOverlay');
    // overlayManager.addWidget(
    //   'TurnIndicatorOverlay',
    //   ...
    // );
    // overlays.add('Notification');
    // overlayManager.addWidget(
    //   'Notification',
    //   ...
    // );
    // overlays.add('PropertyPurchaseDialog');
    // overlayManager.addWidget(
    //   'PropertyPurchaseDialog',
    //   ...
    // );
    // overlays.add('BuildDialog');
    // overlayManager.addWidget(
    //   'BuildDialog',
    //   ...
    // );
    // overlays.add('PropertyDialog');
    // overlayManager.addWidget(
    //   'PropertyDialog',
    //   ...
    // );
    // overlays.add('CardDialog');
    // overlayManager.addWidget(
    //   'CardDialog',
    //   ...
    // );
  }

  HudComponent _buildPlayerHud() {
    return HudComponent(
      children: [
        PlayerHudWidget(engine: engine)
          ..position = Vector2(20, 20),
      ],
    );
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    if (!_rolling) {
      _rolling = true;
      soundManager.playButton();
      dice1.roll().then((_) {
        dice2.roll().then((_) async {
          final d1 = dice1.value;
          final d2 = dice2.value;
          final playerIdx = engine.currentPlayerIndex;
          final player = engine.players[playerIdx];
          final isAI = player is AIPlayer;
          soundManager.playDiceRoll();
          if (isAI) {
            await aiManager.handleAITurn(player as AIPlayer, d1, d2);
          } else {
            await playerManager.handleTurn(player, d1, d2);
          }
          _rolling = false;
        });
      });
    }
    // super.onTapDown(pointerId, info); // Removed: no such method in base class
  }

  void _onDiceRollComplete(int value) {
    // Optionally handle dice roll completion
  }

  void rollDice() {
    dice1.roll();
    dice2.roll();
  }

  void showMoneyTransfer(int fromPlayerIdx, int toPlayerIdx) {
    final fromPos = tokens[fromPlayerIdx].position;
    final toPos = tokens[toPlayerIdx].position;
    late AnimatedMoneyTransfer anim;
    anim = AnimatedMoneyTransfer(
      from: fromPos,
      to: toPos,
      onComplete: () => anim.removeFromParent(),
    );
    add(anim);
  }

  void showLoadingSpinner([String? message]) {
    overlays.add('LoadingSpinner');
    overlayManager.addWidget(
      'LoadingSpinner',
      Center(
        child: Material(
          color: Colors.black54,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message, style: const TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ],
          ),
        ),
      ),
    );
  }
  void hideLoadingSpinner() => overlays.remove('LoadingSpinner');

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    overlays.add('DarkModeSnackbar');
    overlayManager.addWidget(
      'DarkModeSnackbar',
      Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () => overlays.remove('DarkModeSnackbar'));
    // You would also trigger a rebuild of MaterialApp with the new theme here.
  }

  void addTradeButton() {
    overlayManager.addTradeButton();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // TODO: Sync game state with engine, animate tokens, handle events.
    // Listen for game end event and show winner dialog
    if (engine.status == status.GameStatus.finished && !overlays.isActive('WinnerDialog')) {
      final winner = engine.players.where((p) => !p.isBankrupt).toList().isNotEmpty
        ? engine.players.where((p) => !p.isBankrupt).first
        : null;
      if (winner != null) {
        overlays.add('WinnerDialog');
        overlayManager.addWidget(
          'WinnerDialog',
          Center(
            child: Material(
              color: Colors.black54,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Game Over', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Text('Winner: \\${winner.name}', style: const TextStyle(fontSize: 22, color: Colors.green)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => overlays.remove('WinnerDialog'),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
  }
}
