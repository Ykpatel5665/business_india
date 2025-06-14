import 'package:flutter/material.dart';
import 'monopoly_flame_game.dart';
import 'trade_dialog.dart';
import '../game_logic/models/trade.dart';

class OverlayManager {
  final MonopolyFlameGame game;
  OverlayManager(this.game);

  void addTradeButton() {
    game.overlays.add('TradeButton');
    game.overlayManager.addWidget(
      'TradeButton',
      Positioned(
        top: 20,
        right: 20,
        child: ElevatedButton(
          onPressed: () {
            game.overlays.remove('TradeButton');
            _showTradeDialog();
          },
          child: const Text('Trade'),
        ),
      ),
    );
  }

  void _showTradeDialog() {
    final currentPlayer = game.engine.players[game.engine.currentPlayerIndex];
    final otherPlayers = game.engine.players.where((p) => p != currentPlayer).toList();
    game.overlays.add('TradeDialog');
    game.overlayManager.addWidget(
      'TradeDialog',
      TradeDialog(
        playerNames: otherPlayers.map((p) => p.name).toList(),
        myProperties: currentPlayer.ownedProperties.map((p) => p.name).toList(),
        otherProperties: otherPlayers.expand((p) => p.ownedProperties).map((p) => p.name).toList(),
        onSendTrade: (targetPlayerName, offerProps, offerCash, requestProps, requestCash) {
          try {
            final fromPlayer = currentPlayer;
            final toPlayer = game.engine.players.firstWhere((p) => p.name == targetPlayerName);
            final offeredProperties = fromPlayer.ownedProperties.where((p) => offerProps.contains(p.name)).toList();
            final requestedProperties = toPlayer.ownedProperties.where((p) => requestProps.contains(p.name)).toList();
            final trade = Trade(
              fromPlayer: fromPlayer,
              toPlayer: toPlayer,
              offeredProperties: offeredProperties,
              requestedProperties: requestedProperties,
              offeredCash: offerCash.toDouble(),
              requestedCash: requestCash.toDouble(),
            );
            game.engine.processTrade(trade);
            game.overlays.remove('TradeDialog');
          } catch (e) {
            // Optionally show error dialog
          }
        },
        onCancel: () {
          game.overlays.remove('TradeDialog');
        },
      ),
    );
  }
}

extension OverlayManagerAddWidgetExtension on OverlayManager {
  void addWidget(String key, dynamic widget) {
    // Accepts either a Widget (for overlays) or a Flame Component (for game tree).
    // TODO: Implement overlay widget addition logic or leave as stub for now.
  }
}
