import 'player.dart';
import 'property.dart';
import 'bank.dart';

/// AIPlayer: A computer-controlled Monopoly player with basic strategy.
class AIPlayer extends Player {
  AIPlayer({required String name, required int tokenId, double balance = 1500.0})
      : super(name: name, tokenId: tokenId, balance: balance);

  @override
  int decideBid(Property property, int currentHighestBid) {
    // Simple AI: bid if has enough balance and property is not too expensive
    if (balance > property.price * 0.7 && balance > currentHighestBid + 50) {
      return currentHighestBid + 20;
    }
    return 0;
  }

  @override
  bool buyProperty(Property property, num? highestBid) {
    // AI: buy if has enough balance and property is not mortgaged
    if (balance > (highestBid ?? property.price) && !property.isMortgaged) {
      return super.buyProperty(property, highestBid);
    }
    return false;
  }

  // Add more AI logic for trading, building, etc. as needed
}
