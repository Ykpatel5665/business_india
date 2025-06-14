import 'package:flutter/material.dart';
import '../game_logic/models/trade.dart';
import '../game_logic/models/player.dart';
import 'monopoly_flame_game.dart';
import 'trade_dialog.dart';
import 'overlay_manager.dart';

class TradeManager {
  final MonopolyFlameGame game;
  TradeManager(this.game);

  void startTrade(Player fromPlayer) {
    final otherPlayers = game.engine.players.where((p) => p != fromPlayer).toList();
    game.overlays.add('TradeDialog');
    game.overlayManager.addWidget(
      'TradeDialog',
      TradeDialog(
        playerNames: otherPlayers.map((p) => p.name).toList(),
        myProperties: fromPlayer.ownedProperties.map((p) => p.name).toList(),
        otherProperties: otherPlayers.expand((p) => p.ownedProperties).map((p) => p.name).toList(),
        onSendTrade: (targetPlayerName, offerProps, offerCash, requestProps, requestCash) {
          try {
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
