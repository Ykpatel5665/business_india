import 'package:flutter/material.dart';
import '../game_logic/models/player.dart';
import '../game_logic/models/property.dart';
import 'monopoly_flame_game.dart';
import 'overlay_manager.dart';

class AuctionManager {
  final MonopolyFlameGame game;
  AuctionManager(this.game);

  void startAdvancedAuction(Property property) {
    final activePlayers = game.engine.players.where((p) => !p.isBankrupt).toList();
    int highestBid = 0;
    Player? highestBidder;
    int currentBidderIndex = 0;
    Set<Player> passedPlayers = {};

    void nextBidRound() {
      if (passedPlayers.length >= activePlayers.length - 1 && highestBidder != null) {
        highestBidder!.buyProperty(property, highestBid);
        game.overlays.remove('AuctionDialog');
        game.overlays.add('AuctionResultDialog');
        game.overlayManager.addWidget(
          'AuctionResultDialog',
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
                    const Text('Auction Won!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text('Winner: ${highestBidder != null ? highestBidder!.name : "None"}', style: const TextStyle(fontSize: 20)),
                    Text('Bid: \$${highestBid}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => game.overlays.remove('AuctionResultDialog'),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        return;
      }
      do {
        currentBidderIndex = (currentBidderIndex + 1) % activePlayers.length;
      } while (passedPlayers.contains(activePlayers[currentBidderIndex]));
      final currentBidder = activePlayers[currentBidderIndex];
      game.overlays.add('AuctionDialog');
      game.overlayManager.addWidget(
        'AuctionDialog',
        Center(
          child: Material(
            color: Colors.black54,
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Auction: ${property.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Current Bid: \$${highestBid}', style: const TextStyle(fontSize: 18)),
                  Text('Highest Bidder: ${highestBidder != null ? highestBidder!.name : "None"}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text('Your Turn: ${currentBidder.name}', style: const TextStyle(fontSize: 18, color: Colors.blue)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          game.overlays.remove('AuctionDialog');
                          passedPlayers.add(currentBidder);
                          nextBidRound();
                        },
                        child: const Text('Pass'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final bid = await showDialog<int>(
                            context: game.buildContext!,
                            builder: (ctx) {
                              int bidValue = highestBid + 10;
                              return AlertDialog(
                                title: const Text('Enter your bid'),
                                content: TextField(
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => bidValue = int.tryParse(val) ?? (highestBid + 10),
                                  decoration: InputDecoration(hintText: 'Bid (min: \$${highestBid + 10})'),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                  ElevatedButton(onPressed: () => Navigator.pop(ctx, bidValue), child: const Text('Bid')),
                                ],
                              );
                            },
                          );
                          game.overlays.remove('AuctionDialog');
                          if (bid != null && bid > highestBid && bid <= currentBidder.balance) {
                            highestBid = bid;
                            highestBidder = currentBidder;
                          } else {
                            passedPlayers.add(currentBidder);
                          }
                          nextBidRound();
                        },
                        child: const Text('Bid'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    nextBidRound();
  }
}
